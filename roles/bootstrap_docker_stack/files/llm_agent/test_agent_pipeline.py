import os
import time
import sys
import logging
import httpx
import urllib3
import pytest

# ====================== LOGGING & CONFIG BOOTSTRAPPING ======================
logger = logging.getLogger("test_agent_suite")
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)-8s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
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


# Execute initialization prior to global variable assignments
load_env_file()

VIKUNJA_API_URL = os.getenv("VIKUNJA_API_URL")
VIKUNJA_BEARER_TOKEN = os.getenv("VIKUNJA_BEARER_TOKEN")
TARGET_PROJECT_NAME = "crewai-test"

headers = {
    "Authorization": f"Bearer {VIKUNJA_BEARER_TOKEN}",
    "Content-Type": "application/json",
}

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


# ===================================================================
# PYTEST FIXTURES (SETUP / CLEANUP)
# ===================================================================
@pytest.fixture(scope="session", autouse=True)
def environment_bootstrap():
    """Validates core API tokens are present before executing any test paths."""
    if not VIKUNJA_API_URL or not VIKUNJA_BEARER_TOKEN:
        pytest.fail(
            "CRITICAL CONFIGURATION ERROR: VIKUNJA_API_URL or VIKUNJA_BEARER_TOKEN is not defined."
        )


@pytest.fixture(scope="session")
def project_metadata():
    """Resolves target workspace project ID and extracts Kanban board layout layouts."""
    logger.info(f"Resolving workspace context for project: '{TARGET_PROJECT_NAME}'")
    with httpx.Client(verify=False, timeout=10.0) as client:
        # Find Project ID
        res = client.get(f"{VIKUNJA_API_URL}/projects", headers=headers)
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
            f"{VIKUNJA_API_URL}/projects/{project_id}/views", headers=headers
        )
        view_id = None
        if v_res.status_code == 200:
            for view in v_res.json() or []:
                if view.get("view_kind") == "kanban":
                    view_id = view["id"]
                    break

        if not view_id:
            pytest.fail(
                "Target Kanban view interface missing on project dashboard layout."
            )

        # Map Column Buckets
        b_res = client.get(
            f"{VIKUNJA_API_URL}/projects/{project_id}/views/{view_id}/buckets",
            headers=headers,
        )
        bucket_map = {}
        if b_res.status_code == 200:
            for bucket in b_res.json() or []:
                bucket_map[bucket.get("title", "").strip().lower()] = bucket.get("id")

        return {"project_id": project_id, "view_id": view_id, "bucket_map": bucket_map}


@pytest.fixture(autouse=True)
def clean_slate_sweep(project_metadata):
    """Enforces absolute lane isolation by purging open cards prior to running a test case."""
    p_id = project_metadata["project_id"]
    logger.info(f"Enforcing isolation cleanup sweep on Project #{p_id}")
    with httpx.Client(verify=False, timeout=10.0) as client:
        res = client.get(
            f"{VIKUNJA_API_URL}/projects/{p_id}/tasks?filter=done%20=%20false",
            headers=headers,
        )
        if res.status_code == 200:
            for task in res.json() or []:
                client.delete(f"{VIKUNJA_API_URL}/tasks/{task['id']}", headers=headers)


# ===================================================================
# CORE ASSERTION ENGINE (SHARED MONITOR)
# ===================================================================
def poll_and_verify_task_lifecycle(
    task_id: int, expected_outcome: str, bucket_map: dict
):
    """Polls the task state and validates sanitization and structural execution outcomes."""
    review_bucket_id = bucket_map.get("review")
    timeout_counter = 0
    max_timeout_seconds = 480
    poll_interval_seconds = 10

    with httpx.Client(verify=False, timeout=10.0) as client:
        while timeout_counter < max_timeout_seconds:
            res = client.get(f"{VIKUNJA_API_URL}/tasks/{task_id}", headers=headers)
            if res.status_code == 200:
                task_state = res.json()
                labels = task_state.get("labels", []) or []
                current_bucket = task_state.get("bucket_id")

                has_processed_label = any(
                    lbl.get("title") == "agent-processed" for lbl in labels
                )

                if has_processed_label or current_bucket == review_bucket_id:
                    logger.info(
                        f"Task processing completion signal captured at {timeout_counter}s."
                    )

                    # 1. Assert comment-stream sanitization (No leaked structural tool-use JSON)
                    comments_res = client.get(
                        f"{VIKUNJA_API_URL}/tasks/{task_id}/comments", headers=headers
                    )
                    assert comments_res.status_code == 200, (
                        "Failed to retrieve comment payload."
                    )
                    comments_list = comments_res.json() or []
                    assert len(comments_list) > 0, (
                        "Agent closed execution path without providing commentary updates."
                    )

                    for comm in comments_list:
                        text = comm.get("comment", "")
                        assert '"name":' not in text, (
                            "Telemetry leak detected: raw JSON structural field found in text body."
                        )
                        assert "write_code_component_file" not in text, (
                            "Telemetry leak detected: unscrubbed tool identifiers found."
                        )

                    # 2. Assert telemetry state payload attachment
                    attachments_res = client.get(
                        f"{VIKUNJA_API_URL}/tasks/{task_id}/attachments",
                        headers=headers,
                    )
                    assert attachments_res.status_code == 200
                    has_yaml = any(
                        "agent-execution-context.yaml" in att.get("file_name", "")
                        for att in attachments_res.json() or []
                    )
                    assert has_yaml, (
                        "Context tracing execution yaml was completely omitted from task attachments."
                    )

                    # 3. Assert functional workflow mutation expectations (PR opened vs Read-Only)
                    if expected_outcome == "PR_CREATED":
                        assert any(
                            "pull_request_url: https://" in comm.get("comment", "")
                            or "pull_request_url: http://" in comm.get("comment", "")
                            for comm in comments_list
                        ) or any(
                            "Pull Request Synchronized Upstream"
                            in comm.get("comment", "")
                            for comm in comments_list
                        ), (
                            "Workflow target expected codebase mutation, but no valid upstream pull request metadata was exposed."
                        )
                    elif expected_outcome == "NO_CHANGES":
                        assert any(
                            "ANALYZED_NO_CHANGES" in comm.get("comment", "")
                            or "without codebase drift" in comm.get("comment", "")
                            for comm in comments_list
                        ), (
                            "Workflow target expected read-only tracking status, but metadata is mismatching."
                        )

                    return True

            time.sleep(poll_interval_seconds)
            timeout_counter += poll_interval_seconds
            if timeout_counter % 30 == 0:
                logger.info(
                    f"Awaiting model pipeline updates... ({timeout_counter}s elapsed)"
                )

    pytest.fail(
        f"Pipeline verification threshold timed out after {max_timeout_seconds}s without processing completion."
    )


# ===================================================================
# FUNCTIONAL AUTOMATION TEST CASES
# ===================================================================


def test_read_only_analysis_flow(project_metadata):
    """CASE 1: Verifies that analytical descriptions evaluate without forcing filesystem drift or PR generation."""
    meta = project_metadata
    todo_id = (
        meta["bucket_map"].get("to-do")
        or meta["bucket_map"].get("todo")
        or meta["bucket_map"].get("to do")
    )

    payload = {
        "title": "[dettonville.utils] Refactor plugins and modules for strict prefix namespacing (ansible-module)",
        "description": (
            "<p>Please review and execute refactoring guidelines matching dettonville enterprise layouts.</p>"
            "<p>gitea: infra/crewai-test<br>branch: main</p>"
        ),
        "bucket_id": todo_id,
    }

    with httpx.Client(verify=False, timeout=10.0) as client:
        # Step 1: PUT to create the task
        res = client.put(
            f"{VIKUNJA_API_URL}/projects/{meta['project_id']}/tasks",
            headers=headers,
            json=payload,
        )
        assert res.status_code in [200, 201], (
            f"Failed to create task structure: {res.text}"
        )

        task_data = res.json()
        task_id = (
            task_data.get("id")
            if "id" in task_data
            else task_data.get("task", {}).get("id")
        )

        # Step 2: POST to associate the created task to the Kanban bucket column
        bucket_url = f"{VIKUNJA_API_URL}/projects/{meta['project_id']}/views/{meta['view_id']}/buckets/{todo_id}/tasks"
        bucket_res = client.post(bucket_url, headers=headers, json={"task_id": task_id})
        assert bucket_res.status_code in [200, 201], (
            f"Failed to map task into Kanban column: {bucket_res.text}"
        )

    # Poll with explicit structural assertion for read-only tracking configurations
    poll_and_verify_task_lifecycle(
        task_id, expected_outcome="NO_CHANGES", bucket_map=meta["bucket_map"]
    )


def test_pull_request_generation_flow(project_metadata):
    """CASE 2: Asserts code mutation lifecycle behaves end-to-end, pushing branch updates upstream and opening PR."""
    meta = project_metadata
    todo_id = (
        meta["bucket_map"].get("to-do")
        or meta["bucket_map"].get("todo")
        or meta["bucket_map"].get("to do")
    )

    payload = {
        "title": "[dettonville.utils] Refactor plugins and modules for strict prefix namespacing (ansible-module)",
        "description": (
            "<p>Please review and execute refactoring guidelines matching dettonville enterprise layouts.</p>"
            "<p>gitea: infra/crewai-test<br>branch: main</p>"
            "<p>CRITICAL INTEGRATION REQUIREMENT: You MUST create a new documentation summary file named "
            "'namespacing_refactor.md' inside the repository root using your write file tool to record your layout change proposal.</p>"
        ),
        "bucket_id": todo_id,
    }

    with httpx.Client(verify=False, timeout=10.0) as client:
        # Step 1: PUT to create the task
        res = client.put(
            f"{VIKUNJA_API_URL}/projects/{meta['project_id']}/tasks",
            headers=headers,
            json=payload,
        )
        assert res.status_code in [200, 201], (
            f"Failed to create task structure: {res.text}"
        )

        task_data = res.json()
        task_id = (
            task_data.get("id")
            if "id" in task_data
            else task_data.get("task", {}).get("id")
        )

        # Step 2: POST to associate the created task to the Kanban bucket column
        bucket_url = f"{VIKUNJA_API_URL}/projects/{meta['project_id']}/views/{meta['view_id']}/buckets/{todo_id}/tasks"
        bucket_res = client.post(bucket_url, headers=headers, json={"task_id": task_id})
        assert bucket_res.status_code in [200, 201], (
            f"Failed to map task into Kanban column: {bucket_res.text}"
        )

    # Poll with structural expectation that a file modification must trigger a PR mapping link
    poll_and_verify_task_lifecycle(
        task_id, expected_outcome="PR_CREATED", bucket_map=meta["bucket_map"]
    )
