#!/usr/bin/env bash

VERSION="2026.6.1"

#SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(dirname "$0")"
SCRIPT_NAME="$(basename "$0")"

## PURPOSE RELATED VARS
#PROJECT_DIR=$( git rev-parse --show-toplevel )
PROJECT_DIR="$(cd "${SCRIPT_DIR}" && git rev-parse --show-toplevel)"

KEEP_TMP=0

DISPLAY_TEST_RESULTS=0

TEST_CASE_CONFIGS="
validate_yamllint
validate_kicslint
validate_inclusivity
validate_ansiblelint
"

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

# string formatters
# Force color if FORCE_COLOR is set, otherwise auto-detect TTY
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
  for arg in "$@"
  do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

function chomp() {
  printf "%s" "${1/"$'\n'"/}"
}

function reverse_array() {
  local -n array_source_ref=$1
  local -n reversed_array_ref=$2
  # iterate over the keys of the loglevel_to_str array
  for key in "${!array_source_ref[@]}"; do
    # get the value associated with the current key
    value="${array_source_ref[$key]}"
    # add the reversed key-value pair to the reversed_array_ref array
    reversed_array_ref["$value"]="$key"
  done
}

declare -A LOGLEVELSTR_TO_LEVEL
reverse_array LOGLEVEL_TO_STR LOGLEVELSTR_TO_LEVEL

#LOG_LEVEL_IDX=${LOG_DEBUG}
LOG_LEVEL_IDX=${LOG_INFO}
LOG_LEVEL_PADDING_LENGTH=7
#LOG_INCLUDE_INVOKER=true
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
        local script_path="${BASH_SOURCE[2]##*/}"

        # Build Call Stack: skip _log_message (0) and wrapper (1)
        local stack_parts=("${FUNCNAME[@]:2}")
        local call_stack=""

        for (( i=${#stack_parts[@]}-1; i>=0; i-- )); do
            local func="${stack_parts[i]}"

            # Normalize 'source' to 'main' or keep existing 'main'
            if [[ "$func" == "main" || "$func" == "source" ]]; then
                # Only add 'main' if it's the first thing in our built stack
                if [[ -z "$call_stack" ]]; then
                    call_stack="main"
                fi
            else
                # Add real function names, separated by colons
                [[ -n "$call_stack" ]] && call_stack+=":"
                call_stack+="$func"
            fi
        done

        # If call_stack is empty (called from top-level), just use the script name
        # Otherwise, append the stack with parentheses
        local func_context=""
        if [[ -n "$call_stack" ]]; then
            func_context="${call_stack%:}()"
        fi

        local line_no="${BASH_LINENO[1]}"

        case "${log_message_level}" in
            "$LOG_DEBUG") _log_tty_color="${tty_dim_grey}"; log_context="${func_context}[${line_no}]" ;;
            "$LOG_TRACE") _log_tty_color="${tty_blue}";     log_context="${func_context}[${line_no}]" ;;
            "$LOG_SUCCESS") _log_tty_color="${tty_green}"; log_context="${func_context}" ;;
            "$LOG_FAILED")  _log_tty_color="${tty_red}";   log_context="${func_context}" ;;
            "$LOG_WARN")  _log_tty_color="${tty_yellow}";  log_context="${func_context}" ;;
            "$LOG_ERROR") _log_tty_color="${tty_red}";     log_context="${func_context}[${line_no}]" ;;
            *)            _log_tty_color="${tty_reset}";   log_context="${func_context}" ;;
        esac
    else
        log_context="$(basename "$0")"
    fi

    [[ "${LOG_INCLUDE_INVOKER:-false}" = "true" ]] || [[ "${LOG_INCLUDE_INVOKER:-0}" = "1" ]] && log_context="${script_path}=>${log_context}"
    [[ -n "${log_prefix}" ]] && log_context="${log_prefix}::${log_context}"

    # Standardized Output
#    printf "${_log_tty_color}%s [%s] %s:${tty_reset} %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$log_message_level" "$log_context" "$log_message"
    printf "[%s] ${_log_tty_color}%s %s${tty_reset}\n" "$log_level_display" "$log_context" "$log_message"
}

# Wrapper Functions with Prefix Support
log()                { _log_message "${LOG_INFO}"           "$1" "${2:-}"; }
log_debug()          { _log_message "${LOG_DEBUG}"          "$1" "${2:-}"; }
log_trace()          { _log_message "${LOG_TRACE}"          "$1" "${2:-}"; }
log_info()           { _log_message "${LOG_INFO}"           "$1" "${2:-}"; }
log_success()        { _log_message "${LOG_SUCCESS}"        "$1" "${2:-}"; }
log_failed()         { _log_message "${LOG_FAILED}"         "$1" "${2:-}"; }
log_warn()           { _log_message "${LOG_WARN}"           "$1" "${2:-}"; }
log_error()          { _log_message "${LOG_ERROR}"          "$1" "${2:-}"; }

function ohai()  { printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$*"; }
function abort() { log_error "$1"; exit 1; }
function warn()  { log_warn "$1"; }
function error() { log_error "$1"; }
function fail()  { error "$1"; exit 1; }

function set_log_level() {
  local level_idx="${LOGLEVELSTR_TO_LEVEL[${1^^}]}" # ^^ makes it case-insensitive
  if [[ -n "$level_idx" ]]; then
    LOG_LEVEL_IDX="$level_idx"
  else
    abort "Unknown log level: [$1]"
  fi
}

# --- Helper Functions ---

function cleanup_tmpdir() {
  test "${KEEP_TMP:-0}" = 1 || rm -rf "${TMP_DIR}"
}

function execute() {
  log_info "${*}"
  if ! "$@"
  then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

function execute_eval_command() {
  local RUN_COMMAND="${*}"

  log_debug "${RUN_COMMAND}"
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
#    echo "${COMMAND_RESULT}"
    abort "$(printf "Failed during: %s" "${RUN_COMMAND}")"
  fi
}

## ref: https://stackoverflow.com/questions/229551/how-to-check-if-a-string-contains-a-substring-in-bash#229585
function stringContain() { case $2 in *$1* ) return 0;; *) return 1;; esac ;}

function install_lint_collections() {
  local PROJECT_COLLECTIONS_PATH="${PROJECT_DIR}/.ansible/collections"

  log_info "Syncing collections to project-local cache for ansible-lint"
  ansible-galaxy collection install \
    -r "${PROJECT_DIR}/collections/requirements.yml" \
    -p "${PROJECT_COLLECTIONS_PATH}" \
    --force-with-deps \
    > /dev/null 2>&1

  log_info "Collections installed to ${PROJECT_COLLECTIONS_PATH}"
}

function validate_ansiblelint() {
  # Ensure project-local collection cache is populated for ansible-lint resolution
  install_lint_collections

  log_info ""
  log_info "#######################################################"
  eval "ansible-lint --version"
  log_info "Validate ansible-lint"
  local TEST_COMMAND="ansible-lint -p"
  eval "${TEST_COMMAND} > /dev/null 2>&1"
  local RETURN_STATUS=$?

  if [[ $RETURN_STATUS -eq 0 ]]; then
    log_info "SUCCESS => No exceptions found from [${TEST_COMMAND}]!!"
  else
    log_info "There are [${RETURN_STATUS}] exceptions found from [${TEST_COMMAND}]!! :("
    log_info "${TEST_COMMAND}"
    eval "${TEST_COMMAND}"
  fi

  log_info "#######################################################"
  log_info "RETURN_STATUS=${RETURN_STATUS}"
  log_info ""

  return "${RETURN_STATUS}"
}

function validate_yamllint() {
  log_info ""
  log_info "#######################################################"
  eval "yamllint --version"
  log_info "Validate yamllint"
  local TEST_COMMAND="yamllint --no-warnings ."
  eval "${TEST_COMMAND} > /dev/null 2>&1"
  local RETURN_STATUS=$?

  if [[ $RETURN_STATUS -eq 0 ]]; then
    log_info "SUCCESS => No exceptions found from [${TEST_COMMAND}]!!"
  else
    log_info "There are [${RETURN_STATUS}] exceptions found from [${TEST_COMMAND}]!! :("
    log_info "${TEST_COMMAND}"
    eval "${TEST_COMMAND}"
  fi

  log_info "#######################################################"
  log_info "RETURN_STATUS=${RETURN_STATUS}"
  log_info ""

  return "${RETURN_STATUS}"
}

function validate_kicslint() {
  local KICS_CONFIG_FILE=".kics-config.yml"

  ## ref: https://docs.kics.io/latest/documentation/#installation
  ## ref: https://formulae.brew.sh/formula/kics
  #export KICS_QUERIES_PATH=/usr/local/opt/kics/share/kics/assets/queries
  export KICS_QUERIES_PATH=${HOMEBREW_PREFIX:-/usr/local}/opt/kics/share/kics/assets/queries

  log_info ""
  log_info "#######################################################"
  eval "kics version"
  log_info "Validate kics lint"
  local TEST_COMMAND="kics scan --ci --config ${KICS_CONFIG_FILE}"
  eval "${TEST_COMMAND} > /dev/null 2>&1"
  local RETURN_STATUS=$?

  if [[ $RETURN_STATUS -eq 0 ]]; then
    log_info "SUCCESS => No exceptions found from [${TEST_COMMAND}]!!"
  else
    log_info "There are [${RETURN_STATUS}] exceptions found from [${TEST_COMMAND}]!! :("
    log_info "${TEST_COMMAND}"
    eval "${TEST_COMMAND}"
  fi

  log_info "#######################################################"
  log_info "RETURN_STATUS=${RETURN_STATUS}"
  log_info ""

  return "${RETURN_STATUS}"
}

function validate_inclusivity() {
  log_info ""
  log_info "#######################################################"
  eval "woke version"
  log_info "Validate inclusive language lint"
  local TEST_COMMAND="woke -c .inclusivity.yml --exit-1-on-failure ."
  eval "${TEST_COMMAND} > /dev/null 2>&1"
  local RETURN_STATUS=$?

  if [[ $RETURN_STATUS -eq 0 ]]; then
    log_info "SUCCESS => No exceptions found from [${TEST_COMMAND}]!!"
  else
    log_info "There are [${RETURN_STATUS}] exceptions found from [${TEST_COMMAND}]!! :("
    log_info "${TEST_COMMAND}"
    eval "${TEST_COMMAND}"
  fi

  log_info "#######################################################"
  log_info "RETURN_STATUS=${RETURN_STATUS}"
  log_info ""

  return "${RETURN_STATUS}"
}

function run_test_case() {
  local TEST_CASE_ID=$1
  local TEST_FUNCTION=$2
  local TEST_CASES_STR=$3
  shift 3

  local RETURN_STATUS=0

  local TEST_ARGS=()
  if [ $# -gt 0 ]; then
    TEST_ARGS=("${@}")
  fi
  local LOG_PREFIX="run_test_case(${TEST_CASE_ID}):"

  if stringContain "${TEST_CASE_ID}" "${TEST_CASES_STR}" ||
     stringContain "${TEST_FUNCTION}" "${TEST_CASES_STR}" ||
     [ "${TEST_CASES_STR}" == "ALL" ]
  then
    log_debug "${LOG_PREFIX} Run test [${TEST_FUNCTION}]"

    local TEST_COMMAND="${TEST_FUNCTION}"
    log_debug "${LOG_PREFIX} TEST_COMMAND=${TEST_COMMAND}"

#    local TEST_RESULTS=$(${TEST_FUNCTION} "${TEST_ARGS}")
#    local TEST_RESULTS=$(eval "${TEST_FUNCTION} ${TEST_ARGS}")
    eval "${TEST_FUNCTION} ${TEST_ARGS[*]} >/dev/null 2>&1"
    local RETURN_STATUS=$?

    if [[ $RETURN_STATUS -eq 0 ]]; then
      log_info "${LOG_PREFIX} ${TEST_FUNCTION}: SUCCESS"
    else
      log_error "${LOG_PREFIX} ${TEST_FUNCTION}: FAILED"
    fi

    if [[ $RETURN_STATUS -ne 0 || $DISPLAY_TEST_RESULTS -gt 0 ]]; then
      log_info "${LOG_PREFIX} TEST_RESULTS ****"
      eval "${TEST_FUNCTION} ${TEST_ARGS[*]}"
    fi
    log_debug "${LOG_PREFIX} RETURN_STATUS=${RETURN_STATUS}"
  fi
  log_debug "${LOG_PREFIX} TEST_CASE_IDX=${TEST_CASE_IDX_PADDED} TEST_CASE=${TEST_CASE} RETURN_STATUS=${RETURN_STATUS} ERROR_COUNT=${ERROR_COUNT}"
  return "${RETURN_STATUS}"
}

function print_test_cases() {
  local LOG_PREFIX="print_test_cases():"

  TEST_CASE_IDX=0

  IFS=$'\n'
  for TEST_CASE_INFO in ${TEST_CASE_CONFIGS}
  do

    ## ref: https://stackoverflow.com/questions/6723426/looping-over-arrays-printing-both-index-and-value
    ((TEST_CASE_IDX++))

    ## ref: https://stackoverflow.com/questions/1117134/padding-zeros-in-a-string
    TEST_CASE_IDX_PADDED=$(printf %02d $TEST_CASE_IDX)

    # ref: https://stackoverflow.com/questions/12317483/array-of-arrays-in-bash
    # split server name from sub-list
#      TEST_CASE_ARRAY=(${TEST_CASE_INFO//:/})
    IFS="," read -a TEST_CASE_ARRAY <<< $TEST_CASE_INFO

    TEST_CASE=${TEST_CASE_ARRAY[0]}

#    echo "${TEST_CASE_IDX_PADDED}: ${TEST_CASE}"
    echo "${TEST_CASE}"

  done
}


function run_tests() {
  local LOG_PREFIX="run_tests():"
  local ERROR_COUNT=0
#  local TEST_CASES=$@
  local TEST_CASES=("$@")
  local RETURN_STATUS=0

  log_info "TEST_CASES[@]=${TEST_CASES[*]}"
  TEST_CASES_STR="${TEST_CASES[*]}"
  TEST_CASE_IDX=0

  IFS=$'\n'
  for TEST_CASE_INFO in ${TEST_CASE_CONFIGS}
  do

    ## ref: https://stackoverflow.com/questions/6723426/looping-over-arrays-printing-both-index-and-value
    ((TEST_CASE_IDX++))

    ## ref: https://stackoverflow.com/questions/1117134/padding-zeros-in-a-string
    TEST_CASE_IDX_PADDED=$(printf %02d $TEST_CASE_IDX)

    # ref: https://stackoverflow.com/questions/12317483/array-of-arrays-in-bash
    # split server name from sub-list
    IFS="," read -a TEST_CASE_ARRAY <<< $TEST_CASE_INFO

    TEST_CASE=${TEST_CASE_ARRAY[0]}

    log_debug "TEST_CASE_IDX=${TEST_CASE_IDX_PADDED} TEST_CASE=${TEST_CASE}"

    local TEST_CASE_ARGS=()
    if [[ ${#TEST_CASE_ARRAY[@]} -gt 1 ]]; then
      ## ref: https://unix.stackexchange.com/questions/413976/how-to-shift-array-value-in-bash#413990
      TEST_CASE_ARGS=("${TEST_CASE_ARRAY[@]:1}")
      log_debug "TEST_CASE_ARGS=${TEST_CASE_ARGS[*]}"
    fi

    run_test_case "${TEST_CASE_IDX_PADDED}" "${TEST_CASE}" "${TEST_CASES_STR}" "${TEST_CASE_ARGS[@]}"
    RETURN_STATUS=$?
    # shellcheck disable=SC2004
    ERROR_COUNT=$((${ERROR_COUNT} + ${RETURN_STATUS}))
    log_debug "TEST_CASE_IDX=${TEST_CASE_IDX_PADDED} TEST_CASE=${TEST_CASE} RETURN_STATUS=${RETURN_STATUS} ERROR_COUNT=${ERROR_COUNT}"

  done

  log_info "ERROR_COUNT=${ERROR_COUNT}"
  return ${ERROR_COUNT}
}

function checkRequiredCommands() {
    missingCommands=""
    for currentCommand in "$@"
    do
        isInstalled "${currentCommand}" || missingCommands="${missingCommands} ${currentCommand}"
    done

    if [[ ! -z "${missingCommands}" ]]; then
        fail "checkRequiredCommands(): Please install the following commands required by this script:${missingCommands}"
    fi
}

function isInstalled() {
    command -v "${1}" >/dev/null 2>&1 || return 1
}


function install_jq() {
  local LOG_PREFIX="install_jq():"
  local OS="${1}"
  local PACKAGE_NAME="jq"

  echo "==> installing jq - required for yq sort-keys (https://mikefarah.gitbook.io/yq/operators/sort-keys)"
  if [[ -n "${INSTALL_ON_LINUX-}" ]]; then
    log_info "Installing jq for linux"
    if [[ -n "$(command -v dnf)" ]]; then
      sudo dnf install -y "${PACKAGE_NAME}"
    elif [[ -n "$(command -v yum)" ]]; then
      sudo yum install -y "${PACKAGE_NAME}"
    elif [[ -n "$(command -v apt-get)" ]]; then
      sudo apt-get install -y "${PACKAGE_NAME}"
    fi
  fi
  if [[ -n "${INSTALL_ON_MACOS-}" ]]; then
    log_info "Installing jq for MacOS"
    brew install "${PACKAGE_NAME}"
  fi
  if [[ -n "${INSTALL_ON_MSYS-}" ]]; then
    PACKAGE_NAME="mingw-w64-x86_64-jq"
    log_info "Installing jq for MSYS2"
    ## ref: https://packages.msys2.org/package/mingw-w64-x86_64-jq?repo=mingw64
    pacman --noconfirm -S "${PACKAGE_NAME}"
  fi
}

# ref: https://formulae.brew.sh/formula/kics
function install_kics() {
  local LOG_PREFIX="install_kics():"
  local OS="${1}"

  log_info "Installing kics (https://formulae.brew.sh/formula/kics)"

  if [[ -n "${INSTALL_ON_MACOS-}" ]]; then
    ## ref: https://formulae.brew.sh/formula/kics
    log_info "Installing kics for MacOS using brew"
    brew install kics
  else
    log_info "Kics install not supported on platform ${OS}"
  fi
}

## ref: https://github.com/get-woke/woke/#install-woke
## ref: https://docs.getwoke.tech/installation/
function install_woke() {
  local LOG_PREFIX="install_woke():"
  local OS="${1}"

  log_info "Installing woke (https://docs.getwoke.tech/installation/)"

  if [[ -n "${INSTALL_ON_MACOS-}" ]]; then
    ## ref: https://docs.getwoke.tech/installation/
    log_info "Installing woke for MacOS using brew"
    brew install get-woke/tap/woke
  else
    log_info "woke install not supported on platform ${OS}"
  fi
}

function install_ansiblelint() {
  local LOG_PREFIX="install_ansiblelint():"

  PIP_COMMAND="pip install ansible-lint"
  log_debug "${PIP_COMMAND}"
  eval "${PIP_COMMAND} >/dev/null 2>&1"
  log_debug "pip install complete"
}


function install_yamllint() {
  local LOG_PREFIX="install_yamllint():"

  PIP_COMMAND="pip install yamllint"
  log_debug "${PIP_COMMAND}"
  eval "${PIP_COMMAND} >/dev/null 2>&1"
  log_debug "pip install complete"
}


function ensure_tool() {
  local LOG_PREFIX="ensure_tool():"
  if [[ $# -ne 1 ]]
  then
    return 1
  fi

  local executable="${1}"
  local install_function="install_${executable}"

  if [[ -z "$(command -v "${executable}")" ]]; then
    log_debug "executable '${executable}' not found"
    # First check OS.
    PLATFORM_OS=$(uname -s | tr "[:upper:]" "[:lower:]")

    case "${PLATFORM_OS}" in
      linux*)
        INSTALL_ON_LINUX=1
        ;;
      darwin*)
        INSTALL_ON_MACOS=1
        ;;
      cygwin* | mingw64* | mingw32* | msys*)
        INSTALL_ON_MSYS=1
        ;;
      *)
        abort "Package installation method is only supported on macOS, Linux and msys2."
        ;;
    esac

    log_debug "installing executable '${executable}'"
    eval "${install_function} ${PLATFORM_OS}"
  fi
}


function usage() {
  echo "Usage: ${SCRIPT_NAME} [options] [[TESTCASE_ID] [TESTCASE_ID] ...]"
  echo ""
  echo "  Options:"
  echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG] : run with specified log level (default: '${LOGLEVEL_TO_STR[${LOG_LEVEL}]}')"
  echo "       -d : display test results details"
  echo "       -l : show/list test cases"
  echo "       -v : show script version"
  echo "       -k : keep temp directory/files"
  echo "       -h : help"
  echo ""
  echo "  Examples:"
	echo "       ${SCRIPT_NAME} "
	echo "       ${SCRIPT_NAME} -l"
	echo "       ${SCRIPT_NAME} validate_ansiblelint"
	echo "       ${SCRIPT_NAME} validate_yamllint"
	echo "       ${SCRIPT_NAME} -k -L DEBUG validate_ansiblelint"
	echo "       ${SCRIPT_NAME} -L DEBUG"
  echo "       ${SCRIPT_NAME} -v"
	[ -z "$1" ] || exit "$1"
}


function main() {

  while getopts "L:r:dlvhk" opt; do
      case "${opt}" in
          L) setLogLevel "${OPTARG}" ;;
          l) print_test_cases && exit ;;
          d) DISPLAY_TEST_RESULTS=1 ;;
          k) KEEP_TMP=1 ;;
          v) echo "${VERSION}" && exit ;;
          h) usage 1 ;;
          \?) usage 2 ;;
          *) usage ;;
      esac
  done
  shift $((OPTIND-1))

  ## ref: https://pypi.org/project/ansible-lint/
  log_debug "Ensure ansible-lint present/installed"
  ensure_tool ansiblelint

  ## ref: https://pypi.org/project/yamllint/
  log_debug "Ensure yamllint present/installed"
  ensure_tool yamllint

  ## ref: https://docs.kics.io/latest/documentation/
  log_debug "Ensure kics present/installed"
  ensure_tool kics

  ## ref: https://github.com/get-woke/woke/
  log_debug "Ensure woke present/installed"
  ensure_tool woke

  checkRequiredCommands ansible-inventory ansible-lint yamllint kics woke

  TEST_CASES=("ALL")
  if [ $# -gt 0 ]; then
    TEST_CASES=("$@")
  fi

  #log_info "SCRIPT_DIR=${SCRIPT_DIR}"
  log_info "PROJECT_DIR=${PROJECT_DIR}"
  log_info "TEST_CASES=${TEST_CASES[*]}"

  run_tests "${TEST_CASES[@]}"
  TOTAL_FAILED=$?

  log_info "*********************** "
  log_info "OVERALL INVENTORY TEST RESULTS"
  log_info "TOTAL TOTAL_FAILED=${TOTAL_FAILED}"
  if [[ $TOTAL_FAILED -eq 0 ]]; then
    log_info "TEST SUCCEEDED!"
  else
    log_error "TEST FAILED!"
  fi
  exit $TOTAL_FAILED
}

main "$@"
