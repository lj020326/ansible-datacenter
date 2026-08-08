#!/usr/bin/env python3
"""
langgraph_router/main.py - Optimized for speed + reliability
"""

import time
import logging
from fastapi import FastAPI, HTTPException, Header, Depends
from fastapi.security import APIKeyHeader
from langchain_openai import ChatOpenAI
from langgraph.graph import StateGraph, START, END
from pydantic import BaseModel, Field
from typing import TypedDict, Literal
import os
import uvicorn

# ========================= LOGGING =========================
logging.basicConfig(
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
    level=logging.INFO,
)

LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
logger = logging.getLogger("langgraph_router")
logger.setLevel(logging.INFO)

numeric_level = getattr(logging, LOG_LEVEL, logging.INFO)
logger.setLevel(numeric_level)
logger.info(f"Starting with log level: {LOG_LEVEL}")

# --- Schemas ---
class SupervisorState(TypedDict):
    task_id: int
    project_id: int
    title: str
    description: str
    complexity: Literal["low", "medium", "high"]
    routing_target: Literal["fast_path", "crewai_heavy", "blocked"]
    blueprint: str
    rejection_reason: str
    start_time: float = 0.0


# --- Output Schemas for LLM Structured Outputs ---
class TaskAnalysis(BaseModel):
    complexity: Literal["low", "medium", "high"] = Field(
        description="Assessment of task scope and execution dependencies."
    )
    routing_target: Literal["fast_path", "crewai_heavy", "blocked"] = Field(
        description="Determines execution pathway. 'fast_path' for simple text/docs, 'crewai_heavy' for code changes/testing."
    )
    analysis_reasoning: str = Field(
        description="Justification for chosen complexity and routing path."
    )


class ExecutionBlueprint(BaseModel):
    blueprint_markdown: str = Field(
        description="Strict step-by-step markdown plan targeting ONLY the files mentioned."
    )


# --- Configuration & LLM Binding ---
LOCAL_LLM_BASE_URL = os.getenv("LOCAL_LLM_BASE_URL", "http://localhost:8000/v1")
LOCAL_LLM_MODEL = os.getenv("LOCAL_LLM_MODEL", "nemoclaw")
API_KEY = os.getenv("LOCAL_LLM_API_KEY", "mock-key")

shared_llm = ChatOpenAI(
    model=os.getenv("LOCAL_LLM_MODEL", "nemoclaw"),
    base_url=os.getenv("LOCAL_LLM_BASE_URL", "http://localhost:8000/v1"),
    api_key=os.getenv("LOCAL_LLM_API_KEY", "mock-key"),
    temperature=0.0,
    max_tokens=512,          # Smaller for blueprint
)


# --- Graph Nodes ---
def analyze_task_node(state: SupervisorState) -> SupervisorState:
    """Classifies task complexity and routes to the appropriate pipeline."""
    start = time.time()
    logger.info(f"[Analyze] Starting analysis for Task {state.get('task_id')}")

    analyzer_llm = shared_llm.with_structured_output(TaskAnalysis)

    prompt = f"Quick classify only. Title: {state['title']}\nDesc: {state['description'][:300]}"

    try:
        analysis = analyzer_llm.invoke(prompt)
        # Update state slice
        state["complexity"] = analysis.complexity
        state["routing_target"] = analysis.routing_target
    except Exception as e:
        logger.warning(f"[Analyze] LLM failed: {e}")
        # Secure fallback
        state["complexity"] = "medium"
        state["routing_target"] = "crewai_heavy"

    duration = time.time() - start
    logger.info(f"[Analyze] Completed in {duration:.2f}s → {state['routing_target']}")
    return state


def generate_blueprint_node(state: SupervisorState) -> SupervisorState:
    """Generates a structured execution blueprint for the targeted files."""
    start = time.time()
    logger.info(f"[Blueprint] Generating for Task {state.get('task_id')}")

    blueprint_llm = shared_llm.with_structured_output(ExecutionBlueprint)

    prompt = f"Very short plan. Title: {state['title']}\nDesc: {state['description'][:400]}"

    try:
        blueprint_output = blueprint_llm.invoke(prompt)
        state["blueprint"] = blueprint_output.blueprint_markdown
    except Exception as e:
        logger.warning(f"[Blueprint] LLM failed: {e}")
        state["blueprint"] = (
            "Fallback blueprint: Proceed with standard implementation checks."
        )

    logger.info(f"[Blueprint] Done in {time.time()-start:.1f}s")
    return state


def finalize_fast_path_node(state: SupervisorState) -> SupervisorState:
    """Handles fast-path routing by drafting direct solutions immediately."""
    logger.info(f"[FastPath] Finalizing Task {state.get('task_id')}")
    blueprint_content = state.get("blueprint", "")
    state["blueprint"] = (
        f"### FAST-PATH DIRECT RESOLUTION\n{blueprint_content}\nNo heavy agents required."
    )
    return state


# --- Conditional Edges ---
def route_after_analysis(
    state: SupervisorState,
) -> Literal["generate_blueprint_node", "__end__"]:
    if state["routing_target"] == "blocked":
        return "__end__"
    return "generate_blueprint_node"


def route_after_blueprint(
    state: SupervisorState,
) -> Literal["finalize_fast_path_node", "__end__"]:
    if state["routing_target"] == "fast_path":
        return "finalize_fast_path_node"
    return "__end__"


# --- Build Graph ---
workflow = StateGraph(SupervisorState)
workflow.add_node("analyze_task_node", analyze_task_node)
workflow.add_node("generate_blueprint_node", generate_blueprint_node)
workflow.add_node("finalize_fast_path_node", finalize_fast_path_node)

workflow.add_edge(START, "analyze_task_node")
workflow.add_conditional_edges("analyze_task_node", route_after_analysis)
workflow.add_conditional_edges("generate_blueprint_node", route_after_blueprint)
workflow.add_edge("finalize_fast_path_node", END)

app_graph = workflow.compile()

# --- FastAPI Router Deployment ---
app = FastAPI(title="LangGraph Router")
api_key_header = APIKeyHeader(name="X-Agent-Secret", auto_error=True)
ROUTER_API_KEY = os.getenv("LANGGRAPH_API_KEY", "secure-secret")


def verify_token(x_agent_secret: str = Header(None)):
    if not x_agent_secret or x_agent_secret != ROUTER_API_KEY:
        raise HTTPException(status_code=403, detail="Unauthorized")


@app.on_event("startup")
async def warmup_graph():
    """Warm up the LangGraph + LLM connection at service start."""
    logger.info("[Router] Warming up LangGraph + LLM connection...")
    try:
        warmup_state = {
            "task_id": 0,
            "project_id": 0,
            "title": "warmup",
            "description": "Initial connection test.",
            "complexity": "low",
            "routing_target": "fast_path",
            "blueprint": "",
            "rejection_reason": "",
        }
        await app_graph.ainvoke(warmup_state)
        app_graph._first_run_done = True
        logger.info("[Router] ✅ Graph warm-up completed successfully.")
    except Exception as e:
        logger.warning(f"[Router] Warm-up failed (non-critical): {e}")

@app.post("/v1/orchestrate")
async def orchestrate_task(payload: dict, _=Depends(verify_token)):
    start_total = time.time()
    logger.info(f"[Orchestrate] Received Task {payload.get('task_id')}")

    initial_state: SupervisorState = {
        "task_id": payload.get("task_id"),
        "project_id": payload.get("project_id"),
        "title": payload.get("title", ""),
        "description": payload.get("description", ""),
        "complexity": "medium",
        "routing_target": "crewai_heavy",
        "blueprint": "",
        "rejection_reason": "",
        "start_time": start_total,
    }

    try:
        logger.info(f"[Router] Received task: {payload.get('title')}")

        # Warm-up (once)
        if not hasattr(app_graph, "_first_run_done"):
            logger.warning("[Router] graph not warmed up yet...")

        result = await app_graph.ainvoke(initial_state, {"recursion_limit": 10})
        duration = time.time() - start_total
        logger.info(f"[Orchestrate] Completed in {duration:.2f}s → {result.get('routing_target')}")

        return {
            "routing": result.get("routing_target"),
            "complexity": result.get("complexity"),
            "blueprint": result.get("blueprint", ""),
            "summary": f"Processed in {duration:.1f}s",
        }
    except Exception as e:
        logger.error(f"[Orchestrate] Failed Task {task_id}: {e}", exc_info=True)
        # Safe fallback
        return {
            "routing": "crewai_heavy",
            "complexity": "medium",
            "blueprint": "Fallback: Run full CrewAI.",
        }


@app.get("/health")
async def health():
    return {"status": "healthy"}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
