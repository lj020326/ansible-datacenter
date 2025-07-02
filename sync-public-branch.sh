#!/usr/bin/env bash

## ref: https://intoli.com/blog/exit-on-errors-in-bash-scripts/
# exit when any command fails
set -e

VERSION="2025.7.1"

#SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(dirname "$0")"
SCRIPT_NAME="$(basename "$0")"

GIT_DEFAULT_BRANCH=main
GIT_PUBLIC_BRANCH=public

## https://www.pixelstech.net/article/1577768087-Create-temp-file-in-Bash-using-mktemp-and-trap
TEMP_DIR=$(mktemp -d -p ~)

trap 'rm -fr "$TEMP_DIR"' EXIT

GIT_REMOVE_CACHED_FILES=0

CONFIRM=0

## PURPOSE RELATED VARS
#PROJECT_DIR=$( git rev-parse --show-toplevel )
PROJECT_DIR="$(cd "${SCRIPT_DIR}" && git rev-parse --show-toplevel)"

MIRROR_DIR_LIST="
.github
.jenkins
collections
docs
files
inventory
molecule
playbooks
plugins
roles
scripts
tests
vars
"

PUBLIC_GITIGNORE=files/git/pub.gitignore

## ref: https://stackoverflow.com/questions/53839253/how-can-i-convert-an-array-into-a-comma-separated-string
declare -a PRIVATE_CONTENT_ARRAY
PRIVATE_CONTENT_ARRAY+=('**/private/***')
PRIVATE_CONTENT_ARRAY+=('**/vault/***')
PRIVATE_CONTENT_ARRAY+=('**/archive/***')
PRIVATE_CONTENT_ARRAY+=('**/save/***')
PRIVATE_CONTENT_ARRAY+=('**/vault.yml')
PRIVATE_CONTENT_ARRAY+=('**/*vault.yml')
PRIVATE_CONTENT_ARRAY+=('**/secrets.yml')
PRIVATE_CONTENT_ARRAY+=('**/*secrets.yml')
PRIVATE_CONTENT_ARRAY+=('.vault_pass')
#PRIVATE_CONTENT_ARRAY+=('***/*vault*')
PRIVATE_CONTENT_ARRAY+=('***/vault.yml')
PRIVATE_CONTENT_ARRAY+=('**/integration_config.yml')
PRIVATE_CONTENT_ARRAY+=('**/integration_config.vault.yml')
PRIVATE_CONTENT_ARRAY+=('*.log')

printf -v PRIVATE_CONTENT_LIST '%s,' "${PRIVATE_CONTENT_ARRAY[@]}"
PRIVATE_CONTENT_LIST="${PRIVATE_CONTENT_LIST%,}"

## ref: https://stackoverflow.com/questions/53839253/how-can-i-convert-an-array-into-a-comma-separated-string
declare -a EXCLUDES_ARRAY
EXCLUDES_ARRAY+=('.git')
EXCLUDES_ARRAY+=('.gitmodule')
EXCLUDES_ARRAY+=('.idea')
EXCLUDES_ARRAY+=('.vscode')
EXCLUDES_ARRAY+=('venv')
EXCLUDES_ARRAY+=('.DS_Store')

printf -v EXCLUDES_LIST '%s,' "${EXCLUDES_ARRAY[@]}"
EXCLUDES_LIST="${EXCLUDES_LIST%,}"

## https://serverfault.com/questions/219013/showing-total-progress-in-rsync-is-it-possible
## https://www.studytonight.com/linux-guide/how-to-exclude-files-and-directory-using-rsync
RSYNC_OPTS_GIT_MIRROR=()
RSYNC_OPTS_GIT_MIRROR+=("-dar")
RSYNC_OPTS_GIT_MIRROR+=("--links")
RSYNC_OPTS_GIT_MIRROR+=("--delete-excluded")
RSYNC_OPTS_GIT_MIRROR+=("--exclude={${EXCLUDES_LIST},${PRIVATE_CONTENT_LIST}}")

RSYNC_OPTS_GIT_UPDATE=()
RSYNC_OPTS_GIT_UPDATE+=("-ari")
RSYNC_OPTS_GIT_UPDATE+=("--links")

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
    REVERSED_ARRAY_REF["$VALUE"]="$KEY"
  done
}

declare -A LOGLEVELSTR_TO_LEVEL
reverse_array LOGLEVEL_TO_STR LOGLEVELSTR_TO_LEVEL

#LOG_LEVEL=${LOG_DEBUG}
LOG_LEVEL=${LOG_INFO}

function log_error() {
  if [ "$LOG_LEVEL" -ge "$LOG_ERROR" ]; then
  	log_message "${LOG_ERROR}" "${1}"
  fi
}

function log_warn() {
  if [ "$LOG_LEVEL" -ge "$LOG_WARN" ]; then
  	log_message "${LOG_WARN}" "${1}"
  fi
}

function log_info() {
  if [ "$LOG_LEVEL" -ge "$LOG_INFO" ]; then
  	log_message "${LOG_INFO}" "${1}"
  fi
}

function log_trace() {
  if [ "$LOG_LEVEL" -ge "$LOG_TRACE" ]; then
  	log_message "${LOG_TRACE}" "${1}"
  fi
}

function log_debug() {
  if [ "$LOG_LEVEL" -ge "$LOG_DEBUG" ]; then
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
  MISSING_COMMANDS=""
  for CURRENT_COMMAND in "$@"
  do
    is_installed "${CURRENT_COMMAND}" || MISSING_COMMANDS="${MISSING_COMMANDS} ${CURRENT_COMMAND}"
  done

  if [[ -n "${MISSING_COMMANDS}" ]]; then
    fail "Please install the following commands required by this script: ${MISSING_COMMANDS}"
  fi
}

function git_commit_push() {
  local LOCAL_BRANCH
  local REMOTE_AND_BRANCH
  LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" && \
  REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref "${LOCAL_BRANCH}@{upstream}") && \
  IFS=/ read -r REMOTE REMOTE_BRANCH <<< "${REMOTE_AND_BRANCH}" && \
  echo "Staging changes:" && \
  (git add -A || true) && \
  echo "Committing changes:" && \
  (git commit -am "group updates to public branch" || true) && \
  echo "Pushing branch '${LOCAL_BRANCH}' to remote '${REMOTE}' branch '${REMOTE_BRANCH}':" && \
  (git push -f -u "${REMOTE}" "${LOCAL_BRANCH}:${REMOTE_BRANCH}" || true)
}

function search_repo_keywords () {

  #export -p | sed 's/declare -x //' | sed 's/export //'
  if [ -z ${REPO_EXCLUDE_KEYWORDS+x} ]; then
    abort "REPO_EXCLUDE_KEYWORDS not set/defined"
  fi

  log_debug "REPO_EXCLUDE_KEYWORDS=${REPO_EXCLUDE_KEYWORDS}"

  IFS=',' read -ra REPO_EXCLUDE_KEYWORDS_ARRAY <<< "$REPO_EXCLUDE_KEYWORDS"

  log_debug "REPO_EXCLUDE_KEYWORDS_ARRAY=${REPO_EXCLUDE_KEYWORDS_ARRAY[*]}"

  # ref: https://superuser.com/questions/1371834/escaping-hyphens-with-printf-in-bash
  #'-e' ==> '\055e'
  local GREP_DELIM=' \055e '
  printf -v GREP_PATTERN_SEARCH "${GREP_DELIM}%s" "${REPO_EXCLUDE_KEYWORDS_ARRAY[@]}"

  ## strip prefix
  local GREP_PATTERN_SEARCH=${GREP_PATTERN_SEARCH#"$GREP_DELIM"}
  ## strip suffix
  #local GREP_PATTERN_SEARCH=${GREP_PATTERN_SEARCH%"$GREP_DELIM"}

  log_debug "GREP_PATTERN_SEARCH=${GREP_PATTERN_SEARCH}"

  local GREP_COMMAND="grep ${GREP_PATTERN_SEARCH}"
  log_debug "GREP_COMMAND=${GREP_COMMAND}"

  local FIND_DELIM=' -o '
#  printf -v FIND_EXCLUDE_DIRS "\055path '*/%s/*' -prune${FIND_DELIM}" "${EXCLUDES_ARRAY[@]}"
  printf -v FIND_EXCLUDE_DIRS "! -path '*/%s/*'${FIND_DELIM}" "${EXCLUDES_ARRAY[@]}"
  local FIND_EXCLUDE_DIRS=${FIND_EXCLUDE_DIRS%"$FIND_DELIM"}

  log_debug "FIND_EXCLUDE_DIRS=${FIND_EXCLUDE_DIRS}"

  ## this works:
  ## find . \( -path '*/.git/*' \) -prune -name '.*' -o -exec grep -i example {} 2>/dev/null +
  ## find . \( -path '*/save/*' -prune -o -path '*/.git/*' -prune \) -o -exec grep -i example {} 2>/dev/null +
  ## find . \( ! -path '*/save/*' -o ! -path '*/.git/*' \) -o -exec grep -i example {} 2>/dev/null +
  ## ref: https://stackoverflow.com/questions/6565471/how-can-i-exclude-directories-from-grep-r#8692318
  ## ref: https://unix.stackexchange.com/questions/342008/find-and-echo-file-names-only-with-pattern-found
  ## ref: https://www.baeldung.com/linux/find-exclude-paths
  local FIND_CMD="find ${PROJECT_DIR}/ \( ${FIND_EXCLUDE_DIRS} \) -o -exec ${GREP_COMMAND} {} 2>/dev/null +"
  log_info "${FIND_CMD}"

  local EXCEPTION_COUNT
  EXCEPTION_COUNT=$(eval "${FIND_CMD} | wc -l")
  if [[ $EXCEPTION_COUNT -eq 0 ]]; then
    log_info "SUCCESS => No exclusion keyword matches found!!"
  else
    log_error "There are [${EXCEPTION_COUNT}] exclusion keyword matches found:"
    eval "${FIND_CMD}"
    exit 1
  fi
  return "${EXCEPTION_COUNT}"
}

function sync_public_branch() {
  local RSYNC_MIRROR_OPTS="${RSYNC_OPTS_GIT_MIRROR[*]}"
  local RSYNC_UPDATE_OPTS="${RSYNC_OPTS_GIT_UPDATE[*]}"

  log_debug "RSYNC_MIRROR_OPTS=${RSYNC_MIRROR_OPTS}"
  log_debug "RSYNC_UPDATE_OPTS=${RSYNC_UPDATE_OPTS}"

  git fetch --all
  git checkout ${GIT_DEFAULT_BRANCH}
  
  #RSYNC_OPTS=${RSYNC_OPTS_GIT_MIRROR[@]}
  log_debug "copy project to temporary dir $TEMP_DIR"
  local RSYNC_CMD
  RSYNC_CMD="rsync ${RSYNC_MIRROR_OPTS} ${PROJECT_DIR}/ ${TEMP_DIR}/"
  execute_eval_command "${RSYNC_CMD}"
  
  log_info "Checkout public branch"
  git checkout ${GIT_PUBLIC_BRANCH}
  
  if [ $GIT_REMOVE_CACHED_FILES -eq 1 ]; then
    log_info "Removing files cached in git"
    git rm -r --cached .
  fi

  log_info "Copy ${TEMP_DIR} to project dir $PROJECT_DIR"
  RSYNC_CMD="rsync ${RSYNC_UPDATE_OPTS} ${TEMP_DIR}/ ${PROJECT_DIR}/"
  execute_eval_command "${RSYNC_CMD}"

  for TARGET_DIR in "${MIRROR_DIR_ARRAY[@]}"
  do
    log_info "Mirror ${TEMP_DIR}/${TARGET_DIR}/ to project dir ${PROJECT_DIR}/${TARGET_DIR}/"
    RSYNC_CMD="rsync ${RSYNC_MIRROR_OPTS} ${TEMP_DIR}/${TARGET_DIR}/ ${PROJECT_DIR}/${TARGET_DIR}/"
    execute_eval_command "${RSYNC_CMD}"
  done

  printf -v TO_REMOVE '%s ' "${PRIVATE_CONTENT_ARRAY[@]}"
  TO_REMOVE="${TO_REMOVE% }"
  log_info "TO_REMOVE=${TO_REMOVE}"
  CLEANUP_CMD="rm -fr ${TO_REMOVE}"
  execute_eval_command "${CLEANUP_CMD}"

  if [ -e $PUBLIC_GITIGNORE ]; then
    log_info "Update public files:"
    cp -p $PUBLIC_GITIGNORE .gitignore
  fi
  
  log_info "Show changes before push:"
  git status
  
  ## https://stackoverflow.com/questions/5989592/git-cannot-checkout-branch-error-pathspec-did-not-match-any-files-kn
  ## git diff --name-only ${GIT_PUBLIC_BRANCH} ${GIT_DEFAULT_BRANCH} --
  
  if [ $CONFIRM -eq 0 ]; then
    ## https://www.shellhacks.com/yes-no-bash-script-prompt-confirmation/
    read -p "Are you sure you want to merge the changes above to public branch ${TARGET_BRANCH}? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi
  fi
  
  ## https://stackoverflow.com/questions/5738797/how-can-i-push-a-local-git-branch-to-a-remote-with-a-different-name-easily
  log_info "Add all the files:"
  git_commit_push
  log_info "Checkout ${GIT_DEFAULT_BRANCH} branch:" && \
  git checkout ${GIT_DEFAULT_BRANCH}

  log_info "chmod project admin/maintenance scripts"
  chmod +x inventory/*.sh
  chmod +x *.sh

  log_info "creating links for useful project scripts"
  cd ${PROJECT_DIR}
  ln -sf ./inventory/*.sh ./
}


function usage() {
  echo "Usage: ${SCRIPT_NAME} [options]"
  echo ""
  echo "  Options:"
  echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG] : run with specified log level (default: '${LOGLEVEL_TO_STR[${LOG_LEVEL}]}')"
  echo "       -v : show script version"
  echo "       -h : help"
  echo "     [TEST_CASES]"
  echo ""
  echo "  Examples:"
	echo "       ${SCRIPT_NAME} "
	echo "       ${SCRIPT_NAME} -L DEBUG"
  echo "       ${SCRIPT_NAME} -v"
	[ -z "$1" ] || exit "$1"
}


function main() {

  check_required_commands rsync

  while getopts "L:vh" opt; do
      case "${opt}" in
          L) set_log_level "${OPTARG}" ;;
          v) echo "${VERSION}" && exit ;;
          h) usage 1 ;;
          \?) usage 2 ;;
          *) usage ;;
      esac
  done
  shift $((OPTIND-1))

  log_debug "PROJECT_DIR=${PROJECT_DIR}"
  log_debug "TEMP_DIR=${TEMP_DIR}"

  search_repo_keywords
  local RETURN_STATUS=$?
  if [[ $RETURN_STATUS -ne 0 ]]; then
    log_error "search_repo_keywords: FAILED"
    exit ${RETURN_STATUS}
  fi

  sync_public_branch

}

main "$@"
