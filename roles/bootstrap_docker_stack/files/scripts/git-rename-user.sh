#!/usr/bin/env bash

FROM_USER="ansible"
FROM_USER_EMAIL="ansible@localhost"

TO_USER="ansible"
TO_USER_EMAIL="ansible@email.com"

## old methods using git filter-branch
## refs:
## - https://stackoverflow.com/a/750182
#
#git filter-branch --env-filter '
#if [ "$GIT_AUTHOR_NAME" = "${FROM_USER}" ]; then \
#    export GIT_AUTHOR_NAME="ansible" GIT_AUTHOR_EMAIL="${TO_USER_EMAIL}"; \
#fi
#if [ "$GIT_COMMITTER_NAME" = "${FROM_USER}" ]; then \
#    export GIT_COMMITTER_NAME="ansible" GIT_COMMITTER_EMAIL="${TO_USER_EMAIL}"; \
#fi
#'
#
## Can verify the new rewritten log via:
##   git log --pretty=format:"[%h] %cd - Committer: %cn (%ce), Author: %an (%ae)"
##
## To view the users in repo
##   git shortlog --summary --numbered --email

#git filter-branch --env-filter '
#      if test "$GIT_AUTHOR_EMAIL" = "${FROM_USER_EMAIL}"
#      then
#              GIT_AUTHOR_NAME="${TO_USER}"
#              GIT_AUTHOR_EMAIL="${TO_USER_EMAIL}"
#      fi
#      if test "$GIT_COMMITTER_EMAIL" = "${FROM_USER_EMAIL}"
#      then
#              GIT_COMMITTER_NAME="${TO_USER}"
#              GIT_COMMITTER_EMAIL="${TO_USER_EMAIL}"
#      fi
#      ' -- --all

## Recommended method - depends on created git-mailmap file
## ref: https://github.com/newren/git-filter-repo/blob/main/Documentation/converting-from-filter-branch.md#changing-authorcommittertagger-information

## For using alternative history filtering tool [git filter-repo](https://github.com/newren/git-filter-repo/),
## you can first install it and construct a `git-mailmap` according to the format
## of [gitmailmap](https://htmlpreview.github.io/?https://raw.githubusercontent.com/newren/git-filter-repo/docs/html/gitmailmap.html).
#
#```
#Proper Name <proper@email.xx> Commit Name <commit@email.xx>
#```
#
## on a mac, you can install it using homebrew:
## brew install git-filter-repo
## Then run filter-repo with the created mailmap:
#
#```
# ##use fresh clone
# cd tmp
# git clone <url>
# git filter-repo --mailmap ../git-mailmap
# git remote add origin <url>
# git push -u origin --force --all
#```
# then on any existing clone(s) make sure to rebase (or merge-ff):
#```
#$ git pull origin main
#$ git rebase
#```
