#!/usr/bin/env bash

VERSION="2026.5.1"

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(dirname "$0")"

## PURPOSE RELATED VARS
REPO_DIR="$(cd "${SCRIPT_DIR}" && git rev-parse --show-toplevel)"

MOLECULE_IMAGE_DEFAULT="ubuntu26"
MOLECULE_TEST_SCENARIO_DEFAULT="bootstrap_linux_package"

# Define the lookup map using an associative array
declare -A DOCKER_IMAGE_MAP=(
    ["ubuntu26"]="lj020326/systemd-python-ubuntu:26.04"
    ["ubuntu24"]="lj020326/systemd-python-ubuntu:24.04"
    ["ubuntu22"]="lj020326/systemd-python-ubuntu:22.04"
    ["centos9"]="lj020326/systemd-python-centos:9"
    ["centos10"]="lj020326/systemd-python-centos:10"
    ["debian10"]="lj020326/systemd-python-debian:10"
    ["debian11"]="lj020326/systemd-python-debian:11"
    ["debian12"]="lj020326/systemd-python-debian:12"
#    ["redhat8"]="lj020326/systemd-python-redhat:8"
#    ["redhat9"]="lj020326/systemd-python-redhat:9"
#    ["redhat10"]="lj020326/systemd-python-redhat:10"
)

# Space-separated list of directories to ignore
EXCLUDE_DIRS=("save" "shared" "archive")

# 1. Define the Molecule directory and fetch valid scenarios into an array
MOLECULE_DIR="${REPO_DIR}/molecule"
VALID_SCENARIOS=()

DOCKER_IMAGE_KEYS=$(IFS='|'; echo "${!DOCKER_IMAGE_MAP[*]}")

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
  # Iterate over the keys of the LOGLEVEL_TO_STR array
  for KEY in "${!ARRAY_SOURCE_REF[@]}"; do
    # Get the value associated with the current key
    VALUE="${ARRAY_SOURCE_REF[$KEY]}"
    # Add the reversed key-value pair to the REVERSED_ARRAY_REF array
    REVERSED_ARRAY_REF[$VALUE]="$KEY"
  done
}

declare -A LOGLEVELSTR_TO_LEVEL
reverse_array LOGLEVEL_TO_STR LOGLEVELSTR_TO_LEVEL

#LOG_LEVEL=${LOG_DEBUG}
LOG_LEVEL=${LOG_INFO}

function logError() {
  if [ $LOG_LEVEL -ge $LOG_ERROR ]; then
  	logMessage "${LOG_ERROR}" "${1}"
  fi
}
function logWarn() {
  if [ $LOG_LEVEL -ge $LOG_WARN ]; then
  	logMessage "${LOG_WARN}" "${1}"
  fi
}
function logInfo() {
  if [ $LOG_LEVEL -ge $LOG_INFO ]; then
  	logMessage "${LOG_INFO}" "${1}"
  fi
}
function logTrace() {
  if [ $LOG_LEVEL -ge $LOG_TRACE ]; then
  	logMessage "${LOG_TRACE}" "${1}"
  fi
}
function logDebug() {
  if [ $LOG_LEVEL -ge $LOG_DEBUG ]; then
  	logMessage "${LOG_DEBUG}" "${1}"
  fi
}
function abort() {
  logError "$@"
  exit 1
}
function fail() {
  logError "$@"
  exit 1
}

function logMessage() {
  local LOG_MESSAGE_LEVEL="${1}"
  local LOG_MESSAGE="${2}"
  ## remove first item from FUNCNAME array
#  local CALLING_FUNCTION_ARRAY=("${FUNCNAME[@]:2}")
  ## Get the length of the array
  local CALLING_FUNCTION_ARRAY_LENGTH=${#FUNCNAME[@]}
  local CALLING_FUNCTION_ARRAY=("${FUNCNAME[@]:2:$((CALLING_FUNCTION_ARRAY_LENGTH - 3))}")
#  echo "CALLING_FUNCTION_ARRAY[@]=${CALLING_FUNCTION_ARRAY[@]}"

  local CALL_ARRAY_LENGTH=${#CALLING_FUNCTION_ARRAY[@]}
  local REVERSED_CALL_ARRAY=()
  for (( i = CALL_ARRAY_LENGTH - 1; i >= 0; i-- )); do
    REVERSED_CALL_ARRAY+=( "${CALLING_FUNCTION_ARRAY[i]}" )
  done
#  echo "REVERSED_CALL_ARRAY[@]=${REVERSED_CALL_ARRAY[@]}"

#  local CALLING_FUNCTION_STR="${CALLING_FUNCTION_ARRAY[*]}"
  ## ref: https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-a-bash-array-into-a-delimited-string#17841619
  local SEPARATOR=":"
  local CALLING_FUNCTION_STR
  CALLING_FUNCTION_STR=$(printf "${SEPARATOR}%s" "${REVERSED_CALL_ARRAY[@]}")
  CALLING_FUNCTION_STR=${CALLING_FUNCTION_STR:${#SEPARATOR}}

  ## ref: https://stackoverflow.com/a/13221491
  if [ "${LOGLEVEL_TO_STR[${LOG_MESSAGE_LEVEL}]+abc}" ]; then
    LOG_LEVEL_STR="${LOGLEVEL_TO_STR[${LOG_MESSAGE_LEVEL}]}"
  else
    abort "Unknown log level of [${LOG_MESSAGE_LEVEL}]"
  fi

  local LOG_LEVEL_PADDING_LENGTH=5

  local PADDED_LOG_LEVEL
  PADDED_LOG_LEVEL=$(printf "%-${LOG_LEVEL_PADDING_LENGTH}s" "${LOG_LEVEL_STR}")

  local LOG_PREFIX="${CALLING_FUNCTION_STR}():"
  echo -e "[${PADDED_LOG_LEVEL}]: ==> ${LOG_PREFIX} ${LOG_MESSAGE}"
}

function setLogLevel() {
  LOG_LEVEL_STR=$1

  ## ref: https://stackoverflow.com/a/13221491
  if [ "${LOGLEVELSTR_TO_LEVEL[${LOG_LEVEL_STR}]+abc}" ]; then
    LOG_LEVEL="${LOGLEVELSTR_TO_LEVEL[${LOG_LEVEL_STR}]}"
  else
    abort "Unknown log level of [${LOG_LEVEL_STR}]"
  fi

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

function populate_scenarios() {
    if [[ -d "${MOLECULE_DIR}" ]]; then
        # Build the find exclusion arguments dynamically
        local exclude_args=()
        for d in "${EXCLUDE_DIRS[@]}"; do
            exclude_args+=("-not" "-name" "${d}")
        done

        # Populate array with subdirectories only, excluding specified names, and SORTING
        while IFS= read -r dir; do
            VALID_SCENARIOS+=("$dir")
        done < <(find "${MOLECULE_DIR}" -maxdepth 1 -mindepth 1 -type d "${exclude_args[@]}" -exec basename {} \; | sort)
    fi
}

# Initialize the array
populate_scenarios

function usage() {
  echo "Usage: ${SCRIPT_NAME} [options] [MOLECULE_TEST_SCENARIO]"
  echo ""
  echo "  Options:"
  echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG] : run with specified log level (default: '${LOGLEVEL_TO_STR[${LOG_LEVEL}]}')"
  echo "       -i : MOLECULE_IMAGE (${DOCKER_IMAGE_KEYS})"
  echo "       -l : show/list test cases"
  echo "       -v : show script version"
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
	echo "       ${SCRIPT_NAME} -L DEBUG bootstrap_pip"
	echo "       ${SCRIPT_NAME} -L DEBUG"
  echo "       ${SCRIPT_NAME} -v"
	[ -z "$1" ] || exit "$1"
}


function main() {
  while getopts "L:i:lvh" opt; do
      case "${opt}" in
          L) setLogLevel "${OPTARG}" ;;
          i) MOLECULE_IMAGE="${OPTARG}" ;;
          l) print_test_cases && exit ;;
          v) echo "${VERSION}" && exit ;;
          h) usage 1 ;;
          \?) usage 2 ;;
          *) usage ;;
      esac
  done
  shift $((OPTIND-1))

  if [ $# -eq 0 ]; then
    MOLECULE_TEST_SCENARIO="${MOLECULE_TEST_SCENARIO_DEFAULT}"
  elif [ $# -eq 1 ]; then
    MOLECULE_TEST_SCENARIO="${1}"
  else
    usage 2
  fi

  ## 1. Enforce that the script is run from REPO_DIR
  CURRENT_DIR="$(pwd)"
  if [[ "${CURRENT_DIR}" != "${REPO_DIR}" ]]; then
    abort "This script must be executed from the repository root: ${REPO_DIR}"
  fi

  ## 2. Validate the MOLECULE_TEST_SCENARIO is in the VALID_SCENARIOS array
  local is_valid=0
  for scenario in "${VALID_SCENARIOS[@]}"; do
      if [[ "${scenario}" == "${MOLECULE_TEST_SCENARIO}" ]]; then
          is_valid=1
          break
      fi
  done

  if [[ ${is_valid} -eq 0 ]]; then
    logError "Scenario '${MOLECULE_TEST_SCENARIO}' is not valid or is in the exclusion list (save/shared/archive)."
    usage 1
  fi

	[ -z "$MOLECULE_IMAGE" ] && MOLECULE_IMAGE="$MOLECULE_IMAGE_DEFAULT"

  ## 3. Image validation and selection
  ## Check if the key exists in the map
  if [[ -v DOCKER_IMAGE_MAP[$MOLECULE_IMAGE] ]]; then
    echo "${DOCKER_IMAGE_MAP[$MOLECULE_IMAGE]}"
  else
    echo "Error: docker image key '$MOLECULE_IMAGE' not found." >&2
    return usage 2
  fi

  checkRequiredCommands molecule

  local RUN_MOLECULE_CMD_ARRAY=();
  RUN_MOLECULE_CMD_ARRAY+=("MOLECULE_IMAGE=systemd-python-ubuntu:24.04");
  RUN_MOLECULE_CMD_ARRAY+=("molecule destroy");
  RUN_MOLECULE_CMD_ARRAY+=("-s ${MOLECULE_TEST_SCENARIO}");
  RUN_MOLECULE_CMD_ARRAY+=("&& molecule test");
  RUN_MOLECULE_CMD_ARRAY+=("-s ${MOLECULE_TEST_SCENARIO}");

  echo "==> ${RUN_MOLECULE_CMD_ARRAY[*]}"
  if ! eval "${RUN_MOLECULE_CMD_ARRAY[*]}"; then
    echo "Error: molecule test execution failed"
    exit 1
  fi
}

main "$@"
