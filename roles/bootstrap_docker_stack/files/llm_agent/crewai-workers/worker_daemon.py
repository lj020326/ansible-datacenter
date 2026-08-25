#!/usr/bin/env python3
"""
worker_daemon.py

Daemon worker process that manages local LLM agent execution loops.
Uses CrewAI with structured custom tool classes for robust schema
enforcement, parameter validation, and secure execution.

Maintains background orchestration polling loops, local state/project caches,
Kanban state synchronizations, and automated GitOps task runners.
"""

import logging
import os
import sys
import time

from config import settings

from agent_core import (
    display_agent_api_telemetry_banner,
    process_gitops_task
)

from vikunja_api import (
    display_vikunja_api_telemetry_banner,
    fetch_next_kanban_task,
    get_task_display_id,
    populate_vikunja_project_cache,
    resolve_project_ids,
)

__scriptName__ = os.path.basename(sys.argv[0])

# ====================== LOGGING SETUP ======================
LOG_LEVEL_NUMERIC = getattr(logging, settings.LOG_LEVEL, logging.INFO)
logger = logging.getLogger(__scriptName__)
logging.basicConfig(
    format="%(name)s - %(levelname)-8s - %(message)s",
    handlers=[logging.StreamHandler()],
)
logger.setLevel(LOG_LEVEL_NUMERIC)

# Suppress noisy third-party loggers
for logger_noisy in ["httpcore", "urllib3", "openai"]:
    logging.getLogger(logger_noisy).setLevel(logging.WARNING)

for logger_helpful in ["httpx", "crewai", "vllm", "git", "litellm"]:
    logging.getLogger(logger_helpful).setLevel(logging.INFO)

# ===================================================================
# --- CORE DAEMON / WORKFLOW PIPELINE ENGINE ---
# ===================================================================


def display_api_telemetry_banner():
    """Outputs basic trace settings at server instantiation."""
    logger.info("=" * 70 + "\n")
    display_agent_api_telemetry_banner()
    display_vikunja_api_telemetry_banner()
    logger.info(f"Log level set to: {settings.LOG_LEVEL}")
    logger.info("=" * 70 + "\n")


# ====================== RECOMMENDED POLLED TASK HANDLER ======================
def process_polled_task(task_data: dict):
    """
    Processes an individual task claimed by the daemon workflow loop.
    Isolates run execution matrices and encapsulates exceptions safely.
    """
    agent_times = {}
    t_display_id = get_task_display_id(task_data)
    logger.info(f"[Daemon Engine] 🚀 Initiating multi-agent context layer for task {t_display_id}")
    try:
        process_gitops_task(task_data, agent_times)
        logger.info(f"[Daemon Engine] ✅ Task workflow processing finalized for {t_display_id}")
    except Exception as inner_ex:
        logger.error(f"[Daemon Engine] ❌ Critical processing failure on task {t_display_id}: {inner_ex}", exc_info=True)


def start_daemon_polling_loop():
    """Main polling lifecycle scanning for target cards."""

    # 1. Run environment inspection telemetry banner
    display_api_telemetry_banner()

    # Establish dynamic runtime target cache mapping
    scoped_project_ids = resolve_project_ids()

    # Simple sanity safety guard check
    if not scoped_project_ids:
        logger.error(
            "[Daemon Infrastructure] Active tracking targets list empty. Exiting."
        )
        return

    # Cache project layouts at boot time to eliminate repetitive layout discovery calls
    populate_vikunja_project_cache(scoped_project_ids)
    logger.info("[Daemon Engine] 🚀 Multi-Agent execution loop worker thread active.")

    while True:
        try:
            task_data = fetch_next_kanban_task(scoped_project_ids)
            if not task_data:
                time.sleep(settings.VIKUNJA_TASK_POLLING_INTERVAL)
                continue

            # Route execution to the task handler
            process_polled_task(task_data)
        except Exception as e:
            logger.error(
                f"[Daemon Core] Pipeline iteration exception: {e}", exc_info=True
            )

        time.sleep(settings.VIKUNJA_TASK_POLLING_INTERVAL)

# ===================================================================
# --- ENTRYPOINT ---
# ===================================================================


if __name__ == "__main__":
    start_daemon_polling_loop()
