#!/usr/bin/env bash

## ref: https://intoli.com/blog/exit-on-errors-in-bash-scripts/
# exit when any command fails
set -e

UNSTASH=0
CONFIRM=0

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT
#trap 'rm -fr "$TMP_DIR"' EXIT

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
SCRIPT_NAME=`basename $0`

if [ ! -z "$(git status --porcelain)" ]; then
  echo "git repo not clean/found in ${pwd}"
  exit
fi

#PROJECT_DIR="$( cd "$SCRIPT_DIR/../../../" && pwd )"
#PROJECT_DIR="$( pwd . )"
PROJECT_DIR=$(git rev-parse --show-toplevel)
#PROJECT_DIR="$( cd "$SCRIPT_DIR/" && git rev-parse --show-toplevel )"

LOCAL_BRANCH="$(git symbolic-ref --short HEAD)"
BRANCH_SHORT=$(echo "${LOCAL_BRANCH}" | cut -d- -f1-2)

#echo "SCRIPT_DIR=[${SCRIPT_DIR}]"
echo "PROJECT_DIR=${PROJECT_DIR}"
echo "BRANCH_SHORT=${BRANCH_SHORT}"

usage() {
  retcode=${1:-1}
  echo "" 1>&2
  echo "Usage: ${SCRIPT_NAME} [options]" 1>&2
  echo "" 1>&2
  echo "     options:" 1>&2
  echo "       -u : unstash last stash" 1>&2
  echo "       -h : help" 1>&2
  echo "" 1>&2
  echo "  Examples:" 1>&2
  echo "     ${SCRIPT_NAME}" 1>&2
  echo "     ${SCRIPT_NAME} -u" 1>&2
  echo "" 1>&2
  exit ${retcode}
}

while getopts "uh" opt; do
    case "${opt}" in
        u) UNSTASH=1 ;;
        h) usage 1 ;;
        \?) usage 2 ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage 3
            ;;
        *)
            usage 4
            ;;
    esac
done
shift $((OPTIND-1))

if [ $UNSTASH -eq 1 ]; then
  source ./save/.laststash
  echo "Loading stash from ${LAST_STASH}"

  RSYNC_OPTS_GIT_UPDATE=(
      -ari
      --links
      --update
  )

  echo "copy project from stash dir ${LAST_STASH}"
  #rsync_cmd="rsync ${RSYNC_OPTS} ${PROJECT_DIR}/ ${TMP_DIR}/"
  rsync_cmd="rsync ${RSYNC_OPTS_GIT_UPDATE[@]} ${LAST_STASH}/ ${PROJECT_DIR}/"
  echo "${rsync_cmd}"
  eval $rsync_cmd

  exit 0
fi

## https://www.pixelstech.net/article/1577768087-Create-temp-file-in-Bash-using-mktemp-and-trap
mkdir -p save
TMP_DIR=$(mktemp -d -p ./save)

## ref: https://stackoverflow.com/questions/53839253/how-can-i-convert-an-array-into-a-comma-separated-string
declare -a EXCLUDES_ARRAY
EXCLUDES_ARRAY=('.git')
EXCLUDES_ARRAY+=('.idea')
EXCLUDES_ARRAY+=('.vscode')
EXCLUDES_ARRAY+=('save')
EXCLUDES_ARRAY+=('venv')

printf -v EXCLUDES '%s,' "${EXCLUDES_ARRAY[@]}"
EXCLUDES="${EXCLUDES%,}"
echo "EXCLUDES=${EXCLUDES}"

echo "TMP_DIR=${TMP_DIR}"

#exit 0

## https://serverfault.com/questions/219013/showing-total-progress-in-rsync-is-it-possible
## https://www.studytonight.com/linux-guide/how-to-exclude-files-and-directory-using-rsync
RSYNC_OPTS_GIT_MIRROR=(
    -dar
    --info=progress2
    --links
    --delete-excluded
    --exclude={"${EXCLUDES}"}
)

echo "copy project to temporary dir $TMP_DIR"
#rsync_cmd="rsync ${RSYNC_OPTS} ${PROJECT_DIR}/ ${TMP_DIR}/"
rsync_cmd="rsync ${RSYNC_OPTS_GIT_MIRROR[@]} ${PROJECT_DIR}/ ${TMP_DIR}/"
echo "${rsync_cmd}"
eval $rsync_cmd

echo "LAST_STASH=${TMP_DIR}" > ./save/.laststash
