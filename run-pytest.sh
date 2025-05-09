#!/usr/bin/env bash

VERSION="2024.1.1"

PYTEST_REPORT_DIR=".test-results"

PYTESTS_TARGET="."
LIST_TEST_CASES=0

PROJECT_DIR=$( git rev-parse --show-toplevel )

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

function print_test_cases() {
  local LOG_PREFIX="==> print_test_cases():"

  pytest --collect-only .

}


###################################
### run pytests
function run_pytests() {
  local LOG_PREFIX="==> run_pytests():"
  local TEST_CASES=("$@")

  logInfo "${LOG_PREFIX} TEST_CASES[@]=${TEST_CASES[@]}"

#  PYTEST_CMD="pytest --verbose --capture=tee-sys --junitxml=${PYTEST_REPORT_DIR}/junit-report.xml ${PYTESTS_TARGET}"

  ##################
  ## run multiple tests in parallel (inventory tests are threadsafe)
  ## requires the following python libraries to be installed:
  ## - 'py'
  ## - 'pytest-parallel'
  ## pip install py pytest-parallel
  PYTEST_CMD="pytest --capture=tee-sys --workers auto --junitxml=${PYTEST_REPORT_DIR}/junit-report.xml ${PYTESTS_TARGET}"

  if [[ "${TEST_CASES[@]}" != "ALL" ]]; then
    ## ref: https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-a-bash-array-into-a-delimited-string#17841619
    SEPARATOR=" or "
    PYTEST_PARAMS=$(printf "${SEPARATOR}%s" "${TEST_CASES[@]}")
    PYTEST_PARAMS=${PYTEST_PARAMS:${#SEPARATOR}}
    PYTEST_CMD+=" -k '${PYTEST_PARAMS}'"
  fi
  eval "${PYTEST_CMD}"
  local RETURN_STATUS=$?

  logInfo "${LOG_PREFIX} TEST[${TEST_CASE_ID}] - RETURN_STATUS=${RETURN_STATUS}"
  return "${RETURN_STATUS}"
}


usage() {
  echo "Usage: ${0} [options] [[TESTCASE_ID] [TESTCASE_ID] ...]"
  echo ""
  echo "  Options:"
  echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG] : run with specified log level (default INFO)"
  echo "       -l : show/list test cases"
  echo "       -v : show script version"
  echo "       -h : help"
  echo "     [TEST_CASES]"
  echo ""
  echo "  Examples:"
	echo "       ${0} "
	echo "       ${0} -l"
	echo "       ${0} validate_file_extensions"
	echo "       ${0} 01 03 ## using test case indices"
	echo "       ${0} -L DEBUG validate_child_inventories"
  echo "       ${0} -v"
	[ -z "$1" ] || exit "$1"
}


function main() {

#  cd "${PROJECT_DIR}"

  checkRequiredCommands ansible-playbook pytest

  SHOW_VERSION=0
  while getopts "lL:vh" opt; do
      case "${opt}" in
          L) setLogLevel "${OPTARG}" ;;
          l) LIST_TEST_CASES=1 ;;
          v) echo "${VERSION}" && SHOW_VERSION=1 ;;
          h) usage 1 ;;
          \?) usage 2 ;;
          *) usage ;;
      esac
  done
  shift $((OPTIND-1))

  if [ "${SHOW_VERSION}" -eq 1 ]; then
    exit
  fi
  if [ "${LIST_TEST_CASES}" -eq 1 ]; then
    print_test_cases
    exit
  fi

  TEST_CASES=("ALL")
  if [ $# -gt 0 ]; then
    TEST_CASES=("$@")
  fi

  run_pytests "${TEST_CASES[@]}"

}

main "$@"
