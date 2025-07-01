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

ENVS="
PROD
QA
DEV
"

INVENTORY_YML_LIST=("hosts.yml")
INVENTORY_YML_LIST+=("xenv_hosts.yml")
INVENTORY_YML_LIST+=("xenv_groups.yml")

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

## ref: https://unix.stackexchange.com/questions/573047/how-to-get-the-relative-path-between-two-directories
function pnrelpath() {
  ## get the relative path between two directories
  set -- "${1%/}/" "${2%/}/" ''               ## '/'-end to avoid mismatch
  while [ "$1" ] && [ "$2" = "${2#"$1"}" ]    ## reduce $1 to shared path
  do  set -- "${1%/?*/}/"  "$2" "../$3"       ## source/.. target ../relpath
  done
  REPLY="${3}${2#"$1"}"                       ## build result
  # unless root chomp trailing '/', replace '' with '.'
  [ "${REPLY#/}" ] && REPLY="${REPLY%/}" || REPLY="${REPLY:-.}"
  echo "${REPLY}"
}

## For `SPECIAL_LINKS` use the following format to specify any special links
## [linkName]:[linkSource]
##
## NOTE:
## The `create_host_links_yml` function will automatically create links for any hosts files with pattern `*.yml`
## at the inventory top/root level directory across all environments specified in the `ENVS` var.
##
## Since the filename pattern is `*.yml` at the top level, the `xenv_infra_hosts.yml` hosts file will
## setup by `create_host_links_yml` function
##
## Use `SPECIAL_LINKS` for links that are specified in other/non-root locations/subdirs
## and to be shared across a subset of inventory directories and not all.
##
## E.g., assuming there was a sub-directory `NONPROD` with `NONPROD/nonprod_xenv_hosts.yml`
## then use `create_special_links` to setup those links as follows
##
#SPECIAL_LINKS="
#SANDBOX/nonprod_xenv_hosts.yml:../NONPROD/xenv_infra_hosts.yml
#DEV/nonprod_xenv_hosts.yml:../NONPROD/xenv_infra_hosts.yml
#QA/nonprod_xenv_hosts.yml:../NONPROD/xenv_infra_hosts.yml
#"

##############################
## The `create_host_links_yml` function will automatically create links for any hosts files with pattern `*.yml`
## at the inventory top/root level directory across all environments specified in the `ENVS` var.
##
## Since the filename pattern is `*.yml` at the top level, the `xenv_infra_hosts.yml` hosts file will
## setup by `create_host_links_yml` function
function create_host_links_yml() {
  local INVENTORY_DIR=$1
  local ENVS=$2

  BASE_DIRECTORY="${INVENTORY_DIR}"
  log_debug "BASE_DIRECTORY=${BASE_DIRECTORY}"

  ##
  ## for each PATH iteration create a soft link back to all files found in the respective base directory (Sandbox/Prod)
  ##
  IFS=$'\n'
  for ENVIRONMENT in ${ENVS}
  do
    log_debug "############### ENVIRONMENT=${ENVIRONMENT} ########################################"
    log_debug "Create host (*.yml) symlinks for files in ENVIRONMENT [$ENVIRONMENT]"

    ENV_DIR="${INVENTORY_DIR}/${ENVIRONMENT}"
    log_debug "ENV_DIR=${ENV_DIR}"
    log_debug "cd ${ENV_DIR}"
    cd "${ENV_DIR}"/

    log_debug "get the relative path between $PWD and $BASE_DIRECTORY directories"
    RELPATH=$(pnrelpath "$PWD" "$BASE_DIRECTORY")
    log_debug "RELPATH=${RELPATH}"

    log_debug "Remove all existing host links in ${ENV_DIR}"
    if [[ $LOG_LEVEL -gt $LOG_TRACE ]]; then
#      find . -maxdepth 1 -type l -print -exec rm {} \;
      find . -maxdepth 1 -type l -delete
    else
      find . -maxdepth 1 -type l -delete > /dev/null 2>&1
    fi

    log_debug "ln -sf ${RELPATH}/*.yml ./"
    ln -sf "${RELPATH}"/*.yml ./

  done

  return 0
}

function create_groupvars_links_yml() {
  local INVENTORY_DIR=$1
  local ENVS=$2

  BASE_DIRECTORY="${INVENTORY_DIR}"
  log_debug "BASE_DIRECTORY=${BASE_DIRECTORY}"
  log_debug "ENVS=${ENVS}"

  ##
  ## for each PATH iteration create a soft link back to all files found in the respective base directory (Sandbox/Prod)
  ##
  IFS=$'\n'
  for ENVIRONMENT in ${ENVS}
  do
    log_debug "############### ENVIRONMENT=${ENVIRONMENT} ########################################"
    log_debug "Create group_vars/*.yml symlinks for files in ENVIRONMENT [$ENVIRONMENT]"

    ENV_DIR="${INVENTORY_DIR}/${ENVIRONMENT}"
    log_debug "ENV_DIR=${ENV_DIR}"
    log_debug "cd ${ENV_DIR}"
    cd ${ENV_DIR}/

    mkdir -p group_vars
    cd group_vars

    log_debug "get relative path between $PWD and $BASE_DIRECTORY dirs"
    RELPATH=$(pnrelpath "$PWD" "$BASE_DIRECTORY")
    log_debug "RELPATH=${RELPATH}"

    log_debug "Remove all existing group_var links in ${ENV_DIR}"
    if [[ $LOG_LEVEL -gt $LOG_TRACE ]]; then
#      find . -type l -print -exec rm {} \;
      find . -type l -print -delete
    else
      find . -type l -print -delete > /dev/null 2>&1
    fi

    log_debug "ln -sf ${RELPATH}/group_vars/*.yml ./"
    ln -sf ${RELPATH}/group_vars/*.yml ./

    ## ref: https://stackoverflow.com/questions/4210042/how-do-i-exclude-a-directory-when-using-find#15736463
    log_debug "find sub directories in groups_vars excluding 'all'"
    GROUPVAR_SUBDIRS=$(find ${RELPATH}/group_vars/* -maxdepth 0 -type d -not \( -name all -prune \))
    log_debug "GROUPVAR_SUBDIRS=${GROUPVAR_SUBDIRS}"

    for SUB_DIR in ${GROUPVAR_SUBDIRS}; do
      log_debug "ln -sf ${SUB_DIR} ./"
      ln -sf "${SUB_DIR}" ./
    done

#    rm -f all.yml
    log_debug "Create ${PWD}/all dir if does not exist"
    mkdir -p all

    cd all
    RELPATH=$(pnrelpath "$PWD" "$BASE_DIRECTORY")
    log_debug "group_vars/all/ => RELPATH=${RELPATH}"

    log_debug "Remove all existing group_var links in ${ENV_DIR}/group_vars/all/"
    if [[ $LOG_LEVEL -gt $LOG_TRACE ]]; then
#      find . -type l -print -exec rm {} \;
      find . -type l -delete
    else
      find . -type l -delete > /dev/null 2>&1
    fi

    log_debug "ln -sf ${RELPATH}/group_vars/all/*.yml ./"
    ln -sf ${RELPATH}/group_vars/all/*.yml ./

## NOTES:
##   regarding the filename changed from `000_cross_env_vars.yml` to `all.yml`:
##
##   This means with this change that the filename is:
##   a) simpler to implement in the sync - the logic is simpler in that is just links all of whatever exists in the parent `groups_vars/all/*.yml`.
##   b) simpler to follow each link to the respective source file in the parent `group_vars/all/*.yml` and
##   c) simpler to understand what is happening overall
##
## That said, the rename/move each `${CHILD_INV}/group_vars/all/all.yml` to `${CHILD_INV}/group_vars/all/000_cross_env_vars.yml` is easy to do.
## Not sure I like it much though 😐.
##
## The real reason the initial name `000_cross_env_vars.yml` was used was residue from observing the initial example from
## the [source article at digitalocean here](https://www.digitalocean.com/community/tutorials/how-to-manage-multistage-environments-with-ansible).
##
## As such, I did not feel the need to continue to keep to this specific naming convention going forward since:
##
## 1. the name `${CHILD_INV}/group_vars/all/all.yml -> ../../group_vars/all/all.yml` should be more consistent to the actual parent file name.
## 2. now as we evolve towards having multiple parent `group_vars/all/*.yml` files, it becomes less relevant to have a specific _special name_ for a single `all.yml` file.
## 3. and if anything, leading to confusion as to why that specific file has a different name as opposed to the remaining parent `group_vars/all/*.yml` var files which are all global.
##
##
## LIMITATIONS FOUND DURING TESTING:
##
## Ideally, the `env-specific.yml` should always trump/overwrite the other global variable files with a lower ASCII-order name for any specific settings.
##
## > When you put multiple inventory sources in a directory, Ansible merges them in ASCII order according to the filenames
## > source: https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#managing-inventory-variable-load-order
##
## This was the consideration in the naming convention/approach used in [this article at digitalocean](https://www.digitalocean.com/community/tutorials/how-to-manage-multistage-ENVIRONMENTs-with-ansible).
##
## However, during testing it was found that the current ansible version does not appear to support merging variable files in `group_vars/all/*.yml` in ASCII order according to the filenames.
##
## For example, when testing when a variable appears in 1 or more of the global `group_var/all/000_*.yml` files and also appears in the `group_vars/env-specific.yml`, with a test_variable (named `trace_global_var` below), it is found that it does not work as expected.
##
## E.g.,
## SANDBOX/group_vars/all/000_cross_env.yml:
## ```yaml
## trace_global_var: i-am-set-by-all
## ```
##
## SANDBOX/group_vars/all/env-specific.yml:
## ```yaml
## trace_global_var: i-am-set-by-SANDBOX
## ```
##
## ```shell
## $ ansible -i SANDBOX/ -m debug -a var=trace_global_var localhost
## localhost | SUCCESS => {
##     "trace_global_var": "i-am-set-by-all"
## }
## ```
##
## The implied constraint here is for any global variables that are expected to be set at the child inventory level that they must only be set in the CHILD inventory `env-specific.yml` and not at the parent inventory `group_vars/all.yml` level; otherwise, the correct variable value will not prevail in the way expected.
##
## The additional implied is that ASCII-ordered variable file naming does not work/matter in this `group_vars/all/*.yml` use case.
##
#    ln -sf ${RELPATH}/group_vars/all.yml ./000_cross_env_vars.yml
#    mv ./all.yml ./000_cross_env_vars.yml
    touch ./env_specific.yml

  done

  return 0
}

function create_hostvars_links_yml() {
  local INVENTORY_DIR=$1
  local ENVS=$2

  BASE_DIRECTORY="${INVENTORY_DIR}"
  log_debug "BASE_DIRECTORY=${BASE_DIRECTORY}"

  ##
  ## for each PATH iteration create a soft link back to all files found in the respective base directory (Sandbox/Prod)
  ##
  IFS=$'\n'
  for ENVIRONMENT in ${ENVS}
  do
    log_debug "############### ENVIRONMENT=${ENVIRONMENT} ########################################"
    log_debug "Create host_vars symlinks for files in ENVIRONMENT [$ENVIRONMENT]"

    ENV_DIR="${INVENTORY_DIR}/${ENVIRONMENT}"
    log_debug "ENV_DIR=${ENV_DIR}"
    log_debug "cd ${ENV_DIR}"
    cd ${ENV_DIR}/

    log_debug "get the relative path between $PWD and $BASE_DIRECTORY directories"
    RELPATH=$(pnrelpath "$PWD" "$BASE_DIRECTORY")
    log_debug "RELPATH=${RELPATH}"

    log_debug "ln -sf ${RELPATH}/host_vars ./"
    ln -sf ${RELPATH}/host_vars ./

  done

  return 0
}

######################
## The `create_special_links` function will automatically create links
## for `SPECIAL_LINKS` specified in other/non-root locations/subdirs.
##
## This is particularly useful for links shared across a subset of inventory directories and not all
## as well as maintaining any env-specific links if there is a need to do so.
##
## E.g., assuming there was a sub-directory `NONPROD` with `NONPROD/nonprod_xenv_hosts.yml`
## then use `create_special_links` to setup those links as follows
##
##SPECIAL_LINKS="
##SANDBOX/nonprod_xenv_hosts.yml:../NONPROD/xenv_infra_hosts.yml
##DEV/nonprod_xenv_hosts.yml:../NONPROD/xenv_infra_hosts.yml
##QA/nonprod_xenv_hosts.yml:../NONPROD/xenv_infra_hosts.yml
##"
function create_special_links() {
  local INVENTORY_DIR=$1
  local SPECIAL_LINKS=$2
  BASE_DIRECTORY="${INVENTORY_DIR}/${ENV_BASE}"

  log_info "############### BASE_DIRECTORY=${BASE_DIRECTORY} ########################################"

  ##
  ## for each PATH iteration create a soft link back to all files found in the respective base directory (Sandbox/Prod)
  ##
  IFS=$'\n'
  for special_link in ${SPECIAL_LINKS}
  do

    log_info "###############"
    log_info "Create SPECIAL_LINKS symlinks for special_link [$special_link]"
    # split sub-list if available
    if [[ $special_link == *":"* ]]
    then
      # ref: https://stackoverflow.com/questions/12317483/array-of-arrays-in-bash
      # split server name from sub-list
#      linkInfoArray=(${special_link//:/})
      IFS=":" read -a linkInfoArray <<< $special_link
      link=${linkInfoArray[0]}
      linkSource=${linkInfoArray[1]}

      log_debug "link=[$link]"
      log_debug "linkSource=[$linkSource]"

      linkName=$(basename "${link}")
      ENVIRONMENT=$(dirname "${link}")

      log_debug "linkName=[$linkName]"
      log_debug "ENVIRONMENT=[$ENVIRONMENT]"

      ENV_DIR="${INVENTORY_DIR}/${ENVIRONMENT}"
      log_debug "ENV_DIR=${ENV_DIR}"
      log_debug "cd ${ENV_DIR}"
      cd "${ENV_DIR}"/

      log_debug "Remove existing link in ${ENV_DIR}"
      if [[ $LOG_LEVEL -gt $LOG_TRACE ]]; then
#        find . -maxdepth 1 -name "${linkName}" -type l -print -exec rm {} \;
        find . -maxdepth 1 -name "${linkName}" -type l -delete
      else
        find . -maxdepth 1 -name "${linkName}" -type l -delete > /dev/null 2>&1
      fi

      log_debug "ln -sf ${linkSource} ${linkName}"
      ln -sf "${linkSource}" "${linkName}"
    fi

  done

  return 0
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

    ## install sync tool bin dir at ${HOME}/bin (yq)
    INSTALL_DIR="${HOME}/bin"
    if [[ "$UNAME" != "cygwin" && "$UNAME" != "msys" ]]; then
      if [ "$EUID" -eq 0 ]; then
        ## if running as root install in /usr/local/bin
        INSTALL_DIR="/usr/local/bin"
      fi
    fi

    mkdir -p "${INSTALL_DIR}"
    export PATH="${INSTALL_DIR}:${PATH}"

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

function ensure_tool() {
  if [[ $# -ne 1 ]]
  then
    return 1
  fi

  local executable="${1}"
  local install_function="install_${executable}"

  if [[ -z "$(command -v "${executable}")" ]]; then
    # First check OS.
    OS=$(uname -s | tr "[:upper:]" "[:lower:]")

    case "${OS}" in
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

    eval "${install_function} ${OS}"
  fi
}

function ensure_pip_tool() {
  if [[ $# -ne 1 ]]
  then
    return 1
  fi

  local executable="${1}"

  if [[ -z "$(command -v "${executable}")" ]] || pip show "${executable}" | grep -q -i version; then
    pip install "${executable}"
  fi
}

function sort_xenv_files() {
  local INVENTORY_YML_LIST=("$@")

  ## ref: https://pypi.org/project/yq/
  log_debug "Ensure jq present/installed (required for yq sort-keys)"
  ensure_tool jq

  ## ref: https://github.com/mikefarah/yq#install
  log_debug "Ensure yq present/installed (required for yq sort-keys)"
  ensure_tool yq

  log_debug "INVENTORY_YML_LIST=${INVENTORY_YML_LIST[*]}"

  local DELIM=' -o '
  ## ref: https://superuser.com/questions/1371834/escaping-hyphens-with-printf-in-bash
  #'-name' ==> '\055name'
  printf -v FIND_FILE_ARGS "\055name %s${DELIM}" "${INVENTORY_YML_LIST[@]}"
  FIND_FILE_ARGS=${FIND_FILE_ARGS%$DELIM}

  log_debug "FIND_FILE_ARGS=${FIND_FILE_ARGS}"

  FIND_CMD="find . -type f \( ${FIND_FILE_ARGS} \) -printf '%P\n' | sort"
  log_debug "${FIND_CMD}"

  INVENTORY_YML_FILES_FOUND=$(eval "${FIND_CMD}")
  log_debug "INVENTORY_YML_FILES_FOUND=${INVENTORY_YML_FILES_FOUND}"

  for INVENTORY_FILE in ${INVENTORY_YML_FILES_FOUND}
  do
    ## ref: https://mikefarah.gitbook.io/yq/operators/sort-keys
    SORT_CMD="yq -i -P 'sort_keys(..)' ${INVENTORY_FILE}"
    execute_eval_command "${SORT_CMD}"
#    log_debug "${SORT_CMD}"
#    eval "${SORT_CMD}"
##    yq -i -P 'sort_keys(..)' "${INVENTORY_FILE}"
  done

  return 0
}

function run_sync_function() {
  local SYNC_FUNCTION_STR=$1
  local SYNC_FUNCTION=$2
  local SYNC_ARGS=()
  shift 2
  local ERROR_COUNT=0

  if [ $# -gt 0 ]; then
#    SYNC_ARGS=(${@})
    SYNC_ARGS=("$@")
  fi
  local LOG_PREFIX="==> run_sync_function(${SYNC_FUNCTION}):"

  if stringContain "${SYNC_FUNCTION}" "${SYNC_FUNCTION_STR}" || [ "${SYNC_FUNCTION_STR}" == "all" ]; then
#    log_debug "${LOG_PREFIX} SYNC_FUNCTION=${SYNC_FUNCTION}"
#    log_debug "${LOG_PREFIX} SYNC_ARGS=${SYNC_ARGS}"

#    ${SYNC_FUNCTION} "${SYNC_ARGS[@]}"
    sync_results=$(${SYNC_FUNCTION} "${SYNC_ARGS[@]}")
    returnStatus=$?

    log_debug "${LOG_PREFIX} returnStatus=${returnStatus}"
    ERROR_COUNT=$((${ERROR_COUNT} + ${returnStatus}))

    if [[ $returnStatus -eq 0 ]]; then
      log_info "${LOG_PREFIX} SUCCESS"
    else
      log_error "${LOG_PREFIX} FAILED"
    fi
    if [[ $returnStatus -ne 0 || $ALWAYS_SHOW_SYNC_RESULTS -gt 0 || $LOG_LEVEL -ge $LOG_TRACE ]]; then
      log_info "${LOG_PREFIX} sync_results ****"
      echo "${sync_results}"
    fi
  fi

}

function usage() {
  echo "Usage: ${SCRIPT_NAME} [options] [[SYNC_FUNCTION_NAME] [SYNC_FUNCTION_NAME]...]"
  echo ""
  echo "  Options:"
  echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG] : run with specified log level (default: '${LOGLEVEL_TO_STR[${LOG_LEVEL}]}')"
  echo "       -v : show script version"
  echo "       -h : help"
  echo "     [SYNC_FUNCTION_NAME]"
  echo "        choices for SYNC_FUNCTION_NAME:"
  echo "        - create_host_links_yml"
  echo "        - create_groupvars_links_yml"
  echo "        - create_hostvars_links_yml"
  echo "        - create_special_links"
  echo "        - sort_xenv_files"
  echo ""
  echo "  Examples:"
	echo "       ${SCRIPT_NAME} "
	echo "       ${SCRIPT_NAME} create_host_links_yml"
	echo "       ${SCRIPT_NAME} create_host_links_yml create_hostvars_links_yml"
	echo "       ${SCRIPT_NAME} sort_xenv_files"
	echo "       ${SCRIPT_NAME} -L DEBUG sort_xenv_files"
  echo "       ${SCRIPT_NAME} -v"
	[ -z "$1" ] || exit "$1"
}

function main() {

  log_info "==> PROJECT_DIR=${PROJECT_DIR}"
  log_info "==> INVENTORY_DIR=${INVENTORY_DIR}"

  while getopts "L:pvh" opt; do
      case "${opt}" in
          L) set_log_level "${OPTARG}" ;;
          v) echo "${VERSION}" && exit ;;
          h) usage 1 ;;
          \?) usage 2 ;;
          *) usage ;;
      esac
  done
  shift $((OPTIND-1))

  SYNC_FUNCTIONS=("all")
  if [ $# -gt 0 ]; then
    SYNC_FUNCTIONS=("$@")
  fi
  log_info "==> SYNC_FUNCTIONS[@]=${SYNC_FUNCTIONS[@]}"

  SYNC_FUNCTIONS_STR="${SYNC_FUNCTIONS[@]}"

  cd "${INVENTORY_DIR}"

  run_sync_function "${SYNC_FUNCTIONS_STR}" create_host_links_yml "${INVENTORY_DIR}" "${ENVS}"
  run_sync_function "${SYNC_FUNCTIONS_STR}" create_groupvars_links_yml "${INVENTORY_DIR}" "${ENVS}"
  run_sync_function "${SYNC_FUNCTIONS_STR}" create_hostvars_links_yml "${INVENTORY_DIR}" "${ENVS}"
  if [[ -n "${SPECIAL_LINKS}" ]]; then
    run_sync_function "${SYNC_FUNCTIONS_STR}" create_special_links "${INVENTORY_DIR}" "${SPECIAL_LINKS}"
  fi
  if [[ -n "${INVENTORY_YML_LIST}" ]]; then
    run_sync_function "${SYNC_FUNCTIONS_STR}" sort_xenv_files "${INVENTORY_YML_LIST[@]}"
  fi
}

main "$@"
