#!/bin/sh

## How to reset/restart/blast repo:
## Make the current commit the only (initial) commit in a Git repository?
## ref: https://stackoverflow.com/questions/9683279/make-the-current-commit-the-only-initial-commit-in-a-git-repository

#GIT_ORIGIN_REPO=https://github.com/lj020326/placeholder.git
GIT_ORIGIN_REPO=$(git config --get remote.origin.url)

echo "reinitializing git repo"
rm -fr .git
git init
git checkout -b main
git remote add origin ${GIT_ORIGIN_REPO}
git add .
git commit -m "Initial commit"
git push -u --force origin main
