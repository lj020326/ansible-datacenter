#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +%Y%m%d%H%M%S)

GIT_ORIGIN_REPO=git@bitbucket.org:lj020326/ansible-datacenter.git
GIT_INTERNAL_REPO=ssh://git@gitea.admin.dettonville.int:2222/gitadmin/ansible-datacenter.git
GIT_PUBLIC_REPO=git@github.com:lj020326/ansible-datacenter.git

GIT_ARCHIVE_DIR="save"
GIT_ARCHIVE_NAME="${GIT_ARCHIVE_DIR}/.git.${TIMESTAMP}"

PRIVATE_DIR="${GIT_ARCHIVE_DIR}/private.${TIMESTAMP}"
#RESOURCE_DIR="${SCRIPT_DIR}/../../private/resources"
#RESOURCE_DIR="${SCRIPT_DIR}/resources"
RESOURCE_DIR="${PRIVATE_DIR}/resources"

if [ -d ${GIT_ARCHIVE_NAME} ]; then
  echo "cannot save to ${GIT_ARCHIVE_NAME} - backup already exists..."
  exit 1
fi

echo "archiving existing git repo"
mkdir -p ${GIT_ARCHIVE_DIR}
mv .git ${GIT_ARCHIVE_NAME}

echo "stashing private resources"
mv vars/secrets.yml ${GIT_ARCHIVE_DIR}/secrets.yml.${TIMESTAMP}
mv files/private ${GIT_ARCHIVE_DIR}/private.${TIMESTAMP}
cp -p ${RESOURCE_DIR}/pvt.gitignore ./.gitignore

echo "initializing repo"
git init
git add .
git commit -m 'initial commit'
git remote add origin ${GIT_ORIGIN_REPO}
git remote add gitea ${GIT_INTERNAL_REPO}
git remote add github ${GIT_PUBLIC_REPO}
git push -u --force origin master
git push -u --force gitea master

echo "setup public repo"
git checkout -b public
cp -p ${RESOURCE_DIR}/pub.gitignore ./.gitignore
#echo "remove secrets.yml"
#rm vars/secrets.yml || true
echo "add and commit"
git add .
git commit -m 'updates'
#echo "push public branch to github repo"
#git push --set-upstream github public

echo "push public branch to repos"
git push -u --force github public
git push -u --force origin public
git push -u --force gitea public

echo "unstashing resources to private repos"
git checkout master
cp -p ${GIT_ARCHIVE_DIR}/secrets.yml.${TIMESTAMP} vars/secrets.yml
cp -pr ${GIT_ARCHIVE_DIR}/private.${TIMESTAMP} files/private
git add .
git commit -m 'updates'
git push origin master
git push gitea master
