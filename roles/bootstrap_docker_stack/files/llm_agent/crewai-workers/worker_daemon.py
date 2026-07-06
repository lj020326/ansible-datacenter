import copy
import git
import httpx
import logging
import os
import re
import tempfile
import time
import yaml
from crewai import Agent, Task, Crew, Process, LLM
from crewai.tools import tool
from markdown_it import MarkdownIt
from markdownify import markdownify as md_convert
from mdit_py_plugins.tasklists import tasklists_plugin

# ====================== LOGGING SETUP ======================
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
logger = logging.getLogger("crewai_worker")

numeric_level = getattr(logging, LOG_LEVEL, logging.INFO)
logging.basicConfig(
    level=numeric_level,
    format="%(name)s - %(levelname)-8s - %(message)s",
    handlers=[logging.StreamHandler()],
)

# Suppress noisy third-party loggers
for noisy in ["httpcore", "urllib3", "crewai", "openai", "vllm", "git"]:
    logging.getLogger(noisy).setLevel(logging.WARNING)

logger.setLevel(numeric_level)
logger.info(f"CrewAI Worker starting with log level: {LOG_LEVEL}")
# ===================================================================

# --- Core Infrastructure Parameters ---
VIKUNJA_API_URL = os.getenv("VIKUNJA_API_URL")
VIKUNJA_BEARER_TOKEN = os.getenv("VIKUNJA_BEARER_TOKEN")
LOCAL_LLM_BASE_URL = os.getenv("LOCAL_LLM_BASE_URL", "http://localhost:8000/v1")
LOCAL_LLM_MODEL = os.getenv("LOCAL_LLM_MODEL", "nemoclaw")
LOCAL_LLM_API_KEY = os.getenv("LOCAL_LLM_API_KEY", "NA")

# --- Gitea Infrastructure Parameters ---
GITEA_TOKEN = os.getenv("GITEA_TOKEN")
GITEA_BASE_URL = os.getenv("GITEA_BASE_URL", "https://gitea.admin.dettonville.int")

# Comma-separated list of names to watch
TARGET_PROJECT_CONFIG = os.getenv("TARGET_PROJECT_NAMES", "crewai,crewai-test")
TARGET_PROJECT_NAMES = [
    name.strip() for name in TARGET_PROJECT_CONFIG.split(",") if name.strip()
]

logger.info(f"Initializing cluster worker targeting model: {LOCAL_LLM_MODEL}")
logger.info(f"Base URL: {LOCAL_LLM_BASE_URL}")
logger.info(f"Listening on target projects: {TARGET_PROJECT_NAMES}")
logger.info(f"Log level set to: {LOG_LEVEL}")

headers = {
    "Authorization": f"Bearer {VIKUNJA_BEARER_TOKEN}",
    "Content-Type": "application/json"
}

# --- GLOBAL STRUCTURAL CACHE REPOSITORY ---
# Schema: { project_id: { "view_id": int, "bucket_map": { "todo": int, "doing": int, "review": int, "done": int } } }
PROJECT_STRUCTURE_CACHE = {}


# ===================================================================
# 1. CORE WRITER COMPONENT (DYNAMIC TOOL GENERATION)
# ===================================================================
def create_workspace_tools(workspace_path: str):
    """Generates tightly-scoped workspace manipulation tools for the Agent."""

    @tool("Write Code Component File")
    def write_workspace_file(relative_file_path: str, file_contents: str) -> str:
        """Writes or updates a specific code file inside the repository directory workspace."""
        try:
            # Enforce path isolation boundaries to stay safe within /tmp container directory
            safe_target = os.path.normpath(
                os.path.join(workspace_path, relative_file_path.lstrip("/"))
            )
            if not safe_target.startswith(os.path.normpath(workspace_path)):
                return "Error: Security violation."

            os.makedirs(os.path.dirname(safe_target), exist_ok=True)
            with open(safe_target, "w") as code_file:
                code_file.write(file_contents)
            return f"Successfully wrote {relative_file_path} into project workspace."
        except Exception as file_err:
            return f"Failed writing file: {str(file_err)}"

    return [write_workspace_file]


# ===================================================================
# 2. TELEMETRY SCRUBBER & STATE SERIALIZATION
# ===================================================================
def scrub_agent_telemetry(raw_output: str) -> str:
    """Aggressively removes tool calls, JSON, and internal narrative while preserving code blocks."""
    if not raw_output:
        return ""

    text = raw_output

    # 1. Protect code blocks
    code_blocks = re.findall(r'```[\s\S]*?```', text)
    placeholder = "___CODE_BLOCK___"
    for i, block in enumerate(code_blocks):
        text = text.replace(block, f"{placeholder}{i}")

    # 2. Remove tool call JSON (various formats)
    text = re.sub(r'(?i)\{\s*"name"\s*:\s*"[^"]*write_code_component_file[^"]*"\s*,\s*"arguments"\s*:\s*\{[\s\S]*?\}\s*\}', '', text, flags=re.DOTALL)
    text = re.sub(r'(?i)\{\s*"name"\s*:\s*"[^"]+"\s*,\s*"arguments"\s*:\s*\{[\s\S]*?\}\s*\}', '', text, flags=re.DOTALL)
    text = re.sub(r'(?i)\{[^}]*"write_code_component_file"[^}]*\}', '', text, flags=re.DOTALL)

    # 3. Remove narrative references to the tool
    text = re.sub(r'(?i)using the `?write_code_component_file`? function', '', text)
    text = re.sub(r'(?i)Now, let\'?s? write these? files? to the workspace using the .*?function', '', text)
    text = re.sub(r'(?i)First, write the .*? file:', '', text)
    text = re.sub(r'(?i)Next, write the .*? file:', '', text)

    # 4. Restore code blocks
    for i, block in enumerate(code_blocks):
        text = text.replace(f"{placeholder}{i}", block)

    # 5. Final cleanup
    text = re.sub(r"(\n\s*Successfully wrote .*? into project workspace\.?\s*\n)+", "\n*Workspace files written and verified locally.*\n", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    text = re.sub(r'\s*\{[\s\S]*"arguments"[\s\S]*?\}\s*$', '', text, flags=re.DOTALL)

    return text.strip()


def sanitize_agent_output(text: str) -> str:
    """Sanitize output, preserving code blocks."""
    if not text:
        return ""

    # Similar protection for code blocks
    code_blocks = re.findall(r'```[\s\S]*?```', text)
    placeholder = "___CODE_BLOCK___"
    for i, block in enumerate(code_blocks):
        text = text.replace(block, f"{placeholder}{i}")

    text = re.sub(
        r'(?i)\{\s*"name"\s*:\s*"[^"]*write_code_component_file[^"]*"\s*,\s*"arguments"\s*:\s*\{[\s\S]*?\}\s*\}',
        '', text, flags=re.DOTALL
    )
    text = re.sub(r'(?i)using the `?write_code_component_file`? function', '', text)

    for i, block in enumerate(code_blocks):
        text = text.replace(f"{placeholder}{i}", block)

    return text.strip()


def attach_execution_context_to_task(t_id: int, index: int, context_data: dict):
    """Serializes the structural execution environment to YAML and registers it as an agent-only state attachment."""
    try:
        yaml_payload = yaml.safe_dump(
            context_data, default_flow_style=False, sort_keys=False
        )
        filename = "agent-execution-context.yaml"

        files = {
            "files": (filename, yaml_payload.encode("utf-8"), "application/x-yaml")
        }
        attach_headers = {"Authorization": f"Bearer {VIKUNJA_BEARER_TOKEN}"}

        with httpx.Client(timeout=15.0) as client:
            res = client.put(
                f"{VIKUNJA_API_URL}/tasks/{t_id}/attachments",
                headers=attach_headers,
                files=files,
            )
            if res.status_code in [200, 201]:
                logger.info(
                    f"[State Memory] Successfully saved structural telemetry context: {filename}"
                )
            else:
                logger.error(
                    f"[State Memory] Failed storing execution context attachment: {res.status_code} - {res.text}"
                )
    except Exception as e:
        logger.error(
            f"[State Memory] Exception occurred pushing task context data: {e}"
        )


# ===================================================================
# 3. GITEA AUTOMATION LIFECYCLE HANDLERS
# ===================================================================
def create_gitea_pull_request(
    repo_path: str,
    head_branch: str,
    base_branch: str,
    title: str,
    description: str
) -> str:
    """Opens a Pull Request inside Gitea using its standard REST API structure."""
    if not GITEA_TOKEN:
        logger.warning(
            "[Gitea API] Token missing. Skipping Pull Request creation wrapper."
        )
        return ""

    url = f"{GITEA_BASE_URL.rstrip('/')}/api/v1/repos/{repo_path}/pulls"
    headers_gitea = {
        "Authorization": f"token {GITEA_TOKEN}",
        "Content-Type": "application/json",
    }
    payload = {
        "base": base_branch,
        "head": head_branch,
        "title": f"automation: {title}",
        "body": f"Automated refactoring pull request generated from Vikunja workflow.\n\n### Specifications:\n{description}",
    }

    try:
        with httpx.Client(verify=False, timeout=10.0) as client:
            res = client.post(url, headers=headers_gitea, json=payload)
            if res.status_code in [200, 201]:
                pr_data = res.json()
                logger.info(
                    f"[Gitea API] ✅ Pull Request opened successfully: {pr_data.get('html_url')}"
                )
                return pr_data.get("html_url", "")
            else:
                logger.error(
                    f"[Gitea API] Failed opening PR: {res.status_code} - {res.text}"
                )
                return ""
    except Exception as pr_err:
        logger.error(f"[Gitea API] Network crash triggering PR generation: {pr_err}")
        return ""


def display_api_telemetry_banner():
    """Queries and outputs version schemas from the running Vikunja service instance."""
    logger.info("=" * 70)
    logger.info("[Telemetry Router] Gathering target API environment metadata...")
    base_root = (
        VIKUNJA_API_URL.split("/api/v1")[0]
        if "/api/v1" in VIKUNJA_API_URL
        else VIKUNJA_API_URL
    )
    info_url = f"{base_root}/api/v1/info"

    try:
        with httpx.Client(timeout=5.0) as client:
            response = client.get(info_url, headers=headers)
            if response.status_code == 200:
                info_data = response.json()
                version = info_data.get("version", "Unknown Microversion")
                frontend = info_data.get("frontend_url", "N/A")
                logger.info(f" -> Vikunja Core Engine Version: {version}")
                logger.info(f" -> Connected Workspace View: {frontend}")
            else:
                logger.warning(
                    f" -> Telemetry: Non-200 response from info endpoint: {response.status_code}"
                )
    except Exception as telemetry_err:
        logger.warning(
            f" -> Connection Warning: Telemetry engine could not query API versions: {telemetry_err}"
        )
    logger.info("=" * 70 + "\n")


def resolve_project_ids() -> list:
    """Discovers project IDs matching the targeted list names, auto-creating any that are missing."""
    resolved_ids = []
    try:
        with httpx.Client(timeout=10.0) as client:
            # 1. Fetch current projects
            response = client.get(f"{VIKUNJA_API_URL}/projects", headers=headers)
            existing_projects = {}
            if response.status_code == 200:
                for proj in response.json() or []:
                    title = proj.get("title", "").strip()
                    existing_projects[title.lower()] = {
                        "id": proj.get("id"),
                        "title": title,
                    }

            # 2. Iterate through expected target names
            for target in TARGET_PROJECT_NAMES:
                tgt_lower = target.lower()
                if tgt_lower in existing_projects:
                    data = existing_projects[tgt_lower]
                    logger.info(
                        f"[CrewAI Daemon] Found target project '{data['title']}' (ID: {data['id']})"
                    )
                    resolved_ids.append(data["id"])
                else:
                    logger.info(
                        f"[Project Setup] Provisioning missing required workspace: '{target}'"
                    )
                    payload = {"title": target}
                    create_res = client.put(
                        f"{VIKUNJA_API_URL}/projects", headers=headers, json=payload
                    )
                    if create_res.status_code in [200, 201]:
                        new_id = create_res.json().get("id")
                        logger.info(
                            f"[Project Setup] -> Success! Created '{target}' (ID: {new_id})"
                        )
                        resolved_ids.append(new_id)
                    else:
                        raise RuntimeError(
                            f"[Project Setup] Critical error creating project '{target}': {create_res.text}"
                        )
    except Exception as e:
        logger.error(f"[Project Setup] Critical workspace auto-discovery error: {e}")
    return resolved_ids


def populate_project_structure_cache(project_ids: list):
    """Fetches Kanban view IDs and column mappings once on daemon initialization."""
    logger.info(
        "[Cache Initialization] Constructing static bucket metadata registry..."
    )
    try:
        with httpx.Client(timeout=10.0) as client:
            for p_id in project_ids:
                kanban_view_id = None
                view_title = None
                bucket_map = {}

                # Get project title
                proj_res = client.get(
                    f"{VIKUNJA_API_URL}/projects/{p_id}", headers=headers
                )
                project_title = (
                    proj_res.json().get("title", "Unknown")
                    if proj_res.status_code == 200
                    else "Unknown"
                )

                views_res = client.get(
                    f"{VIKUNJA_API_URL}/projects/{p_id}/views", headers=headers
                )
                if views_res.status_code == 200:
                    for view in views_res.json() or []:
                        if view.get("view_kind") == "kanban":
                            kanban_view_id = view.get("id")
                            view_title = view.get(
                                "title", f"Kanban-View-{kanban_view_id}"
                            )
                            break

                if kanban_view_id:
                    buckets_res = client.get(
                        f"{VIKUNJA_API_URL}/projects/{p_id}/views/{kanban_view_id}/buckets",
                        headers=headers,
                    )
                    if buckets_res.status_code == 200:
                        for bucket in buckets_res.json() or []:
                            title_clean = bucket.get("title", "").strip().lower()
                            bucket_map[title_clean] = bucket.get("id")

                PROJECT_STRUCTURE_CACHE[p_id] = {
                    "title": project_title,
                    "view_id": kanban_view_id,
                    "view_title": view_title,
                    "bucket_map": bucket_map
                }
                logger.info(
                    f" -> Project '{project_title}' (#{p_id}) cached layout: {bucket_map} "
                    f"(View: '{view_title}' ID: {kanban_view_id})"
                )

        logger.info(f"PROJECT_STRUCTURE_CACHE => {PROJECT_STRUCTURE_CACHE}")
    except Exception as e:
        logger.error(f"[Cache Error] Failed compiling layout matrices: {e}")


def extract_gitea_metadata_from_task_context(title: str, description: str) -> dict:
    """Parses task context strings looking for target repository qualifiers matching 'gitea:org/repo' syntax."""
    combined_text = f"{title}\n{description}"
    match = re.search(r"gitea:([\w\-\./]+)", combined_text, re.IGNORECASE)

    if match:
        repo_target = match.group(1).strip()
        logger.info(f"[Metadata Extraction] Detected Gitea repo: '{repo_target}'")
        return {"has_git": True, "repo": repo_target}

    logger.info("[Metadata Extraction] No Gitea repo metadata found")
    return {"has_git": False, "repo": None}


def extract_gitea_metadata(
    task_title: str, task_desc: str, task_labels: list = None
) -> dict:
    """
    Extracts Gitea repository paths and target branches from task labels or description meta blocks.
    Looks for:
      - Labels matching 'repo:org/name' or 'branch:name'
      - Explicit blocks like 'gitea:org/name' in description
    """
    meta = {"repo": None, "branch": "main"}

    # 1. Check Vikunja labels if available
    if task_labels:
        for label in task_labels:
            label_name = label.get("title", "").strip()
            if label_name.startswith("repo:"):
                meta["repo"] = label_name.split("repo:", 1)[1].strip()
            elif label_name.startswith("branch:"):
                meta["branch"] = label_name.split("branch:", 1)[1].strip()

    # 2. Fallback: Parse description metadata block
    if not meta["repo"] and task_desc:
        repo_match = re.search(
            r"(?:gitea|repo):\s*([a-zA-Z0-9_\-]+/[a-zA-Z0-9_\-]+)",
            task_desc,
            re.IGNORECASE,
        )
        if repo_match:
            meta["repo"] = repo_match.group(1).strip()

        branch_match = re.search(
            r"branch:\s*([a-zA-Z0-9_\-\/]+)", task_desc, re.IGNORECASE
        )
        if branch_match:
            meta["branch"] = branch_match.group(1).strip()

    return meta


def move_task_bucket(
    project_id: int, view_id: int, target_task: dict, bucket_id: int, action_name="Move"
):
    """Moves target cards across Kanban columns using functional bucket API updates."""
    if not all([project_id, view_id, bucket_id]):
        logger.warning(f"[State Machine] Skipping {action_name}: missing IDs")
        return False

    cache_meta = PROJECT_STRUCTURE_CACHE.get(project_id, {})
    project_name = cache_meta.get("title", f"Project-{project_id}")
    t_display_id = target_task['display_id']

    logger.info(
        f"[State Machine] {action_name} Task {t_display_id} → bucket {bucket_id} in '{project_name}'"
    )

    # Use the endpoint that consistently succeeds
    url = f"{VIKUNJA_API_URL}/projects/{project_id}/views/{view_id}/buckets/{bucket_id}/tasks"
    payload = {"task_id": int(target_task["id"])}

    try:
        with httpx.Client(timeout=10.0) as client:
            response = client.post(url, headers=headers, json=payload)
            if response.status_code == 200:
                logger.info(
                    f"[State Machine API] ✅ {action_name} succeeded for Task {t_display_id}"
                )
                return True
            else:
                logger.error(
                    f"[State Machine API] Failed for Task {t_display_id}: {response.status_code} - {response.text[:300]}"
                )
                return False
    except Exception as e:
        logger.error(
            f"[State Update Error] {action_name} failed for Task {t_display_id}: {e}",
            exc_info=True,
        )
        return False


def fetch_next_kanban_task(project_ids: list) -> dict:
    """Queries open tasks, skipping those already processed via label elements."""
    logger.debug(f"[Polling] Scanning projects: {[PROJECT_STRUCTURE_CACHE.get(pid, {}).get('title', pid) for pid in project_ids]}")
    try:
        with httpx.Client(timeout=10.0) as client:
            for p_id in project_ids:
                cache_meta = PROJECT_STRUCTURE_CACHE.get(
                    p_id, {"title": f"Project-{p_id}", "bucket_map": {}}
                )
                bucket_map = cache_meta.get("bucket_map", {})
                project_name = cache_meta.get("title")
                todo_bucket_id = (
                    bucket_map.get("to-do") or bucket_map.get("todo") or bucket_map.get("to do")
                )
                if not todo_bucket_id:
                    continue

                url = f"{VIKUNJA_API_URL}/projects/{p_id}/tasks?filter=done%20=%20false"
                response = client.get(url, headers=headers)
                if response.status_code != 200:
                    continue

                tasks = response.json() or []
                for t in tasks:
                    task = copy.deepcopy(t)
                    display_id = f"#{task['index']} (ID {task['id']})"
                    task["display_id"] = display_id
                    current_bucket = t.get("bucket_id")
                    labels = t.get("labels", []) or []

                    # FIX: If the target is the To-Do bucket, accept both its explicit ID
                    # AND 0 (unassigned default) to account for Vikunja view decoupling.
                    is_in_todo = (current_bucket == todo_bucket_id) or (current_bucket == 0)

                    if not is_in_todo:
                        logger.debug(
                            f"Skipping Task {display_id} - Bucket {current_bucket} does not match To-Do Target {todo_bucket_id}")
                        continue

                    # Skip if already processed
                    if any(label.get("title", "").lower() == "agent-processed" for label in labels):
                        logger.debug(f"[Polling] Skipping Task {display_id} (already processed)")
                        continue

                    logger.info(f"[Polling] ✅ Claiming unprocessed Task {display_id} in '{project_name}' [{p_id}]")
                    return task

                # Add backoff/sleep to prevent 429 rate limits
                time.sleep(5)
    except Exception as e:
        logger.error(f"[Polling Warning] Connectivity delay: {e}")
    return None


def convert_markdown_to_vikunja_html(markdown_text: str) -> str:
    """Converts markdown to standard HTML matching CommonMark conventions."""
    md = MarkdownIt("commonmark", {"html": True, "breaks": True})
    md.use(tasklists_plugin)
    return md.render(markdown_text).strip()


def convert_vikunja_html_to_markdown(html_text: str) -> str:
    """Converts standard HTML elements back into readable markdown for LLM context processing."""
    if not html_text:
        return ""

    # markdownify cleanly strips block tags, handles breaks, and formats nested list indices
    markdown_out = md_convert(
        html_text,
        heading_style="ATX",
        bullets="-",
        strip=["script", "style"]
    )
    return markdown_out.strip()


def extract_gitea_metadata(task_title: str, task_desc: str, task_labels: list = None) -> dict:
    """
    Extracts Gitea repository paths and target branches from task labels or description meta blocks.
    Looks for:
      - Labels matching 'repo:org/name' or 'branch:name'
      - Explicit blocks like 'gitea:org/name' in description
    """
    meta = {"repo": None, "branch": "main"}

    # 1. Check Vikunja labels if available
    if task_labels:
        for label in task_labels:
            label_name = label.get("title", "").strip()
            if label_name.startswith("repo:"):
                meta["repo"] = label_name.split("repo:", 1)[1].strip()
            elif label_name.startswith("branch:"):
                meta["branch"] = label_name.split("branch:", 1)[1].strip()

    # 2. Fallback: Parse description metadata block
    if not meta["repo"] and task_desc:
        repo_match = re.search(r'(?:gitea|repo):\s*([a-zA-Z0-9_\-]+/[a-zA-Z0-9_\-]+)', task_desc, re.IGNORECASE)
        if repo_match:
            meta["repo"] = repo_match.group(1).strip()

        branch_match = re.search(r'branch:\s*([a-zA-Z0-9_\-\/]+)', task_desc, re.IGNORECASE)
        if branch_match:
            meta["branch"] = branch_match.group(1).strip()

    return meta


# ===================================================================
# 4. CREWAI PIPELINE REFACTORING & EXECUTOR
# ===================================================================
def execute_crewai_workflow(
    title: str,
    description: str,
    context_directory: str = None
) -> str:
    """Assembles localized runtime parameters, provisions workspace tools, and executes agents."""
    logger.info(
        f"[CrewAI Execution] Invoking model backend team setup. Scoped workspace path: {context_directory}"
    )

    # Parse .continue/config.yaml structures if present
    repo_config = parse_repo_specific_config(context_directory)

    # Format system rules into clear agent boundaries
    additional_backstory = ""
    if repo_config.get("rules"):
        formatted_rules = "\n".join([f" - {rule}" for rule in repo_config["rules"]])
        additional_backstory = f"\n\nYou MUST strictly follow these repository constraints:\n{formatted_rules}"

    # Match prompt injections based on keywords in title/description
    injected_prompt_guidance = ""
    if "prompts" in repo_config:
        for p in repo_config["prompts"]:
            p_name = p.get("name", "").lower()
            # If the task references the prompt name (e.g. "ansible-module") match it
            if p_name in title.lower() or p_name in description.lower():
                injected_prompt_guidance = f"\n\n### Specialized Prompt Context Guide ({p.get('name')}):\n{p.get('prompt')}"
                logger.info(
                    f"[Context Engine] Matching template injection triggered: {p.get('name')}"
                )
                break

    workspace_tools = (
        create_workspace_tools(context_directory) if context_directory else []
    )

    local_model = LLM(
        model=f"hosted_vllm/{LOCAL_LLM_MODEL}",
        base_url=LOCAL_LLM_BASE_URL,
        api_key=LOCAL_LLM_API_KEY,
        temperature=0.2,
        timeout=300
    )

    developer = Agent(
        role="Senior Developer Architect",
        goal="Analyze engineering tasks, write cleanly namespaced components, and output working code adjustments.",
        backstory=f"An enterprise cloud and platform automation engineer specialized in DRY code structuring.{additional_backstory}",
        llm=local_model,
        tools=workspace_tools,
        verbose=True,
    )

    dev_task = Task(
        description=(
            f"Process the given instruction set:\n"
            f"Title: {title}\n"
            f"Details: {description}\n\n"
            f"Workspace Path: {context_directory}\n"
            f"Use 'Write Code Component File' directly to update or draft clean code structures. "
            f"Do not leak raw JSON block formatting parameters in any final conversational updates.\n"
            f"{injected_prompt_guidance}"
        ),
        expected_output="Detailed engineering summary outlining what file changes or additions were written directly to the workspace.",
        agent=developer,
    )

    crew = Crew(
        agents=[developer],
        tasks=[dev_task],
        process=Process.sequential,
        verbose=True
    )

    result = crew.kickoff()
    logger.info("[CrewAI Workflow] ✅ Agent execution completed")
    return result


def process_gitops_task(task_obj, todo_bucket_id, review_bucket_id, view_id):
    """Orchestrates filesystem tasks, resolving dynamic model generation calls cleanly."""
    t_id = task_obj.get("id")
    t_title = task_obj.get("title", "")
    t_desc = task_obj.get("description", "")
    t_labels = task_obj.get("labels", [])

    # 1. Extract Gitea coordinates
    git_meta = extract_gitea_metadata(t_title, t_desc, t_labels)
    if not git_meta["repo"]:
        logger.info(f"Task #{t_id} has no specified Gitea repository tag. Processing as standard task.")
        return False

    # 2. Configure authentication using container environment secrets
    gitea_token = os.getenv("GITEA_TOKEN")
    gitea_base = os.getenv("GITEA_BASE_URL", "https://kanban.admin.johnson.int").replace("https://", "")
    clone_url = f"https://automation-bot:{gitea_token}@{gitea_base}/{git_meta['repo']}.git"

    feature_branch = f"agent/task-{t_id}-automation"

    with tempfile.TemporaryDirectory(prefix=f"gitea-task-{t_id}-") as workspace_dir:
        logger.info(f"Cloning {git_meta['repo']} into isolated container directory: {workspace_dir}")

        # Clone and switch to feature branch
        repo = git.Repo.clone_from(clone_url, workspace_dir)
        repo.git.checkout("-b", feature_branch)

        # 3. Hand the filesystem workspace directory to the CrewAI Pipeline
        # The agent reads code from workspace_dir, modifies logic, edits files, etc.
        agent_output_raw = execute_crewai_workflow(t_title, t_desc, context_directory=workspace_dir)
        agent_output = sanitize_agent_output(str(agent_output_raw))

        # 4. GitOps Verification & Push Commit
        if repo.is_dirty(untracked_files=True):
            repo.git.add(A=True)
            repo.index.commit(
                f"automation: processed task #{t_id}\n\nTitle: {t_title}\n\nGenerated via local model backend.")
            repo.git.push("--set-upstream", "origin", feature_branch)

            # 5. Open a Pull Request in Gitea via API
            pr_url = create_gitea_pull_request(git_meta["repo"], feature_branch, git_meta["branch"], t_title, t_desc)

            # Append PR tracking link directly to Vikunja resolution comment
            final_comment = f"### 🤖 Agent Code Execution Complete\n\n**Pull Request Created:** {pr_url}\n\n#### Output Summary:\n{agent_output}"
        else:
            final_comment = f"### 🤖 Agent Code Execution Complete\nNo filesystem modifications were made to the codebase.\n\n{agent_output}"

        # Resolve project maps structures out of context maps for post resolution transitions
        p_id = task_obj.get("project_id")
        cache_meta = PROJECT_STRUCTURE_CACHE.get(p_id, {})
        bucket_map = cache_meta.get("bucket_map", {})

        post_resolution_to_vikunja(p_id, view_id, task_obj, final_comment, bucket_map, pr_url=pr_url, git_meta=git_meta)
        return True


def get_label_id(title: str, hex_color: str = "#4CAF50") -> int:
    """Ensures a label with the given title exists globally in Vikunja."""

    # 1. Fetch all existing global labels
    labels_url = f"{VIKUNJA_API_URL}/labels"
    try:
        with httpx.Client(timeout=10.0) as client:
            response = client.get(labels_url, headers=headers)
            if response.status_code == 200:
                existing_labels = response.json() or []
                for label in existing_labels:
                    if label.get("title") == title:
                        logger.debug(f"[Label Manager] Found existing global label '{title}' (ID: {label['id']})")
                        return label["id"]
            else:
                logger.warning(
                    f"[Label Manager] Failed to fetch labels, status: {response.status_code}. Attempting creation.")

            # 2. Label doesn't exist globally; create it
            create_payload = {
                "title": title,
                "hex_color": hex_color.lstrip("#")
            }

            logger.info(f"[Label Manager] Global label '{title}' not found. Creating new instance...")
            create_res = client.put(labels_url, headers=headers, json=create_payload)

            if create_res.status_code in [200, 201]:
                new_label = create_res.json()
                logger.info(f"[Label Manager] ✅ Successfully created global label '{title}' (ID: {new_label['id']})")
                return new_label["id"]
            else:
                raise RuntimeError(
                    f"Failed to create global label '{title}'. Status: {create_res.status_code}, Response: {create_res.text}"
                )
    except Exception as e:
        raise RuntimeError(f"Failed to ensure global label '{title}': {e}")


def add_label_to_task(target_task: dict, title: str, hex_color: str = "#4CAF50"):
    """Ensures a tracking label is attached to the processed task item."""
    t_id = target_task["id"]
    t_display_id = target_task["display_id"]
    try:
        label_id = get_label_id(title=title, hex_color=hex_color)
        label_payload = {"label_id": label_id}
        with httpx.Client(timeout=10.0) as client:
            label_res = client.put(
                f"{VIKUNJA_API_URL}/tasks/{t_id}/labels", headers=headers, json=label_payload
            )
            if label_res.status_code in [200, 201]:
                logger.info(
                    f"[Post Resolution] Tagged Task {t_display_id} as 'agent-processed'"
                )
            else:
                raise RuntimeError(
                    f"Failed to tag task {t_display_id}. Status : {label_res.status_code} | Msg: {label_res.text}"
                )
    except Exception as e:
        raise RuntimeError(
            f"Failed to add label '{title}' to task {t_display_id}: Network error fetching global labels: {e}"
        )


def post_resolution_to_vikunja(
    project_id: int,
    view_id: int,
    target_task: dict,
    agent_output: str,
    bucket_map: dict,
    pr_url: str = None,
    git_meta: dict = None,
):
    """Cleans up output telemetry, posts human summaries to comments, and captures structured YAML state."""
    t_id = target_task["id"]
    t_display_id = target_task["display_id"]
    review_bucket_id = bucket_map.get("review")
    cache_meta = PROJECT_STRUCTURE_CACHE.get(project_id, {})
    project_name = cache_meta.get("title", f"Project-{project_id}")

    logger.info(f"[Post Resolution] Processing output for Task {t_display_id} in '{project_name}'")
    raw_text = agent_output.raw if hasattr(agent_output, "raw") else str(agent_output)

    # 1. Scrub internal JSON arrays and raw tool call noise from user-facing commentary
    clean_summary = scrub_agent_telemetry(raw_text)
    clean_summary = sanitize_agent_output(clean_summary)

    # Additional aggressive cleanup pass for any remaining JSON artifacts
    clean_summary = re.sub(
        r'(?i)\{\s*"name"\s*:\s*"[^"]*"\s*,\s*"arguments"\s*:\s*\{[\s\S]*?\}\s*\}',
        '',
        clean_summary,
        flags=re.DOTALL
    )
    clean_summary = re.sub(
        r'(?i)\{[^}]*"write_code_component_file"[^}]*\}',
        '',
        clean_summary,
        flags=re.DOTALL
    )
    # Remove any trailing JSON-like structures
    clean_summary = re.sub(r'\s*\{[\s\S]*"arguments"[\s\S]*?\}\s*$', '', clean_summary, flags=re.DOTALL)

    # 2. Compile and save structured memory context for long-running workflows / supervisor loop
    execution_state = {
        "task_id": t_id,
        "index": target_task.get("index"),
        "title": target_task.get("title"),
        "status": "COMPLETED" if pr_url else "ANALYZED_NO_CHANGES",
        "timestamp": int(time.time()),
        "gitops": {
            "repository": git_meta.get("repo") if git_meta else None,
            "base_branch": git_meta.get("branch") if git_meta else None,
            "feature_branch": f"agent/task-{target_task.get('index')}-automation",
            "pull_request_url": pr_url,
        },
        "raw_agent_summary": clean_summary,
    }
    attach_execution_context_to_task(t_id, target_task.get("index"), execution_state)

    # 3. Format clean user comment payload
    comment_markdown = f"### 🤖 Core Worker Resolution Complete\n\n{clean_summary}"
    if pr_url:
        comment_markdown += f"\n\n**🎯 Pull Request Synchronized Upstream:** {pr_url}"
    else:
        comment_markdown += "\n\n*Pipeline run finished. Local checks evaluated without codebase drift.*"

    # 4. Convert the complete document cleanly into Vikunja-compatible HTML
    comment_body = convert_markdown_to_vikunja_html(comment_markdown)

    # 5. Deliver the final payload cleanly as raw HTML text
    comment_url = f"{VIKUNJA_API_URL}/tasks/{t_id}/comments"
    comment_payload = {
        "comment": comment_body
    }

    try:
        with httpx.Client(timeout=10.0) as client:
            c_res = client.put(comment_url, headers=headers, json=comment_payload)

            if c_res.status_code not in [200, 201]:
                logger.error(
                    f"[API Error] Failed to post comment to task {t_display_id}. Status : {c_res.status_code} | Msg: {c_res.text}"
                )

            # Inject long payload fallback protection if text is extraordinarily verbose
            if len(raw_text) > 12000:
                files = {
                    "files": (
                        f"raw_worker_debug_{target_task['index']}.log",
                        raw_text.encode("utf-8"),
                        "text/plain",
                    )
                }
                client.put(
                    f"{VIKUNJA_API_URL}/tasks/{t_id}/attachments",
                    headers={"Authorization": f"Bearer {VIKUNJA_BEARER_TOKEN}"},
                    files=files,
                )

            add_label_to_task(target_task, title="agent-processed", hex_color="#4CAF50")

            # 6. Complete column shift to review
            if review_bucket_id and view_id:
                logger.info(f"[State Machine] Advancing Task {t_display_id} into 'Review' column...")
                move_task_bucket(
                    project_id,
                    view_id,
                    target_task,
                    review_bucket_id,
                    action_name="Advance to Review"
                )
            else:
                raise RuntimeError(
                    f"[State Machine Warning] No 'Review' column in project '{project_name}' for Task {t_display_id}."
                )
    except Exception as e:
        logger.error(
            f"[Completion Pipeline] Failure posting final resolutions in project '{project_name}' to Task {t_display_id}: {e}",
            exc_info=True
        )


def parse_repo_specific_config(context_directory: str) -> dict:
    """Looks for `.continue/config.yaml` inside the checked-out workspace."""
    config_data = {"rules": [], "matched_prompt": ""}
    if not context_directory:
        return config_data

    # Check both standard locations
    potential_paths = [
        os.path.join(context_directory, ".continue", "config.yaml"),
        os.path.join(context_directory, ".continue", "config.yml"),
        os.path.join(context_directory, "config.yaml"),
    ]

    for path in potential_paths:
        if os.path.exists(path):
            try:
                with open(path, "r") as f:
                    parsed = yaml.safe_load(f) or {}
                    if "rules" in parsed and isinstance(parsed["rules"], list):
                        config_data["rules"] = parsed["rules"]
                    if "prompts" in parsed and isinstance(parsed["prompts"], list):
                        config_data["prompts"] = parsed["prompts"]
                break
            except Exception as ex:
                logger.warning(
                    f"[Context Engine] Failed parsing workspace configuration: {ex}"
                )
    return config_data


def start_daemon_polling_loop():
    """Main lifecycle loop scanning for target cards and isolating Gitea branch modifications."""

    # 1. Run environment inspection telemetry banner
    display_api_telemetry_banner()

    # Establish dynamic runtime target cache mapping
    scoped_project_ids = resolve_project_ids()

    # Simple sanity safety guard check
    if not scoped_project_ids:
        logger.error("[Daemon Infrastructure] Active tracking targets list empty. Exiting.")
        return

    # Cache project layouts at boot time to eliminate repetitive layout discovery calls
    populate_project_structure_cache(scoped_project_ids)
    logger.info("[Daemon Engine] 🚀 Core polling worker thread active.")

    while True:
        try:
            target_task = fetch_next_kanban_task(scoped_project_ids)
            if not target_task:
                time.sleep(10)
                continue

            p_id = target_task["project_id"]
            t_title = target_task.get("title", "")
            t_display_id = target_task["display_id"]
            t_labels = target_task.get("labels", [])
            t_desc = convert_vikunja_html_to_markdown(target_task.get("description", ""))

            cache_meta = PROJECT_STRUCTURE_CACHE.get(p_id, {})
            view_id = cache_meta.get("view_id")
            bucket_map = cache_meta.get("bucket_map", {})
            todo_bucket_id = (
                bucket_map.get("to-do") or bucket_map.get("todo") or bucket_map.get("to do")
            )
            doing_bucket_id = (
                bucket_map.get("doing")
                or bucket_map.get("in progress")
                or bucket_map.get("in-progress")
                or bucket_map.get("in progress")
            )

            is_successfully_completed = False
            pr_url = None

            try:
                # 1. Update status to 'Doing' to prevent worker conflicts
                if doing_bucket_id:
                    move_task_bucket(
                        p_id,
                        view_id,
                        target_task,
                        doing_bucket_id,
                        action_name="Move to Doing"
                    )

                # 2. Extract Gitea tracking parameters
                git_meta = extract_gitea_metadata(t_title, t_desc, t_labels)

                if git_meta["repo"]:
                    logger.info(
                        f"[GitOps Pipeline] Identified target repository framework context: {git_meta['repo']}"
                    )

                    # Compute safe HTTPS clone URI combining container token metrics
                    gitea_clean_base = GITEA_BASE_URL.replace("https://", "").replace("http://", "")
                    clone_url = f"https://automation-bot:{GITEA_TOKEN}@{gitea_clean_base}/{git_meta['repo']}.git"
                    feature_branch = f"agent/task-{target_task['index']}-automation"

                    # 3. Provision ephemeral disk workspace isolation
                    with tempfile.TemporaryDirectory(
                        prefix=f"gitea-task-{target_task['id']}-"
                    ) as workspace_dir:
                        logger.debug(
                            f"[GitOps Pipeline] Cloning {git_meta['repo']} to scratch directory: {workspace_dir}"
                        )

                        # Clone target codebase repository
                        repo = git.Repo.clone_from(clone_url, workspace_dir)

                        # Create and checkout clean task branch bound to original root base
                        logger.debug(
                            f"[GitOps Pipeline] Establishing clean branch environment: '{feature_branch}' based on branch '{git_meta['branch']}'"
                        )
                        repo.git.checkout(git_meta["branch"])
                        repo.git.checkout("-b", feature_branch)

                        # 4. Fire localized execution teams passing specific directory boundaries
                        result = execute_crewai_workflow(
                            t_title, t_desc, context_directory=workspace_dir
                        )

                        # 5. Analyze changes and push modifications
                        if repo.is_dirty(untracked_files=True):
                            logger.info(
                                "[GitOps Pipeline] Codebase modifications caught. Committing patches..."
                            )
                            repo.git.add(A=True)
                            repo.index.commit(
                                f"automation: processed task #{t_display_id}\n\nTitle: {t_title}"
                            )
                            repo.git.push("--set-upstream", "origin", feature_branch)

                            # Open pull request targeting upstream base branch
                            pr_url = create_gitea_pull_request(
                                repo_path=git_meta["repo"],
                                head_branch=feature_branch,
                                base_branch=git_meta["branch"],
                                title=t_title,
                                description=t_desc,
                            )
                        else:
                            logger.info(
                                "[GitOps Pipeline] Run finished cleanly with no system drift."
                            )
                else:
                    # Standard non-code parsing workflow fallback
                    result = execute_crewai_workflow(t_title, t_desc)

                # 6. Save resolution metrics, comments, labels, and advance card to Review
                post_resolution_to_vikunja(
                    project_id=p_id,
                    view_id=view_id,
                    target_task=target_task,
                    agent_output=result,
                    bucket_map=bucket_map,
                    pr_url=pr_url,
                    git_meta=git_meta,
                )
                is_successfully_completed = True
                logger.info(
                    f"✅ Task {t_display_id} fully processed successfully."
                )

            except Exception as loop_error:
                logger.error(
                    f"[CRITICAL] Worker crashed on Task {t_display_id}: {loop_error}",
                    exc_info=True,
                )

            finally:
                if not is_successfully_completed and todo_bucket_id:
                    logger.warning(
                        f"[Rollback] Reverting Task {t_display_id} to To-Do bucket."
                    )
                    move_task_bucket(
                        p_id,
                        view_id,
                        target_task,
                        todo_bucket_id,
                        action_name="Rollback to To-Do"
                    )

        except Exception as e:
            logger.error(
                f"[Daemon Core] Pipeline iteration exception: {e}", exc_info=True
            )

        time.sleep(5)


if __name__ == "__main__":
    start_daemon_polling_loop()
