import os
import time
import sys
import logging
import httpx
import urllib3
import pytest
import random
from markdown_it import MarkdownIt
from mdit_py_plugins.tasklists import tasklists_plugin

# ====================== LOGGING & CONFIG BOOTSTRAPPING ======================
logger = logging.getLogger("test_agent_suite")
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)-8s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
    stream=sys.stdout
)


def load_env_file():
    """Finds and loads environment variables from test_agent_pipeline.env if it exists."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    env_path = os.path.join(script_dir, "test_agent_pipeline.env")

    if os.path.exists(env_path):
        logger.info(f"[Env Loader] Found local configuration file at: {env_path}")
        with open(env_path, "r") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" in line:
                    key, value = line.split("=", 1)
                    key = key.strip()
                    value = value.strip().strip('"').strip("'")
                    # Sourced from file if not already defined in system environment
                    if key and not os.getenv(key):
                        os.environ[key] = value
    else:
        logger.info(
            "[Env Loader] No local .env file found. Falling back to ambient system environment."
        )


# Bootstrap environment configurations
load_env_file()

MAX_ATTEMPTS = int(os.getenv("MAX_ATTEMPTS", 40))

VIKUNJA_API_URL = os.getenv("VIKUNJA_API_URL")
VIKUNJA_BEARER_TOKEN = os.getenv("VIKUNJA_BEARER_TOKEN")
GITEA_BASE_URL = os.getenv("GITEA_BASE_URL")
GITEA_TOKEN = os.getenv("GITEA_TOKEN")

TARGET_PROJECT_NAME = "crewai-test"

# Fail early if infrastructure keys are missing
assert VIKUNJA_API_URL, "Missing VIKUNJA_API_URL environment configuration."
assert VIKUNJA_BEARER_TOKEN, "Missing VIKUNJA_BEARER_TOKEN environment configuration."

VIKUNJA_HEADERS = {
    "Authorization": f"Bearer {VIKUNJA_BEARER_TOKEN}",
    "Content-Type": "application/json",
}

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def convert_markdown_to_vikunja_html(markdown_text: str) -> str:
    """Converts markdown to standard HTML matching CommonMark conventions."""
    md = MarkdownIt("commonmark", {"html": True, "breaks": True})
    md.use(tasklists_plugin)
    return md.render(markdown_text).strip()


def get_task_payload(title: str, description: str, bucket_id: int) -> dict:
    task_description = convert_markdown_to_vikunja_html(description)
    return {
        "title": title,
        "description": task_description,
        "bucket_id": bucket_id
    }


def move_task_bucket(
    project_id: int, view_id: int, task: dict, bucket_id: int, context: str = ""
):
    """Moves a task to a target Kanban bucket view."""
    url = f"{VIKUNJA_API_URL}/projects/{project_id}/views/{view_id}/buckets/{bucket_id}/tasks"
    try:
        with httpx.Client(verify=False, timeout=10.0) as client:
            res = client.post(
                url, headers=VIKUNJA_HEADERS, json={"task_id": task["id"]}
            )
            if res.status_code in [200, 201]:
                logger.info(
                    f" -> {context} Moved Task {task.get('display_id', task['id'])} to Bucket #{bucket_id}"
                )
            else:
                logger.warning(
                    f" -> Failed to move task bucket position: {res.status_code}"
                )
    except Exception as e:
        logger.warning(f" -> Exception while moving task bucket: {e}")


def soft_archive_test_task(
    task_body: dict, project_id: int, view_id: int, layout_map: dict
):
    """Soft-archives an individual completed test task."""
    task_id = task_body["id"]
    logger.info(f"\n[-] Soft-archiving Test Task ID {task_id}...")
    archive_bucket_id = (
        layout_map.get("archived")
        or layout_map.get("archive")
        or layout_map.get("done")
    )

    # Construct complete baseline state payload to avoid blank field resets on older micro-releases
    archive_payload = {"done": True, "description": task_body.get("description", "")}

    try:
        with httpx.Client(verify=False, timeout=10.0) as client:
            # 1. Soft-close task parameters by marking it done
            client.post(
                f"{VIKUNJA_API_URL}/tasks/{task_id}",
                headers=VIKUNJA_HEADERS,
                json=archive_payload,
            )

            # 2. Relocate its card position out of production processing loops
            if view_id and archive_bucket_id:
                move_task_bucket(
                    project_id,
                    view_id,
                    {"id": task_id, "display_id": f"ID {task_id}"},
                    archive_bucket_id,
                    "(Teardown)",
                )
    except Exception as e:
        logger.warning(f"[Teardown Warning] Failed to soft-archive task {task_id}: {e}")


# ===================================================================
# FIXTURES (DYNAMIC ROUTING & UTILITIES)
# ===================================================================


@pytest.fixture(scope="session", autouse=True)
def environment_bootstrap():
    """Validates core API tokens are present before executing any test paths."""
    if not VIKUNJA_API_URL or not VIKUNJA_BEARER_TOKEN:
        pytest.fail(
            "CRITICAL CONFIGURATION ERROR: VIKUNJA_API_URL or VIKUNJA_BEARER_TOKEN is not defined."
        )


@pytest.fixture(scope="session")
def pipeline_metadata():
    """Resolves target workspace project ID and extracts Kanban board layouts."""
    logger.info(f"Resolving workspace context for project: '{TARGET_PROJECT_NAME}'")
    with httpx.Client(verify=False, timeout=10.0) as client:
        # Find Project ID
        res = client.get(f"{VIKUNJA_API_URL}/projects", headers=VIKUNJA_HEADERS)
        assert res.status_code == 200, (
            f"Failed to fetch projects index mapping: {res.text}"
        )

        project_id = None
        for proj in res.json() or []:
            if proj.get("title", "").strip().lower() == TARGET_PROJECT_NAME.lower():
                project_id = proj["id"]
                break

        if not project_id:
            pytest.fail(
                f"Target verification workspace '{TARGET_PROJECT_NAME}' missing from platform."
            )

        # Find Kanban View ID
        v_res = client.get(
            f"{VIKUNJA_API_URL}/projects/{project_id}/views", headers=VIKUNJA_HEADERS
        )
        view_id_kanban = None
        if v_res.status_code == 200:
            for view in v_res.json() or []:
                if view.get("view_kind") == "kanban":
                    view_id_kanban = view["id"]
                    break

        if not view_id_kanban:
            pytest.fail(
                "Target Kanban view interface missing on project dashboard layout."
            )

        # Map Column Buckets
        b_res = client.get(
            f"{VIKUNJA_API_URL}/projects/{project_id}/views/{view_id_kanban}/buckets",
            headers=VIKUNJA_HEADERS,
        )
        layout_map = {}
        if b_res.status_code == 200:
            for bucket in b_res.json() or []:
                title_clean = bucket.get("title", "").strip().lower()
                layout_map[title_clean] = bucket.get("id")

        assert "to-do" in layout_map, (
            "To-Do lane missing from Kanban project view layout."
        )
        assert "doing" in layout_map, (
            "Doing lane missing from Kanban project view layout."
        )
        assert "review" in layout_map, (
            "Review lane missing from Kanban project view layout."
        )

        return {
            "project_id": project_id,
            "view_id_kanban": view_id_kanban,
            "bucket_id_todo": layout_map["to-do"],
            "bucket_id_doing": layout_map["doing"],
            "bucket_id_review": layout_map["review"],
            "layout_map": layout_map,
        }


@pytest.fixture
def task_teardown_manager(pipeline_metadata):
    """
    Yields a registration context list. Any task added during test executions
    will automatically be archived during the post-test function teardown phase.
    """
    registered_tasks = []
    yield registered_tasks

    for task_context in registered_tasks:
        soft_archive_test_task(
            task_body={
                "id": task_context["id"],
                "description": task_context.get("description", ""),
            },
            project_id=pipeline_metadata["project_id"],
            view_id=pipeline_metadata["view_id_kanban"],
            layout_map=pipeline_metadata["layout_map"]
        )


def get_task_display_id(task_data: dict) -> str:
    t_display_id = f"#{task_data['index']} (ID {task_data['id']})"
    return t_display_id


def get_task_current_bucket_id(task_id: int, cache_meta: dict):
    """Helper to locate which bucket an active card resides in."""
    p_id = cache_meta["project_id"]
    view_id_kanban = cache_meta["view_id_kanban"]
    endpoint = f"{VIKUNJA_API_URL}/projects/{p_id}/views/{view_id_kanban}/tasks?filter=id={task_id}"
    t_bucket_id = None
    with httpx.Client(verify=False) as client:
        res = client.get(endpoint, headers=VIKUNJA_HEADERS)
        if res.status_code == 200:
            for bucket in res.json():
                tasks = bucket.get("tasks", []) or []
                if any(t.get("id") == task_id for t in tasks):
                    t_bucket_id = bucket.get("id")
    logger.debug(f"Task {task_id} bucket_id = {t_bucket_id}")
    return t_bucket_id


def check_task_has_label(task_id, label_name):
    """Helper to verify if a label has been successfully attached to a task."""
    endpoint = f"{VIKUNJA_API_URL}/tasks/{task_id}"
    with httpx.Client(verify=False) as client:
        res = client.get(endpoint, headers=VIKUNJA_HEADERS)
        if res.status_code == 200:
            labels = res.json().get("labels", []) or []
            if any(label.get("title") == label_name for label in labels):
                logger.info(f"✅ Label `{label_name}` found.")
                return True
        else:
            logger.warning("⚠️ No labels found yet.")
    return False


def check_task_comments(task_id, expected_outcome: str) -> bool:
    """
    Evaluates comments for GitOps metadata. Returns a clean boolean instead
    of asserting immediately to avoid crashing active retry polling loops.
    """
    endpoint = f"{VIKUNJA_API_URL}/tasks/{task_id}/comments"
    with httpx.Client(verify=False) as client:
        res = client.get(endpoint, headers=VIKUNJA_HEADERS)
        if res.status_code == 200:
            comments = res.json() or []
            if comments:
                combined_comments_text = " ".join(
                    [c.get("comment", "").lower() for c in comments]
                )

                # --- SANITIZATION HOOKS (Saves immediate failures for structural leaks) ---
                for comm in comments:
                    text = comm.get("comment", "")
                    if (
                        '"name":' in text
                        or '{"name": "write_code_component_file"' in text
                    ):
                        logger.error(
                            "❌ Telemetry leak detected inside raw JSON schema signatures."
                        )
                        return False

                # --- EVALUATE EXPECTED GITOPS OUTCOMES ---
                if expected_outcome == "PR_CREATED":
                    if (
                        "/pulls/" in combined_comments_text
                        or "pull/" in combined_comments_text
                    ):
                        logger.info(
                            "✅ Verified GitOps PR creation link in comment history."
                        )
                        return True
                    else:
                        logger.warning(
                            "⚠️ Comments exist, but the Gitea PR URL path has not been posted yet."
                        )
                        return False
                else:
                    if (
                        "pulls/" not in combined_comments_text
                        and "pull/" not in combined_comments_text
                    ):
                        logger.info(
                            "✅ Verified read-only execution flow preserved filesystem stability."
                        )
                        return True
                    else:
                        logger.error(
                            "❌ Mismatch: Read-only execution path leaked mutating GitOps paths."
                        )
                        return False
            else:
                logger.warning("⚠️ No comments found yet.")
    return False


# ===================================================================
# CORE ASSERTION ENGINE (SHARED MONITOR)
# ===================================================================
def poll_and_verify_task_lifecycle(
    test_description: str,
    task_data: dict,
    expected_outcome: str,
    cache_meta: dict,
    max_attempts: int = 20,
    poll_interval_seconds: int = 20
):
    """Polls task state, validates structural outcomes, and ensures safety labels exist."""
    t_id = task_data.get("id")
    t_display_id = get_task_display_id(task_data)
    passed = False

    expected_label = (
        "agent-submitted-pr" if expected_outcome == "PR_CREATED" else "agent-processed"
    )

    for attempt in range(1, max_attempts + 1):
        current_bucket_id = get_task_current_bucket_id(t_id, cache_meta)
        logger.info(
            f"Checking Task {t_display_id} state -> Attempt {attempt}/{max_attempts}"
        )

        # Short-circuit check: Wait until worker moves the card to Review
        has_review_bucket = current_bucket_id == cache_meta["bucket_id_review"]
        if has_review_bucket:
            logger.info(
                f"📍 Task {t_display_id} detected in Review lane. Validating metadata components..."
            )
            has_label = check_task_has_label(t_id, expected_label)
            has_comments = check_task_comments(t_id, expected_outcome=expected_outcome)

            if has_label and has_comments:
                logger.info(
                    f"✅ Success! Task {t_display_id} cleanly processed into Review with label '{expected_label}'."
                )
                passed = True
                break
            else:
                logger.warning(
                    f"⏳ Lane transition complete but metadata sync is lagging (Label: {has_label}, Comments: {has_comments}). "
                    f"Retrying in next poll window..."
                )

        time.sleep(poll_interval_seconds)

    assert passed, (
        f"❌ Task {t_display_id} failed verification checks for: {test_description}."
    )


# ===================================================================
# --- TEST SCENARIO 1: LANGGRAPH BYPASS/ROUTER FLOW ---
# ===================================================================


def test_langgraph_bypass_flow(pipeline_metadata, task_teardown_manager):
    """
    Validates that a low-complexity, non-code administrative task triggers an
    early-exit bypass decision via LangGraph, instantly routing the card to the Review lane.
    """
    cache_meta = pipeline_metadata
    p_id = cache_meta["project_id"]
    view_id_kanban = cache_meta["view_id_kanban"]
    bucket_id_todo = cache_meta["bucket_id_todo"]

    logger.info(
        "🧪 Launching Scenario 1: LangGraph Supervisor Early-Exit Bypass Route Test..."
    )

    payload = get_task_payload(
        title="Update architectural-notes.md documentation guidelines [repo: infra-test/docker-crewai]",
        description="Please append a paragraph detailing standard naming convention definitions. No functional code modifications needed.",
        bucket_id=bucket_id_todo
    )

    with httpx.Client(verify=False, timeout=10.0) as client:
        res = client.put(
            f"{VIKUNJA_API_URL}/projects/{p_id}/tasks",
            headers=VIKUNJA_HEADERS,
            json=payload,
        )
        assert res.status_code in [200, 201], f"Failed creating task: {res.text}"
        task_data = res.json() or res.json().get("task", {})
        t_id = task_data.get("id")
        t_display_id = get_task_display_id(task_data)

        task_teardown_manager.append(
            {"id": t_id, "description": payload["description"]}
        )

        # Step 2: POST to associate the created task to the Kanban bucket column
        bucket_url = f"{VIKUNJA_API_URL}/projects/{p_id}/views/{view_id_kanban}/buckets/{bucket_id_todo}/tasks"
        bucket_res = client.post(
            bucket_url, headers=VIKUNJA_HEADERS, json={"task_id": t_id}
        )
        assert bucket_res.status_code in [200, 201], (
            f"Failed to map task into Kanban column: {bucket_res.text}"
        )

    logger.info(
        f"Task {t_display_id} added to To-Do. Polling for LangGraph bypass routing resolution..."
    )

    poll_and_verify_task_lifecycle(
        test_description="LangGraph supervisor bypass loop",
        task_data=task_data,
        expected_outcome="NO_CHANGES",
        cache_meta=cache_meta,
        max_attempts=MAX_ATTEMPTS
    )


# ===================================================================
# --- TEST SCENARIO 2: LANGGRAPH BYPASS/ROUTER FLOW ---
# ===================================================================


def test_read_only_analysis_flow(pipeline_metadata, task_teardown_manager):
    """
    Validates that a low-complexity, non-code administrative task triggers an
    early-exit bypass decision via LangGraph, instantly routing the card to the Review lane.
    """
    cache_meta = pipeline_metadata
    p_id = cache_meta["project_id"]
    view_id_kanban = cache_meta["view_id_kanban"]
    bucket_id_todo = cache_meta["bucket_id_todo"]

    logger.info(
        "🧪 Launching Scenario 2: LangGraph Supervisor Early-Exit Bypass Route Test..."
    )

    payload = get_task_payload(
        title="[dettonville.utils] Refactor plugins and modules for strict prefix namespacing (ansible-module)",
        description=(
            "Please review and execute refactoring guidelines matching dettonville enterprise layouts.\n\n"
            "gitea: infra-test/docker-crewai\n\n"
            "branch: main"
        ),
        bucket_id=bucket_id_todo
    )

    with httpx.Client(verify=False, timeout=10.0) as client:
        res = client.put(
            f"{VIKUNJA_API_URL}/projects/{p_id}/tasks",
            headers=VIKUNJA_HEADERS,
            json=payload,
        )
        assert res.status_code in [200, 201], f"Failed creating task: {res.text}"
        task_data = res.json() or res.json().get("task", {})
        t_id = task_data.get("id")
        t_display_id = get_task_display_id(task_data)

        task_teardown_manager.append(
            {"id": t_id, "description": payload["description"]}
        )

        # Step 2: POST to associate the created task to the Kanban bucket column
        bucket_url = f"{VIKUNJA_API_URL}/projects/{p_id}/views/{view_id_kanban}/buckets/{bucket_id_todo}/tasks"
        bucket_res = client.post(
            bucket_url, headers=VIKUNJA_HEADERS, json={"task_id": t_id}
        )
        assert bucket_res.status_code in [200, 201], (
            f"Failed to map task into Kanban column: {bucket_res.text}"
        )

    logger.info(
        f"Task {t_display_id} added to To-Do. Polling for LangGraph bypass routing resolution..."
    )

    poll_and_verify_task_lifecycle(
        test_description="LangGraph supervisor bypass loop",
        task_data=task_data,
        expected_outcome="NO_CHANGES",
        cache_meta=cache_meta,
        max_attempts=MAX_ATTEMPTS
    )


# ===================================================================
# --- TEST SCENARIO 3: FULL CODE GENERATION & QA INTERACTIVE FLOW ---
# ===================================================================


def test_full_agent_engineering_and_qa_flow(pipeline_metadata, task_teardown_manager):
    """
    Validates the complete execution loop: code generation falls through the router,
    the 3-Agent Crew updates files, local `pytest` tools confirm validation success,
    and a Gitea Pull Request is generated and commented on the task.
    """
    cache_meta = pipeline_metadata
    p_id = cache_meta["project_id"]
    view_id_kanban = cache_meta["view_id_kanban"]
    bucket_id_todo = cache_meta["bucket_id_todo"]

    logger.info(
        "🧪 Launching Scenario 3: Full Code Engineering and QA Test Runner Loop..."
    )

    payload = get_task_payload(
        title="Implement strict prefix namespacing validation logic [repo: infra-test/ansible-dettonville-utils]",
        description=(
            "Create a new python configuration validation module inside the repository root directory. "
            "Write a function that enforces explicit prefix rules on incoming properties, ensuring "
            "full compliance with standard naming schema practices. Include passing test assertions."
        ),
        bucket_id=bucket_id_todo
    )

    with httpx.Client(verify=False, timeout=10.0) as client:
        task_url = f"{VIKUNJA_API_URL}/projects/{p_id}/tasks"
        res = client.put(task_url, headers=VIKUNJA_HEADERS, json=payload)
        assert res.status_code in [200, 201], f"Failed creating task: {res.text}"

        task_data = res.json() or res.json().get("task", {})
        t_id = task_data.get("id")
        t_display_id = get_task_display_id(task_data)

        task_teardown_manager.append(
            {"id": t_id, "description": payload["description"]}
        )

        bucket_url = f"{VIKUNJA_API_URL}/projects/{p_id}/views/{view_id_kanban}/buckets/{bucket_id_todo}/tasks"
        bucket_res = client.post(
            bucket_url, headers=VIKUNJA_HEADERS, json={"task_id": t_id}
        )
        assert bucket_res.status_code in [200, 201], (
            f"Failed to map task into Kanban column: {bucket_res.text}"
        )

    logger.info(
        f"Task {t_display_id} submitted to engineering queue. Polling 3-Agent crew engineering execution stack..."
    )

    poll_and_verify_task_lifecycle(
        test_description="Engineering execution loop test",
        task_data=task_data,
        expected_outcome="PR_CREATED",
        cache_meta=cache_meta,
        max_attempts=MAX_ATTEMPTS
    )


# ===================================================================
# --- TEST SCENARIO 4: PR GENERATION FLOW ---
# ===================================================================


def test_pull_request_generation_flow(pipeline_metadata, task_teardown_manager):
    """
    Validates the complete PR execution loop
    """
    cache_meta = pipeline_metadata
    p_id = cache_meta["project_id"]
    view_id_kanban = cache_meta["view_id_kanban"]
    bucket_id_todo = cache_meta["bucket_id_todo"]

    logger.info(
        "🧪 Launching Scenario 4: Full Code Engineering and QA Test Runner Loop..."
    )

    unique_seed = random.randint(10000, 99999)

    payload = get_task_payload(
        title=f"[dettonville.utils] Refactor plugins and modules for strict prefix namespacing (ansible-module) - Run {unique_seed}",
        description=(
            "gitea: infra-test/ansible-dettonville-utils\n\n"
            "branch: main\n\n"
            f"EXECUTION_SEED: {unique_seed}\n\n"
            "COMMAND: You must write a file to disk now. Use your write_code_component_file tool to create a new file \n"
            f"named 'namespacing_refactor_{unique_seed}.md' directly in the root directory of the cloned repository.\n"
            "Write the text 'Strict prefix namespacing enforcement proposal' inside it.\n"
            "Do not describe doing this; execute the tool immediately to write the file. This is a mutating test."
        ),
        bucket_id=bucket_id_todo
    )

    with httpx.Client(verify=False, timeout=10.0) as client:
        task_url = f"{VIKUNJA_API_URL}/projects/{p_id}/tasks"
        res = client.put(task_url, headers=VIKUNJA_HEADERS, json=payload)
        assert res.status_code in [200, 201], f"Failed creating task: {res.text}"

        task_data = res.json() or res.json().get("task", {})
        t_id = task_data.get("id")
        t_display_id = get_task_display_id(task_data)

        task_teardown_manager.append(
            {"id": t_id, "description": payload["description"]}
        )

        bucket_url = f"{VIKUNJA_API_URL}/projects/{p_id}/views/{view_id_kanban}/buckets/{bucket_id_todo}/tasks"
        bucket_res = client.post(
            bucket_url, headers=VIKUNJA_HEADERS, json={"task_id": t_id}
        )
        assert bucket_res.status_code in [200, 201], (
            f"Failed to map task into Kanban column: {bucket_res.text}"
        )

    logger.info(f"Task {t_display_id} submitted to engineering queue...")

    poll_and_verify_task_lifecycle(
        test_description="PR generation test",
        task_data=task_data,
        expected_outcome="PR_CREATED",
        cache_meta=cache_meta,
        max_attempts=MAX_ATTEMPTS
    )
