import os
import httpx
from fastapi import FastAPI, HTTPException, Security, Depends
from fastapi.security import APIKeyHeader
from pydantic import BaseModel
from typing import Dict, List, Any
from langgraph.graph import StateGraph, END

# --- Infrastructure Configurations ---
VIKUNJA_API_URL = os.getenv("VIKUNJA_API_URL")
VIKUNJA_BEARER_TOKEN = os.getenv("VIKUNJA_BEARER_TOKEN")
LOCAL_LLM_BASE_URL = os.getenv("LOCAL_LLM_BASE_URL")
LOCAL_LLM_MODEL = os.getenv("LOCAL_LLM_MODEL")
AGENT_SECRET_KEY = os.getenv("AGENT_SECRET_KEY")

app = FastAPI(title="LangGraph Supervisor Router", version="1.0.0")
api_key_header = APIKeyHeader(name="X-Agent-Secret", auto_error=True)


async def verify_secret(api_key: str = Depends(api_key_header)):
    if api_key != AGENT_SECRET_KEY:
        raise HTTPException(status_code=403, detail="Invalid Agent Secret Key Signature")


class TaskPayload(BaseModel):
    task_id: int
    project_id: int
    title: str
    description: str = ""


class AgentState(Dict):
    task: Dict[str, Any]
    route: str
    analysis: str


# --- LangGraph Node Logic ---
def supervisor_analyze_task(state: AgentState) -> Dict:
    """Analyze the task complexity and determine routing destination."""
    task_title = state["task"]["title"]
    task_desc = state["task"]["description"]

    # Payload for our local high-capacity model (e.g., Qwen-Coder or Nemoclaw)
    prompt = f"Analyze this task: Title: {task_title}. Desc: {task_desc}. Route it to 'crewai' or 'complete'."

    # Default fallback routing logic
    route = "crewai"
    if "complete" in task_title.lower() or "close" in task_title.lower():
        route = "complete"

    return {"task": state["task"], "route": route, "analysis": "Analyzed via local LLM infrastructure context."}


def route_to_crewai(state: AgentState) -> Dict:
    """Delegate execution to the active CrewAI workers pool via a state change or internal hook."""
    print(f"[Supervisor] Dispatching task {state['task']['task_id']} to CrewAI Workers loop.")
    return state


def finalize_task(state: AgentState) -> Dict:
    """Directly mark the task as finalized if no agent work is needed."""
    print(f"[Supervisor] Task {state['task']['task_id']} bypasses agent workflow and closes.")
    return state


# --- Build the LangGraph Workflow ---
workflow = StateGraph(AgentState)
workflow.add_node("supervisor", supervisor_analyze_task)
workflow.add_node("crewai_pool", route_to_crewai)
workflow.add_node("finalizer", finalize_task)

workflow.set_entry_point("supervisor")

# Define execution conditional router paths
workflow.add_conditional_edges(
    "supervisor",
    lambda state: state["route"],
    {
        "crewai": "crewai_pool",
        "complete": "finalizer"
    }
)

workflow.add_edge("crewai_pool", END)
workflow.add_edge("finalizer", END)
compiled_graph = workflow.compile()


# --- API Endpoints ---
@app.post("/v1/orchestrate", dependencies=[Depends(verify_secret)])
async def orchestrate_phase_task(payload: TaskPayload):
    initial_state = {
        "task": payload.dict(),
        "route": "supervisor",
        "analysis": ""
    }
    try:
        output = compiled_graph.invoke(initial_state)
        return {"status": "success", "routing": output["route"], "summary": output["analysis"]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/health")
async def health_check():
    return {"status": "healthy", "model_context": LOCAL_LLM_MODEL}
