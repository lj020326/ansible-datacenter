import os
import time
import httpx
from crewai import Agent, Task, Crew, Process

# --- Core Infrastructure Parameters ---
VIKUNJA_API_URL = os.getenv("VIKUNJA_API_URL")
VIKUNJA_BEARER_TOKEN = os.getenv("VIKUNJA_BEARER_TOKEN")
LOCAL_LLM_BASE_URL = os.getenv("LOCAL_LLM_BASE_URL")
LOCAL_LLM_MODEL = os.getenv("LOCAL_LLM_MODEL")

print(f"[CrewAI Daemon] Initializing cluster worker targeting model: {LOCAL_LLM_MODEL}")

headers = {
    "Authorization": f"Bearer {VIKUNJA_BEARER_TOKEN}",
    "Content-Type": "application/json"
}


def fetch_next_kanban_task():
    """Polls the Vikunja API for unassigned tasks in the active phase project blocks."""
    try:
        with httpx.Client(timeout=10.0) as client:
            # Fetch tasks from Vikunja global list
            response = client.get(f"{VIKUNJA_API_URL}/tasks", headers=headers)
            if response.status_code == 200:
                tasks = response.json()
                # Find an uncompleted task that needs processing
                for task in tasks:
                    if not task.get("is_done") and "agent-processed" not in task.get("description", ""):
                        return task
    except Exception as e:
        print(f"[CrewAI Daemon Error] Failed to connect to Vikunja: {e}")
    return None


def update_vikunja_task(task_id: int, original_desc: str, resolution: str):
    """Appends execution results back into Vikunja and flags the task as handled."""
    updated_desc = f"{original_desc}\n\n### [Agent Execution Result]\n{resolution}\n\n"
    payload = {
        "description": updated_desc,
        "is_done": True
    }
    try:
        with httpx.Client() as client:
            res = client.post(f"{VIKUNJA_API_URL}/tasks/{task_id}", headers=headers, json=payload)
            if res.status_code == 200:
                print(f"[CrewAI Daemon] Successfully synchronized and resolved Task #{task_id} on Vikunja.")
    except Exception as e:
        print(f"[CrewAI Daemon Error] Failed to update Vikunja task #{task_id}: {e}")


def execute_crewai_workflow(task_title: str, task_description: str) -> str:
    """Spins up a specialized crew context dynamically to execute the task."""

    # Configure the Agent to target your local server cluster
    analyst_agent = Agent(
        role="Automation Engineer",
        goal="Deconstruct technical infrastructure tasks and formulate execution scripts.",
        backstory="An automated system expert deployed to manage internal homelab and cluster orchestrations.",
        verbose=True,
        allow_delegation=False,
        llm={
            "model": LOCAL_LLM_MODEL,
            "base_url": LOCAL_LLM_BASE_URL,
            "api_key": "ollama"  # Standard placeholder for local endpoints
        }
    )

    execution_task = Task(
        description=f"Process this work item:\nTitle: {task_title}\nContext: {task_description}",
        expected_output="A definitive step-by-step resolution strategy or operational log output.",
        agent=analyst_agent
    )

    crew = Crew(
        agents=[analyst_agent],
        tasks=[execution_task],
        process=Process.sequential
    )

    return crew.kickoff()


# --- Main Runtime Daemon Loop ---
if __name__ == "__main__":
    print("[CrewAI Daemon] Worker group successfully online. Entering continuous polling sequence...")
    while True:
        target_task = fetch_next_kanban_task()

        if target_task:
            t_id = target_task["id"]
            t_title = target_task["title"]
            t_desc = target_task.get("description", "")

            print(f"\n[CrewAI Daemon] Claiming Task #{t_id}: '{t_title}'")

            # Execute agent logic
            result = execute_crewai_workflow(t_title, t_desc)

            # Sync findings back up to Vikunja
            update_vikunja_task(t_id, t_desc, str(result))

        else:
            # Idle sleep to keep from throttling API interfaces
            time.sleep(15)
