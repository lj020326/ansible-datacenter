# `llm-utils.sh` — Multi-Endpoint LLM Management Utility

`llm-utils.sh` is a lightweight Bash script designed to manage and inspect multiple LLM endpoints (Ollama and vLLM) from a single command-line interface. It handles authentication schemes (Bearer tokens for vLLM and Basic Auth for Ollama behind reverse proxies like Traefik), redacts credentials from output logs, and simplifies model listing, running status checks, downloading, and removal.

---

## Features

* **Multi-Endpoint Support**: Iterates through multiple pre-configured Ollama and vLLM instances automatically.
* **Smart Authentication Handling**:
  * **vLLM**: Supports standard `Authorization: Bearer <token>` authentication.
  * **Ollama**: Supports Traefik Basic Auth via `user:pass` string encoding or pre-encoded Base64 keys.
* **Credential Masking**: Redacts sensitive API keys and authorization headers in execution log outputs.
* **Clean Formatting**: Defaults to listing model names line-by-line, with an optional `--json` flag to inspect full API responses.
* **Network Safety**: Enforces connection timeouts (`--connect-timeout 5`, `--max-time 15`) to prevent hangs when endpoints are unreachable.

---

## Prerequisites

Ensure the following dependencies are installed on your machine:

* `bash` (v4.0+)
* `curl`
* `jq`
* `sed` / `base64`

---

## Environment Setup

Export the following environment variables in your shell (or include them in your `.bashrc` / `.zshrc`):

```bash
export VLLM_API_URL="[https://vllm.llm-gb10.johnson.int/v1](https://vllm.llm-gb10.johnson.int/v1)"
export VLLM_API_KEY="your-vllm-api-key"

export OLLAMA_API_URL="[https://ollama.llm-rtx.johnson.int](https://ollama.llm-rtx.johnson.int)"
export OLLAMA_API_KEY="username:password" # or pre-encoded Base64 string
```

---

## Usage

### Syntax

```bash
./llm-utils.sh [-j|--json] [-e|--endpoint <url>] [action] [model_name]
```

### Options & Flags

| Flag | Description |
| :--- | :--- |
| `-j`, `--json` | Output raw, pretty-printed JSON instead of the simplified model list. |
| `-e`, `--endpoint <URL>` | Target a specific endpoint URL instead of looping through all default endpoints. |

---

## Available Actions

### 1. `display` / `ls` / `list` *(Default Action)*
Lists available and installed models across all configured endpoints.

```bash
# Clean list output (Default)
./llm-utils.sh

# Display full raw JSON responses
./llm-utils.sh --json

# Query a single specific endpoint
./llm-utils.sh -e [https://ollama.llm-gb10.johnson.int](https://ollama.llm-gb10.johnson.int) display
```

### 2. `ps` / `running`
Displays currently loaded/running models in memory across all Ollama endpoints (`/api/ps`).

```bash
./llm-utils.sh ps
```

### 3. `pull` / `download` `<model_name>`
Triggers a model pull operation on all configured Ollama endpoints.

```bash
./llm-utils.sh pull mistral:latest
```

### 4. `remove` / `rm` / `delete` `<model_name>`
Deletes the specified model from Ollama endpoints. *(Note: vLLM does not support dynamic weight deletion over its HTTP server API)*.

```bash
./llm-utils.sh remove llama3.1:8b
```

---

## Default Endpoints Configuration

By default, if no target is specified using the `-e` flag, `llm-utils.sh` runs commands against:

1. `${OLLAMA_API_URL}` *(Defaults to `https://ollama.llm-rtx.johnson.int`)*
2. `${VLLM_API_URL}` *(Defaults to `https://vllm.llm-gb10.johnson.int/v1`)*
3. `https://ollama.llm-gb10.johnson.int`
