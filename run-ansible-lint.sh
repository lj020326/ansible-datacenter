#!/usr/bin/env bash

# Run ansible-lint with project-local collection cache pre-populated.
#
# Problem solved: ansible-lint always prepends .ansible/collections to
# ANSIBLE_COLLECTIONS_PATH before ~/.ansible/collections. When collections
# listed in requirements.yml are not installed into the project-local cache
# (only scaffolded as empty stubs by ansible-lint itself in offline mode),
# module resolution fails with syntax-check[unknown-module] even though the
# collections are properly installed in ~/.ansible/collections.
#
# Solution: install all collections from requirements.yml into the project-local
# cache before running ansible-lint, so the project-local path is authoritative
# and complete rather than a stub skeleton.

VERSION="2026.6.12"

SCRIPT_DIR="$(dirname "$0")"
SCRIPT_NAME="$(basename "$0")"

PROJECT_DIR="$(cd "${SCRIPT_DIR}" && git rev-parse --show-toplevel)"

## Collection paths
PROJECT_COLLECTIONS_PATH="${PROJECT_DIR}/.ansible/collections"
ANSIBLE_COLLECTION_REQUIREMENTS="${PROJECT_DIR}/collections/requirements.yml"

## ansible-lint options
_FORCE_COLLECTIONS="${FORCE_COLLECTIONS:-0}"
_SKIP_COLLECTION_INSTALL="${SKIP_COLLECTION_INSTALL:-0}"

#### LOGGING RELATED
LOG_ERROR=0
LOG_WARN=1
LOG_FAILED=2
LOG_SUCCESS=3
LOG_INFO=4
LOG_TRACE=5
LOG_DEBUG=6

declare -A LOGLEVEL_TO_STR
LOGLEVEL_TO_STR["${LOG_ERROR}"]="ERROR"
LOGLEVEL_TO_STR["${LOG_WARN}"]="WARN"
LOGLEVEL_TO_STR["${LOG_FAILED}"]="FAILED"
LOGLEVEL_TO_STR["${LOG_SUCCESS}"]="SUCCESS"
LOGLEVEL_TO_STR["${LOG_INFO}"]="INFO"
LOGLEVEL_TO_STR["${LOG_TRACE}"]="TRACE"
LOGLEVEL_TO_STR["${LOG_DEBUG}"]="DEBUG"

# string formatters — force color if FORCE_COLOR is set, otherwise auto-detect TTY
if [[ -n "${FORCE_COLOR:-}" ]] || [[ -t 1 ]]; then
    tty_escape() { printf "\033[%sm" "$1"; }
else
    tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_dim_grey="$(tty_escape "2;39")"
tty_red="$(tty_mkbold 31)"
tty_green="$(tty_mkbold 32)"
tty_yellow="$(tty_mkbold 33)"
tty_blue="$(tty_mkbold 34)"
tty_magenta="$(tty_mkbold 35)"
tty_cyan="$(tty_mkbold 36)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

function shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"; do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

function reverse_array() {
  local -n array_source_ref=$1
  local -n reversed_array_ref=$2
  for key in "${!array_source_ref[@]}"; do
    value="${array_source_ref[$key]}"
    reversed_array_ref["$value"]="$key"
  done
}

declare -A LOGLEVELSTR_TO_LEVEL
reverse_array LOGLEVEL_TO_STR LOGLEVELSTR_TO_LEVEL

LOG_LEVEL_IDX=${LOG_INFO}
LOG_LEVEL_PADDING_LENGTH=7
LOG_PAD_LEVEL=true

# --- Logging Functions ---

function _log_message() {
    local log_message_level="${1}"
    local log_message="${2}"
    local log_prefix="${3:-}"

    if (( log_message_level > LOG_LEVEL_IDX )); then
        return 0
    fi

    local log_level_str="${LOGLEVEL_TO_STR[$log_message_level]}"
    [[ -z "$log_level_str" ]] && { echo "Unknown level: $log_message_level" >&2; return 1; }

    local log_level_display="${log_level_str}"
    if [[ "${LOG_PAD_LEVEL:-false}" = "true" ]] || [[ "${LOG_PAD_LEVEL:-0}" = "1" ]]; then
        printf -v log_level_display "%-${LOG_LEVEL_PADDING_LENGTH}s" "${log_level_str}"
    fi

    local log_context=""
    local _log_tty_color="${tty_reset}"

    if [ -n "${BASH_VERSION:-}" ]; then
        local stack_parts=("${FUNCNAME[@]:2}")
        local call_stack=""

        for (( i=${#stack_parts[@]}-1; i>=0; i-- )); do
            local func="${stack_parts[i]}"
            if [[ "$func" == "main" || "$func" == "source" ]]; then
                if [[ -z "$call_stack" ]]; then
                    call_stack="main"
                fi
            else
                [[ -n "$call_stack" ]] && call_stack+=":"
                call_stack+="$func"
            fi
        done

        local func_context=""
        if [[ -n "$call_stack" ]]; then
            func_context="${call_stack%:}()"
        fi

        local line_no="${BASH_LINENO[1]}"

        case "${log_message_level}" in
            "$LOG_DEBUG")   _log_tty_color="${tty_dim_grey}"; log_context="${func_context}[${line_no}]" ;;
            "$LOG_TRACE")   _log_tty_color="${tty_blue}";     log_context="${func_context}[${line_no}]" ;;
            "$LOG_SUCCESS") _log_tty_color="${tty_green}";    log_context="${func_context}" ;;
            "$LOG_FAILED")  _log_tty_color="${tty_red}";      log_context="${func_context}" ;;
            "$LOG_WARN")    _log_tty_color="${tty_yellow}";   log_context="${func_context}" ;;
            "$LOG_ERROR")   _log_tty_color="${tty_red}";      log_context="${func_context}[${line_no}]" ;;
            *)              _log_tty_color="${tty_reset}";    log_context="${func_context}" ;;
        esac
    else
        log_context="$(basename "$0")"
    fi

    [[ "${LOG_INCLUDE_INVOKER:-false}" = "true" ]] || [[ "${LOG_INCLUDE_INVOKER:-0}" = "1" ]] \
        && log_context="${BASH_SOURCE[2]##*/}=>${log_context}"
    [[ -n "${log_prefix}" ]] && log_context="${log_prefix}::${log_context}"

    printf "[%s] ${_log_tty_color}%s %s${tty_reset}\n" "$log_level_display" "$log_context" "$log_message"
}

log()          { _log_message "${LOG_INFO}"    "$1" "${2:-}"; }
log_debug()    { _log_message "${LOG_DEBUG}"   "$1" "${2:-}"; }
log_trace()    { _log_message "${LOG_TRACE}"   "$1" "${2:-}"; }
log_info()     { _log_message "${LOG_INFO}"    "$1" "${2:-}"; }
log_success()  { _log_message "${LOG_SUCCESS}" "$1" "${2:-}"; }
log_failed()   { _log_message "${LOG_FAILED}"  "$1" "${2:-}"; }
log_warn()     { _log_message "${LOG_WARN}"    "$1" "${2:-}"; }
log_error()    { _log_message "${LOG_ERROR}"   "$1" "${2:-}"; }

function ohai()  { printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$*"; }
function abort() { log_error "$1"; exit 1; }
function warn()  { log_warn "$1"; }
function fail()  { log_error "$1"; exit 1; }

function set_log_level() {
  local level_idx="${LOGLEVELSTR_TO_LEVEL[${1^^}]}"
  if [[ -n "$level_idx" ]]; then
    LOG_LEVEL_IDX="$level_idx"
  else
    abort "Unknown log level: [$1]"
  fi
}

# --- Helper Functions ---

function execute_eval_command() {
    local RUN_COMMAND="${*}"

    log_info "${RUN_COMMAND}"
    COMMAND_RESULT=$(eval "${RUN_COMMAND}")
    #  COMMAND_RESULT=$(eval "${RUN_COMMAND} > /dev/null 2>&1")
    local RETURN_STATUS=$?

    if [[ "$RETURN_STATUS" -eq 0 ]]; then
        if [[ "$COMMAND_RESULT" != "" ]]; then
          log_debug $'\n'"${COMMAND_RESULT}"
        fi
        log_debug "SUCCESS!"
    else
        log_error "ERROR (${RETURN_STATUS})"
        echo "\n${COMMAND_RESULT}"
        abort "$(printf "Failed during: %s" "${RUN_COMMAND}")"
    fi

}

function isInstalled() {
    command -v "${1}" >/dev/null 2>&1 || return 1
}

function checkRequiredCommands() {
    local missingCommands=""
    for currentCommand in "$@"; do
        isInstalled "${currentCommand}" || missingCommands="${missingCommands} ${currentCommand}"
    done
    if [[ -n "${missingCommands}" ]]; then
        fail "Please install the following commands required by this script:${missingCommands}"
    fi
}

# --- Collection Install ---

function install_lint_collections() {
  if [[ "${_SKIP_COLLECTION_INSTALL}" -eq 1 ]]; then
    log_info "Skipping collection install (SKIP_COLLECTION_INSTALL=1)"
    return 0
  fi

  if [[ ! -f "${ANSIBLE_COLLECTION_REQUIREMENTS}" ]]; then
    abort "Collection requirements file not found: ${ANSIBLE_COLLECTION_REQUIREMENTS}"
  fi

  ohai "Installing collections to project-local cache"
  log_info "Requirements : ${ANSIBLE_COLLECTION_REQUIREMENTS}"
  log_info "Install path : ${PROJECT_COLLECTIONS_PATH}"

  local GALAXY_CMD=("ansible-galaxy" "collection" "install"
    "-r" "${ANSIBLE_COLLECTION_REQUIREMENTS}"
    "-p" "${PROJECT_COLLECTIONS_PATH}"
    "--force-with-deps"
    "--clear-response-cache"
  )

  if [[ "${_FORCE_COLLECTIONS}" -eq 1 ]]; then
    GALAXY_CMD+=("--force")
  fi

  log_debug "${GALAXY_CMD[*]}"
  # Stream errors to stderr; stream standard info if log level is DEBUG/TRACE
  if [[ "${LOG_LEVEL_IDX}" -ge "${LOG_DEBUG}" ]]; then
    execute_eval_command "${GALAXY_CMD[*]}"
  else
    execute_eval_command "${GALAXY_CMD[*]} > /dev/null"
  fi

  log_success "Collections installed to ${PROJECT_COLLECTIONS_PATH}"

  # Confirm dettonville.utils resolved correctly (the canary for this bug)
  local utils_modules="${PROJECT_COLLECTIONS_PATH}/ansible_collections/dettonville/utils/plugins/modules"
  if [[ -d "${utils_modules}" ]]; then
    log_debug "dettonville.utils modules present: $(ls "${utils_modules}" | tr '\n' ' ')"
  else
    log_warn "dettonville.utils plugins/modules not found at expected path — stub may still be in place"
    log_warn "Expected: ${utils_modules}"
  fi
}

# --- Lint ---

function run_ansible_lint() {
  local LINT_ARGS=("$@")

  ohai "Running ansible-lint"
  log_info "ansible-lint version: $(ansible-lint --version 2>&1 | head -1)"
  log_info "Project dir : ${PROJECT_DIR}"
  log_info "Collections : ${PROJECT_COLLECTIONS_PATH}"

  local LINT_CMD=("ansible-lint" "-p")
  if [[ "${LOG_LEVEL_IDX}" -ge "${LOG_DEBUG}" ]]; then
    LINT_CMD+=("-v")
  fi
  if [[ "${#LINT_ARGS[@]}" -gt 0 ]]; then
    LINT_CMD+=("${LINT_ARGS[@]}")
  fi

  log_debug "${LINT_CMD[*]}"
  "${LINT_CMD[@]}"
  local RETURN_STATUS=$?

  if [[ "${RETURN_STATUS}" -eq 0 ]]; then
    log_success "ansible-lint passed with no violations"
  else
    log_failed "ansible-lint found violations (exit code: ${RETURN_STATUS})"
  fi

  return "${RETURN_STATUS}"
}

# --- Usage ---

function usage() {
  echo "Usage: ${SCRIPT_NAME} [options] [-- ansible-lint-args...]"
  echo ""
  echo "  Installs Ansible collections into the project-local cache"
  echo "  (.ansible/collections) and then runs ansible-lint."
  echo ""
  echo "  This ensures ansible-lint resolves modules from fully-installed"
  echo "  collections rather than empty stubs it scaffolds in offline mode."
  echo ""
  echo "  Options:"
  echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG]"
  echo "                   : log level (default: INFO)"
  echo "       -s          : skip collection install step (SKIP_COLLECTION_INSTALL=1)"
  echo "       -f          : force reinstall of all collections (FORCE_COLLECTIONS=1)"
  echo "       -v          : show script version"
  echo "       -h          : help"
  echo ""
  echo "  Environment variables:"
  echo "       SKIP_COLLECTION_INSTALL=1  : skip the collection install step"
  echo "       FORCE_COLLECTIONS=1        : pass --force to ansible-galaxy install"
  echo "       FORCE_COLOR=1              : force color output even when not a TTY"
  echo ""
  echo "  Examples:"
  echo "       ${SCRIPT_NAME}"
  echo "       ${SCRIPT_NAME} -L DEBUG"
  echo "       ${SCRIPT_NAME} -s                         # skip collection install"
  echo "       ${SCRIPT_NAME} -f                         # force collection reinstall"
  echo "       FORCE_COLLECTIONS=1 ${SCRIPT_NAME}        # same via env var"
  echo "       ${SCRIPT_NAME} -- --profile production    # pass args to ansible-lint"
  echo "       ${SCRIPT_NAME} -v"
  [ -z "$1" ] || exit "$1"
}

# --- Main ---

function main() {
  while getopts "L:sfvh" opt; do
    case "${opt}" in
      L) set_log_level "${OPTARG}" ;;
      s) _SKIP_COLLECTION_INSTALL=1 ;;
      f) _FORCE_COLLECTIONS=1 ;;
      v) echo "${VERSION}" && exit 0 ;;
      h) usage 0 ;;
      \?) usage 2 ;;
      *) usage ;;
    esac
  done
  shift $((OPTIND-1))

  # Remaining args (after --) are passed through to ansible-lint
  local LINT_ARGS=("$@")

  checkRequiredCommands ansible-galaxy ansible-lint

  log_info "PROJECT_DIR=${PROJECT_DIR}"
  log_info "ANSIBLE_COLLECTION_REQUIREMENTS=${ANSIBLE_COLLECTION_REQUIREMENTS}"
  log_info "PROJECT_COLLECTIONS_PATH=${PROJECT_COLLECTIONS_PATH}"
  log_debug "SKIP_COLLECTION_INSTALL=${_SKIP_COLLECTION_INSTALL}"
  log_debug "FORCE_COLLECTIONS=${_FORCE_COLLECTIONS}"

  install_lint_collections

  run_ansible_lint "${LINT_ARGS[@]}"
  local RETURN_STATUS=$?

  log_info "*********************** "
  if [[ "${RETURN_STATUS}" -eq 0 ]]; then
    log_success "ANSIBLE LINT SUCCEEDED"
  else
    log_failed "ANSIBLE LINT FAILED (exit code: ${RETURN_STATUS})"
  fi

  exit "${RETURN_STATUS}"
}

main "$@"
