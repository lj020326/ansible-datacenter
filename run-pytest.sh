#!/usr/bin/env bash

VERSION="2024.1.1"

PYTEST_REPORT_DIR=".test-results"

PYTESTS_TARGET="."
LIST_TEST_CASES=0

PROJECT_DIR=$( git rev-parse --show-toplevel )

LOG_ERROR=0
LOG_WARN=1
LOG_INFO=2
LOG_TRACE=3
LOG_DEBUG=4

#LOG_LEVEL=${LOG_DEBUG}
LOG_LEVEL=${LOG_INFO}

function logError() {
  if [ $LOG_LEVEL -ge $LOG_ERROR ]; then
  	echo -e "[ERROR]: ${1}"
  fi
}
function logWarn() {
  if [ $LOG_LEVEL -ge $LOG_WARN ]; then
  	echo -e "[WARN ]: ${1}"
  fi
}
function logInfo() {
  if [ $LOG_LEVEL -ge $LOG_INFO ]; then
  	echo -e "[INFO ]: ${1}"
  fi
}
function logTrace() {
  if [ $LOG_LEVEL -ge $LOG_TRACE ]; then
  	echo -e "[TRACE]: ${1}"
  fi
}
function logDebug() {
  if [ $LOG_LEVEL -ge $LOG_DEBUG ]; then
  	echo -e "[DEBUG]: ${1}"
  fi
}

function setLogLevel() {
  local LOGLEVEL=$1

  case "${LOGLEVEL}" in
    ERROR*)
      LOG_LEVEL=$LOG_ERROR
      ;;
    WARN*)
      LOG_LEVEL=$LOG_WARN
      ;;
    INFO*)
      LOG_LEVEL=$LOG_INFO
      ;;
    TRACE*)
      LOG_LEVEL=$LOG_TRACE
      ;;
    DEBUG*)
      LOG_LEVEL=$LOG_DEBUG
      ;;
    *)
      abort "Unknown loglevel of [${LOGLEVEL}] specified"
  esac

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
