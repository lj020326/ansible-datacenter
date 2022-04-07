#!/usr/bin/env bash

## ref: https://intoli.com/blog/exit-on-errors-in-bash-scripts/
# exit when any command fails
set -e

## https://www.pixelstech.net/article/1577768087-Create-temp-file-in-Bash-using-mktemp-and-trap
TMP_DIR="$(mktemp -d -p ~)"

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT
trap 'rm -fr "$TMP_DIR"' EXIT

CONFIRM=0
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

#PROJECT_DIR="$( cd "$SCRIPT_DIR/../../../" && pwd )"
#PROJECT_DIR="$( pwd . )"
#PROJECT_DIR=$(git rev-parse --show-toplevel)
PROJECT_DIR="$( cd "$SCRIPT_DIR/" && git rev-parse --show-toplevel )"

## ref: https://stackoverflow.com/questions/53839253/how-can-i-convert-an-array-into-a-comma-separated-string
declare -a PRIVATE_CONTENT_ARRAY
PRIVATE_CONTENT_ARRAY+=('**/private/***')
PRIVATE_CONTENT_ARRAY+=('**/save/***')
PRIVATE_CONTENT_ARRAY+=('**/secrets.yml')
PRIVATE_CONTENT_ARRAY+=('**/*secrets.yml')
PRIVATE_CONTENT_ARRAY+=('.vault_pass')
PRIVATE_CONTENT_ARRAY+=('***/*vault*')
PRIVATE_CONTENT_ARRAY+=('*.log')

printf -v EXCLUDE_AND_REMOVE '%s,' "${PRIVATE_CONTENT_ARRAY[@]}"
EXCLUDE_AND_REMOVE="${EXCLUDE_AND_REMOVE%,}"
echo "EXCLUDE_AND_REMOVE=${EXCLUDE_AND_REMOVE}"

## ref: https://stackoverflow.com/questions/53839253/how-can-i-convert-an-array-into-a-comma-separated-string
declare -a EXCLUDES_ARRAY
EXCLUDES_ARRAY=('.git')
EXCLUDES_ARRAY+=('.idea')
EXCLUDES_ARRAY+=('.vscode')
EXCLUDES_ARRAY+=('**/.DS_Store')
EXCLUDES_ARRAY+=('venv')

printf -v EXCLUDES '%s,' "${EXCLUDES_ARRAY[@]}"
EXCLUDES="${EXCLUDES%,}"
echo "EXCLUDES=${EXCLUDES}"

echo "SCRIPT_DIR=[${SCRIPT_DIR}]"
echo "PROJECT_DIR=${PROJECT_DIR}"
echo "TMP_DIR=${TMP_DIR}"

#exit 0

## https://serverfault.com/questions/219013/showing-total-progress-in-rsync-is-it-possible
## https://www.studytonight.com/linux-guide/how-to-exclude-files-and-directory-using-rsync
RSYNC_OPTS_GIT_MIRROR=(
    -dar
    --info=progress2
    --links
    --delete-excluded
    --exclude={"${EXCLUDES},${EXCLUDE_AND_REMOVE}"}
)

RSYNC_OPTS_GIT_UPDATE=(
    -ari
    --links
)

git fetch --all
git checkout master

#RSYNC_OPTS=${RSYNC_OPTS_GIT_MIRROR[@]}

echo "copy project to temporary dir $TMP_DIR"
#rsync_cmd="rsync ${RSYNC_OPTS} ${PROJECT_DIR}/ ${TMP_DIR}/"
rsync_cmd="rsync ${RSYNC_OPTS_GIT_MIRROR[@]} ${PROJECT_DIR}/ ${TMP_DIR}/"
echo "${rsync_cmd}"
eval $rsync_cmd

#exit 0

echo "Checkout public branch"
git checkout public

echo "Removing files cached in git"
git rm -r --cached .

#echo "Removing existing non-dot files for clean sync"
#rm -fr *

echo "Mirror ${TMP_DIR} to project dir $PROJECT_DIR"
#echo "rsync ${RSYNC_OPTS_GIT_UPDATE[@]} ${TMP_DIR}/ ${PROJECT_DIR}/"
rsync_cmd="rsync ${RSYNC_OPTS_GIT_UPDATE[@]} ${TMP_DIR}/ ${PROJECT_DIR}/"
echo "${rsync_cmd}"
eval $rsync_cmd

#rm -fr private/
#rm -fr files/private/
#rm -fr vars/secrets.yml
#rm -fr .vault_pass

printf -v TO_REMOVE '%s ' "${PRIVATE_CONTENT_ARRAY[@]}"
TO_REMOVE="${TO_REMOVE% }"
echo "TO_REMOVE=${TO_REMOVE}"
cleanupPvt="rm -fr ${TO_REMOVE}"
echo "${cleanupPvt}"
eval $cleanupPvt

#exit 0

if [ -e files/git/pub.gitignore ]; then
  echo "Update public files:"
  cp -p files/git/pub.gitignore .gitignore
fi

echo "Show changes before push:"
git status

## https://stackoverflow.com/questions/5989592/git-cannot-checkout-branch-error-pathspec-did-not-match-any-files-kn
## git diff --name-only public master --

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
echo "Add all the files:"
LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" && \
REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) && \
IFS=/ read REMOTE REMOTE_BRANCH <<< ${REMOTE_AND_BRANCH} && \
echo "Staging changes:" && \
git add -A || true && \
echo "Committing changes:" && \
git commit -am "group updates to public branch" || true && \
echo "Pushing branch '${LOCAL_BRANCH}' to remote origin branch '${LOCAL_BRANCH}':" && \
git push -f origin ${LOCAL_BRANCH} || true && \
echo "Pushing public branch update to github repository (as main branch):" && \
git push -f -u github public:main || true && \
echo "Finally, checkout master branch:" && \
git checkout master
