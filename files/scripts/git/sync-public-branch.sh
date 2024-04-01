#!/usr/bin/env bash

GIT_DEFAULT_BRANCH=main
GIT_PUBLIC_BRANCH=public

## ref: https://intoli.com/blog/exit-on-errors-in-bash-scripts/
# exit when any command fails
set -e

## https://www.pixelstech.net/article/1577768087-Create-temp-file-in-Bash-using-mktemp-and-trap
TMP_DIR=$(mktemp -d -p ~)

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT
trap 'rm -fr "$TMP_DIR"' EXIT

GIT_REMOVE_CACHED_FILES=0

CONFIRM=0
#SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(dirname "$0")"

## PURPOSE RELATED VARS
#PROJECT_DIR=$( git rev-parse --show-toplevel )
PROJECT_DIR="$(cd "${SCRIPT_DIR}" && git rev-parse --show-toplevel)"
#PROJECT_DIR=$(git rev-parse --show-toplevel)

source "${PROJECT_DIR}/files/scripts/logger.sh"


MIRROR_DIR_LIST="
.github
.jenkins
collections
docs
files
filter_plugins
inventory
library
molecule
playbooks
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

printf -v EXCLUDE_AND_REMOVE '%s,' "${PRIVATE_CONTENT_ARRAY[@]}"
EXCLUDE_AND_REMOVE="${EXCLUDE_AND_REMOVE%,}"
logDebug "EXCLUDE_AND_REMOVE=${EXCLUDE_AND_REMOVE}"

## ref: https://stackoverflow.com/questions/53839253/how-can-i-convert-an-array-into-a-comma-separated-string
declare -a EXCLUDES_ARRAY
EXCLUDES_ARRAY=('.git')
EXCLUDES_ARRAY+=('.gitmodule')
EXCLUDES_ARRAY+=('.idea')
EXCLUDES_ARRAY+=('.vscode')
EXCLUDES_ARRAY+=('**/.DS_Store')
EXCLUDES_ARRAY+=('venv')
EXCLUDES_ARRAY+=('*.log')

printf -v EXCLUDES '%s,' "${EXCLUDES_ARRAY[@]}"
EXCLUDES="${EXCLUDES%,}"
logDebug "EXCLUDES=${EXCLUDES}"

logDebug "PROJECT_DIR=${PROJECT_DIR}"
logDebug "TMP_DIR=${TMP_DIR}"

## https://serverfault.com/questions/219013/showing-total-progress-in-rsync-is-it-possible
## https://www.studytonight.com/linux-guide/how-to-exclude-files-and-directory-using-rsync
RSYNC_OPTS_GIT_MIRROR=(
    -dar
    --links
    --delete-excluded
    --exclude={"${EXCLUDES},${EXCLUDE_AND_REMOVE}"}
)

RSYNC_OPTS_GIT_UPDATE=(
    -ari
    --links
)

function search_repo_keywords () {
  local LOG_PREFIX="==> search_repo_keywords():"

  local REPO_EXCLUDE_DIR_LIST=(".git")
  REPO_EXCLUDE_DIR_LIST+=(".idea")
  REPO_EXCLUDE_DIR_LIST+=("venv")
  REPO_EXCLUDE_DIR_LIST+=("private")
  REPO_EXCLUDE_DIR_LIST+=("save")

  #export -p | sed 's/declare -x //' | sed 's/export //'
  if [ -z ${REPO_EXCLUDE_KEYWORDS+x} ]; then
    logError "${LOG_PREFIX} REPO_EXCLUDE_KEYWORDS not set/defined"
    exit 1
  fi

  logDebug "${LOG_PREFIX} REPO_EXCLUDE_KEYWORDS=${REPO_EXCLUDE_KEYWORDS}"

  IFS=',' read -ra REPO_EXCLUDE_KEYWORDS_ARRAY <<< "$REPO_EXCLUDE_KEYWORDS"

  logDebug "${LOG_PREFIX} REPO_EXCLUDE_KEYWORDS_ARRAY=${REPO_EXCLUDE_KEYWORDS_ARRAY[*]}"

  # ref: https://superuser.com/questions/1371834/escaping-hyphens-with-printf-in-bash
  #'-e' ==> '\055e'
  GREP_DELIM=' \055e '
  printf -v GREP_PATTERN_SEARCH "${GREP_DELIM}%s" "${REPO_EXCLUDE_KEYWORDS_ARRAY[@]}"

  ## strip prefix
  GREP_PATTERN_SEARCH=${GREP_PATTERN_SEARCH#"$GREP_DELIM"}
  ## strip suffix
  #GREP_PATTERN_SEARCH=${GREP_PATTERN_SEARCH%"$GREP_DELIM"}

  logDebug "${LOG_PREFIX} GREP_PATTERN_SEARCH=${GREP_PATTERN_SEARCH}"

  GREP_COMMAND="grep ${GREP_PATTERN_SEARCH}"
  logDebug "${LOG_PREFIX} GREP_COMMAND=${GREP_COMMAND}"

  local FIND_DELIM=' -o '
#  printf -v FIND_EXCLUDE_DIRS "\055path %s${FIND_DELIM}" "${REPO_EXCLUDE_DIR_LIST[@]}"
  printf -v FIND_EXCLUDE_DIRS "! -path %s${FIND_DELIM}" "${REPO_EXCLUDE_DIR_LIST[@]}"
  FIND_EXCLUDE_DIRS=${FIND_EXCLUDE_DIRS%$FIND_DELIM}

  logDebug "${LOG_PREFIX} FIND_EXCLUDE_DIRS=${FIND_EXCLUDE_DIRS}"

  ## ref: https://stackoverflow.com/questions/6565471/how-can-i-exclude-directories-from-grep-r#8692318
  ## ref: https://unix.stackexchange.com/questions/342008/find-and-echo-file-names-only-with-pattern-found
#  FIND_CMD="find ${PROJECT_DIR}/ -type f \( ${FIND_EXCLUDE_DIRS} \) -prune -o -exec ${GREP_COMMAND} {} 2>/dev/null \;"
  FIND_CMD="find ${PROJECT_DIR}/ -type f \( ${FIND_EXCLUDE_DIRS} \) -prune -o -exec ${GREP_COMMAND} {} 2>/dev/null +"
  logDebug "${LOG_PREFIX} ${FIND_CMD}"

  EXCEPTION_COUNT=$(eval "${FIND_CMD} | wc -l")
  if [[ $EXCEPTION_COUNT -eq 0 ]]; then
    logInfo "${LOG_PREFIX} SUCCESS => No exclusion keyword matches found!!"
  else
    logError "${LOG_PREFIX} There are [${EXCEPTION_COUNT}] exclusion keyword matches found:"
    eval "${FIND_CMD}"
    exit 1
  fi
  return "${EXCEPTION_COUNT}"
}

function main() {

#  search_repo_keywords
  eval search_repo_keywords
  local RETURN_STATUS=$?
  if [[ $RETURN_STATUS -eq 0 ]]; then
    logInfo "${LOG_PREFIX} search_repo_keywords: SUCCESS"
  else
    logError "${LOG_PREFIX} search_repo_keywords: FAILED"
    exit ${RETURN_STATUS}
  fi

  git fetch --all
  git checkout ${GIT_DEFAULT_BRANCH}
  
  #RSYNC_OPTS=${RSYNC_OPTS_GIT_MIRROR[@]}
  
  logDebug "copy project to temporary dir $TMP_DIR"
  #local RSYNC_CMD="rsync ${RSYNC_OPTS} ${PROJECT_DIR}/ ${TMP_DIR}/"
  local RSYNC_CMD="rsync ${RSYNC_OPTS_GIT_MIRROR[@]} ${PROJECT_DIR}/ ${TMP_DIR}/"
  logDebug "${RSYNC_CMD}"
  eval $RSYNC_CMD
  
  logInfo "Checkout public branch"
  git checkout ${GIT_PUBLIC_BRANCH}
  
  if [ $GIT_REMOVE_CACHED_FILES -eq 1 ]; then
    logInfo "Removing files cached in git"
    git rm -r --cached .
  fi
  
  #logInfo "Removing existing non-dot files for clean sync"
  #rm -fr *
  
  logInfo "Copy ${TMP_DIR} to project dir $PROJECT_DIR"
  #logInfo "rsync ${RSYNC_OPTS_GIT_UPDATE[@]} ${TMP_DIR}/ ${PROJECT_DIR}/"
  RSYNC_CMD="rsync ${RSYNC_OPTS_GIT_UPDATE[@]} ${TMP_DIR}/ ${PROJECT_DIR}/"
  logInfo "${RSYNC_CMD}"
  eval ${RSYNC_CMD}
  
  IFS=$'\n'
  for dir in ${MIRROR_DIR_LIST}
  do
    logInfo "Mirror ${TMP_DIR}/${dir}/ to project dir $PROJECT_DIR/${dir}/"
    RSYNC_CMD="rsync ${RSYNC_OPTS_GIT_UPDATE[@]} --delete --update --exclude=save ${TMP_DIR}/${dir}/ ${PROJECT_DIR}/${dir}/"
    logInfo "${RSYNC_CMD}"
    eval ${RSYNC_CMD}
  done
  
  printf -v TO_REMOVE '%s ' "${PRIVATE_CONTENT_ARRAY[@]}"
  TO_REMOVE="${TO_REMOVE% }"
  logInfo "TO_REMOVE=${TO_REMOVE}"
  CLEANUP_CMD="rm -fr ${TO_REMOVE}"
  logInfo "${CLEANUP_CMD}"
  eval ${CLEANUP_CMD}
  
  if [ -e $PUBLIC_GITIGNORE ]; then
    logInfo "Update public files:"
    cp -p $PUBLIC_GITIGNORE .gitignore
  fi
  
  logInfo "Show changes before push:"
  git status
  
  ## https://stackoverflow.com/questions/5989592/git-cannot-checkout-branch-error-pathspec-did-not-match-any-files-kn
  ## git diff --name-only public ${GIT_DEFAULT_BRANCH} --
  
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
  logInfo "Add all the files:"
  LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" && \
  REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) && \
  IFS=/ read REMOTE REMOTE_BRANCH <<< ${REMOTE_AND_BRANCH} && \
  logInfo "Staging changes:" && \
  git add -A || true && \
  logInfo "Committing changes:" && \
  git commit -am "group updates to public branch" || true && \
  logInfo "Pushing branch '${LOCAL_BRANCH}' to remote origin branch '${LOCAL_BRANCH}':" && \
  git push -f origin ${LOCAL_BRANCH} || true && \
  logInfo "Pushing branch '${LOCAL_BRANCH}' to remote '${REMOTE}' branch '${REMOTE_BRANCH}':" && \
  git push -f -u ${REMOTE} ${LOCAL_BRANCH}:${REMOTE_BRANCH} || true && \
  logInfo "Finally, checkout ${GIT_DEFAULT_BRANCH} branch:" && \
  git checkout ${GIT_DEFAULT_BRANCH}
  
  logInfo "chmod project admin/maintenance scripts"
  chmod +x inventory/*.sh
  chmod +x files/scripts/*.sh
  chmod +x files/scripts/git/*.sh
  
  logInfo "creating links for useful project scripts"
  cd ${PROJECT_DIR}
  chmod +x ./files/scripts/git/*.sh
  ln -sf ./files/scripts/git/stash-*.sh ./
  ln -sf ./files/scripts/git/sync-*.sh ./
  ln -sf ./inventory/*.sh ./
}

main "$@"
