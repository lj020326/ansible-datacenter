```markdown
---
title: Agent Execution Pipeline & Inference Testing Guide
original_path: roles/bootstrap_docker_stack/files/llm_agent/README.md
category: Documentation
tags: [agent-pipeline, inference-testing, vllm-coder]
---

# Agent Execution Pipeline & Inference Testing Guide

This directory (`agent_stack/`) contains configuration and orchestration components for driving localized multi-agent task execution workloads against local high-throughput inference stacks (`vllm-coder`).

Follow this document to clear out stale agent states, verify runtime configurations, query backend models, and monitor real-time execution pipelines.

## Prerequisites & Environment Setup

All execution scripts depend on Python modules isolated inside the global Ansible system-level virtual environment, as well as an environment file mapping configuration values such as backend endpoints and API tokens.

First, navigate to your base configuration context and activate the virtual environment:

```shell
# Navigate to deployment working directory
cd /home/container-user/docker

# Activate the shared python virtual environment
source /usr/local/lib/ansible/venv/bin/activate
```

Next, source the environment profile containing authorization credentials (`OPENAI_API_KEY`), custom endpoints, and target routes required by your local crew frameworks:

```shell
# Load the API token and stack routing specifications
source agent_stack/test_agent_pipeline.env
```

## Health Check: Validating Local vLLM Inference Models

Before launching task execution workflows, verify that your localized inference node (`vllm-coder`) is responding successfully and exposing the expected aliases (e.g., `nemoclaw`).

Run a validation request against the endpoints authenticated with the token you sourced above:

```shell
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

## Running Execution Test Scenarios

To process a deterministic pipeline validation run without task overlap from previous testing residue, clean target task queues if necessary, and execute the standard automated testing runner:

```shell
# Trigger the verification pipeline via the testing harness script
python3 agent_stack/test_agent_pipeline.py
```

## Real-Time Distributed Logging & Pipeline Monitoring

Multi-agent coordination layers execute concurrently across separated worker instances and context routers. While your test script runs in your primary interactive shell terminal, open an alternating terminal window on `gpu01` to view live streaming telemetry:

```shell
# Stream combined logs for agent orchestration, prompt routing, and inference layers
docker-compose logs -f crewai-workers langgraph-router vllm-coder
```

### Telemetry Performance Metrics to Watch

- **Triton kernel JIT compilation**: May cause a momentary early execution pause while kernel compilation completes shapes during initial warmup.
- **Prefix cache hit rate**: Shows cache retention efficiency across multiple turns. High percentages (~48%+) denote successful prompt reuse without processing penalties.
- **Avg generation throughput**: Displays hardware generation speed over active text processing loops.
- **Agent Final Answer**: Confirms context compilation completeness and structured completion returns.

## Agent Engineering Team Workflow

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

## Backlinks

- [Agent Stack Overview](../README.md)
- [System Architecture Documentation](../../architecture.md)
```

This improved version includes a standardized YAML frontmatter, clear headings, and a "Backlinks" section for better navigation.