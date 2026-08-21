#!/usr/bin/env python3
"""
vikunja_api.py
Pure Kanban / Vikunja integration layer.
Handles authentication, task polling, state transitions, comments, labels, attachments.
"""

import httpx
import logging
import os
import sys
import time
import yaml
from functools import wraps
from markdown_it import MarkdownIt
from markdownify import markdownify as md_convert
from mdit_py_plugins.tasklists import tasklists_plugin
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

from config import settings

__scriptName__ = os.path.basename(sys.argv[0])

# ====================== LOGGING SETUP ======================
LOG_LEVEL_NUMERIC = getattr(logging, settings.LOG_LEVEL, logging.INFO)
logger = logging.getLogger(__scriptName__)
logger.setLevel(LOG_LEVEL_NUMERIC)

# Structural Metadata Cache Maps
# Schema: { project_id: { "view_id": int, "layout_map": { "todo": int, "doing": int, "review": int, "done": int } } }
VIKUNJA_PROJECT_CACHE = {}


def httpx_retry_decorator(max_attempts=3):
    """Centralized retry for httpx calls."""
    def decorator(func):
        @retry(
            stop=stop_after_attempt(max_attempts),
            wait=wait_exponential(multiplier=1, min=2, max=10),
            retry=retry_if_exception_type((httpx.TimeoutException, httpx.ConnectError, httpx.HTTPStatusError)),
            reraise=True,
        )
        @wraps(func)
        def wrapper(*args, **kwargs):
            return func(*args, **kwargs)
        return wrapper
    return decorator


def get_task_display_id(task_data: dict) -> str:
    return f"#{task_data.get('index', '???')} (ID {task_data.get('id', '???')})"


def get_task_current_bucket_id(task_id: int, cache_meta: dict):
    """Helper to locate which bucket an active card resides in."""
    p_id = cache_meta["project_id"]
    view_id_kanban = cache_meta["view_id_kanban"]
    endpoint = f"{settings.VIKUNJA_API_URL}/projects/{p_id}/views/{view_id_kanban}/tasks?filter=id={task_id}"
    t_bucket_id = None
    with httpx.Client(verify=False) as client:
        res = client.get(endpoint, headers=settings.VIKUNJA_HEADERS)
        if res.status_code == 200:
            for bucket in res.json():
                logger.info(f"bucket['id'] = {bucket.get('id')}")
                tasks = bucket.get("tasks", []) or []
                if any(t.get("id") == task_id for t in tasks):
                    t_bucket_id = bucket.get("id")
    logger.debug(f"Task {task_id} bucket_id = {t_bucket_id}")
    return t_bucket_id


def display_vikunja_api_telemetry_banner():
    """Outputs basic trace settings at server instantiation."""
    logger.info(f"Listening on target projects: {settings.VIKUNJA_PROJECT_NAMES}")
    logger.info(f"Target Infrastructure Base: {settings.VIKUNJA_API_URL}")
    logger.info(f"Log level set to: {settings.LOG_LEVEL}")
    vikunja_info_url = f"{settings.VIKUNJA_API_URL}/info"

    try:
        @httpx_retry_decorator(max_attempts=2)
        def get_info():
            with httpx.Client(timeout=5.0, verify=False) as client:
                return client.get(vikunja_info_url, headers=settings.VIKUNJA_HEADERS)

        response = get_info()
        if response.status_code == 200:
            info_data = response.json()
            version = info_data.get("version", "Unknown")
            frontend = info_data.get("frontend_url", "N/A")
            logger.info(f" -> Vikunja Core Engine Version: {version}")
            logger.info(f" -> Connected Workspace View: {frontend}")
        else:
            logger.warning(
                f" -> Telemetry: Non-200 response from Vikunja endpoint: {response.status_code}"
            )
    except Exception as telemetry_err:
        logger.warning(f" -> Telemetry banner error: {telemetry_err}")


def convert_markdown_to_vikunja_html(markdown_text: str) -> str:
    """Converts markdown to standard HTML matching CommonMark conventions."""
    md = MarkdownIt("commonmark", {"html": True, "breaks": True}).enable('table')
    md.use(tasklists_plugin)
    return md.render(markdown_text).strip()


def convert_vikunja_html_to_markdown(html_text: str) -> str:
    """Converts standard HTML elements back into readable markdown for LLM context processing."""
    if not html_text:
        return ""

    # markdownify cleanly strips block tags, handles breaks, and formats nested list indices
    markdown_out = md_convert(
        html_text, heading_style="ATX", bullets="-", strip=["script", "style"]
    )
    return markdown_out.strip()


def resolve_project_ids() -> list:
    """Discovers project IDs matching targets, auto-creating missing ones."""
    resolved_ids = []
    monitored_project_list = [
        name.strip().lower() for name in settings.VIKUNJA_PROJECT_NAMES.split(",") if name.strip()
    ]
    try:
        with httpx.Client(verify=False, timeout=10.0) as client:
            # 1. Fetch current projects
            response = client.get(
                f"{settings.VIKUNJA_API_URL}/projects", headers=settings.VIKUNJA_HEADERS
            )
            existing_projects = {}
            if response.status_code == 200:
                for proj in response.json() or []:
                    title = proj.get("title", "").strip()
                    existing_projects[title.lower()] = {
                        "id": proj.get("id"),
                        "title": title,
                    }

            # 2. Iterate through expected target names
            for target in monitored_project_list:
                if target in existing_projects:
                    resolved_ids.append(existing_projects[target]["id"])
                else:
                    logger.info(
                        f"[Project Setup] Provisioning missing required workspace: '{target}'"
                    )
                    payload = {"title": target}
                    create_res = client.put(
                        f"{settings.VIKUNJA_API_URL}/projects",
                        headers=settings.VIKUNJA_HEADERS,
                        json=payload,
                    )
                    if create_res.status_code in [200, 201]:
                        new_id = create_res.json().get("id")
                        logger.info(
                            f"[Project Setup] -> Success! Created '{target}' (ID: {new_id})"
                        )
                        resolved_ids.append(new_id)
                        # Add backoff/sleep to prevent 429 rate limits
                        time.sleep(5)
                    else:
                        raise RuntimeError(
                            f"[Project Setup] Critical error creating project '{target}': {create_res.text}"
                        )
    except Exception as e:
        raise RuntimeError(f"[Project Setup] Critical auto-discovery error: {e}")
    return resolved_ids


def populate_vikunja_project_cache(project_ids_list: list):
    """Pre-maps layout views to clear dynamic lookup overhead."""
    logger.info(
        "[Cache Initialization] Constructing static bucket metadata registry..."
    )
    global VIKUNJA_PROJECT_CACHE
    try:
        with httpx.Client(verify=False, timeout=10.0) as client:
            for p_id in project_ids_list:
                view_id_kanban = None
                bucket_id_todo = None
                bucket_id_doing = None
                bucket_id_review = None
                view_title = None
                layout_map = {}

                # Get project title
                proj_res = client.get(
                    f"{settings.VIKUNJA_API_URL}/projects/{p_id}", headers=settings.VIKUNJA_HEADERS
                )
                project_title = (
                    proj_res.json().get("title", "Unknown")
                    if proj_res.status_code == 200
                    else "Unknown"
                )

                views_res = client.get(
                    f"{settings.VIKUNJA_API_URL}/projects/{p_id}/views", headers=settings.VIKUNJA_HEADERS
                )
                if views_res.status_code != 200 or not views_res.json():
                    logger.warning(
                        f" -> No views found for Project '{project_title}' (ID: {p_id})"
                    )
                    continue

                for view in views_res.json() or []:
                    if view.get("view_kind") == "kanban":
                        view_id_kanban = view.get("id")
                        view_title = view.get(
                            "title", f"Kanban-View-{view_id_kanban}"
                        )
                        break

                if view_id_kanban:
                    buckets_res = client.get(
                        f"{settings.VIKUNJA_API_URL}/projects/{p_id}/views/{view_id_kanban}/buckets",
                        headers=settings.VIKUNJA_HEADERS,
                    )
                    if buckets_res.status_code != 200:
                        logger.warning(
                            f" -> No buckets found for Project '{project_title}' (ID: {p_id})"
                        )
                        continue
                    for bucket in buckets_res.json() or []:
                        title_clean = bucket.get("title", "").strip().lower()
                        layout_map[title_clean] = bucket.get("id")

                        if title_clean == "to-do":
                            bucket_id_todo = bucket.get("id")
                        elif title_clean == "doing":
                            bucket_id_doing = bucket.get("id")
                        elif title_clean == "review":
                            bucket_id_review = bucket.get("id")

                VIKUNJA_PROJECT_CACHE[p_id] = {
                    "title": project_title,
                    "view_id_kanban": view_id_kanban,
                    "view_title": view_title,
                    "bucket_id_todo": bucket_id_todo,
                    "bucket_id_doing": bucket_id_doing,
                    "bucket_id_review": bucket_id_review,
                    "layout_map": layout_map
                }
                logger.info(
                    f"[Cache Engine] Hydrated routing table layout for Project '{project_title}' (ID: {p_id}): {VIKUNJA_PROJECT_CACHE[p_id]}"
                )
    except Exception as e:
        raise RuntimeError(f"[Cache Engine] Cache pre-mapping failure: {e}")
    logger.info(f"[Cache Engine] VIKUNJA_PROJECT_CACHE => {VIKUNJA_PROJECT_CACHE}")
    # logger.debug(f"[Cache Engine] VIKUNJA_PROJECT_CACHE => \n{prettyprint(VIKUNJA_PROJECT_CACHE)}")


def fetch_next_kanban_task(monitored_project_ids: list) -> dict:
    """Pulls next active work queue targets residing inside designated To-Do lane columns."""
    try:
        with httpx.Client(verify=False, timeout=10.0) as client:
            for p_id in monitored_project_ids:
                cache_meta = VIKUNJA_PROJECT_CACHE.get(p_id, {})
                project_name = cache_meta.get("title")
                view_id_kanban = cache_meta.get("view_id_kanban")
                bucket_id_todo = cache_meta.get("bucket_id_todo")
                if not bucket_id_todo:
                    logger.warning(
                        f"Skipping Project {project_name} - no todo bucket found"
                    )
                    continue

                endpoint = f"{settings.VIKUNJA_API_URL}/projects/{p_id}/views/{view_id_kanban}/tasks?filter=bucket_id={bucket_id_todo}"
                tasks_res = client.get(endpoint, headers=settings.VIKUNJA_HEADERS)
                if tasks_res.status_code != 200 or not tasks_res.json():
                    logger.info(
                        f"Skipping Project {project_name} - no todo tasks found"
                    )
                    # Add backoff/sleep to prevent 429 rate limits
                    time.sleep(5)
                    continue

                for task in tasks_res.json():
                    t_display_id = get_task_display_id(task)
                    # labels = task.get("labels", []) or []
                    #
                    # # Skip if already processed
                    # if any(
                    #     label.get("title", "").lower() in [TASK_LABEL_SUCCESS, TASK_LABEL_FAILED]
                    #     for label in labels
                    # ):
                    #     logger.debug(
                    #         f"[Polling] Skipping Task {t_display_id} (already processed)"
                    #     )
                    #     continue

                    logger.info(
                        f"[Polling] ✅ Claiming unprocessed Task {t_display_id} in '{project_name}' [{p_id}]"
                    )
                    return task

                # Add backoff/sleep to prevent 429 rate limits
                time.sleep(5)
    except Exception as e:
        raise RuntimeError(f"[Polling Engine] Queue query exception: {e}")
    return None


def move_task_to_bucket(task_data: dict, target_bucket_name: str):
    """Moves Vikunja cards dynamically across kanban lanes."""
    task_id = task_data.get("id")
    t_project_id = task_data.get("project_id")
    t_display_id = get_task_display_id(task_data)
    bucket_name = target_bucket_name.lower()

    cache_meta = VIKUNJA_PROJECT_CACHE.get(t_project_id, {})
    if not cache_meta:
        logger.error(
            f"[State Machine API] Project ID {t_project_id} not found in cache for Task {t_display_id}"
        )
        return

    view_id_kanban = cache_meta.get("view_id_kanban")
    layout_map = cache_meta.get("layout_map", {})

    if not layout_map or bucket_name not in layout_map:
        logger.error(
            f"[State Machine API] Project ID {t_project_id} and bucket {bucket_name} not found in cache for Task {t_display_id}"
        )
        return

    target_bucket_id = layout_map[bucket_name]
    logger.info(
        f"[State Machine API] Moving Task {t_display_id} to '{bucket_name}' column..."
    )

    endpoint = f"{settings.VIKUNJA_API_URL}/projects/{t_project_id}/views/{view_id_kanban}/buckets/{target_bucket_id}/tasks"
    payload = {"task_id": int(task_id)}
    try:
        with httpx.Client(verify=False) as client:
            res = client.post(
                endpoint, headers=settings.VIKUNJA_HEADERS, json=payload
            )
            if res.status_code in [200, 201]:
                logger.info(
                    f"[State Machine API] ✅ Advance to {bucket_name} succeeded for Task {t_display_id}"
                )
            else:
                raise RuntimeError(f"[State Machine API] Shift failed: {res.text}")
    except Exception as e:
        raise RuntimeError(f"[State Machine API] Task bucket shift aborted: {e}")


def get_label_id(title: str, hex_color: str = "#4CAF50") -> int:
    """Ensures a label with the given title exists globally in Vikunja."""

    # 1. Fetch all existing global labels
    labels_url = f"{settings.VIKUNJA_API_URL}/labels"
    try:
        with httpx.Client(timeout=10.0) as client:
            response = client.get(labels_url, headers=settings.VIKUNJA_HEADERS)
            if response.status_code == 200:
                existing_labels = response.json() or []
                for label in existing_labels:
                    if label.get("title") == title:
                        return label["id"]

            # 2. Label doesn't exist globally; create it
            logger.info(
                f"[Label Manager] Global label '{title}' not found. Creating new instance..."
            )
            create_payload = {"title": title, "hex_color": hex_color.lstrip("#")}
            create_res = client.put(
                labels_url, headers=settings.VIKUNJA_HEADERS, json=create_payload
            )

            if create_res.status_code in [200, 201]:
                return create_res.json()["id"]
            else:
                raise RuntimeError(
                    f"Failed to create global label '{title}'. Status: {create_res.status_code}, Response: {create_res.text}"
                )
    except Exception as e:
        raise RuntimeError(f"Failed to ensure global label '{title}': {e}")


def add_task_label(task_data: dict, label_title: str, hex_color: str = "#4CAF50"):
    """Applies target metadata status tracking tag identifier elements onto execution keys."""
    task_id = task_data.get("id")
    t_display_id = get_task_display_id(task_data)

    try:
        label_id = get_label_id(title=label_title, hex_color=hex_color)
        label_payload = {"label_id": label_id}
        with httpx.Client(timeout=10.0) as client:
            label_res = client.put(
                f"{settings.VIKUNJA_API_URL}/tasks/{task_id}/labels",
                headers=settings.VIKUNJA_HEADERS,
                json=label_payload,
            )
            if label_res.status_code in [200, 201]:
                logger.info(
                    f"[Post Resolution] Tagged Task {t_display_id} as '{label_title}'"
                )
    except Exception as e:
        raise RuntimeError(
            f"[Label Engine] Label tagging mutation failed for Task {task_id}: {e}"
        )


def post_kanban_comment(task_id, comment_body_markdown):
    """Appends Markdown summary commentary updates back onto running cards uniformly."""
    endpoint = f"{settings.VIKUNJA_API_URL}/tasks/{task_id}/comments"

    # Convert the complete document cleanly into Vikunja-compatible HTML
    comment_body = convert_markdown_to_vikunja_html(comment_body_markdown)

    # 5. Deliver the final payload cleanly as raw HTML text
    comment_payload = {"comment": comment_body}
    try:
        with httpx.Client(verify=False, timeout=10.0) as client:
            c_res = client.put(
                endpoint,
                headers=settings.VIKUNJA_HEADERS,
                json=comment_payload
            )
            if c_res.status_code in [200, 201]:
                logger.info(
                    f"[State Machine API] ✅ Comment successfully attached to Task ID {task_id}"
                )
            else:
                logger.error(
                    f"[State Machine API] Failed attaching comment to Task ID {task_id}: {c_res.status_code}"
                )
    except Exception as e:
        raise RuntimeError(f"[State Machine API] Error pushing comment: {e}")


def attach_execution_context_to_task(t_id: int, index: int, context_data: dict):
    """Serializes execution environment to YAML and registers it as an agent-only state attachment."""
    try:
        yaml_payload = yaml.safe_dump(
            context_data, default_flow_style=False, sort_keys=False
        )
        filename = f"agent-execution-context-{index}.yaml"

        files = {
            "files": (filename, yaml_payload.encode("utf-8"), "application/x-yaml")
        }
        attach_headers = {"Authorization": f"Bearer {settings.VIKUNJA_BEARER_TOKEN}"}

        with httpx.Client(timeout=15.0) as client:
            res = client.put(
                f"{settings.VIKUNJA_API_URL}/tasks/{t_id}/attachments",
                headers=attach_headers,
                files=files,
            )
            if res.status_code in [200, 201]:
                logger.info("[State Memory] Successfully saved telemetry context attachment.")
            else:
                logger.error(f"[State Memory] Failed storing execution context: {res.text}")
    except Exception as e:
        logger.error(f"[State Memory] Exception occurred pushing task context data: {e}")
