#!/usr/bin/env bash

## ref: https://intoli.com/blog/exit-on-errors-in-bash-scripts/
# exit when any command fails
#set -e

VERSION="2025.6.12"

#SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(dirname "$0")"
SCRIPT_NAME="$(basename "$0")"

## PURPOSE RELATED VARS
#PROJECT_DIR=$( git rev-parse --show-toplevel )
PROJECT_DIR="$(cd "${SCRIPT_DIR}" && git rev-parse --show-toplevel)"
INVENTORY_DIR="${PROJECT_DIR}/inventory"

KEEP_TMP=0
RUN_PYTEST=0
ENSURE_PYTHON_MODULES=0

PYTEST_JUNIT_REPORT_DEFAULT=".test-results/junit-report.xml"

DISPLAY_TEST_RESULTS=0

INVENTORY_LIST="
PROD
QA
DEV
"

INVENTORY_YML_LIST=("hosts.yml")
INVENTORY_YML_LIST+=("xenv_hosts.yml")
INVENTORY_YML_LIST+=("xenv_groups.yml")

TEST_CASE_CONFIGS="
validate_file_extensions
validate_yml_sortorder
validate_xenv_group_hierarchy
validate_child_inventories
validate_child_groupvars
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

# string formatters
if [[ -t 1 ]]
then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_orange="$(tty_mkbold 33)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

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

function log_error() {
  if [ $LOG_LEVEL -ge $LOG_ERROR ]; then
  	log_message "${LOG_ERROR}" "${1}"
  fi
}

function log_warn() {
  if [ $LOG_LEVEL -ge $LOG_WARN ]; then
  	log_message "${LOG_WARN}" "${1}"
  fi
}

function log_info() {
  if [ $LOG_LEVEL -ge $LOG_INFO ]; then
  	log_message "${LOG_INFO}" "${1}"
  fi
}

function log_trace() {
  if [ $LOG_LEVEL -ge $LOG_TRACE ]; then
  	log_message "${LOG_TRACE}" "${1}"
  fi
}

function log_debug() {
  if [ $LOG_LEVEL -ge $LOG_DEBUG ]; then
  	log_message "${LOG_DEBUG}" "${1}"
  fi
}

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

function ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

function abort() {
  log_error "$@"
  exit 1
}

function warn() {
  log_warn "$@"
#  log_warn "$(chomp "$1")"
#  printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")" >&2
}

#function abort() {
#  printf "%s\n" "$@" >&2
#  exit 1
#}

function error() {
  log_error "$@"
#  printf "%s\n" "$@" >&2
##  echo "$@" 1>&2;
}

function fail() {
  error "$@"
  exit 1
}

function log_message() {
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
  local __LOG_MESSAGE="${LOG_PREFIX} ${LOG_MESSAGE}"
#  echo -e "[${PADDED_LOG_LEVEL}]: ==> ${__LOG_MESSAGE}"
  if [ "${LOG_MESSAGE_LEVEL}" -eq $LOG_INFO ]; then
    printf "${tty_blue}[${PADDED_LOG_LEVEL}]: ==> ${LOG_PREFIX}${tty_reset} %s\n" "${LOG_MESSAGE}" >&2
#    printf "${tty_blue}[${PADDED_LOG_LEVEL}]: ==>${tty_reset} %s\n" "${__LOG_MESSAGE}" >&2
#    printf "${tty_blue}[${PADDED_LOG_LEVEL}]: ==>${tty_bold} %s${tty_reset}\n" "${__LOG_MESSAGE}"
  elif [ "${LOG_MESSAGE_LEVEL}" -eq $LOG_WARN ]; then
    printf "${tty_orange}[${PADDED_LOG_LEVEL}]: ==> ${LOG_PREFIX}${tty_bold} %s${tty_reset}\n" "${LOG_MESSAGE}" >&2
#    printf "${tty_orange}[${PADDED_LOG_LEVEL}]: ==>${tty_bold} %s${tty_reset}\n" "${__LOG_MESSAGE}" >&2
#    printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")" >&2
  elif [ "${LOG_MESSAGE_LEVEL}" -le $LOG_ERROR ]; then
    printf "${tty_red}[${PADDED_LOG_LEVEL}]: ==> ${LOG_PREFIX}${tty_bold} %s${tty_reset}\n" "${LOG_MESSAGE}" >&2
#    printf "${tty_red}[${PADDED_LOG_LEVEL}]: ==>${tty_bold} %s${tty_reset}\n" "${__LOG_MESSAGE}" >&2
#    printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")" >&2
  else
    printf "${tty_bold}[${PADDED_LOG_LEVEL}]: ==> ${LOG_PREFIX}${tty_reset} %s\n" "${LOG_MESSAGE}" >&2
#    printf "[${PADDED_LOG_LEVEL}]: ==> %s\n" "${LOG_PREFIX} ${LOG_MESSAGE}"
  fi
}

function set_log_level() {
  LOG_LEVEL_STR=$1

  ## ref: https://stackoverflow.com/a/13221491
  if [ "${LOGLEVELSTR_TO_LEVEL[${LOG_LEVEL_STR}]+abc}" ]; then
    LOG_LEVEL="${LOGLEVELSTR_TO_LEVEL[${LOG_LEVEL_STR}]}"
  else
    abort "Unknown log level of [${LOG_LEVEL_STR}]"
  fi

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

  if [[ $RETURN_STATUS -eq 0 ]]; then
    if [[ $COMMAND_RESULT != "" ]]; then
      log_debug "${COMMAND_RESULT}"
    fi
    log_debug "SUCCESS!"
  else
    log_error "ERROR (${RETURN_STATUS})"
#    echo "${COMMAND_RESULT}"
    abort "$(printf "Failed during: %s" "${COMMAND_RESULT}")"
  fi

}

function is_installed() {
  command -v "${1}" >/dev/null 2>&1 || return 1
}

function check_required_commands() {
  missingCommands=""
  for currentCommand in "$@"
  do
    is_installed "${currentCommand}" || missingCommands="${missingCommands} ${currentCommand}"
  done

  if [[ -n "${missingCommands}" ]]; then
    fail "Please install the following commands required by this script:${missingCommands}"
  fi
}

function cleanup_tmpdir() {
  test "${KEEP_TMP:-0}" = 1 || rm -rf "${TMP_DIR}"
}

## ref: https://stackoverflow.com/questions/229551/how-to-check-if-a-string-contains-a-substring-in-bash#229585
function stringContain() { case $2 in *$1* ) return 0;; *) return 1;; esac ;}

###################################
### validation functions
function validate_file_extensions() {
  local ERROR_COUNT=0

  log_info ""
  log_info "#######################################################"
  log_info "Validate all files consistent with *.yml"

  local EXCEPTION_COUNT=$(find . \
    -type f \( ! -iname ".*" ! -iname "*.yml" ! -iname "*.sh" ! -iname "*.py" ! -iname "*.log" ! -iname "*.md" ! -iname "pytest.ini" \) \
      -not -path "./.test-results/*" -not -path "./__pycache__/*" -not -path "./.pytest_cache/*" | wc -l)
  if [[ $EXCEPTION_COUNT -eq 0 ]]; then
    log_info "SUCCESS => No inconsistent file extensions found!!"
  else
    ERROR_COUNT=$((${ERROR_COUNT} + ${EXCEPTION_COUNT}))
    log_info "There are [${EXCEPTION_COUNT}] inconsistent file names found without *.yml extension:"
    find . \
      -type f \( ! -iname ".*" ! -iname "*.yml" ! -iname "*.sh" ! -iname "*.py" ! -iname "*.log" ! -iname "*.md" ! -iname "pytest.ini" \) \
      -not -path "./.test-results/*" -not -path "./__pycache__/*" -not -path "./.pytest_cache/*"
  fi

  log_info "#######################################################"
  log_info "ERROR_COUNT=${ERROR_COUNT}"
  log_info ""

  return "${ERROR_COUNT}"
}

function validate_child_inventories() {
  ansible-inventory --version
  local ERROR_COUNT=0
  log_info ""

  IFS=$'\n'
  for INVENTORY in ${INVENTORY_LIST}
  do
    log_info "#######################################################"
    log_info "Validate yamllint"
    local VALIDATION_TEST_COMMAND="ansible-inventory --graph -i ${INVENTORY} 2>&1"
    log_info "[${VALIDATION_TEST_COMMAND} | grep -i -e warning -e error]"
    local EXCEPTION_COUNT=$(eval "${VALIDATION_TEST_COMMAND} | grep -c -i -e warning -e error")

    if [[ $EXCEPTION_COUNT -eq 0 ]]; then
      log_info "SUCCESS => No ansible-inventory exceptions found!!"
    else
#      ERROR_COUNT+=EXCEPTION_COUNT
      ERROR_COUNT=$((${ERROR_COUNT} + ${EXCEPTION_COUNT}))
      log_info "There are [${EXCEPTION_COUNT}] ansible-inventory exceptions found:"
      eval "${VALIDATION_TEST_COMMAND} | grep -A 2 -i -e warning -e error"
    fi
  done

  log_info "#######################################################"
  log_info "ERROR_COUNT=${ERROR_COUNT}"
  log_info ""

  return "${ERROR_COUNT}"
}

function validate_child_groupvars() {
  local ERROR_COUNT=0
  log_info ""

  IFS=$'\n'
  for INVENTORY in ${INVENTORY_LIST}
  do
    log_info "#######################################################"
    log_info "Compare ./group_vars and [$INVENTORY]"
    local EXCEPTION_COUNT=$(diff -r group_vars "${INVENTORY}/group_vars" | grep -c -v ": env_specific.yml")
    if [[ $EXCEPTION_COUNT -eq 0 ]]; then
      log_info "SUCCESS => No group_var diffs found!!"
    else
      ERROR_COUNT=$((${ERROR_COUNT} + ${EXCEPTION_COUNT}))
      log_info "There are [${EXCEPTION_COUNT}] group_var diffs found :("
      diff -r group_vars "${INVENTORY}/group_vars" | grep -v ": env_specific.yml"
    fi
  done
  log_info "#######################################################"
  log_info "ERROR_COUNT=${ERROR_COUNT}"
  log_info ""

  return "${ERROR_COUNT}"
}

function validate_xenv_group_hierarchy() {
  local ERROR_COUNT=0
  log_info ""
  local RETURN_STATUS=0

  IFS=$'\n'
  for INVENTORY in ${INVENTORY_LIST}
  do
    log_info "#######################################################"
    log_info "Check if all groups in [${INVENTORY}/hosts.yml] exist in xenv_groups.yml"

    local TEST_COMMAND="python3 run-group-in-xenv-check.py -G xenv_groups.yml ${INVENTORY}/hosts.yml 2>&1"
    eval "${TEST_COMMAND} > /dev/null 2>&1"
    local RETURN_STATUS=$?
    ERROR_COUNT=$((${ERROR_COUNT} + ${RETURN_STATUS}))

    if [[ $RETURN_STATUS -eq 0 ]]; then
      log_info "SUCCESS => No exceptions found from [${TEST_COMMAND}]!!"
    else
      log_info "There are [${RETURN_STATUS}] exceptions found from [${TEST_COMMAND}]!! :("
      log_info "${TEST_COMMAND}"
      eval "${TEST_COMMAND}"
    fi

  done
  log_info "#######################################################"
  log_info ""

  log_info ""
  log_info "#######################################################"
  log_info "Check if all groups in [xenv_hosts.yml] exist in xenv_groups.yml"

  TEST_COMMAND="python3 run-group-in-xenv-check.py -G xenv_groups.yml xenv_hosts.yml 2>&1"
  eval "${TEST_COMMAND} > /dev/null 2>&1"
  local RETURN_STATUS=$?
  ERROR_COUNT=$((${ERROR_COUNT} + ${RETURN_STATUS}))

  if [[ $RETURN_STATUS -eq 0 ]]; then
    log_info "SUCCESS => No exceptions found from [${TEST_COMMAND}]!!"
  else
    log_info "There are [${RETURN_STATUS}] exceptions found from [${TEST_COMMAND}]!! :("
    log_info "${TEST_COMMAND}"
    eval "${TEST_COMMAND}"
  fi

  log_info "#######################################################"
  log_info "ERROR_COUNT=${ERROR_COUNT}"
  log_info ""

  return "${ERROR_COUNT}"
}

function validate_xenv_groups_unique() {
  log_info ""
  log_info "#######################################################"
  log_info "Check if all groups in [xenv_groups.yml] are unique"

  TEST_COMMAND="python3 run-group-in-xenv-check.py -d xenv_groups.yml 2>&1"
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

function validate_yml_sortorder() {
  local ERROR_COUNT=0
  log_info ""

  TMP_DIR="$(mktemp -d --suffix .inventory-tests XXXX -p /tmp)"
  trap cleanup_tmpdir INT TERM EXIT

  local DELIM=' -o '
  ## ref: https://superuser.com/questions/1371834/escaping-hyphens-with-printf-in-bash
  #'-name' ==> '\055name'
  printf -v FIND_FILE_ARGS "\055name %s${DELIM}" "${INVENTORY_YML_LIST[*]}"
  FIND_FILE_ARGS=${FIND_FILE_ARGS%$DELIM}

  log_debug "FIND_FILE_ARGS=${FIND_FILE_ARGS}"

  FIND_CMD="find . -type f \( ${FIND_FILE_ARGS} \) -printf '%P\n' | sort"
  log_info "${FIND_CMD}"

  INVENTORY_YML_FILES_FOUND=$(eval "${FIND_CMD}")
  log_debug "INVENTORY_YML_FILES_FOUND=${INVENTORY_YML_FILES_FOUND}"

  for INVENTORY_FILE in ${INVENTORY_YML_FILES_FOUND}
  do

    ## ref: https://mikefarah.gitbook.io/yq/operators/sort-keys
    local INVENTORY_FILE_DIRNAME=$(dirname "${INVENTORY_FILE}")
    local INVENTORY_FILE_BASENAME=$(basename "${INVENTORY_FILE}")
    local INVENTORY_FILE_NO_EXT="${INVENTORY_FILE_BASENAME%.*}"

    local TMP_INVENTORY_FILE_PREFIX=""
    if [[ "${INVENTORY_FILE_BASENAME}" != "." ]]; then
      TMP_INVENTORY_FILE_PREFIX="${INVENTORY_FILE_DIRNAME}_"
    fi
    TMP_INVENTORY_FILE_SORTED="${TMP_DIR}/${TMP_INVENTORY_FILE_PREFIX}${INVENTORY_FILE_BASENAME%.*}_sorted.yml"
    TMP_INVENTORY_FILE="${TMP_DIR}/${TMP_INVENTORY_FILE_PREFIX}${INVENTORY_FILE_BASENAME}"

    log_debug "Create temporary sorted file to compare with ${INVENTORY_FILE}"
    yq "${INVENTORY_FILE}" > "${TMP_INVENTORY_FILE}"
    yq -P 'sort_keys(..)' "${INVENTORY_FILE}" > "${TMP_INVENTORY_FILE_SORTED}"

    log_info "#######################################################"
    log_info "Compare ${INVENTORY_FILE} and ${TMP_INVENTORY_FILE_SORTED}"

    ## ref: https://stackoverflow.com/questions/1566461/how-to-count-differences-between-two-files-on-linux#8837860
    local EXCEPTION_COUNT=$(diff -U 0 "${TMP_INVENTORY_FILE_SORTED}" "${TMP_INVENTORY_FILE}" | grep -c "^@")
    if [[ $EXCEPTION_COUNT -eq 0 ]]; then
      log_info "SUCCESS => No sort diffs found!!"
    else
      ERROR_COUNT=$((${ERROR_COUNT} + ${EXCEPTION_COUNT}))
      log_info "There are [${EXCEPTION_COUNT}] sort diffs found :("
      diff -U 0 "${TMP_INVENTORY_FILE_SORTED}" "${TMP_INVENTORY_FILE}" | grep "^@"
    fi
    log_info "ERROR_COUNT=${ERROR_COUNT}"
  done
  log_info "#######################################################"
  log_info "ERROR_COUNT=${ERROR_COUNT}"
  log_info ""

  return "${ERROR_COUNT}"
}


###################################
### run pytests
function run_pytests() {
  local PYTEST_JUNIT_REPORT=$1
  local PYTESTS_TARGET=$2
  shift 2
  local TEST_CASES=("$@")

  log_info "TEST_CASES[@]=${TEST_CASES[@]}"

  local TEST_COMMAND="pytest --verbose --capture=tee-sys --junitxml=${PYTEST_JUNIT_REPORT} ${PYTESTS_TARGET}"
  if [[ "${TEST_CASES[@]}" != "ALL" ]]; then
    ## ref: https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-a-bash-array-into-a-delimited-string#17841619
    SEPARATOR=" or "
    PYTEST_PARAMS=$(printf "${SEPARATOR}%s" "${TEST_CASES[@]}")
    PYTEST_PARAMS=${PYTEST_PARAMS:${#SEPARATOR}}
    TEST_COMMAND+=" -k '${PYTEST_PARAMS}'"
  fi
  eval "${TEST_COMMAND} > /dev/null 2>&1"
  local RETURN_STATUS=$?

  if [[ $RETURN_STATUS -eq 0 ]]; then
    log_info "SUCCESS => No exceptions found from [${TEST_COMMAND}]!!"
  else
    log_info "There are [${RETURN_STATUS}] exceptions found from [${TEST_COMMAND}]!! :("
    log_info "${TEST_COMMAND}"
    eval "${TEST_COMMAND}"
  fi
  log_info "TEST[${TEST_CASE_ID}] - RETURN_STATUS=${RETURN_STATUS}"

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

  if stringContain "${TEST_CASE_ID}" "${TEST_CASES_STR}" ||
     stringContain "${TEST_FUNCTION}" "${TEST_CASES_STR}" ||
     [ "${TEST_CASES_STR}" == "ALL" ]
  then
    log_debug "Run test [${TEST_FUNCTION}]"

    local TEST_COMMAND="${TEST_FUNCTION}"
    log_debug "TEST_COMMAND=${TEST_COMMAND}"

#    local TEST_RESULTS=$(${TEST_FUNCTION} "${TEST_ARGS}")
#    local TEST_RESULTS=$(eval "${TEST_FUNCTION} ${TEST_ARGS}")
    eval "${TEST_FUNCTION} ${TEST_ARGS} >/dev/null 2>&1"
    local RETURN_STATUS=$?

    if [[ $RETURN_STATUS -eq 0 ]]; then
      log_info "${TEST_FUNCTION}: SUCCESS"
    else
      log_error "${TEST_FUNCTION}: FAILED"
    fi

    if [[ $RETURN_STATUS -ne 0 || $DISPLAY_TEST_RESULTS -gt 0 ]]; then
      log_info "TEST_RESULTS ****"
      eval "${TEST_FUNCTION} ${TEST_ARGS}"
    fi
    log_debug "RETURN_STATUS=${RETURN_STATUS}"
  fi
  log_debug "TEST_CASE_IDX=${TEST_CASE_IDX_PADDED} TEST_CASE=${TEST_CASE} RETURN_STATUS=${RETURN_STATUS} ERROR_COUNT=${ERROR_COUNT}"
  return "${RETURN_STATUS}"

}

function print_test_cases() {

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
  local ERROR_COUNT=0
#  local TEST_CASES=$@
  local TEST_CASES=("$@")
  local RETURN_STATUS=0

  log_info "TEST_CASES[*]=${TEST_CASES[*]}"
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
      TEST_CASE_ARGS=${TEST_CASE_ARRAY[@]:1}
      log_debug "TEST_CASE_ARGS=${TEST_CASE_ARGS[@]}"
    fi

    run_test_case "${TEST_CASE_IDX_PADDED}" "${TEST_CASE}" "${TEST_CASES_STR}" "${TEST_CASE_ARGS[@]}"
    RETURN_STATUS=$?
    ERROR_COUNT=$((${ERROR_COUNT} + ${RETURN_STATUS}))
    log_debug "TEST_CASE_IDX=${TEST_CASE_IDX_PADDED} TEST_CASE=${TEST_CASE} RETURN_STATUS=${RETURN_STATUS} ERROR_COUNT=${ERROR_COUNT}"

  done

  log_info "ERROR_COUNT=${ERROR_COUNT}"
  return ${ERROR_COUNT}
}

function install_jq() {
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


function install_yq() {
  local OS="${1}"
  local VERSION="v4.40.5"
  local BINARY="yq_linux_amd64"

  log_info "Installing yq (golang) (https://github.com/mikefarah/yq#install)"

  if [[ -n "${INSTALL_ON_LINUX-}" ]]; then

    TMPDIR="$(mktemp -d --suffix .yq-go XXXX -p /tmp)"
    trap cleanup_tmpdir INT TERM EXIT

#    INSTALL_DIR="/usr/local/bin"
    INSTALL_DIR="${HOME}/bin"
    mkdir -p "${INSTALL_DIR}"

    log_info "Installing yq for linux"
    ## ref: https://unix.stackexchange.com/questions/85194/how-to-download-an-archive-and-extract-it-without-saving-the-archive-to-disk
    curl -s -L "https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz" |\
      tar xzf - -C "${TMPDIR}" && mv "${TMPDIR}/${BINARY}" "${INSTALL_DIR}/yq"
  fi
  if [[ -n "${INSTALL_ON_MACOS-}" ]]; then
    log_info "Installing jq for MacOS"
    brew install yq
  fi
  if [[ -n "${INSTALL_ON_MSYS-}" ]]; then
    log_info "Installing jq for MSYS2"

    ## ref: https://github.com/mikefarah/yq#arch-linux
    #pacman --noconfirm -S go-yq

    ## ref: https://stackoverflow.com/questions/37198369/use-go-lang-with-msys2
    pacman --noconfirm -S mingw-w64-x86_64-go && \
    export GOROOT=/mingw64/lib/go && \
    export GOPATH=/mingw64 && \
    go install github.com/mikefarah/yq/v4@latest

    # go install github.com/mikefarah/yq/v4@latest
  fi
}


function ensure_python_modules() {
  PIP_COMMAND="pip install -r ${PROJECT_DIR}/requirements.txt"
  log_debug "${PIP_COMMAND}"
  eval "${PIP_COMMAND} >/dev/null 2>&1"
  log_debug "pip install complete"
}


function ensure_tool() {
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
  echo "       -p : run pytest"
  echo "       -r [PYTEST_JUNIT_REPORT] : use specified junitxml path for pytest report"
  echo "       -v : show script version"
  echo "       -k : keep temp directory/files"
  echo "       -h : help"
  echo "     [TEST_CASES]"
  echo ""
  echo "  Examples:"
	echo "       ${SCRIPT_NAME} "
	echo "       ${SCRIPT_NAME} -l"
	echo "       ${SCRIPT_NAME} 01"
	echo "       ${SCRIPT_NAME} validate_file_extensions"
	echo "       ${SCRIPT_NAME} -k -L DEBUG validate_yml_sortorder"
	echo "       ${SCRIPT_NAME} 01 03"
	echo "       ${SCRIPT_NAME} -L DEBUG 02 04"
	echo "       ${SCRIPT_NAME} -p"
	echo "       ${SCRIPT_NAME} -p 01 02"
	echo "       ${SCRIPT_NAME} -r .test-results/junit-report.xml"
  echo "       ${SCRIPT_NAME} -v"
	[ -z "$1" ] || exit "$1"
}


function main() {

  while getopts "L:r:dlpvhk" opt; do
      case "${opt}" in
          L) set_log_level "${OPTARG}" ;;
          l) print_test_cases && exit ;;
          r) PYTEST_JUNIT_REPORT="${OPTARG}" ;;
          d) DISPLAY_TEST_RESULTS=1 ;;
          k) KEEP_TMP=1 ;;
          p) RUN_PYTEST=1 ;;
          v) echo "${VERSION}" && exit ;;
          h) usage 1 ;;
          \?) usage 2 ;;
          *) usage ;;
      esac
  done
  shift $((OPTIND-1))

  if [[ -n "${PYTEST_JUNIT_REPORT-}" ]]; then
    PYTEST_JUNIT_REPORT="${PYTEST_JUNIT_REPORT_DEFAULT}"
  fi

  ## ref: https://pypi.org/project/yq/
  log_debug "Ensure jq present/installed (required for yq sort-keys)"
  ensure_tool jq

  ## ref: https://github.com/mikefarah/yq#install
  log_debug "Ensure yq present/installed (required for yq sort-keys)"
  ensure_tool yq

  if [ $ENSURE_PYTHON_MODULES -eq 1 ]; then
    log_debug "Ensure python modules present/installed"
    ensure_python_modules
  fi

  check_required_commands ansible-inventory yamllint jq yq

  TEST_CASES=("ALL")
  if [ $# -gt 0 ]; then
    TEST_CASES=("$@")
  fi

  #log_info "SCRIPT_DIR=${SCRIPT_DIR}"
  log_info "PROJECT_DIR=${PROJECT_DIR}"
  log_info "TEST_CASES=${TEST_CASES[*]}"

  if [ $RUN_PYTEST -eq 1 ]; then
    check_required_commands pytest
    run_pytests "${PYTEST_JUNIT_REPORT}" "${INVENTORY_DIR}" "${TEST_CASES[@]}"
    exit $?
  fi

  cd "${INVENTORY_DIR}"

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
