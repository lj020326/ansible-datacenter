#!/usr/bin/env bash

## ref: https://bitbucket.org/snippets/atlassian/qedp7d
function getgitrequestid() {
  PROJECT_DIR="$(git rev-parse --show-toplevel)"
  LOCAL_BRANCH="$(git symbolic-ref --short HEAD)"
  COMMENT_PREFIX=$(echo "${LOCAL_BRANCH}" | cut -d- -f1-2)
#  ISSUE_KEY=`git branch | grep -o "\* \(.*/\)*[A-Z]\{2,\}-[0-9]\+" | grep -o "[A-Z]\{2,\}-[0-9]\+"`

  if [[ $COMMENT_PREFIX = *develop* ]]; then
    if [ -f ${PROJECT_DIR}/.git.request.refid ]; then
      COMMENT_PREFIX=$(cat ${PROJECT_DIR}/.git.request.refid)
    elif [ -f ${PROJECT_DIR}/save/.git.request.refid ]; then
      COMMENT_PREFIX=$(cat ${PROJECT_DIR}/save/.git.request.refid)
    elif [ -f ./.git.request.refid ]; then
      COMMENT_PREFIX=$(cat ./.git.request.refid)
    fi
  fi
  echo "${COMMENT_PREFIX}"
}

## https://stackoverflow.com/questions/35010953/how-to-automatically-generate-commit-message
unalias getgitcomment 1>/dev/null 2>&1
unset -f getgitcomment || true
function getgitcomment() {
  COMMENT_PREFIX=$(getgitrequestid)
  COMMENT_BODY="$(LANG=C git -c color.status=false status \
      | sed -n -r -e '1,/Changes to be committed:/ d' \
            -e '1,1 d' \
            -e '/^Untracked files:/,$ d' \
            -e 's/^\s*//' \
            -e '/./p' \
            | sed -e '/git restore/ d')"
  GIT_COMMENT="${COMMENT_PREFIX} - ${COMMENT_BODY}"
  echo "${GIT_COMMENT}"
}

#getgitrequestid

getgitcomment
