#!/usr/bin/env bash

# Option Flags
SHOW_RAW_JSON=false
ACTION=""
ACTION_SET=false
MODEL_NAME=""
declare -a USER_ENDPOINTS=()

# Define Default Endpoints using Bash Associative Array
declare -A DEFAULT_ENDPOINTS=(
  ["${OLLAMA_API_URL:-https://ollama.llm-rtx.johnson.int}"]="ollama"
  ["${LLAMA_API_URL:-https://llama.llm-rtx.johnson.int/v1}"]="llama"
  ["${VLLM_API_URL:-https://vllm.llm-gb10.johnson.int/v1}"]="vllm"
  ["https://ollama.llm-gb10.johnson.int"]="ollama"
  ["https://llama.llm-gb10.johnson.int"]="llama"
  ["https://ollama.admin.johnson.int"]="ollama"
)

# Curl default options as an array
CURL_OPTS=(--connect-timeout 5 --max-time 15)

# Helper execution function using array-based arguments
function exec_curl() {
  local endpoint_type="$1"
  shift
  local curl_args=("$@")

  # Format command string for logging with quotes around arguments containing spaces
  local log_cmd="curl -sS"
  local skip_next_mask=false

  for ((i=0; i<${#curl_args[@]}; i++)); do
    local arg="${curl_args[i]}"

    if [[ "${skip_next_mask}" == "true" ]]; then
      log_cmd+=" '[REDACTED]'"
      skip_next_mask=false
    elif [[ "${arg}" == "-u" ]]; then
      log_cmd+=" -u"
      skip_next_mask=true
    elif [[ "${arg}" =~ [[:space:]] ]]; then
      log_cmd+=" '${arg}'"
    else
      log_cmd+=" ${arg}"
    fi
  done

  # Apply standard header redactions to printable log output
  local masked_cmd
  masked_cmd=$(echo "${log_cmd}" | sed -E \
    -e 's/Authorization: Bearer [^ '\''"]+/Authorization: Bearer [REDACTED]/g' \
    -e 's/Authorization: Basic [^ '\''"]+/Authorization: Basic [REDACTED]/g' \
    -e 's/-u '\''[^'\'']+'\''/-u '\''[REDACTED]'\''/g')

  echo ">>> Running: ${masked_cmd}"

  # Capture HTTP Status Code along with response body
  local tmp_file
  tmp_file=$(mktemp)

  local http_code
  http_code=$(curl -sS "${curl_args[@]}" -w '%{http_code}' -o "${tmp_file}" 2>&1)
  local RETURN_STATUS=$?
  local output
  output=$(cat "${tmp_file}")
  rm -f "${tmp_file}"

  if [[ $RETURN_STATUS -ne 0 ]]; then
    echo "ERROR (exit status ${RETURN_STATUS}):"
    echo "${http_code}"
  else
    # Status validation for health responses
    if [[ "${endpoint_type}" == "raw" || "${endpoint_type}" == "health" ]]; then
      if [[ "${http_code}" -ge 200 && "${http_code}" -lt 300 ]]; then
        echo "Status: OK (HTTP ${http_code})"
      else
        echo "Status: FAILED (HTTP ${http_code})"
      fi
    fi

    if [[ -n "${output}" ]]; then
      if echo "${output}" | jq . >/dev/null 2>&1; then
        if [[ "${SHOW_RAW_JSON}" == "true" ]]; then
          echo "${output}" | jq
        else
          # Extract model names by endpoint type
          case "${endpoint_type}" in
            ollama)
              echo "${output}" | jq -r '.models[]?.name // empty' | sed 's/^/ - /'
              ;;
            vllm|llama)
              echo "${output}" | jq -r '.data[]?.id // empty' | sed 's/^/ - /'
              ;;
            *)
              echo "${output}" | jq
              ;;
          esac
        fi
      else
        echo "${output}"
      fi
    fi
  fi
  echo ""
}

# Helper to populate auth flags array for Bearer Token Auth Headers (vLLM and Llama)
function get_bearer_auth_args() {
  local endpoint_type="$1"
  local key=""

  if [[ "${endpoint_type}" == "llama" ]]; then
    key="${LLAMA_API_KEY:-${VLLM_API_KEY}}"
  elif [[ "${endpoint_type}" == "vllm" ]]; then
    key="${VLLM_API_KEY}"
  fi

  if [[ -n "${key}" ]]; then
    echo "-H"
    echo "Authorization: Bearer ${key}"
  fi
}

# Helper to populate auth flags array for Ollama Basic Auth Header / Option
function get_ollama_auth_args() {
  if [[ -n "${OLLAMA_API_KEY}" ]]; then
    # If the key contains a colon, it's raw 'user:password'
    if [[ "${OLLAMA_API_KEY}" == *":"* ]]; then
      echo "-u"
      echo "${OLLAMA_API_KEY}"
    else
      echo "-H"
      echo "Authorization: Basic ${OLLAMA_API_KEY}"
    fi
  fi
}

# Function to display usage help and detailed command examples
function show_usage() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS] [COMMAND] [MODEL_NAME]

Multi-Endpoint LLM Server Management Utility.

OPTIONS:
  -h, --help                 Show this help message and exit.
  -j, --json                 Output raw, unformatted JSON responses from endpoints.
  -e, --endpoint <URL>       Specify a custom endpoint URL. Can be supplied multiple times.

COMMANDS:
  health | check             Check availability and health status across target endpoints.
  display | ls | list        List all downloaded/available models across all endpoints (Default action).
  ps | running               List currently loaded/running models in VRAM (Ollama endpoints only).
  pull | download <model>    Pull/download a model from registry (Ollama endpoints only).
  remove | rm | delete <model>  Remove/delete a model from local storage (Ollama endpoints only).

===============================================================================
                               USE CASES & EXAMPLES
===============================================================================

1. HEALTH CHECK (health / check)
   Use Case: Validate network connectivity and service status before submitting workloads.

   # Check health across all configured endpoints
   $ $(basename "$0") health

   # Verify health on a targeted server
   $ $(basename "$0") -e https://vllm.llm-gb10.johnson.int/v1 check

2. LISTING MODELS (display / ls / list)
   Use Case: Quick inventory audit to check what LLM weights are available.

   # List models across all default endpoints in standard formatted list
   $ $(basename "$0") display

   # List models and output the raw JSON response
   $ $(basename "$0") --json display

   # Check models on a specific host only
   $ $(basename "$0") -e https://ollama.llm-gb10.johnson.int list

3. MONITORING RUNNING MODELS (ps / running)
   Use Case: Inspect active models residing in VRAM to debug memory load or OOM issues.

   # Query all active Ollama endpoints for currently running models in VRAM
   $ $(basename "$0") ps

   # Check active models on a custom Ollama host
   $ $(basename "$0") -e https://ollama.llm-rtx.johnson.int running

4. DOWNLOADING MODELS (pull / download)
   Use Case: Remote deployment of new model weights to local inference backends.

   # Download a 7B coder model to Ollama instances
   $ $(basename "$0") pull qwen2.5-coder:7b

   # Download a model to a specific target host
   $ $(basename "$0") -e https://ollama.llm-gb10.johnson.int download llama3.1:8b

5. DELETING MODELS (remove / rm / delete)
   Use Case: Reclaim GPU disk or VRAM space by removing large unused model weights.

   # Delete a specific model from Ollama backends
   $ $(basename "$0") remove qwen3-coder-next:q4_K_M

   # Remove a model from a single specified endpoint
   $ $(basename "$0") -e https://ollama.llm-gb10.johnson.int rm deepseek-r1:14b

===============================================================================
EOF
  exit 0
}

# -----------------------------------------------------------------------------
# 1. Parse Command Line Flags & Positional Arguments FIRST
# -----------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_usage
      ;;
    --json|-j)
      SHOW_RAW_JSON=true
      shift
      ;;
    --endpoint|-e)
      USER_ENDPOINTS+=("$2")
      shift 2
      ;;
    *)
      if [[ "${ACTION_SET}" == "false" ]]; then
        ACTION="$1"
        ACTION_SET=true
      elif [[ -z "${MODEL_NAME}" ]]; then
        MODEL_NAME="$1"
      fi
      shift
      ;;
  esac
done

# Default to "display" action if none supplied
if [[ "${ACTION_SET}" == "false" ]]; then
  ACTION="display"
fi

# -----------------------------------------------------------------------------
# 2. Populate Target Endpoints Array AFTER parsing arguments
# -----------------------------------------------------------------------------
declare -A ENDPOINTS
if [[ ${#USER_ENDPOINTS[@]} -gt 0 ]]; then
  for ep in "${USER_ENDPOINTS[@]}"; do
    clean_ep="${ep%/}"
    if [[ "${clean_ep}" == *"llama"* ]]; then
      ENDPOINTS["${clean_ep}"]="llama"
    elif [[ "${clean_ep}" == *"/v1"* ]] || [[ "${clean_ep}" == *"vllm"* ]]; then
      ENDPOINTS["${clean_ep}"]="vllm"
    else
      ENDPOINTS["${clean_ep}"]="ollama"
    fi
  done
else
  for url in "${!DEFAULT_ENDPOINTS[@]}"; do
    clean_url="${url%/}"
    ENDPOINTS["${clean_url}"]="${DEFAULT_ENDPOINTS[$url]}"
  done
fi

# -----------------------------------------------------------------------------
# 3. Execution Router
# -----------------------------------------------------------------------------
counter=1
case "${ACTION}" in
  health|check)
    for url in "${!ENDPOINTS[@]}"; do
      type="${ENDPOINTS[$url]}"
      echo "=========================================="
      echo " ${counter}. Health Check [${type^^}]: ${url}"
      echo "=========================================="

      if [[ "${type}" == "ollama" ]]; then
        readarray -t auth_args < <(get_ollama_auth_args)
        exec_curl "health" "${CURL_OPTS[@]}" "${auth_args[@]}" "${url}/api/version"
      elif [[ "${type}" == "vllm" ]]; then
        base_url="${url%/v1}"
        readarray -t auth_args < <(get_bearer_auth_args "vllm")
        exec_curl "health" "${CURL_OPTS[@]}" "${auth_args[@]}" "${base_url}/health"
      elif [[ "${type}" == "llama" ]]; then
        base_url="${url%/v1}"
        readarray -t auth_args < <(get_bearer_auth_args "llama")
        exec_curl "health" "${CURL_OPTS[@]}" "${auth_args[@]}" "${base_url}/health"
      fi
      ((counter++))
    done
    ;;

  display|ls|list)
    for url in "${!ENDPOINTS[@]}"; do
      type="${ENDPOINTS[$url]}"
      echo "=========================================="
      echo " ${counter}. Endpoint [${type^^}]: ${url}"
      echo "=========================================="

      if [[ "${type}" == "ollama" ]]; then
        readarray -t auth_args < <(get_ollama_auth_args)
        exec_curl "ollama" "${CURL_OPTS[@]}" "${auth_args[@]}" "${url}/api/tags"
      elif [[ "${type}" == "vllm" ]]; then
        target_url="${url}"
        [[ "${target_url}" != *"/v1"* ]] && target_url="${target_url}/v1"
        readarray -t auth_args < <(get_bearer_auth_args "vllm")
        exec_curl "vllm" "${CURL_OPTS[@]}" "${auth_args[@]}" "${target_url}/models"
      elif [[ "${type}" == "llama" ]]; then
        target_url="${url}"
        [[ "${target_url}" != *"/v1"* ]] && target_url="${target_url}/v1"
        readarray -t auth_args < <(get_bearer_auth_args "llama")
        exec_curl "llama" "${CURL_OPTS[@]}" "${auth_args[@]}" "${target_url}/models"
      fi
      ((counter++))
    done
    ;;

  ps|running)
    for url in "${!ENDPOINTS[@]}"; do
      type="${ENDPOINTS[$url]}"
      if [[ "${type}" == "ollama" ]]; then
        echo "=========================================="
        echo " ${counter}. Endpoint [OLLAMA]: ${url} (/api/ps)"
        echo "=========================================="
        readarray -t auth_args < <(get_ollama_auth_args)
        exec_curl "ollama" "${CURL_OPTS[@]}" "${auth_args[@]}" "${url}/api/ps"
        ((counter++))
      fi
    done
    ;;

  remove|rm|delete)
    if [[ -z "${MODEL_NAME}" ]]; then
      echo "Error: You must specify a model name to remove."
      echo "Usage: $0 [-e endpoint] remove <model_name>"
      exit 1
    fi

    for url in "${!ENDPOINTS[@]}"; do
      type="${ENDPOINTS[$url]}"
      echo "=========================================="
      echo " Target Endpoint [${type^^}]: ${url}"
      echo "=========================================="
      if [[ "${type}" == "ollama" ]]; then
        readarray -t auth_args < <(get_ollama_auth_args)
        exec_curl "raw" "${CURL_OPTS[@]}" -X DELETE "${auth_args[@]}" "${url}/api/delete" -d "{\"model\": \"${MODEL_NAME}\"}"
      else
        echo "Note: ${type^^} endpoints do not support dynamic REST deletion of model weights."
        echo ""
      fi
    done
    ;;

  pull|download)
    if [[ -z "${MODEL_NAME}" ]]; then
      echo "Error: You must specify a model name to pull."
      echo "Usage: $0 [-e endpoint] pull <model_name>"
      exit 1
    fi

    for url in "${!ENDPOINTS[@]}"; do
      type="${ENDPOINTS[$url]}"
      if [[ "${type}" == "ollama" ]]; then
        echo "=========================================="
        echo " Pulling '${MODEL_NAME}' to ${url}"
        echo "=========================================="
        readarray -t auth_args < <(get_ollama_auth_args)
        exec_curl "raw" "${CURL_OPTS[@]}" -X POST "${auth_args[@]}" "${url}/api/pull" -d "{\"name\": \"${MODEL_NAME}\", \"stream\": false}"
      fi
    done
    ;;

  *)
    echo "Unknown command: ${ACTION}"
    echo "Run '$0 --help' for usage and examples."
    exit 1
    ;;
esac
