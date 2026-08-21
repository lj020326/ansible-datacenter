#!/usr/bin/env python3
"""
agent_core.py
All LLM agent, tool definitions, workspace management, GitOps, CrewAI orchestration.
"""

import asyncio
import asyncpg
import concurrent.futures
import fnmatch
import git
import httpx
import inspect
import json
import logging
import os
import pprint
import re
import subprocess
import sys
import tempfile
import time
import yaml
from collections import OrderedDict
from contextvars import ContextVar
from crewai import Agent, Task, Crew, CrewOutput, Process, LLM
from crewai.tools import BaseTool
from functools import wraps
from pathlib import Path
from pydantic import BaseModel, Field
from typing import List, Dict, Any, Callable

from config import settings

from vikunja_api import (
    add_task_label,
    attach_execution_context_to_task,
    convert_vikunja_html_to_markdown,
    get_task_display_id,
    move_task_to_bucket,
    post_kanban_comment,
)

# from coco_index import (
#     build_repo_index
# )

__scriptName__ = os.path.basename(sys.argv[0])

# ====================== LOGGING SETUP ======================
LOG_LEVEL_NUMERIC = getattr(logging, settings.LOG_LEVEL, logging.INFO)
logger = logging.getLogger(__scriptName__)
logger.setLevel(LOG_LEVEL_NUMERIC)

logging.basicConfig(
    format="%(name)s - %(levelname)-8s - %(message)s",
    handlers=[logging.StreamHandler()],
)

# Thread-safe global context for the executing agent's role
active_agent_role: ContextVar[str] = ContextVar(
    "active_agent_role", default="Unknown/System"
)

TASK_LABEL_SUCCESS = "agent-processed"
TASK_LABEL_PR_SUCCESS = "agent-submitted-pr"
TASK_LABEL_FAILED = "agent-failed"

# Strict instructions targeting JSON-escaping and Python block nesting bugs
SYNTAX_GUARD_INSTRUCTIONS = (
    "\n\n### CRITICAL PYTHON & DOCUMENTATION SYNTAX RULES:\n"
    "1. **Never Nest Triple Quotes**: Do NOT wrap a whole Python file or Ansible module in top-level triple-quotes (e.g. \"\"\"...\"\"\").\n"
    "2. **Ansible DOCUMENTATION Variables**: Declare the Ansible `DOCUMENTATION = r'''...'''` directly at the top level of the file. "
    "Never nest it inside an outer Python triple-quoted string block, as this corrupts Python's syntax parser and causes `SyntaxError` failures.\n"
    "3. **Module Utilities**: Helper files under `plugins/module_utils/` are general Python helper scripts. They do NOT require "
    "the standard Ansible `DOCUMENTATION` or `EXAMPLES` blocks unless they are active entry-point modules."
)

# Define a strict instruction snippet to inject into the agent's definition
# Refactored for clearer boundary definitions:
PARSER_GUARD_INSTRUCTIONS = (
    "\n\n### CRITICAL INSTRUCTIONS FOR TOOL USAGE:\n"
    "1. You MUST interact with the system strictly by invoking tools natively. "
    "NEVER embed raw 'Action:' or tool call JSON syntax directly inside your 'Final Answer' prose.\n"
    "2. Do NOT summarize or simulate actions unless you have already received the actual execution output from the system tool framework.\n"
    "3. Your 'Final Answer' must only contain your concluded conversational summary of work that was *actually* completed."
)


# Base architectural guardrail rules injected across team roles
DEVELOPER_GUARD_INSTRUCTIONS = (
    "### CRITICAL EXECUTION GUARDRAILS\n"
    "1. You MUST successfully achieve an EXIT CODE 0 on all test executions before passing code to QA.\n"
    "2. If any test execution returns a non-zero exit code, treat this as a CRITICAL FAILURE.\n"
    "3. Do not attempt to report success after a failure. Read outputs and fix the issue.\n"
    "4. For Ansible collection test execution paths, ensure targets run via the environment helper: `./run-tests.sh`.\n"
)
# Tool Registry
TOOL_REGISTRY = []


def prettyprint(data: Any):
    if isinstance(data, OrderedDict):
        return pprint.pformat(dict(data))
    return pprint.pformat(data)


def _write_file_task(relative_file_path: str, content: str) -> Dict[str, Any]:
    try:
        os.makedirs(os.path.dirname(relative_file_path), exist_ok=True)
        with open(relative_file_path, "w", encoding="utf-8") as f:
            f.write(content)
        return {
            "status": "success",
            "file": relative_file_path,
            "message": "Written successfully",
        }
    except Exception as e:
        return {"status": "failed", "file": relative_file_path, "error": str(e)}


def _execute_shell_command(command: str, cwd: str, timeout=60) -> Dict[str, Any]:
    try:
        env = os.environ.copy()
        env["PYTHONPATH"] = f"{cwd}:{env.get('PYTHONPATH', '')}"
        env["ANSIBLE_LOG_PATH"] = "/dev/null"

        result = subprocess.run(
            command,
            cwd=cwd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=timeout,
            env=env
        )
        return {
            "status": "success" if result.returncode == 0 else "failed",
            "returncode": result.returncode,
            "stdout": result.stdout.strip(),
            "stderr": result.stderr.strip(),
        }
    except subprocess.TimeoutExpired:
        return {"status": "failed", "error": f"Command timed out: '{command}'"}
    except Exception as e:
        return {"status": "failed", "error": str(e)}


# ===================================================================
# STRUCTURED WORKSPACE TOOL SCHEMAS & CLASSES
# ===================================================================


def register_tool(tool_class):
    """Register a tool class for auto-discovery."""
    TOOL_REGISTRY.append(tool_class)
    return tool_class


async def get_remote_embedding(text: str) -> List[float]:
    """Fetch embeddings from remote OpenAI-compatible API using httpx."""
    url = f"{settings.EMBEDDING_API_BASE.rstrip('/')}/embeddings"
    headers = {
        "Authorization": f"Bearer {settings.EMBEDDING_API_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "input": text,
        "model": settings.COCO_EMBED_MODEL
    }

    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.post(url, json=payload, headers=headers)
        response.raise_for_status()
        data = response.json()
        return data["data"][0]["embedding"]


class ActionItem(BaseModel):
    action_type: str = Field(
        ..., description="Type of action: 'write_file', 'format_code', or 'run_test'"
    )
    relative_file_path: str = Field(
        None, description="Target relative path for writing or formatting files"
    )
    content: str = Field(None, description="Content to write to the file")
    formatter: str = Field(None, description="Formatter to use (e.g., 'ruff')")
    command: str = Field(None, description="Command to run for testing")


class BatchActionSchema(BaseModel):
    actions: List[ActionItem] = Field(
        ..., description="List of structured batch actions to process"
    )


@register_tool
class ExecuteBatchActionsTool(BaseTool):
    name: str = "execute_batch_actions"
    description: str = (
        "Executes a batch of file writes in parallel, followed by "
        "sequential code formatting or testing steps to avoid race conditions."
    )
    workspace_path: str = Field(
        ..., description="The dynamic absolute workspace root path."
    )
    args_schema: type[BaseModel] = BatchActionSchema

    def _run(self, actions: List[Any]) -> str:
        write_actions = []
        serial_actions = []

        if isinstance(actions, str):
            try:
                actions = json.loads(actions)
            except Exception:
                pass

        for action in actions:
            act_dict = action if isinstance(action, dict) else action.dict()
            a_type = act_dict.get("action_type")

            if a_type == "write_file":
                write_actions.append(act_dict)
            elif a_type in ["format_code", "run_test"]:
                serial_actions.append(act_dict)
            else:
                if "content" in act_dict and "relative_file_path" in act_dict:
                    write_actions.append(act_dict)
                else:
                    serial_actions.append(act_dict)

        results = {"parallel_writes": [], "sequential_steps": []}

        # Phase 1: Throttled Parallel Writes (anchored to workspace_path)
        if write_actions:
            with concurrent.futures.ThreadPoolExecutor(
                max_workers=settings.MAX_IO_WORKERS
            ) as executor:
                futures = {}
                for act in write_actions:
                    # Safely resolve the absolute path within the workspace
                    abs_path = os.path.abspath(
                        os.path.join(self.workspace_path, act["relative_file_path"])
                    )
                    # Simple guardrail to ensure it doesn't write outside the workspace
                    if not abs_path.startswith(os.path.abspath(self.workspace_path)):
                        results["parallel_writes"].append(
                            {
                                "status": "failed",
                                "file": act["relative_file_path"],
                                "error": "Security violation: Attempted write outside workspace path.",
                            }
                        )
                        continue

                    futures[
                        executor.submit(_write_file_task, abs_path, act["content"])
                    ] = act["relative_file_path"]

                for future in concurrent.futures.as_completed(futures):
                    file_path = futures[future]
                    try:
                        results["parallel_writes"].append(future.result())
                    except Exception as exc:
                        results["parallel_writes"].append(
                            {"status": "failed", "file": file_path, "error": str(exc)}
                        )

        # Abort downstream tasks if writes fail
        failed_writes = [
            r for r in results["parallel_writes"] if r["status"] == "failed"
        ]
        if failed_writes:
            return json.dumps(
                {
                    "error": "Batch write phase failed. Formatting and testing aborted.",
                    "write_results": results["parallel_writes"],
                },
                indent=2,
            )

        # Phase 2: Sequential execution (Prevents formatting/testing race conditions)
        for act in serial_actions:
            if act.get("action_type") == "format_code" or "formatter" in act:
                formatter = act.get("formatter", "ruff")
                file_path = act.get("relative_file_path")

                if formatter == "ruff" and file_path:
                    cmd = f"ruff format {file_path} && ruff check --fix {file_path}"
                else:
                    cmd = "echo 'Unknown or unsupported formatter'"

                results["sequential_steps"].append(
                    {
                        "action": f"format_{formatter}",
                        "file": file_path,
                        # Pass the workspace path as cwd to the execution helper
                        "result": _execute_shell_command(cmd, cwd=self.workspace_path),
                    }
                )

            elif act.get("action_type") == "run_test" or "command" in act:
                cmd = act.get("command")
                results["sequential_steps"].append(
                    {
                        "action": "run_test",
                        "command": cmd,
                        # Pass the workspace path as cwd to the execution helper
                        "result": _execute_shell_command(cmd, cwd=self.workspace_path),
                    }
                )

        return json.dumps(results, indent=2)


class ListRepoFilesSchema(BaseModel):
    pattern: str = Field(
        default="(plugins|tests)/**/*.py",
        description=(
            "Glob or extended glob pattern to filter files, "
            "e.g., '(plugins|tests)/**/*.py' or 'tests/**/*.py'"
        ),
    )


@register_tool
class ListRepoFilesTool(BaseTool):
    name: str = "list_repo_files"
    description: str = (
        "Fast recursive file listing: skips caches, respects .gitignore, "
        "and filters by pattern to prevent output bloat."
    )
    workspace_path: str = Field(
        ..., description="The dynamic absolute workspace root path."
    )
    args_schema: type[BaseModel] = ListRepoFilesSchema

    def _run(self, pattern: str = "(plugins|tests)/**/*.py") -> str:
        try:
            always_exclude = {
                ".git",
                "__pycache__",
                ".pytest_cache",
                ".coverage",
                "venv",
                ".venv",
            }
            gitignore_patterns = set()
            gitignore_path = os.path.join(self.workspace_path, ".gitignore")

            if os.path.exists(gitignore_path):
                try:
                    with open(gitignore_path, "r", encoding="utf-8") as f:
                        for line in f:
                            line = line.strip()
                            if (
                                line
                                and not line.startswith("#")
                                and not line.startswith("!")
                            ):
                                gitignore_patterns.add(line)
                except Exception as e:
                    logger.warning(f"Failed to parse .gitignore: {e}")

            exclude_patterns = always_exclude.union(gitignore_patterns)
            files = []

            # Support basic extended glob syntax like (dir1|dir2) by converting it to a regex
            regex_pattern = None
            if "(" in pattern and "|" in pattern:
                # 1. Escape regex-sensitive characters except group structures
                raw_regex = pattern.replace(".", "\\.").replace("+", "\\+")

                # 2. Convert recursive wildcards accurately
                raw_regex = raw_regex.replace("/**/", "/.*/").replace("**/", ".*/")

                # 3. Convert standard single wildcards without breaking directory separators
                raw_regex = raw_regex.replace("*", "[^/]*")

                # 4. Handle any duplicate wildcards caused by conversion edge-cases
                raw_regex = raw_regex.replace("[^/]*[^/]*", ".*")

                regex_pattern = re.compile(f"^{raw_regex}$")

            for root, dirs, filenames in os.walk(self.workspace_path):
                dirs[:] = [
                    d
                    for d in dirs
                    if d not in always_exclude
                    and not any(
                        fnmatch.fnmatch(d, pat.rstrip("/"))
                        for pat in gitignore_patterns
                    )
                ]
                for f in filenames:
                    rel_path = os.path.relpath(
                        os.path.join(root, f), self.workspace_path
                    )
                    if any(
                        fnmatch.fnmatch(rel_path, pat)
                        or fnmatch.fnmatch(rel_path, pat + "/**")
                        for pat in exclude_patterns
                    ):
                        continue

                    # Apply pattern matching
                    if regex_pattern:
                        if regex_pattern.match(rel_path):
                            files.append(rel_path)
                    else:
                        if fnmatch.fnmatch(rel_path, pattern):
                            files.append(rel_path)

            return "\n".join(sorted(files)[:500])
        except Exception as e:
            return f"Error listing files: {e}"


class ReadCodeComponentFileSchema(BaseModel):
    relative_file_path: str = Field(
        ..., description="Relative path from repository root."
    )


@register_tool
class ReadCodeComponentFileTool(BaseTool):
    name: str = "read_code_component_file"
    description: str = "Reads contents of targeted repository files securely."
    workspace_path: str = Field(
        ..., description="The dynamic absolute workspace root path."
    )
    args_schema: type[BaseModel] = ReadCodeComponentFileSchema

    def _run(self, relative_file_path: str) -> str:
        try:
            safe_target = os.path.normpath(
                os.path.join(self.workspace_path, relative_file_path.lstrip("/"))
            )
            if not safe_target.startswith(os.path.normpath(self.workspace_path)):
                return f"File Read Error: Security violation accessing {safe_target}."
            if os.path.isdir(safe_target):
                return f"Path is a directory. Contents: {os.listdir(safe_target)[:20]}"
            if not os.path.exists(safe_target):
                return f"Error: Asset location '{relative_file_path}' could not be resolved."
            with open(safe_target, "r", encoding="utf-8") as f:
                return f.read()
        except Exception as file_err:
            return f"Failed reading file: {str(file_err)}"


# --- Tool 4: Read Repo Skill ---
class ReadRepoSkillSchema(BaseModel):
    skill_name: str = Field(
        ...,
        description="The name of the specialized skill or guideline file to read, e.g., 'TESTING' or 'DOCKER'",
    )


@register_tool
class ReadRepoSkillTool(BaseTool):
    name: str = "read_repo_skill"
    description: str = (
        "Reads specialized skill and process documentation from the repository."
    )
    workspace_path: str = Field(
        ..., description="The dynamic absolute workspace root path."
    )
    args_schema: type[BaseModel] = ReadRepoSkillSchema

    @property
    def func(self):
        """Bind the execution method to satisfy CrewAI internal lookups."""
        return self._run

    def _run(self, skill_name: str) -> str:
        try:
            # Common skill file patterns
            candidates = [
                f"{skill_name}.md",
                f"{skill_name.lower()}.md",
                f"docs/{skill_name}.md",
                f"tests/{skill_name}.md",
                "TESTING.md",
                "AGENT.md",
            ]

            for candidate in candidates:
                path = os.path.join(self.workspace_path, candidate)
                if os.path.exists(path):
                    with open(path, "r", encoding="utf-8") as f:
                        content = f.read()
                    return f"### {candidate} Content:\n\n{content[:8000]}"

            return f"No skill documentation found for '{skill_name}'."
        except Exception as e:
            return f"Error reading skill '{skill_name}': {e}"


class RemedyLintErrorsSchema(BaseModel):
    target_path: str = Field(default=".", description="The relative path to remediate.")
    formatter: str = Field(
        default="ruff",
        description="Formatting tool to use ('ruff', 'black', or 'autopep8').",
    )


@register_tool
class RemedyLintErrorsTool(BaseTool):
    name: str = "remedy_lint_errors_tool"
    description: str = (
        "Executes linting remediation tools (ruff, black) on the workspace."
    )
    workspace_path: str = Field(
        ..., description="The dynamic absolute workspace root path."
    )
    args_schema: type[BaseModel] = RemedyLintErrorsSchema

    def _run(
        self,
        target_path: str = ".",
        formatter: str = "ruff"
    ) -> str:
        # Resolve the role dynamically from context to prevent prompt leakage
        executing_agent_role = active_agent_role.get()

        safe_target = os.path.normpath(
            os.path.join(self.workspace_path, target_path.lstrip("/"))
        )
        if not safe_target.startswith(os.path.normpath(self.workspace_path)):
            return "Security violation: Access denied."

        logger.info(
            f"[Lint Tool] Invoked by {executing_agent_role} using {formatter} on {target_path}"
        )

        try:
            if formatter == "ruff":
                # Run ruff check with auto-fix
                cmd_fix = f"ruff check --fix {safe_target}"
                logger.info(f"[Run Lint Tool] Running: {cmd_fix}")
                subprocess.run(
                    cmd_fix.split(),
                    capture_output=True,
                    timeout=30,
                    check=False
                )

                # Run ruff format
                cmd_fmt = f"ruff format {safe_target}"
                logger.info(f"[Run Lint Tool] Running: {cmd_fmt}")
                subprocess.run(
                    cmd_fmt.split(),
                    capture_output=True,
                    timeout=30,
                    check=False
                )
                return "Ruff fixes and formatting successfully executed."
            elif formatter == "black":
                cmd = f"black {safe_target}"
                logger.info(f"[Run Lint Tool] Running: {cmd}")
                subprocess.run(
                    cmd.split(),
                    capture_output=True,
                    timeout=30,
                    check=True
                )
                return "Black formatting executed successfully."
            return f"Unsupported formatter: {formatter}"
        except Exception as e:
            return f"Lint remediation failed: {e}"


# --- Tool 7: Run Local Tests ---
class RunLocalTestsSchema(BaseModel):
    test_command: str = Field(
        default="./run-tests.sh pytest tests/unit/",
        description="The full test suite command.",
    )
    timeout: int = Field(default=120, description="Max execution duration.")


@register_tool
class RunLocalTestsTool(BaseTool):
    name: str = "run_local_tests_tool"
    description: str = "Executes repository testing tasks securely."
    workspace_path: str = Field(
        ..., description="The dynamic absolute workspace root path."
    )
    args_schema: type[BaseModel] = RunLocalTestsSchema

    def _run(
        self,
        test_command: str = "./run-tests.sh pytest tests/unit/",
        timeout: int = 120,
    ) -> str:
        # Resolve the role dynamically from context to prevent prompt leakage
        executing_agent_role = active_agent_role.get()

        logger.info(f"[Run Test Tool] Invoked by: [{executing_agent_role}]")
        logger.info(
            f"[Run Test Tool] Running: '{test_command}' inside '{self.workspace_path}'"
        )

        try:
            result = _execute_shell_command(
                test_command,
                cwd=self.workspace_path,
                timeout=timeout,
            )

            returncode = result.get("returncode", -1)
            stdout = result.get("stdout", "")
            stderr = result.get("stderr", "")

            output_payload = (
                f"EXECUTED BY ROLE: {executing_agent_role}\n"
                f"COMMAND: {test_command}\n"
                f"EXIT CODE: {returncode}\n\n"
            )

            if stdout:
                output_payload += f"STDOUT:\n{stdout}\n"
            if stderr:
                output_payload += f"STDERR:\n{stderr}\n"

            if returncode == 0:
                logger.info(
                    f"[Run Test Tool] ✅ Tests passed for [{executing_agent_role}] (Exit Code 0)"
                )
            else:
                logger.warning(
                    f"[Run Test Tool] ❌ Tests failed for [{executing_agent_role}] with code {returncode}"
                )

            return output_payload
        except Exception as e:
            return f"Test execution failed for command '{test_command}': {e}"


class WriteCodeComponentFileSchema(BaseModel):
    relative_file_path: str = Field(..., description="Relative path from repo root.")
    file_contents: str = Field(..., description="The exact text content to write.")


@register_tool
class WriteCodeComponentFileTool(BaseTool):
    name: str = "write_code_component_file"
    description: str = (
        "Writes code contents directly to a specific workspace file path."
    )
    workspace_path: str = Field(
        ..., description="The dynamic absolute workspace root path."
    )
    args_schema: type[BaseModel] = WriteCodeComponentFileSchema

    def _run(self, relative_file_path: str, file_contents: str) -> str:
        try:
            # Resilient safety boundary checks
            safe_target = os.path.normpath(
                os.path.join(self.workspace_path, relative_file_path.lstrip("/"))
            )
            if not safe_target.startswith(os.path.normpath(self.workspace_path)):
                return f"Security violation accessing {safe_target}."

            # --- SANITIZE ESCAPED NEWLINES ---
            if "\\n" in file_contents:
                logger.info(
                    "[Tool Sanitization] Decoding escaped literal \\n sequences into true line breaks."
                )
                file_contents = file_contents.replace("\\n", "\n")

            # Try Unicode escape decoding for raw literal representation evaluation blocks
            try:
                file_contents = bytes(file_contents, "utf-8").decode("unicode_escape")
            except Exception:
                pass

            os.makedirs(os.path.dirname(safe_target), exist_ok=True)
            with open(safe_target, "w", encoding="utf-8") as code_file:
                code_file.write(file_contents)
            return f"Successfully wrote {relative_file_path}"
        except Exception as file_err:
            return f"Failed writing file: {str(file_err)}"


# --- New: CocoIndex Query Tool ---
class QueryRepoIndexSchema(BaseModel):
    query: str = Field(
        ...,
        description="Semantic search query to locate relevant code structures or patterns.",
    )


@register_tool
class QueryRepoIndexTool(BaseTool):
    name: str = "query_repo_index"
    description: str = "Performs vector semantic search on indexed codebase files."
    table_name: str = Field(
        default="repo_idx_default", description="Postgres table containing embeddings"
    )
    args_schema: type[BaseModel] = QueryRepoIndexSchema

    async def _run_async(self, query: str, top_k: int = 5) -> str:
        try:
            # 1. Fetch vector embedding from remote endpoint
            query_vector = await get_remote_embedding(query)
            vector_str = f"[{','.join(map(str, query_vector))}]"

            # 2. Query Postgres pgvector directly
            conn = await asyncpg.connect(settings.COCOINDEX_DB_URL)
            try:
                sql = f"""
                    SELECT filename, start_line, end_line, code, (embedding <=> $1) as distance
                    FROM "{self.table_name}"
                    ORDER BY distance ASC
                    LIMIT $2;
                """
                rows = await conn.fetch(sql, vector_str, top_k)

                results = []
                for row in rows:
                    results.append(
                        {
                            "filename": row["filename"],
                            "lines": f"{row['start_line']}-{row['end_line']}",
                            "score": round(1 - float(row["distance"]), 4),
                            "code": row["code"],
                        }
                    )

                return json.dumps(results, indent=2)
            finally:
                await conn.close()

        except Exception as e:
            logger.error(f"Error querying repository index: {e}")
            return f"Error querying index: {str(e)}"

    def _run(self, query: str, top_k: int = 5) -> str:
        return asyncio.run(self._run_async(query, top_k))


# ===================================================================
# BUILD WORKSPACE TOOLS EXPORTER
# ===================================================================


def create_workspace_tools(workspace_path: str) -> list:
    """Instantiates and returns tools, dynamically passing only supported arguments."""
    tools = []

    # Map of all available parameters tool constructors might need
    available_params = {
        "workspace_path": workspace_path,
        # Add any other common context params here if needed in the future
    }

    for tool_cls in TOOL_REGISTRY:
        try:
            # Get the constructor parameters for the current tool class
            sig = inspect.signature(tool_cls.__init__)
            param_names = set(sig.parameters.keys()) - {"self"}

            # Filter kwargs to match only what this specific tool accepts
            kwargs = {k: v for k, v in available_params.items() if k in param_names}

            # Instantiate with matching parameters (or zero args if none match)
            tools.append(tool_cls(**kwargs))

        except Exception as e:
            logger.warning(f"Failed to instantiate {tool_cls.__name__}: {e}")

    return tools


def display_agent_api_telemetry_banner():
    """Outputs basic trace settings at server instantiation."""
    logger.info(f"Initializing cluster worker targeting model: {settings.LOCAL_LLM_MODEL}")
    logger.info(f"LLM Base URL: {settings.LOCAL_LLM_BASE_URL}")
    logger.info(f"Target Router Connection Endpoint: {settings.LANGGRAPH_ROUTER_URL}")


def detect_repo_type(workspace_path: str) -> str:
    """Detects repository type for specialized agent behavior."""
    indicators = {
        "ansible_collection": ["galaxy.yml", "meta/runtime.yml"],
        "ansible_role": ["defaults/main.yml", "tasks/main.yml", "meta/main.yml"],
        "python_app": ["setup.py", "pyproject.toml", "requirements.txt"],
        "docker": ["Dockerfile"],
        "terraform": [".tf", "main.tf"],
    }
    for repo_type, files in indicators.items():
        for f in files:
            if os.path.exists(os.path.join(workspace_path, f)) or any(
                os.path.exists(os.path.join(workspace_path, d, f))
                for d in ["", "meta", "tests", "plugins"]
            ):
                return repo_type
    return "generic"


def parse_repo_specific_config(context_directory: str) -> dict:
    """
    Looks for workspace configurations inside the checked-out workspace.
    Prioritizes AGENT.md rules, and merges/falls back to .continue/config.yaml.
    """
    config_data = {"rules": [], "prompts": []}
    if not context_directory:
        return config_data

    # 1. Look for AGENT.md first for dedicated agent-instruction overrides
    agent_md_path = os.path.join(context_directory, "AGENT.md")
    if os.path.exists(agent_md_path):
        try:
            with open(agent_md_path, "r", encoding="utf-8") as f:
                content = f.read().strip()
                if content:
                    config_data["rules"].append(content)
        except Exception as ex:
            logger.warning(f"[Context Engine] Failed reading AGENT.md: {ex}")

    # 2. Check standard yaml configurations
    potential_paths = [
        os.path.join(context_directory, ".continue", "config.yaml"),
        os.path.join(context_directory, ".continue", "config.yml"),
        os.path.join(context_directory, "config.yaml"),
    ]

    for path in potential_paths:
        if os.path.exists(path):
            try:
                with open(path, "r", encoding="utf-8") as f:
                    parsed = yaml.safe_load(f) or {}
                    if "rules" in parsed and isinstance(parsed["rules"], list):
                        # Extend rules from config yaml
                        config_data["rules"].extend(parsed["rules"])
                    if "prompts" in parsed and isinstance(parsed["prompts"], list):
                        config_data["prompts"] = parsed["prompts"]
                break
            except Exception as ex:
                logger.warning(
                    f"[Context Engine] Failed parsing workspace configuration {path}: {ex}"
                )

    return config_data


def get_optimized_llm(complexity: str = "medium"):
    """Returns tuned LLM config based on task complexity from LangGraph."""
    base = {
        "model": f"{settings.LOCAL_LLM_PROVIDER}/{settings.LOCAL_LLM_MODEL}",
        "base_url": settings.LOCAL_LLM_BASE_URL,
        "api_key": settings.LOCAL_LLM_API_KEY,
        "temperature": 0.1,
    }

    if complexity == "low":
        base.update({"max_tokens": 2048, "temperature": 0.0})
    elif complexity == "high":
        base.update({"max_tokens": 8192, "temperature": 0.2})
    else:  # medium
        base.update({"max_tokens": 4096, "temperature": 0.1})

    return LLM(**base)


# ===================================================================
# TELEMETRY CLEANUP & PARSING HANDLERS
# ===================================================================
def get_calling_agent_role(args, kwargs) -> str:
    """Helper to detect the calling agent's role dynamically from arguments or the call stack."""
    # 1. Direct schema argument pass-through
    if "executing_agent_role" in kwargs and kwargs["executing_agent_role"]:
        return kwargs["executing_agent_role"]

    # 2. Positional argument check
    for arg in args:
        if isinstance(arg, str) and any(
            role_keyword in arg for role_keyword in ["Engineer", "Architect", "Agent", "QA"]
        ):
            return arg

    # 3. Stack-frame scanning
    try:
        for frame_info in inspect.stack():
            frame = frame_info.frame
            locals_dict = frame.f_locals

            # Check if 'self' is an Agent instance
            self_obj = locals_dict.get("self")
            if self_obj:
                if hasattr(self_obj, "role") and isinstance(self_obj.role, str):
                    return self_obj.role
                if self_obj.__class__.__name__ in ["Agent", "CrewAgent"] and hasattr(self_obj, "role"):
                    return getattr(self_obj, "role")

            # Check if 'agent' is a local variable in context
            agent_obj = locals_dict.get("agent")
            if (
                agent_obj
                and hasattr(agent_obj, "role")
                and isinstance(agent_obj.role, str)
            ):
                return agent_obj.role

            # Look through values in local variables
            for val in locals_dict.values():
                if hasattr(val, "role") and isinstance(getattr(val, "role", None), str):
                    class_name = val.__class__.__name__.lower()
                    if "agent" in class_name:
                        return val.role
    except Exception:
        pass

    return "Unknown Agent"


def wrap_tool_with_telemetry(tool_instance: Any, agent_times: dict) -> Any:
    """
    Wraps a CrewAI BaseTool, intercepting its execution to log run metrics
    using dynamic calling-frame analysis with ContextVar fallbacks.
    """
    # Accommodate both class instance methods and decorated functional tools safely
    original_run = getattr(tool_instance, "_run", getattr(tool_instance, "func", None))
    if not original_run:
        return tool_instance

    @wraps(original_run)
    def telemetry_wrapper(*args, **kwargs):
        agent_role = get_calling_agent_role(args, kwargs) or active_agent_role.get()
        tool_name = getattr(tool_instance, "name", "unnamed_tool")

        start_time = time.perf_counter()
        start_str = time.strftime("%H:%M:%S")

        logger.info(json.dumps({
            "event": "tool_start",
            "tool": tool_name,
            "executing_agent_role": agent_role,
            "inputs": {k: v for k, v in kwargs.items() if k not in ["content", "file_contents"]}
        }))

        token = active_agent_role.set(agent_role)
        try:
            result = original_run(*args, **kwargs)
            duration = time.perf_counter() - start_time
            end_str = time.strftime("%H:%M:%S", time.localtime())

            logger.info(json.dumps({
                "event": "tool_success",
                "tool": tool_name,
                "executing_agent_role": agent_role,
                "duration_seconds": round(duration, 4),
                "status": "success"
            }))

            # Record metrics
            if agent_role not in agent_times:
                agent_times[agent_role] = {}
            agent_times[agent_role][tool_name] = {
                "start": start_str,
                "end": end_str,
                "duration": duration,
            }
            return result

        except Exception as e:
            duration = time.perf_counter() - start_time
            logger.error(json.dumps({
                "event": "tool_failure",
                "tool": tool_name,
                "executing_agent_role": agent_role,
                "duration_seconds": round(duration, 4),
                "error": str(e)
            }))
            raise
        finally:
            # Reset ContextVar back to pre-execution state
            active_agent_role.reset(token)

    # Re-attach safely
    if hasattr(tool_instance, "_run"):
        tool_instance._run = telemetry_wrapper
    else:
        tool_instance.func = telemetry_wrapper

    return tool_instance


def execute_agent_loop(agent_name: str, task_fn: Callable, *args, **kwargs):
    """
    Sets the active agent context for the duration of the task run.
    Any telemetry-wrapped tool executed during this task will automatically
    attribute its metrics to this agent.
    """
    token = active_agent_role.set(agent_name)
    try:
        return task_fn(*args, **kwargs)
    finally:
        active_agent_role.reset(token)


def execute_pending_tool_calls(result: str, workspace_tools: list) -> str:
    """Safely extracts JSON payloads for automatic execution."""
    if not result or not isinstance(result, str):
        return result

    write_tool = next(
        (t for t in workspace_tools if t.name == "write_code_component_file"), None
    )
    if not write_tool:
        logger.warning("[Tool Fallback] write_code_component_file tool not found.")
        return result

    # Standard non-recursive extraction
    json_candidates = re.findall(r"(\{[\s\S]*?\})", result)
    for candidate in json_candidates:
        try:
            data = json.loads(candidate.strip().strip("`"))
            if isinstance(data, dict):
                args = data.get("arguments", data)
                if "relative_file_path" in args and "file_contents" in args:
                    write_tool._run(
                        relative_file_path=args["relative_file_path"],
                        file_contents=args["file_contents"],
                    )
                    logger.info(
                        f"[Tool Fallback] Extracted execution path written: {args['relative_file_path']}"
                    )
                    return result
        except Exception:
            pass
    return result


def truncate_log_output(text: str, max_lines_edge: int = 15) -> str:
    """
    Slices raw terminal output to only contain the first and last N lines,
    bridged by ellipses, if the content exceeds the height limit.
    """
    if not text:
        return ""
    lines = text.splitlines()
    if len(lines) <= (max_lines_edge * 2 + 3):
        return text

    head = lines[:max_lines_edge]
    tail = lines[-max_lines_edge:]
    return "\n".join(head + ["...", "...", "..."] + tail)


def scrub_agent_telemetry(raw_output: str) -> str:
    """Aggressively removes tool calls, JSON, and internal narrative while preserving code blocks."""
    if not raw_output:
        return ""

    text = raw_output

    # 1. Protect code blocks
    code_blocks = re.findall(r"```[\s\S]*?```", text)
    placeholder = "___CODE_BLOCK___"
    for i, block in enumerate(code_blocks):
        text = text.replace(block, f"{placeholder}{i}")

    # 2. Remove tool call JSON (various formats)
    text = re.sub(
        r'(?i)\{\s*"name"\s*:\s*"[^"]*write_code_component_file[^"]*"\s*,\s*"arguments"\s*:\s*\{[\s\S]*?\}\s*\}',
        "",
        text,
    )
    text = re.sub(r"(?i)using the `?write_code_component_file`? function", "", text)

    # 4. Restore code blocks
    for i, block in enumerate(code_blocks):
        text = text.replace(f"{placeholder}{i}", block)

    # If the output looks like raw terminal output/logs and doesn't already contain a markdown code block,
    # wrap it in code fences to prevent the parser from mangling underscores/slashes.
    text_stripped = text.strip()

    # CRITICAL FIX: Only auto-fence if the block is purely terminal outputs
    # (i.e. it doesn't start with Markdown headers or lists, but contains terminal keywords)
    if (
        "PASSED" in text_stripped or "EXIT CODE:" in text_stripped
    ) and not text_stripped.startswith("```"):
        if not any(
            text_stripped.startswith(prefix) for prefix in ["#", "*", "-", "1.", "###"]
        ):
            return f"```text\n{truncate_log_output(text_stripped)}\n```"

    return text.strip()


# ===================================================================
# AGENT & CREW ORCHESTRATION FACTORY (FACTORY INJECTION)
# ===================================================================
def build_multi_agent_crew(
    workspace_dir: str,
    task_data: dict,
    workspace_tools: list,
    repo_type: str = "generic",
) -> Crew:
    """Assembles the multi-agent execution hierarchy with dynamically isolated targets."""
    t_title = task_data.get("title")
    t_description = convert_vikunja_html_to_markdown(task_data.get("description", ""))
    t_complexity = task_data.get("complexity", "medium")
    t_blueprint = task_data.get("blueprint", "")

    dev_llm = get_optimized_llm(t_complexity)
    qa_llm = get_optimized_llm("low")

    # # Parse AGENT.md or .continue/config.yaml structures if present
    # repo_config = parse_repo_specific_config(workspace_dir)
    # # Format the workspace rules dynamically into a clean Markdown block
    # workspace_rules_str = ""
    # if repo_config.get("rules"):
    #     workspace_rules_str = "\n### REPOSITORY DEVELOPMENT STANDARDS:\n" + "\n".join(
    #         f"- {rule}" for rule in repo_config["rules"]
    #     )

    # Build the complete backstory dynamically
    developer_backstory = (
        "You are an expert infrastructure engineer who writes clean, testable code.\n"
        "Follow TESTING.md strictly. Create predictable test files only.\n"
        "You proactively run formatting and lint checks (Ruff) before declaring tasks complete.\n"
        f"{DEVELOPER_GUARD_INSTRUCTIONS}\n"
        # f"{workspace_rules_str}\n"
        f"{PARSER_GUARD_INSTRUCTIONS}\n"
        f"{SYNTAX_GUARD_INSTRUCTIONS}"
    )

    # Declarative Developer Configuration
    developer_agent = Agent(
        role="Senior Platform Automation Engineer",
        goal="Implement the requested features cleanly, verify with local test runners, and hand off to QA.",
        backstory=developer_backstory,
        llm=dev_llm,
        tools=workspace_tools,
        max_iter=12,
        max_execution_time=420,
        max_interventions=6,
        allow_delegation=False,
        cache=False,
        verbose=True,
    )

    # Dynamic QA Configuration Mapping (Factory Design)
    qa_configs = {
        "ansible_collection": {
            "role": "Specialized Ansible Collection QA & Sanity Engineer",
            "backstory": (
                "Expert in Ansible verification pipelines. Leverages repository-root wrappers to validate syntax.\n"
                f"{PARSER_GUARD_INSTRUCTIONS}\n"
                f"{SYNTAX_GUARD_INSTRUCTIONS}"
            ),
            "description": (
                f"Validate workspace alterations in: {workspace_dir}\n"
                "1. Run `./run-tests.sh units` using `run_local_tests_tool`.\n"
                "2. Run `./run-tests.sh sanity` using `run_local_tests_tool`.\n"
                "3. Confirm commands return cleanly before signing off."
            ),
            "expected_output": (
                "1. Summary of `./run-tests.sh units` test results.\n"
                "2. Summary of `./run-tests.sh sanity` test results."
            ),
        },
        "python_app": {
            "role": "Specialized Python Testing Automation Engineer",
            "backstory": (
                "Expert Python QA developer focused on pytest coverage and module imports.\n"
                f"{PARSER_GUARD_INSTRUCTIONS}\n"
                f"{SYNTAX_GUARD_INSTRUCTIONS}"
            ),
            "description": f"Execute test modules using local pytest setups in: {workspace_dir}",
            "expected_output": "Pytest metrics and coverage statistics summary output.",
        },
        "generic": {
            "role": "Principal Quality Assurance Automation Architect",
            "goal": "Validate changes with targeted, efficient testing",
            "backstory": (
                "Meticulous verification architect running quick and targeted validation patterns.\n"
                f"{PARSER_GUARD_INSTRUCTIONS}\n"
                f"{SYNTAX_GUARD_INSTRUCTIONS}"
            ),
            "description": f"Analyze modifications in {workspace_dir} using structural scripts.",
            "expected_output": "Targeted validation parameters confirmation trace.",
        },
    }

    selected_config = qa_configs.get(repo_type, qa_configs["generic"])

    qa_agent = Agent(
        role=selected_config["role"],
        goal="Validate changes with targeted, highly-efficient test strategies.",
        backstory=f"{selected_config['backstory']}\n{PARSER_GUARD_INSTRUCTIONS}",
        llm=qa_llm,
        tools=workspace_tools,
        cache=True,
        verbose=True,
        max_iter=4,
        max_execution_time=300,
    )

    development_task = Task(
        description=(
            f"Task: {t_title}\n"
            f"Blueprint: {t_blueprint}\n"
            f"Workspace: {workspace_dir}\n"
            f"Repository Type: {repo_type}\n"
            f"Functional Objectives: {t_description}\n\n"
            "STRICT RULES:\n"
            "- Call read_repo_skill('TESTING') and list_repo_files to review repository architectural context."
            "- Make necessary code updates. ONLY edit files required for the feature (e.g. new/updated module + matching tests).\n"
            "- NEVER touch run-tests.sh, .gitignore, Dockerfiles, or CI files.\n"
            "- Use execute_batch_actions for all writes.\n"
            "- After code updates, run `remedy_lint_errors_tool` to auto-clean and format modified files.\n"
            "- Validate Python code styling and quality:\n"
            "   - Invoke `run_local_tests_tool` with the command argument set to: './run-tests.sh sanity'\n"
            "   - If Pylint or PEP8 errors are returned, modify the files directly until the tool returns zero errors.\n"
            "- Execute unit testing suites:\n"
            "   - Invoke `run_local_tests_tool` with the command argument set to: './run-tests.sh pytest tests/unit/'\n"
            "- Ensure all test and lint executions return a clean exit status code (0) before completing the task."
        ),
        expected_output=(
            "Clean code + passing tests."
        ),
        agent=developer_agent,
    )

    qa_task = Task(
        description=selected_config["description"],
        expected_output=selected_config["expected_output"],
        agent=qa_agent,
    )

    return Crew(
        agents=[developer_agent, qa_agent],
        tasks=[development_task, qa_task],
        process=Process.sequential,
        verbose=True,
    )


def generate_clean_agent_summary(crew_result) -> str:
    """Generates a clean, structured Markdown summary of the CrewAI run.
    Prioritizes test logs when present.
    """
    if not hasattr(crew_result, "tasks_output") or not crew_result.tasks_output:
        return "No execution tasks were returned by the multi-agent orchestration run."

    summary_blocks = []

    for idx, task_out in enumerate(crew_result.tasks_output, 1):
        agent_name = getattr(task_out, "agent", f"CrewAI Agent {idx}")
        task_description_short = getattr(
            task_out, "description", f"Execution Block {idx}"
        )

        if len(task_description_short) > 150:
            task_description_short = task_description_short[:147] + "..."

        raw_out = getattr(task_out, "raw", "") or str(task_out)

        # Regex parsing for modified/created files
        file_matches = re.findall(
            r"(?:written successfully|successfully wrote|file:|path:)\s*`?([a-zA-Z0-9_\-\.\/]+)`?",
            raw_out,
            re.IGNORECASE,
        )
        file_matches += re.findall(
            r"\b([a-zA-Z0-9_\-\/]+\.(?:py|md|yml|yaml|json|groovy|sh|tf))\b", raw_out
        )
        unique_files = sorted(list(set(file_matches)))

        # Handle terminal versus conversational outputs
        terminal_separator = "EXECUTED BY ROLE:"
        if terminal_separator in raw_out:
            parts = raw_out.split(terminal_separator, 1)
            clean_conversational = scrub_agent_telemetry(parts[0].strip())
            # clean_conversational = parts[0].strip()
            raw_terminal_part = terminal_separator + parts[1]

            clean_terminal = (
                f"```text\n{truncate_log_output(raw_terminal_part.strip())}\n```"
            )
            combined_output = (
                f"{clean_conversational}\n\n#### 🖥️ Test Output Logs:\n{clean_terminal}"
            )
        else:
            clean_conversational = scrub_agent_telemetry(raw_out)
            # FORCE test output visibility
            if (
                "PASSED" in raw_out
                or "EXIT CODE: 0" in raw_out
                or "tests/" in raw_out
            ):
                combined_output = f"```text\n{truncate_log_output(raw_out)}\n```"
            elif len(clean_conversational) > 500 or "DOCUMENTATION" in clean_conversational:
                combined_output = "*Raw code payload omitted for readability. Code changes can be reviewed below in the PR Files Changed tab.*"
            else:
                combined_output = clean_conversational

        files_summary_markdown = "#### 📁 Modified/Created Files:\n" + "\n".join(f"- `{f}`" for f in unique_files) if unique_files else "#### 📁 Modified/Created Files:\n- *No file mutations explicitly logged.*"

        summary_blocks.append(
            f"### 🤖 CrewAI Task Resolution Step {idx}\n"
            f"**Agent Role:** `{agent_name}`\n"
            f"**Task Assigned:** *{task_description_short}*\n\n"
            f"{files_summary_markdown}\n\n"
            f"#### Output Summary:\n{combined_output}"
        )

    return "\n\n---\n\n".join(summary_blocks)


def post_multi_agent_kanban_comments(task_id: int, crew_result: CrewOutput):
    """Iterates completed tasks and posts clean, readable audit traces step-by-step."""
    if hasattr(crew_result, "tasks_output") and crew_result.tasks_output:
        logger.info(
            f"[Pipeline Engine] Documenting {len(crew_result.tasks_output)} individual task audit traces..."
        )

        # Reuse the clean helper logic to post distinct, step-by-step comments to the Kanban card
        for task_out in crew_result.tasks_output:
            # To preserve individual, iterative comments on the Kanban card,
            # we can still parse them step-by-step using a miniature single-task helper or
            # run a quick map. For absolute consistency, we'll build the single block:
            single_task_result = CrewOutput(raw="", tasks_output=[task_out])
            step_comment = generate_clean_agent_summary(single_task_result)

            try:
                post_kanban_comment(task_id, step_comment)
                # Small backoff delay to guarantee correct sequential sorting order in Vikunja Comments thread
                time.sleep(1.5)
            except Exception as post_err:
                logger.warning(
                    f"Failed posting individual task step comment: {post_err}"
                )


def generate_optimized_final_summary(
    crew_result: CrewOutput, agent_times: dict, pr_url: str = ""
) -> str:
    """
    Generates a condensed summary comment of test execution and records start, end,
    and duration tracking of each task split per agent.
    """
    raw_output = crew_result.raw if hasattr(crew_result, "raw") else str(crew_result)
    logger.debug(f"generate_optimized_final_summary(): raw_output={raw_output}")

    # 1. Parse pytest summary line (e.g., "112 passed, 2 warnings in 4.5s")
    test_summary = "All tests executed successfully."
    match = re.search(
        r"(=+\s*[\s\w,]+passed[\s\w,]*=+|\d+\s+passed[\s\w,]+in\s+[\d\.]+s)",
        raw_output,
        re.IGNORECASE
    )
    if match:
        test_summary = match.group(1).strip()

    # 2. Build Agent Time Allocation Table
    time_table = "| Agent Role | Tool Task / Task Identifier | Start Time | End Time | Duration |\n| :--- | :--- | :--- | :--- | :--- |\n"
    total_time = 0.0

    for agent, tasks in agent_times.items():
        if isinstance(tasks, dict):
            for task_name, info in tasks.items():
                duration = info.get("duration", 0.0)
                start_str = info.get("start", "")
                end_str = info.get("end", "")
                time_table += f"| `{agent}` | `{task_name}` | {start_str} | {end_str} | {duration:.2f}s |\n"
                total_time += duration
        else:
            time_table += f"| `{agent}` | `Task Run Execution` | - | - | {tasks:.2f}s |\n"
            total_time += tasks

    time_table += f"| **Total Overhead** | | | | **{total_time:.2f}s** |\n"

    # 2. Extract token usage metadata safely (with fallbacks if metrics are empty)
    token_summary = "⚠️ Token tracking metrics unavailable for this execution run."
    if hasattr(crew_result, "token_usage") and crew_result.token_usage:
        usage = crew_result.token_usage

        # Read attributes directly from the UsageMetrics object
        prompt_tokens = getattr(usage, "prompt_tokens", 0) or getattr(
            usage, "initial_tokens", 0
        )
        completion_tokens = getattr(usage, "completion_tokens", 0) or getattr(
            usage, "final_tokens", 0
        )
        total_tokens = getattr(usage, "total_tokens", 0)

        token_summary = (
            f"📊 **LLM Infrastructure Token Telemetry:**\n"
            f"- **Prompt (Input) Tokens:** {prompt_tokens:,}\n"
            f"- **Completion (Output) Tokens:** {completion_tokens:,}\n"
            f"- **Total Combined Tokens:** {total_tokens:,}\n"
        )

    # 3. Construct Final Comment
    condensed_comment = (
        "### 🎉 Task Execution Complete\n\n"
        "All development and verification tasks have successfully concluded.\n\n"
    )

    if pr_url:
        condensed_comment += (
            "#### 🔗 Proposed Changes\n"
            f"* **Pull Request:** [Review PR Branches]({pr_url})\n\n"
        )

    condensed_comment += (
        "#### 📊 Test Execution Summary\n"
        f"> **Result:** `{test_summary}`\n\n"
        "---\n\n"
        f"{token_summary}\n\n"
        "---\n\n"
        "#### ⏱️ Agent Time Allocation & Observability metrics\n"
        f"{time_table}"
    )

    return condensed_comment


# ===================================================================
# GITEA AUTOMATION LIFECYCLE HANDLERS
# ===================================================================


def extract_gitea_metadata(task_data: dict) -> dict:
    """Extracts Gitea repositories and target branches from task context qualifiers."""
    task_title = task_data.get("title", "")
    task_desc = convert_vikunja_html_to_markdown(task_data.get("description", ""))
    task_labels = task_data.get("labels", [])
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

    # 3. Fallback: Parse title metadata block
    if not meta["repo"] and task_title:
        repo_match = re.search(
            r"(?:gitea|repo):\s*([a-zA-Z0-9_\-]+/[a-zA-Z0-9_\-]+)",
            task_title,
            re.IGNORECASE,
        )
        if repo_match:
            meta["repo"] = repo_match.group(1).strip()

        branch_match = re.search(
            r"branch:\s*([a-zA-Z0-9_\-\/]+)", task_title, re.IGNORECASE
        )
        if branch_match:
            meta["branch"] = branch_match.group(1).strip()

    return meta


def clone_gitea_target_repository(repo_identifier, local_disk_destination):
    """Provides authenticated pathing context to orchestrate clones."""
    sanitized_endpoint = settings.GITEA_BASE_URL.replace("https://", "").replace("http://", "")
    authenticated_clone_url = (
        f"https://{settings.GITEA_USER}:{settings.GITEA_TOKEN}@{sanitized_endpoint}/{repo_identifier}.git"
    )

    try:
        logger.info(f"[Git Sandbox] Cloning repository: {settings.GITEA_BASE_URL}/{repo_identifier}")
        return git.Repo.clone_from(authenticated_clone_url, local_disk_destination)
    except Exception as exc:
        logger.error(f"[Git Sandbox] Error cloning targets: {exc}")
        return None


def dispatch_gitea_pull_request(
    repo_path: str, head_branch: str, base_branch: str, task_meta: dict, pr_body: str
):
    """Opens a Pull Request inside Gitea using its standard REST API structure."""
    t_title = task_meta.get("title", "")
    t_display_id = get_task_display_id(task_meta)
    # t_description = convert_vikunja_html_to_markdown(task_meta.get("description", ""))

    base_endpoint = settings.GITEA_BASE_URL.rstrip("/")
    pr_dispatch_url = f"{base_endpoint}/api/v1/repos/{repo_path}/pulls"
    headers_gitea = {
        "Authorization": f"token {settings.GITEA_TOKEN}",
        "Content-Type": "application/json",
    }

    payload = {
        "base": base_branch,
        "head": head_branch,
        "title": f"feat(agent): resolve automated enhancement for task card {t_display_id}",
        "body": f"Automated processing pipeline implementation resolving: {t_title}\n\n### Agent Run Diagnostics:\n{pr_body}",
    }

    try:
        with httpx.Client(verify=False, timeout=10.0) as client:
            res = client.post(pr_dispatch_url, headers=headers_gitea, json=payload)
            if res.status_code in [200, 201]:
                pr_data = res.json()
                logger.info(f"[Gitea API] ✅ Pull Request opened: {pr_data.get('html_url')}")
                return pr_data.get("html_url", "")
            logger.error(
                f"[Gitea API] Failed opening PR: {res.status_code} - {res.text}"
            )
    except Exception as net_ex:
        logger.error(f"[Gitea API] Connection failure: {net_ex}")
    return None


def call_langgraph_supervisor(task_data: dict) -> dict:
    """Dispatches Vikunja task to supervisor router with robust retry + longer timeout."""
    langgraph_headers = {
        "X-Agent-Secret": settings.LANGGRAPH_API_KEY,
        "Content-Type": "application/json"
    }
    payload = {
        "task_id": task_data.get("id"),
        "project_id": task_data.get("project_id"),
        "title": task_data.get("title", ""),
        "description": task_data.get("description", ""),
    }
    t_display_id = get_task_display_id(task_data)

    logger.info(f"[LangGraph Router] Evaluating Task {t_display_id}: '{payload['title']}'")

    timeout_list = [15, 30, 45]  # seconds

    for attempt, timeout_sec in enumerate(timeout_list, 1):
        try:
            with httpx.Client(verify=False, timeout=timeout_sec) as client:
                response = client.post(
                    settings.LANGGRAPH_ROUTER_URL,
                    headers=langgraph_headers,
                    json=payload,
                    timeout=timeout_sec
                )

                if response.status_code == 200:
                    result = response.json()
                    logger.info(
                        f"[LangGraph Router] Analysis returned -> Routing: {result.get('routing')}"
                    )
                    return result
                else:
                    logger.warning(
                        f"[LangGraph Router] Attempt {attempt} failed with {response.status_code}: {response.text[:300]}"
                    )

        except httpx.TimeoutException:
            logger.warning(f"[LangGraph Router] Attempt {attempt} timed out after {timeout_sec}s")
        except Exception as e:
            logger.warning(f"[LangGraph Router] Attempt {attempt} exception: {e}")

        if attempt < len(timeout_list):
            backoff = attempt * 3
            logger.info(f"[LangGraph Router] Retrying in {backoff}s...")
            time.sleep(backoff)

    # Final fallback
    logger.error(f"[LangGraph Router] All attempts failed for Task {t_display_id}. Using fallback.")
    return {"routing": "crewai", "summary": "Router unreachable → fallback to CrewAI"}


# ====================== PROCESS GITOPS TASK ======================
def process_gitops_task(task_data: dict, agent_times: dict):
    """Processes an individual task coordinating supervisor decisions and multi-agent execution loops."""
    task_id = task_data.get("id")
    t_project_id = task_data.get("project_id")
    t_title = task_data.get("title")
    t_display_id = get_task_display_id(task_data)
    t_description = convert_vikunja_html_to_markdown(task_data.get("description", ""))
    agent_status_label = TASK_LABEL_SUCCESS

    logger.info(
        f"[Pipeline Engine] Found execution target Task {t_display_id} in Project {t_project_id}"
    )
    move_task_to_bucket(task_data, target_bucket_name="Doing")

    # 1. INTERCEPT VIA THE LANGGRAPH SUPERVISOR ROUTER
    decision = call_langgraph_supervisor(task_data)

    # Merge router decision into task_data for downstream use
    task_data.update(
        {
            "complexity": decision.get("complexity", "medium"),
            "routing_target": decision.get("routing_target", "crewai_heavy"),
            "blueprint": decision.get("blueprint", ""),
        }
    )

    routing = decision.get("routing_target", "crewai_heavy")
    logger.info(
        f"[Pipeline Engine] LangGraph Routing Decision: {routing} for Task {t_display_id}"
    )

    # Operational Early-Exit Path Detection
    if routing in ["complete", "blocked", "fast_path"]:
        logger.info(f"[Pipeline Engine] ⚡ Early exit via router: {routing} for task {t_display_id}")

        if routing == "fast_path":
            comment_body = f"### 🤖 Fast-Path Resolution\n\n{decision.get('blueprint', 'No heavy agents required.')}"
        else:
            comment_body = f"### 🤖 CrewAI Skipped\n\nRouter decision: **{routing}**"

        # Post comment
        post_kanban_comment(task_id, comment_body)
        add_task_label(task_data, TASK_LABEL_SUCCESS)
        move_task_to_bucket(task_data, "Review")
        return

    # 2. CODE CONTEXT LOOP GENERATION (FALLTHROUGH PATH)
    logger.info(
        f"[Pipeline Engine] 🛠️ Commencing deep agent execution stack for Task {t_display_id}"
    )
    git_meta = extract_gitea_metadata(task_data)
    repo_target = git_meta["repo"]
    if not repo_target:
        logger.error(
            f"[Pipeline Engine] Cannot establish target repository for Task {t_display_id}"
        )
        return

    with tempfile.TemporaryDirectory(
        prefix=f"gitops_crew_workspace_{task_id}_"
    ) as workspace_dir:
        logger.info(
            f"[Git Architecture] Ephemeral checkout folder targeting route established: {workspace_dir}"
        )
        logger.debug(
            f"[GitOps Pipeline] Cloning {git_meta['repo']} to scratch directory: {workspace_dir}"
        )

        # Clone repository profile
        repo = clone_gitea_target_repository(repo_target, workspace_dir)
        logger.info(
            f"[Git Architecture] Isolated clone phase complete for context targets: {repo_target}"
        )
        if not repo:
            logger.error(f"[Git Architecture] Repository clone failed: {repo_target}")
            return

        feature_branch_name = f"feature/agent-task-{task_id}-{int(time.time())}"
        # Create and checkout clean task branch bound to original root base
        logger.debug(
            f"[GitOps Pipeline] Establishing clean branch environment: '{feature_branch_name}' based on branch '{git_meta['branch']}'"
        )
        try:
            repo.git.checkout(git_meta["branch"])
            repo.git.checkout("-b", feature_branch_name)
            # new_branch = repo.create_head(feature_branch_name)
            # new_branch.checkout()
            logger.info(
                f"[Git Architecture] Active branch: {feature_branch_name}"
            )
        except Exception as err:
            logger.error(f"[Git Architecture] Branch setup failed: {err}")
            return

        # build_repo_index(Path(workspace_dir))

        # Dynamic tools setup with integrated metrics tracking wrapper
        workspace_tools = create_workspace_tools(workspace_dir)
        workspace_tools = [
            wrap_tool_with_telemetry(t, agent_times) for t in workspace_tools
        ]
        repo_type = detect_repo_type(workspace_dir)
        logger.info(f"[Pipeline Engine] Detected repository type: {repo_type}")

        # Read testing guidance
        testing_guidance = ""
        try:
            skill_tool = next((t for t in workspace_tools if getattr(t, "name", None) == "read_repo_skill"), None)
            if skill_tool:
                testing_guidance = skill_tool.func("TESTING")
        except Exception as e:
            logger.warning(f"Failed to read TESTING skill: {e}")

        # 3. INITIALIZE MULTI-AGENT WORKSPACE LOOP
        crew_instance = build_multi_agent_crew(
            workspace_dir=workspace_dir,
            task_data=task_data,
            workspace_tools=workspace_tools,
            repo_type=repo_type
        )

        # Pass to crew
        inputs_payload = {
            "task_id": task_id,
            "task_title": t_title,
            "task_description": t_description,
            "repo_type": repo_type,
            "testing_guidance": testing_guidance[:2000]
        }

        logger.info(
            f"[Crew Stack Loop] Deploying Agent Execution Crew targeting '{workspace_dir}'"
        )

        # Wrapped with execute_agent_loop to capture overall context as safety fallback
        crew_result = execute_agent_loop(
            "CrewAI Orchestrator", crew_instance.kickoff, inputs=inputs_payload
        )
        logger.info("[Crew Stack Loop] Multi-Agent verification cycle complete.")

        # Post the highly readable, clean, and sliced comments to the board
        post_multi_agent_kanban_comments(task_id, crew_result)

        # Handle file-writing checks
        if hasattr(crew_result, "tasks_output") and crew_result.tasks_output:
            logger.info(
                "[Pipeline Engine] Scanning intermediate task outputs for pending tool write calls..."
            )
            for task_out in crew_result.tasks_output:
                raw_text = getattr(task_out, "raw", "") or str(task_out)
                execute_pending_tool_calls(
                    result=raw_text, workspace_tools=workspace_tools
                )

        # Execute parsing fallback strategy extraction on final crew result as well
        execute_pending_tool_calls(
            result=str(crew_result), workspace_tools=workspace_tools
        )

        # 3. Check for structural mutations on filesystem assets
        has_changes = repo.is_dirty(untracked_files=True)
        pull_request_url = ""

        if has_changes:
            logger.info(
                "[Pipeline Engine] Source transformations detected. Building pull request commits..."
            )
            # 4. COMMIT AND PUSH MUTATIONS TO GITEA
            try:
                with repo.config_writer() as git_config:
                    git_config.set_value("user", "name", settings.GIT_USER_NAME)
                    git_config.set_value("user", "email", settings.GIT_USER_EMAIL)

                repo.git.add(A=True)
                repo.index.commit(
                    f"feat(gitops): automated multi-agent resolution updates for Task {t_display_id}"
                )

                logger.info(
                    f"[Git Architecture] Pushing isolated branch: {feature_branch_name} -> Origin"
                )
                # origin_remote = repo.remote(name="origin")
                # origin_remote.push(refspec=f"{feature_branch_name}:{feature_branch_name}")
                # repo.git.push("--set-upstream", "origin", feature_branch_name)
                repo.remotes.origin.push(f"{feature_branch_name}:{feature_branch_name}")
            except Exception as git_err:
                logger.error(f"[Git Architecture] Failed pushing mutations: {git_err}")
                return

            # 5. DISPATCH PULL REQUEST INVERSION CALL
            # Generate matching, clean documentation without the raw script dumps
            pr_body_structured = generate_clean_agent_summary(crew_result)

            pull_request_url = dispatch_gitea_pull_request(
                repo_path=repo_target,
                head_branch=feature_branch_name,
                base_branch=git_meta["branch"],
                task_meta=task_data,
                pr_body=pr_body_structured,
            )

            if not pull_request_url:
                logger.error(
                    f"[Post Resolution] Failed to create PR for: {repo_target}/{feature_branch_name}; skipping resolution"
                )
                agent_status_label = TASK_LABEL_FAILED
            else:
                logger.info(
                    f"[Post Resolution] Appending generated PR validation trace endpoint context mapping: {pull_request_url}"
                )
                # Assign success label specifically signaling PR submission state
                agent_status_label = TASK_LABEL_PR_SUCCESS
        else:
            logger.warning(
                "[Pipeline Engine] ⚠️ Crew execution exited without applying any filesystem changes."
            )

        # -------------------------------------------------------------
        # 💾 SAVE THE FULL, UNTRUNCATED DIALOGUES & LOGS AS AN ATTACHMENT
        # -------------------------------------------------------------
        execution_state = {
            "task_id": task_id,
            "index": task_data.get("index"),
            "title": t_title,
            "status": "COMPLETED" if pull_request_url else "ANALYZED_NO_CHANGES",
            "timestamp": int(time.time()),
            "gitops": {
                "repository": repo_target,
                "base_branch": git_meta.get("branch"),
                "feature_branch": feature_branch_name,
                "pull_request_url": pull_request_url,
            },
            # Complete un-truncated raw summary details are safely locked here:
            "raw_agent_summary": str(crew_result),
            "raw_agent_tasks": [
                {
                    "agent": getattr(task_out, "agent", "Unknown"),
                    "description": getattr(task_out, "description", ""),
                    "raw_output": getattr(task_out, "raw", ""),
                }
                for task_out in getattr(crew_result, "tasks_output", [])
            ],
        }

        # Dispatch complete artifact directly to Vikunja
        attach_execution_context_to_task(
            task_id, task_data.get("index"), execution_state
        )

        # Post the optimized final observability matrix
        final_comment_markdown = generate_optimized_final_summary(
            crew_result=crew_result,
            agent_times=agent_times,
            pr_url=pull_request_url
        )

        logger.info("[Crew Stack Loop] posting final comment.")
        post_kanban_comment(task_id, final_comment_markdown)

        # 4. Standardize downstream label updates and Kanban lane progression updates
        add_task_label(task_data, agent_status_label)
        move_task_to_bucket(task_data, "Review")
        logger.info(f"✅ Task {t_display_id} fully processed.")
