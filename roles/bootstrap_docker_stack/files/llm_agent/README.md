
# Agent Execution Pipeline & Inference Testing Guide

This directory (`agent_stack/`) contains configuration and orchestration components for driving localized multi-agent task execution workloads against local high-throughput inference stacks (`vllm-coder`).

Follow this document to clear out stale agent states, verify runtime configurations, query backend models, and monitor real-time execution pipelines.

---

## 1. Prerequisites & Environment Setup

All execution scripts depend on Python modules isolated inside the global Ansible system-level virtual environment, as well as an environment file mapping configuration values such as backend endpoints and API tokens.

First, navigate to your base configuration context and activate the virtual environment:

```shell
# Navigate to deployment working directory
cd /home/container-user/docker

# Activate the shared python virtual environment
source /usr/local/lib/ansible/venv/bin/activate
```

### Environment Variable Bootstrapping
The testing suite relies on a hybrid fallback strategy configuration. The suite uses an internal `load_env_file()` function that automatically checks for the presence of a local configuration file named `test_agent_pipeline.env` inside its directory structure. 

* If the `.env` file is present, its internal parameters are automatically injected into the execution space.
* If a given variable is already defined within your ambient shell context, the system-level shell value will take precedence.
* If no `.env` file exists, it falls back entirely to standard system environment exports.

To source your profile manually beforehand if desired:
```shell
# Load the API token and stack routing specifications
source agent_stack/test_agent_pipeline.env
```

---

## 2. Automated Test Framework (`pytest`)

The testing layer has been converted to a scalable, production-grade **`pytest`** suite. This enables multi-scenario lifecycle automation, automatic isolation cleanups, and seamless integration for AI testing assistants or specialized QA agents to drop in new functional edges.

### Test Architecture Modes
The test suite explicitly handles two fundamental agent execution patterns to guarantee the engine's edge cases are robustly evaluated:

1. **Read-Only Analysis (`test_read_only_analysis_flow`)**: Validates how the agent behaves given an analytical description. It asserts that the agent safely parses the workspace, updates tracking cards, appends telemetric data, and handles comments without introducing filesystem drift or triggering upstream Git pushes (`ANALYZED_NO_CHANGES`).
2. **Pull Request Generation (`test_pull_request_generation_flow`)**: Forces a code mutation lifecycle path by supplying task payload instructions that mandate local tool utilization (`write_code_component_file`). It asserts that the working directory dirties, pushes a tracked feature branch upstream, registers an active Gitea Pull Request link, and exposes the metadata back inside the tracking system (`PR_CREATED`).

### Shared Pipeline Assertions
Both execution pipelines validate strict technical criteria upon completion:
* **Comment Stream Sanitization**: Inspects comments left on task cards to ensure no raw LLM tool call schemas (e.g., `\"name\":` or `write_code_component_file`) leak out unscrubbed into user-facing text streams.
* **Context Payload Attaching**: Ensures an updated execution tracing context file (`agent_execution-context.yaml`) is generated and safely attached to the task target for audit logs.

### Execution Commands

```shell
# Execute the entire suite against the agent container infrastructure
pytest -v agent_stack/test_agent_pipeline.py

# Target an individual test path directly
pytest -v agent_stack/test_agent_pipeline.py::test_read_only_analysis_flow
pytest -v agent_stack/test_agent_pipeline.py::test_pull_request_generation_flow

# Suppress standard capture output and view real-time logging streams
pytest -s -v agent_stack/test_agent_pipeline.py
```

---

## 3. Health Check: Validating Local vLLM Inference Models

Before launching task execution workloads, verify that your localized inference node (`vllm-coder`) is responding successfully and exposing the expected aliases (e.g., `nemoclaw`).

Run a validation query directly via standard cURL requests:
```shell
curl http://localhost:8000/v1/models
## OR if secured with api key
curl -s -H "Authorization: Bearer ${OPENAI_API_KEY}" http://localhost:8000/v1/models | jq
```

### Expected JSON Response Matrix
A successful configuration returns an array matching the layout below, displaying both the parent base model signature and your operational system tag `nemoclaw`:

```json
{
  "object": "list",
  "data": [
    {
      "id": "Qwen/Qwen2.5-Coder-32B-Instruct-AWQ",
      "object": "model",
      "owned_by": "vllm",
      "max_model_len": 32768
    },
    {
      "id": "nemoclaw",
      "object": "model",
      "owned_by": "vllm",
      "max_model_len": 32768
    }
  ]
}
```

To tail real-time runtime processing logs or diagnostic health counters across active containers:
```shell
# Monitor combined cluster environment logs
docker-compose logs -f crewai-workers langgraph-router vllm-coder
```

### Telemetry Performance Metrics to Watch:
* **`Triton kernel JIT compilation`**: May cause a momentary early execution pause while kernel compilation completes shapes during initial warmup.
* **`Prefix cache hit rate`**: Shows cache retention efficiency across multiple turns. High percentages (~48%+) denote successful prompt reuse without processing penalties.
* **`Avg generation throughput`**: Displays hardware generation speed over active text processing loops.
* **`Agent Final Answer`**: Confirms context compilation completeness and structured completion returns.

---

## 4. Agent Engineering Team Workflow

The code team setup is an actionable Engineering Team that writes code directly to the ephemeral workspace, commits the changes via `GitPython`, pushes the feature branch back to `origin`, and returns a Gitea Pull Request URL.

Here is the architectural sequence for this workflow phase:

```text
[Vikunja Task Claimed] 
         │
         ▼
[Clone Gitea Repo & Clean Sanitized Branch]
         │
         ▼
[CrewAI: Engineer Tool writes file changes to /tmp/scratchpad]
         │
         ▼
[GitPython: stage changes ──> git commit ──> git push origin]
         │
         ▼
[Httpx Client: POST /api/v1/repos/.../pulls ──> Generate Gitea PR]
         │
         ▼
[Vikunja Card: Moved to Review + Commented with Pull Request URL Link]
```
