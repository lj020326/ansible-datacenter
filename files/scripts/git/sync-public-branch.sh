#!/usr/bin/env bash

#INITIAL_WD=`pwd`
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "SCRIPT_DIR=[${SCRIPT_DIR}]"

PROJECT_DIR="$( cd "$SCRIPT_DIR/../../../" && pwd )"
EXCLUDES="--exclude=save"
EXCLUDES+=" --exclude=private"
EXCLUDES+=" --exclude=secrets.yml"
EXCLUDES+=" --exclude=.vault_pass"
EXCLUDES+=" --exclude=vault"
EXCLUDES+=" --exclude=venv"

FROM="${PROJECT_DIR}/collections ${PROJECT_DIR}/doc"
DIRS="collections doc files filter_plugins inventory library playbooks plugins roles scripts tests vars"

## ref: https://intoli.com/blog/exit-on-errors-in-bash-scripts/
# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

echo "Check out master branch:"
git checkout master

git pull origin master

echo "Check out master branch:"
git checkout public

echo "Removing files cached in git"
git rm -r --cached .


for dir in $DIRS
do
  echo "Fetch changes from master for ${dir}"
  git checkout master ${dir}
done

rm -fr private/
rm -fr files/private/
rm -fr vars/secrets.yml

echo "Update public files:"
cp -p files/git/pub.gitignore .gitignore

echo "Show changes before push:"
git status

if [ $CONFIRM -eq 0 ]; then
  ## https://www.shellhacks.com/yes-no-bash-script-prompt-confirmation/
  read -p "Are you sure you want to merge the changes above to public branch ${TARGET_BRANCH}? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
      exit 1
  fi
fi

echo "Add all the files:"
git add -A

echo "Commit the changes:"
git commit -am "group updates to public branch"

echo "Force public branch update to origin repository:"
git push -f origin public
#git push -f --set-upstream origin public

echo "Force public branch update to github repository:"
git push -f github public

echo "Finally, checkout master branch:"
git checkout master
