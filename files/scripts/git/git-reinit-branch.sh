#!/usr/bin/env bash

CONFIRM=0
SCRIPT_NAME=$(basename $0)

usage() {
  retcode=${1:-1}
  echo "" 1>&2
  echo "Usage: ${SCRIPT_NAME} [options] target_branch" 1>&2
  echo "" 1>&2
  echo "     options:" 1>&2
  echo "       -y : provide answer yes to skip confirmation" 1>&2
  echo "       -h : help" 1>&2
  echo "     target_branch: name of the branch to target the reset" 1>&2
  echo "" 1>&2
  echo "  Examples:" 1>&2
  echo "     ${SCRIPT_NAME} -y public" 1>&2
  echo "     ${SCRIPT_NAME} master" 1>&2
  echo "" 1>&2
  exit ${retcode}
}

while getopts "yhf" opt; do
    case "${opt}" in
        y) CONFIRM=1 ;;
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

if [ $# -lt 1 ]; then
    echo "required target_branch not specified" >&2
    usage 5
fi

## https://stackoverflow.com/questions/1593051/how-to-programmatically-determine-the-current-checked-out-git-branch
CURRENT_GIT_BRANCH=$(git symbolic-ref HEAD 2>/dev/null)
TARGET_BRANCH=${1:-"${CURRENT_GIT_BRANCH}"}

if [ $CONFIRM -eq 0 ]; then
  ## https://www.shellhacks.com/yes-no-bash-script-prompt-confirmation/
  read -p "Are you sure you want to re-init branch ${TARGET_BRANCH}? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
      exit 1
  fi
fi

## ref: https://intoli.com/blog/exit-on-errors-in-bash-scripts/
# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

echo "Check out current ${TARGET_BRANCH} branch:"
git checkout ${TARGET_BRANCH}

echo "Check out to a temporary branch:"
git checkout --orphan TEMP_BRANCH

echo "Add all the files:"
git add -A

echo "Commit the changes:"
git commit -am "Initial commit"

echo "Delete the old ${TARGET_BRANCH} branch:"
git branch -D ${TARGET_BRANCH}

echo "Rename the temporary branch to ${TARGET_BRANCH}:"
## ref: https://gist.github.com/heiswayi/350e2afda8cece810c0f6116dadbe651
git branch -m ${TARGET_BRANCH}

echo "Force ${TARGET_BRANCH} branch update to origin repository:"
git push -f origin ${TARGET_BRANCH}
#git push -f --set-upstream origin ${TARGET_BRANCH}
