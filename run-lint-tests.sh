#!/usr/bin/env bash

VERSION="2025.6.12"

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

function cleanup_tmpdir() {
  test "${KEEP_TMP:-0}" = 1 || rm -rf "${TMP_DIR}"
}

## ref: https://stackoverflow.com/questions/229551/how-to-check-if-a-string-contains-a-substring-in-bash#229585
function stringContain() { case $2 in *$1* ) return 0;; *) return 1;; esac ;}

function validate_ansiblelint() {
  local LOG_PREFIX="validate_ansiblelint():"

  logInfo ""
  logInfo "#######################################################"
  eval "ansible-lint --version"
  logInfo "${LOG_PREFIX} Validate ansible-lint"
  local TEST_COMMAND="ansible-lint -p"
  eval "${TEST_COMMAND} > /dev/null 2>&1"
  local RETURN_STATUS=$?

  if [[ $RETURN_STATUS -eq 0 ]]; then
    logInfo "${LOG_PREFIX} SUCCESS => No exceptions found from [${TEST_COMMAND}]!!"
  else
    logInfo "${LOG_PREFIX} There are [${RETURN_STATUS}] exceptions found from [${TEST_COMMAND}]!! :("
    logInfo "${LOG_PREFIX} ${TEST_COMMAND}"
    eval "${TEST_COMMAND}"
  fi

  logInfo "#######################################################"
  logInfo "${LOG_PREFIX} RETURN_STATUS=${RETURN_STATUS}"
  logInfo ""

  return "${RETURN_STATUS}"
}

function validate_yamllint() {
  local LOG_PREFIX="validate_yamllint():"

  logInfo ""
  logInfo "#######################################################"
  eval "yamllint --version"
  logInfo "${LOG_PREFIX} Validate yamllint"
  local TEST_COMMAND="yamllint --no-warnings ."
  eval "${TEST_COMMAND} > /dev/null 2>&1"
  local RETURN_STATUS=$?

  if [[ $RETURN_STATUS -eq 0 ]]; then
    logInfo "${LOG_PREFIX} SUCCESS => No exceptions found from [${TEST_COMMAND}]!!"
  else
    logInfo "${LOG_PREFIX} There are [${RETURN_STATUS}] exceptions found from [${TEST_COMMAND}]!! :("
    logInfo "${LOG_PREFIX} ${TEST_COMMAND}"
    eval "${TEST_COMMAND}"
  fi

  logInfo "#######################################################"
  logInfo "${LOG_PREFIX} RETURN_STATUS=${RETURN_STATUS}"
  logInfo ""

  return "${RETURN_STATUS}"
}

function validate_kicslint() {
  local LOG_PREFIX="validate_kicslint():"

  local KICS_CONFIG_FILE=".kics-config.yml"

  ## ref: https://docs.kics.io/latest/documentation/#installation
  ## ref: https://formulae.brew.sh/formula/kics
  #export KICS_QUERIES_PATH=/usr/local/opt/kics/share/kics/assets/queries
  export KICS_QUERIES_PATH=${HOMEBREW_PREFIX:-/usr/local}/opt/kics/share/kics/assets/queries

  logInfo ""
  logInfo "#######################################################"
  eval "kics version"
  logInfo "${LOG_PREFIX} Validate kics lint"
  local TEST_COMMAND="kics scan --ci --config ${KICS_CONFIG_FILE}"
  eval "${TEST_COMMAND} > /dev/null 2>&1"
  local RETURN_STATUS=$?

  if [[ $RETURN_STATUS -eq 0 ]]; then
    logInfo "${LOG_PREFIX} SUCCESS => No exceptions found from [${TEST_COMMAND}]!!"
  else
    logInfo "${LOG_PREFIX} There are [${RETURN_STATUS}] exceptions found from [${TEST_COMMAND}]!! :("
    logInfo "${LOG_PREFIX} ${TEST_COMMAND}"
    eval "${TEST_COMMAND}"
  fi

  logInfo "#######################################################"
  logInfo "${LOG_PREFIX} RETURN_STATUS=${RETURN_STATUS}"
  logInfo ""

  return "${RETURN_STATUS}"
}

function validate_inclusivity() {
  local LOG_PREFIX="validate_inclusivity():"

  logInfo ""
  logInfo "#######################################################"
  eval "woke version"
  logInfo "${LOG_PREFIX} Validate inclusive language lint"
  local TEST_COMMAND="woke -c .inclusivity.yml --exit-1-on-failure ."
  eval "${TEST_COMMAND} > /dev/null 2>&1"
  local RETURN_STATUS=$?

  if [[ $RETURN_STATUS -eq 0 ]]; then
    logInfo "${LOG_PREFIX} SUCCESS => No exceptions found from [${TEST_COMMAND}]!!"
  else
    logInfo "${LOG_PREFIX} There are [${RETURN_STATUS}] exceptions found from [${TEST_COMMAND}]!! :("
    logInfo "${LOG_PREFIX} ${TEST_COMMAND}"
    eval "${TEST_COMMAND}"
  fi

  logInfo "#######################################################"
  logInfo "${LOG_PREFIX} RETURN_STATUS=${RETURN_STATUS}"
  logInfo ""

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
    TEST_ARGS=${@}
  fi
  local LOG_PREFIX="run_test_case(${TEST_CASE_ID}):"

  if stringContain "${TEST_CASE_ID}" "${TEST_CASES_STR}" ||
     stringContain "${TEST_FUNCTION}" "${TEST_CASES_STR}" ||
     [ "${TEST_CASES_STR}" == "ALL" ]
  then
    logDebug "${LOG_PREFIX} Run test [${TEST_FUNCTION}]"

    local TEST_COMMAND="${TEST_FUNCTION}"
    logDebug "${LOG_PREFIX} TEST_COMMAND=${TEST_COMMAND}"

#    local TEST_RESULTS=$(${TEST_FUNCTION} "${TEST_ARGS}")
#    local TEST_RESULTS=$(eval "${TEST_FUNCTION} ${TEST_ARGS}")
    eval "${TEST_FUNCTION} ${TEST_ARGS} >/dev/null 2>&1"
    local RETURN_STATUS=$?

    if [[ $RETURN_STATUS -eq 0 ]]; then
      logInfo "${LOG_PREFIX} ${TEST_FUNCTION}: SUCCESS"
    else
      logError "${LOG_PREFIX} ${TEST_FUNCTION}: FAILED"
    fi

    if [[ $RETURN_STATUS -ne 0 || $DISPLAY_TEST_RESULTS -gt 0 ]]; then
      logInfo "${LOG_PREFIX} TEST_RESULTS ****"
      eval "${TEST_FUNCTION} ${TEST_ARGS}"
    fi
    logDebug "${LOG_PREFIX} RETURN_STATUS=${RETURN_STATUS}"
  fi
  logDebug "${LOG_PREFIX} TEST_CASE_IDX=${TEST_CASE_IDX_PADDED} TEST_CASE=${TEST_CASE} RETURN_STATUS=${RETURN_STATUS} ERROR_COUNT=${ERROR_COUNT}"
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

    local TEST_CASE_ARGS=()
    if [[ ${#TEST_CASE_ARRAY[@]} -gt 1 ]]; then
      ## ref: https://unix.stackexchange.com/questions/413976/how-to-shift-array-value-in-bash#413990
      TEST_CASE_ARGS=${TEST_CASE_ARRAY[@]:1}
      logDebug "${LOG_PREFIX} TEST_CASE_ARGS=${TEST_CASE_ARGS[@]}"
    fi

    run_test_case "${TEST_CASE_IDX_PADDED}" "${TEST_CASE}" "${TEST_CASES_STR}" "${TEST_CASE_ARGS[@]}"
    RETURN_STATUS=$?
    ERROR_COUNT=$((${ERROR_COUNT} + ${RETURN_STATUS}))
    logDebug "${LOG_PREFIX} TEST_CASE_IDX=${TEST_CASE_IDX_PADDED} TEST_CASE=${TEST_CASE} RETURN_STATUS=${RETURN_STATUS} ERROR_COUNT=${ERROR_COUNT}"

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


function install_jq() {
  local LOG_PREFIX="install_jq():"
  local OS="${1}"
  local PACKAGE_NAME="jq"

  echo "==> installing jq - required for yq sort-keys (https://mikefarah.gitbook.io/yq/operators/sort-keys)"
  if [[ -n "${INSTALL_ON_LINUX-}" ]]; then
    logInfo "${LOG_PREFIX} Installing jq for linux"
    if [[ -n "$(command -v dnf)" ]]; then
      sudo dnf install -y "${PACKAGE_NAME}"
    elif [[ -n "$(command -v yum)" ]]; then
      sudo yum install -y "${PACKAGE_NAME}"
    elif [[ -n "$(command -v apt-get)" ]]; then
      sudo apt-get install -y "${PACKAGE_NAME}"
    fi
  fi
  if [[ -n "${INSTALL_ON_MACOS-}" ]]; then
    logInfo "${LOG_PREFIX} Installing jq for MacOS"
    brew install "${PACKAGE_NAME}"
  fi
  if [[ -n "${INSTALL_ON_MSYS-}" ]]; then
    PACKAGE_NAME="mingw-w64-x86_64-jq"
    logInfo "${LOG_PREFIX} Installing jq for MSYS2"
    ## ref: https://packages.msys2.org/package/mingw-w64-x86_64-jq?repo=mingw64
    pacman --noconfirm -S "${PACKAGE_NAME}"
  fi
}

# ref: https://formulae.brew.sh/formula/kics
function install_kics() {
  local LOG_PREFIX="install_kics():"
  local OS="${1}"

  logInfo "${LOG_PREFIX} Installing kics (https://formulae.brew.sh/formula/kics)"

  if [[ -n "${INSTALL_ON_MACOS-}" ]]; then
    ## ref: https://formulae.brew.sh/formula/kics
    logInfo "${LOG_PREFIX} Installing kics for MacOS using brew"
    brew install kics
  else
    logInfo "${LOG_PREFIX} Kics install not supported on platform ${OS}"
  fi
}

## ref: https://github.com/get-woke/woke/#install-woke
## ref: https://docs.getwoke.tech/installation/
function install_woke() {
  local LOG_PREFIX="install_woke():"
  local OS="${1}"

  logInfo "${LOG_PREFIX} Installing woke (https://docs.getwoke.tech/installation/)"

  if [[ -n "${INSTALL_ON_MACOS-}" ]]; then
    ## ref: https://docs.getwoke.tech/installation/
    logInfo "${LOG_PREFIX} Installing woke for MacOS using brew"
    brew install get-woke/tap/woke
  else
    logInfo "${LOG_PREFIX} woke install not supported on platform ${OS}"
  fi
}

function install_ansiblelint() {
  local LOG_PREFIX="install_ansiblelint():"

  PIP_COMMAND="pip install ansible-lint"
  logDebug "${LOG_PREFIX} ${PIP_COMMAND}"
  eval "${PIP_COMMAND} >/dev/null 2>&1"
  logDebug "${LOG_PREFIX} pip install complete"
}


function install_yamllint() {
  local LOG_PREFIX="install_yamllint():"

  PIP_COMMAND="pip install yamllint"
  logDebug "${LOG_PREFIX} ${PIP_COMMAND}"
  eval "${PIP_COMMAND} >/dev/null 2>&1"
  logDebug "${LOG_PREFIX} pip install complete"
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
    logDebug "${LOG_PREFIX} executable '${executable}' not found"
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

    logDebug "${LOG_PREFIX} installing executable '${executable}'"
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

  while getopts "L:r:dlpvhk" opt; do
      case "${opt}" in
          L) setLogLevel "${OPTARG}" ;;
          l) print_test_cases && exit ;;
          r) PYTEST_JUNIT_REPORT="${OPTARG}" ;;
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
  logDebug "Ensure ansible-lint present/installed"
  ensure_tool ansiblelint

  ## ref: https://pypi.org/project/yamllint/
  logDebug "Ensure yamllint present/installed"
  ensure_tool yamllint

  ## ref: https://docs.kics.io/latest/documentation/
  logDebug "Ensure kics present/installed"
  ensure_tool kics

  ## ref: https://github.com/get-woke/woke/
  logDebug "Ensure woke present/installed"
  ensure_tool woke

  checkRequiredCommands ansible-inventory ansible-lint yamllint kics woke

  TEST_CASES=("ALL")
  if [ $# -gt 0 ]; then
    TEST_CASES=("$@")
  fi

  #logInfo "SCRIPT_DIR=${SCRIPT_DIR}"
  logInfo "PROJECT_DIR=${PROJECT_DIR}"
  logInfo "TEST_CASES=${TEST_CASES[@]}"

  run_tests "${TEST_CASES[@]}"
  TOTAL_FAILED=$?

  logInfo "*********************** "
  logInfo "OVERALL INVENTORY TEST RESULTS"
  logInfo "TOTAL TOTAL_FAILED=${TOTAL_FAILED}"
  if [[ $TOTAL_FAILED -eq 0 ]]; then
    logInfo "TEST SUCCEEDED!"
  else
    logError "TEST FAILED!"
  fi
  exit $TOTAL_FAILED
}

main "$@"
