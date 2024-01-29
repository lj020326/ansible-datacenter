#!/usr/bin/env bash

VERSION="2024.1.1"

#### PURPOSE RELATED
PROJECT_DIR=$( git rev-parse --show-toplevel )
INVENTORY_DIR="${PROJECT_DIR}/inventory"

RUN_PYTEST=0
LIST_TEST_CASES=0

PYTEST_REPORT_DIR=".test-results"

ALWAYS_SHOW_TEST_RESULTS=0

INVENTORY_LIST="
PROD
QA
DEV
"

TEST_CASE_CONFIGS="
validate_file_extensions
validate_yamllint
validate_child_inventories
validate_child_groupvars
validate_xenv_group_hierarchy
"

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

function fail() {
  error "$@"
  exit 1
}

## ref: https://stackoverflow.com/questions/229551/how-to-check-if-a-string-contains-a-substring-in-bash#229585
function stringContain() { case $2 in *$1* ) return 0;; *) return 1;; esac ;}

###################################
### validation functions
function validate_file_extensions() {
  local LOG_PREFIX="validate_file_extensions():"
  local ERROR_COUNT=0

  logInfo ""
  logInfo "#######################################################"
  logInfo "${LOG_PREFIX} Validate all files consistent with *.yml"
  local EXCEPTION_COUNT=$(find . -type f \( ! -iname ".*" ! -iname "*.yml" ! -iname "*.sh" ! -iname "*.py" ! -iname "*.log" \) | wc -l)
  if [[ $EXCEPTION_COUNT -eq 0 ]]; then
    logInfo "${LOG_PREFIX} SUCCESS => No group_var diffs found!!"
  else
    ERROR_COUNT=$((${ERROR_COUNT} + ${EXCEPTION_COUNT}))
    logInfo "${LOG_PREFIX} There are [${EXCEPTION_COUNT}] inconsistent file names found without *.yml extension:"
    find . -type f \( ! -iname ".*" ! -iname "*.yml" ! -iname "*.sh" ! -iname "*.py" ! -iname "*.log" \)
  fi
  logInfo "#######################################################"
  logInfo ""

  return "${ERROR_COUNT}"
}

function validate_yamllint() {
  local LOG_PREFIX="validate_yamllint():"

  logInfo ""
  logInfo "#######################################################"
  logInfo "${LOG_PREFIX} Validate yamllint"
  test_command="yamllint . 2>&1"
  test_results=$(eval "${test_command}")
  local RETURN_STATUS=$?

  if [[ $RETURN_STATUS -eq 0 ]]; then
    logInfo "${LOG_PREFIX} SUCCESS => No exceptions found from [${test_command}]!!"
  else
    logInfo "${LOG_PREFIX} There are [${RETURN_STATUS}] exceptions found from [${test_command}]!! :("
    logInfo "${test_results}"
  fi

  logInfo "#######################################################"
  logInfo ""

  return "${RETURN_STATUS}"
}

function validate_child_inventories() {

  ansible-inventory --version
  local ERROR_COUNT=0
  logInfo ""

  IFS=$'\n'
  for INVENTORY in ${INVENTORY_LIST}
  do
    logInfo "#######################################################"
    logInfo "==> ansible-inventory --graph -i ${INVENTORY}"
    logInfo "==>"
    local EXCEPTION_COUNT=$(ansible-inventory --graph -i "${INVENTORY}" 2>&1 | grep -c -i -e warning -e error)

    if [[ $EXCEPTION_COUNT -eq 0 ]]; then
      logInfo "SUCCESS => No ansible-inventory exceptions found!!"
    else
#      ERROR_COUNT+=EXCEPTION_COUNT
      ERROR_COUNT=$((${ERROR_COUNT} + ${EXCEPTION_COUNT}))
      logInfo "There are [${EXCEPTION_COUNT}] ansible-inventory exceptions found:"
      ansible-inventory --graph "${INVENTORY}" 2>&1 | grep -i -e warning -e error
    fi
  done

  logInfo "#######################################################"
  logInfo ""

  return "${ERROR_COUNT}"
}

function validate_child_groupvars() {
  local LOG_PREFIX="validate_child_groupvars():"
  local ERROR_COUNT=0
  logInfo ""

  IFS=$'\n'
  for INVENTORY in ${INVENTORY_LIST}
  do
    logInfo "#######################################################"
    logInfo "${LOG_PREFIX} Compare ./group_vars and [$INVENTORY]"
    local EXCEPTION_COUNT=$(diff -r group_vars "${INVENTORY}/group_vars" | grep -c -v ": env_specific.yml")
    if [[ $EXCEPTION_COUNT -eq 0 ]]; then
      logInfo "${LOG_PREFIX} SUCCESS => No group_var diffs found!!"
    else
      ERROR_COUNT=$((${ERROR_COUNT} + ${EXCEPTION_COUNT}))
      logInfo "${LOG_PREFIX} There are [${EXCEPTION_COUNT}] group_var diffs found :("
      diff -r group_vars "${INVENTORY}/group_vars" | grep -v ": env_specific.yml"
    fi
  done
  logInfo "#######################################################"
  logInfo ""

  return "${ERROR_COUNT}"
}

function validate_xenv_group_hierarchy() {
  local LOG_PREFIX="validate_xenv_group_hierarchy():"
  local ERROR_COUNT=0
  logInfo ""
  local RETURN_STATUS=0

  IFS=$'\n'
  for INVENTORY in ${INVENTORY_LIST}
  do
    logInfo "#######################################################"
    logInfo "${LOG_PREFIX} Check if all groups in [${INVENTORY}/hosts.yml] exist in xenv_groups.yml"

    test_command="python3 run-group-in-xenv-check.py -G xenv_groups.yml ${INVENTORY}/hosts.yml 2>&1"
    local TEST_RESULTS=$(eval "${test_command}")
    RETURN_STATUS=$?
#    ERROR_COUNT+=$RETURN_STATUS
#    ERROR_COUNT=${ERROR_COUNT}+${RETURN_STATUS}
    ERROR_COUNT=$((${ERROR_COUNT} + ${RETURN_STATUS}))

    if [[ $RETURN_STATUS -eq 0 ]]; then
      logInfo "${LOG_PREFIX} SUCCESS => No exceptions found from [${test_command}]!!"
    else
      logInfo "${LOG_PREFIX} There are [${RETURN_STATUS}] exceptions found from [${test_command}]!! :("
      logInfo "${TEST_RESULTS}"
    fi

  done
  logInfo "#######################################################"
  logInfo ""

  logInfo ""
  logInfo "#######################################################"
  logInfo "${LOG_PREFIX} Check if all groups in [xenv_infra_hosts.yml] exist in xenv_groups.yml"

  test_command="python3 run-group-in-xenv-check.py -G xenv_groups.yml xenv_hosts.yml 2>&1"
  local TEST_RESULTS=$(eval "${test_command}")
  RETURN_STATUS=$?
  ERROR_COUNT=$((${ERROR_COUNT} + ${RETURN_STATUS}))

  if [[ $RETURN_STATUS -eq 0 ]]; then
    logInfo "${LOG_PREFIX} SUCCESS => No exceptions found from [${test_command}]!!"
  else
    logInfo "${LOG_PREFIX} There are [${RETURN_STATUS}] exceptions found from [${test_command}]!! :("
    logInfo "${TEST_RESULTS}"
  fi

  logInfo "${LOG_PREFIX} ERROR_COUNT=${ERROR_COUNT}"
  logInfo "#######################################################"
  logInfo ""

  return "${ERROR_COUNT}"
}

function validate_xenv_groups_unique() {
  local LOG_PREFIX="validate_xenv_groups_unique():"

  logInfo ""
  logInfo "#######################################################"
  logInfo "${LOG_PREFIX} Check if all groups in [xenv_groups.yml] are unique"

  test_command="python3 run-group-in-xenv-check.py -d xenv_groups.yml 2>&1"
  local TEST_RESULTS=$(eval "${test_command}")
  local RETURN_STATUS=$?

  if [[ $RETURN_STATUS -eq 0 ]]; then
    logInfo "${LOG_PREFIX} SUCCESS => No exceptions found from [${test_command}]!!"
  else
    logInfo "${LOG_PREFIX} There are [${RETURN_STATUS}] exceptions found from [${test_command}]!! :("
    logInfo "${TEST_RESULTS}"
  fi

  logInfo "#######################################################"
  logInfo ""

  return "${RETURN_STATUS}"
}

###################################
### run pytests
function run_pytests() {
  local LOG_PREFIX="==> run_pytests():"
  local TEST_CASES=("$@")

  logInfo "${LOG_PREFIX} TEST_CASES[@]=${TEST_CASES[@]}"

  PYTEST_CMD="pytest --verbose --capture=tee-sys --junitxml=${PYTEST_REPORT_DIR}/junit-report.xml ."
  if [[ "${TEST_CASES[@]}" != "ALL" ]]; then
    ## ref: https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-a-bash-array-into-a-delimited-string#17841619
    SEPARATOR=" or "
    PYTEST_PARAMS=$(printf "${SEPARATOR}%s" "${TEST_CASES[@]}")
    PYTEST_PARAMS=${PYTEST_PARAMS:${#SEPARATOR}}
    PYTEST_CMD+=" -k '${PYTEST_PARAMS}'"
  fi
  local TEST_RESULTS=$(eval "${PYTEST_CMD}")
  local RETURN_STATUS=$?

  logInfo "${TEST_RESULTS}"
  logInfo "${LOG_PREFIX} TEST[${TEST_CASE_ID}] - RETURN_STATUS=${RETURN_STATUS}"

  return "${RETURN_STATUS}"
}

function run_test_case() {
  local TEST_CASE_ID=$1
  local TEST_FUNCTION=$2
  local TEST_CASES_STR=$3
  shift 3

  local TEST_ARGS=()
  local RETURN_STATUS=0

  if [ $# -gt 0 ]; then
    TEST_ARGS=${@}
  fi
  local LOG_PREFIX="==> run_test_case(${TEST_CASE_ID}):"

  if stringContain "${TEST_CASE_ID}" "${TEST_CASES_STR}" ||
     stringContain "${TEST_FUNCTION}" "${TEST_CASES_STR}" ||
     [ "${TEST_CASES_STR}" == "ALL" ]
  then
    logInfo "${LOG_PREFIX} Run test [${TEST_FUNCTION}]"

    local TEST_RESULTS=$(${TEST_FUNCTION} "${TEST_ARGS}")
    RETURN_STATUS=$?
    logDebug "${LOG_PREFIX} RETURN_STATUS=${RETURN_STATUS}"

    if [[ $RETURN_STATUS -eq 0 ]]; then
      logInfo "${LOG_PREFIX} SUCCESS"
    else
      logError "${LOG_PREFIX} FAILED"
    fi
    if [[ $RETURN_STATUS -ne 0 || $ALWAYS_SHOW_TEST_RESULTS -gt 0 ]]; then
      logInfo "${LOG_PREFIX} TEST_RESULTS ****"
      echo "${TEST_RESULTS}"
    fi
  fi
  return "${RETURN_STATUS}"

}

function print_test_cases() {
  local LOG_PREFIX="==> print_test_cases():"

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
  local LOG_PREFIX="==> run_tests():"
  local ERROR_COUNT=0
#  local TEST_CASES=$@
  local TEST_CASES=("$@")
  local RETURN_STATUS=0

  logInfo "${LOG_PREFIX} TEST_CASES[@]=${TEST_CASES[@]}"
  TEST_CASES_STR="${TEST_CASES[@]}"
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

    logDebug "${LOG_PREFIX} TEST_CASE_IDX=${TEST_CASE_IDX_PADDED} TEST_CASE=${TEST_CASE}"

    if [[ ${#TEST_CASE_ARRAY[@]} -gt 1 ]]; then
      ## ref: https://unix.stackexchange.com/questions/413976/how-to-shift-array-value-in-bash#413990
      TEST_CASE_ARGS=${TEST_CASE_ARRAY[@]:1}
      logDebug "${LOG_PREFIX} TEST_CASE_ARGS=${TEST_CASE_ARGS[@]}"
    fi

    run_test_case "${TEST_CASE_IDX_PADDED}" "${TEST_CASE}" "${TEST_CASES_STR}" "${TEST_CASE_ARGS[@]}"
    RETURN_STATUS=$?
    ERROR_COUNT=$((${ERROR_COUNT} + ${RETURN_STATUS}))

  done

  logInfo "${LOG_PREFIX} ERROR_COUNT=${ERROR_COUNT}"
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

usage() {
  echo "Usage: ${0} [options] [[TESTCASE_ID] [TESTCASE_ID] ...]"
  echo ""
  echo "  Options:"
  echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG] : run with specified log level (default INFO)"
  echo "       -l : show/list test cases"
  echo "       -p : run pytest"
  echo "       -v : show script version"
  echo "       -h : help"
  echo "     [TEST_CASES]"
  echo ""
  echo "  Examples:"
	echo "       ${0} "
	echo "       ${0} -l"
	echo "       ${0} 01"
	echo "       ${0} validate_file_extensions"
	echo "       ${0} 01 03"
	echo "       ${0} -L DEBUG 02 04"
	echo "       ${0} -p"
	echo "       ${0} -p 01 02"
  echo "       ${0} -v"
	[ -z "$1" ] || exit "$1"
}

function main() {

  checkRequiredCommands ansible-inventory yamllint

  SHOW_VERSION=0
  while getopts "lL:pvh" opt; do
      case "${opt}" in
          L) setLogLevel "${OPTARG}" ;;
          l) LIST_TEST_CASES=1 ;;
          p) RUN_PYTEST=1 ;;
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

  #logInfo "==> SCRIPT_DIR=${SCRIPT_DIR}"
  logInfo "==> PROJECT_DIR=${PROJECT_DIR}"
  logInfo "==> TEST_CASES=${TEST_CASES[@]}"

  if [ $RUN_PYTEST -eq 1 ]; then
    checkRequiredCommands pytest
    run_pytests "${TEST_CASES[@]}"
    exit $?
  fi

  cd "${INVENTORY_DIR}"

  run_tests "${TEST_CASES[@]}"
  TOTAL_FAILED=$?

  logInfo "==> *********************** "
  logInfo "==> OVERALL INVENTORY TEST RESULTS"
  logInfo "==> TOTAL TOTAL_FAILED=${TOTAL_FAILED}"
  if [[ $TOTAL_FAILED -eq 0 ]]; then
    logInfo "==> TEST SUCCEEDED!"
  else
    logError "==> TEST FAILED!"
  fi
  exit $TOTAL_FAILED
}

main "$@"
