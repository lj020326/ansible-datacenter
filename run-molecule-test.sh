#!/usr/bin/env bash

VERSION="2026.5.2"  # Updated version

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(dirname "$0")"

## PURPOSE RELATED VARS
REPO_DIR="$(cd "${SCRIPT_DIR}" && git rev-parse --show-toplevel)"

TEST_LOG_DIR="save"
RUN_WITH_DEBUG=false

MOLECULE_IMAGE_SHORT="ubuntu26"
MOLECULE_TEST_SCENARIO="bootstrap_linux_package"
MOLECULE_COMMAND="test"

# Define the lookup map using an associative array
declare -A DOCKER_IMAGE_MAP=(
    ["ubuntu26"]="systemd-python-ubuntu:26.04"
    ["ubuntu24"]="systemd-python-ubuntu:24.04"
    ["ubuntu22"]="systemd-python-ubuntu:22.04"
    ["centos9"]="systemd-python-centos:9"
    ["centos10"]="systemd-python-centos:10"
    ["debian10"]="systemd-python-debian:10"
    ["debian11"]="systemd-python-debian:11"
    ["debian12"]="systemd-python-debian:12"
#    ["redhat8"]="systemd-python-redhat:8"
#    ["redhat9"]="systemd-python-redhat:9"
#    ["redhat10"]="systemd-python-redhat:10"
)

# Space-separated list of directories to ignore
EXCLUDE_DIRS=("save" "shared" "archive")

# 1. Define the Molecule directory and fetch valid scenarios
MOLECULE_DIR="${REPO_DIR}/molecule"
VALID_SCENARIOS=()

#DOCKER_IMAGE_KEYS=$(IFS='|'; echo "${!DOCKER_IMAGE_MAP[*]}")
DOCKER_IMAGE_KEYS=$(printf "%s\n" "${!DOCKER_IMAGE_MAP[@]}" | sort | paste -sd '|' -)

#### LOGGING RELATED
LOG_ERROR=0
LOG_WARN=1
LOG_INFO=2
LOG_TRACE=3
LOG_DEBUG=4

declare -A LOGLEVEL_TO_STR
LOGLEVEL_TO_STR["${LOG_ERROR}"]="ERROR"
LOGLEVEL_TO_STR["${LOG_WARN}"]="WARN"
LOGLEVEL_TO_STR["${LOG_INFO}"]="INFO"
LOGLEVEL_TO_STR["${LOG_TRACE}"]="TRACE"
LOGLEVEL_TO_STR["${LOG_DEBUG}"]="DEBUG"

function reverse_array() {
  local -n ARRAY_SOURCE_REF=$1
  local -n REVERSED_ARRAY_REF=$2
  for KEY in "${!ARRAY_SOURCE_REF[@]}"; do
    VALUE="${ARRAY_SOURCE_REF[$KEY]}"
    REVERSED_ARRAY_REF[$VALUE]="$KEY"
  done
}

declare -A LOGLEVELSTR_TO_LEVEL
reverse_array LOGLEVEL_TO_STR LOGLEVELSTR_TO_LEVEL

LOG_LEVEL=${LOG_INFO}

# ==================== SENSITIVE DATA SANITIZATION ====================

#SANITIZE_SED='
#    s/ANSIBLE_BECOME_PASSWORD: .*/ANSIBLE_BECOME_PASSWORD: [REDACTED]/gi
#    s/ANSIBLE_SSH_PASSWORD: .*/ANSIBLE_SSH_PASSWORD: [REDACTED]/gi
#    s/ANSIBLE_GALAXY_TOKEN: .*/ANSIBLE_GALAXY_TOKEN: [REDACTED]/gi
#    s/password: .*/password: [REDACTED]/gi
#    s/Password: .*/Password: [REDACTED]/gi
#    s/PASSWORD: .*/PASSWORD: [REDACTED]/gi
#    s/token: .*/token: [REDACTED]/gi
#    s/Token: .*/Token: [REDACTED]/gi
#    s/secret: .*/secret: [REDACTED]/gi
#    s/SECRET: .*/SECRET: [REDACTED]/gi
#    s/key: [A-Za-z0-9][^[:space:]]*/key: [REDACTED]/gi
#    s/KEY: [A-Za-z0-9][^[:space:]]*/KEY: [REDACTED]/gi
#    /^[[:space:]]*[A-Za-z_]*[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd].*/d
#    /^[[:space:]]*[A-Za-z_]*[Tt][Oo][Kk][Ee][Nn].*/d
#    /^[[:space:]]*[A-Za-z_]*[Ss][Ee][Cc][Rr][Ee][Tt].*/d
#'

# ==================== FAST SANITIZATION ====================
# Very lightweight: delete any line containing password/token/secret (case insensitive)
SANITIZE_CMD='sed -E "/[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]|[Tt][Oo][Kk][Ee][Nn]|[Ss][Ee][Cc][Rr][Ee][Tt]/d"'

function sanitize_output() {
#    sed -E "${SANITIZE_SED}"
    eval "$SANITIZE_CMD"
}

# ==================== LOGGING FUNCTIONS (unchanged) ====================

function logError() { [ $LOG_LEVEL -ge $LOG_ERROR ] && logMessage "${LOG_ERROR}" "${1}"; }
function logWarn()  { [ $LOG_LEVEL -ge $LOG_WARN ]  && logMessage "${LOG_WARN}"  "${1}"; }
function logInfo()  { [ $LOG_LEVEL -ge $LOG_INFO ]  && logMessage "${LOG_INFO}"  "${1}"; }
function logTrace() { [ $LOG_LEVEL -ge $LOG_TRACE ] && logMessage "${LOG_TRACE}" "${1}"; }
function logDebug() { [ $LOG_LEVEL -ge $LOG_DEBUG ] && logMessage "${LOG_DEBUG}" "${1}"; }
function abort() { logError "$@"; exit 1; }
function fail()  { logError "$@"; exit 1; }

function logMessage() {
  local LOG_MESSAGE_LEVEL="${1}"
  local LOG_MESSAGE="${2}"
  local CALLING_FUNCTION_ARRAY_LENGTH=${#FUNCNAME[@]}
  local CALLING_FUNCTION_ARRAY=("${FUNCNAME[@]:2:$((CALLING_FUNCTION_ARRAY_LENGTH - 3))}")

  local REVERSED_CALL_ARRAY=()
  for (( i = ${#CALLING_FUNCTION_ARRAY[@]} - 1; i >= 0; i-- )); do
    REVERSED_CALL_ARRAY+=( "${CALLING_FUNCTION_ARRAY[i]}" )
  done

  local SEPARATOR=":"
  local CALLING_FUNCTION_STR
  CALLING_FUNCTION_STR=$(printf "${SEPARATOR}%s" "${REVERSED_CALL_ARRAY[@]}")
  CALLING_FUNCTION_STR=${CALLING_FUNCTION_STR:${#SEPARATOR}}

  local LOG_LEVEL_STR="${LOGLEVEL_TO_STR[${LOG_MESSAGE_LEVEL}]}"
  local PADDED_LOG_LEVEL=$(printf "%-5s" "${LOG_LEVEL_STR}")
  local LOG_PREFIX="${CALLING_FUNCTION_STR}():"

  echo -e "[${PADDED_LOG_LEVEL}]: ==> ${LOG_PREFIX} ${LOG_MESSAGE}"
}

function setLogLevel() {
  if [ "${LOGLEVELSTR_TO_LEVEL[${1}]+abc}" ]; then
    LOG_LEVEL="${LOGLEVELSTR_TO_LEVEL[${1}]}"
  else
    abort "Unknown log level of [${1}]"
  fi
}

function checkRequiredCommands() {
    missingCommands=""
    for currentCommand in "$@"; do
        command -v "${currentCommand}" >/dev/null 2>&1 || missingCommands="${missingCommands} ${currentCommand}"
    done
    [[ -z "${missingCommands}" ]] || fail "Please install the following commands:${missingCommands}"
}

function populate_scenarios() {
    if [[ -d "${MOLECULE_DIR}" ]]; then
        local exclude_args=()
        for d in "${EXCLUDE_DIRS[@]}"; do
            exclude_args+=("-not" "-name" "${d}")
        done

        while IFS= read -r dir; do
            VALID_SCENARIOS+=("$dir")
        done < <(find "${MOLECULE_DIR}" -maxdepth 1 -mindepth 1 -type d "${exclude_args[@]}" -exec basename {} \; | sort)
    fi
}

populate_scenarios

function usage() {
  echo "Usage: ${SCRIPT_NAME} [options] [MOLECULE_TEST_SCENARIO (default: ${MOLECULE_TEST_SCENARIO})]"
  echo ""
  echo "  Options:"
  echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG] : log level (default: ${LOGLEVEL_TO_STR[${LOG_LEVEL}]})"
  echo "       -a : MOLECULE_COMMAND (create|login|converge|test|destroy|...)"
  echo "       -i : MOLECULE_IMAGE_SHORT (${DOCKER_IMAGE_KEYS})"
  echo "       -d : run molecule with '--debug' flag"
  echo "       -l : list test cases"
  echo "       -v : show version"
  echo "       -h : help"
  echo ""
  echo "  Available Scenarios:"
  for scenario in "${VALID_SCENARIOS[@]}"; do
      echo "       - ${scenario}"
  done
  echo ""
  echo "  Examples:"
	echo "       ${SCRIPT_NAME} "
	echo "       ${SCRIPT_NAME} -l"
	echo "       ${SCRIPT_NAME} bootstrap_linux_package"
	echo "       ${SCRIPT_NAME} -i ubuntu26 bootstrap_ntp"
	echo "       ${SCRIPT_NAME} -a create -i debian12"
	echo "       ${SCRIPT_NAME} -a login -i centos10"
	echo "       ${SCRIPT_NAME} -d -a converge -i centos10 bootstrap_sshd"
	echo "       ${SCRIPT_NAME} -L DEBUG bootstrap_pip"
	echo "       ${SCRIPT_NAME} -L DEBUG"
  echo "       ${SCRIPT_NAME} -v"
	[ -z "$1" ] || exit "$1"
}


function main() {
  while getopts "L:a:i:dlvh" opt; do
      case "${opt}" in
          L) setLogLevel "${OPTARG}" ;;
          a) MOLECULE_COMMAND="${OPTARG}" ;;
          i) MOLECULE_IMAGE_SHORT="${OPTARG}" ;;
          d) RUN_WITH_DEBUG="true" ;;
          l) print_test_cases && exit ;;
          v) echo "${VERSION}" && exit ;;
          h) usage 1 ;;
          \?) usage 2 ;;
      esac
  done
  shift $((OPTIND-1))

  if [ $# -eq 0 ]; then
    logDebug "Using default scenario ${MOLECULE_TEST_SCENARIO}"
  elif [ $# -eq 1 ]; then
    MOLECULE_TEST_SCENARIO="${1}"
  else
    usage 2
  fi

  CURRENT_DIR="$(pwd)"
  [[ "${CURRENT_DIR}" == "${REPO_DIR}" ]] || abort "This script must be executed from the repository root: ${REPO_DIR}"

  # Validate scenario
  local is_valid=0
  for scenario in "${VALID_SCENARIOS[@]}"; do
      [[ "${scenario}" == "${MOLECULE_TEST_SCENARIO}" ]] && is_valid=1
  done
  [[ ${is_valid} -eq 1 ]] || { logError "Invalid scenario: ${MOLECULE_TEST_SCENARIO}"; usage 1; }

  # Validate image
  if [[ ! -v DOCKER_IMAGE_MAP[$MOLECULE_IMAGE_SHORT] ]]; then
    logError "Image key '$MOLECULE_IMAGE_SHORT' not found."
    usage 2
  fi

  MOLECULE_IMAGE="${DOCKER_IMAGE_MAP[$MOLECULE_IMAGE_SHORT]}"
  logDebug "MOLECULE_IMAGE=${MOLECULE_IMAGE}"

  checkRequiredCommands molecule

  # Destroy previous instance if needed
  local RUN_MOLECULE_CMD_ARRAY=();
  case "${MOLECULE_COMMAND}" in
    "test" | "create")
      RUN_MOLECULE_CMD_ARRAY+=("MOLECULE_IMAGE=${MOLECULE_IMAGE}");
      RUN_MOLECULE_CMD_ARRAY+=("MOLECULE_IMAGE_SHORT=${MOLECULE_IMAGE_SHORT}");
      RUN_MOLECULE_CMD_ARRAY+=("molecule destroy");
      RUN_MOLECULE_CMD_ARRAY+=("-s ${MOLECULE_TEST_SCENARIO}");
      logInfo "==> ${RUN_MOLECULE_CMD_ARRAY[*]}"
      if ! eval "${RUN_MOLECULE_CMD_ARRAY[*]}"; then
        logError "Error: molecule destroy execution failed"
        exit 1
      fi
      ;;
  esac

  echo ""
  echo "=============================================== "
  echo "============= START molecule ${MOLECULE_COMMAND} ============= "
  echo ""
  RUN_MOLECULE_CMD_ARRAY=("MOLECULE_IMAGE=${MOLECULE_IMAGE}");
  RUN_MOLECULE_CMD_ARRAY+=("MOLECULE_IMAGE_SHORT=${MOLECULE_IMAGE_SHORT}");
  RUN_MOLECULE_CMD_ARRAY+=("molecule");
  if [[ "${RUN_WITH_DEBUG}" == "true" ]]; then
    RUN_MOLECULE_CMD_ARRAY+=("--debug");
  fi
  RUN_MOLECULE_CMD_ARRAY+=("${MOLECULE_COMMAND}");
  RUN_MOLECULE_CMD_ARRAY+=("-s ${MOLECULE_TEST_SCENARIO}");

  mkdir -p "${TEST_LOG_DIR}"
  local LOG_FILE="${TEST_LOG_DIR}/molecule.${MOLECULE_IMAGE_SHORT}.log"

  # Build and run molecule command with sanitization

  logInfo "Running: ${RUN_MOLECULE_CMD_ARRAY[*]} | sanitize_output | tee ${LOG_FILE}"
  # Execute with sanitization applied to both stdout and log file
  if ! eval "${RUN_MOLECULE_CMD_ARRAY[*]}" 2>&1 | sanitize_output | tee "${LOG_FILE}"; then
    logError "Molecule command failed"
    exit 1
  fi

  logInfo "Test completed. Log saved to: ${LOG_FILE}"
}

main "$@"
