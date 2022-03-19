#!/usr/bin/env bash

#INITIAL_WD=`pwd`
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
PROJECT_DIR="$( cd "${SCRIPT_DIR}/../../../" && pwd )"

FROM="${PROJECT_DIR}/inventory/group_vars"

ENVS="dev"
ENVS+=" test"
ENVS+=" prod"

echo "SCRIPT_DIR=${SCRIPT_DIR}"
echo "PROJECT_DIR=${PROJECT_DIR}"
echo "FROM=${FROM}"

for environment in $ENVS
do
  echo "Create symlinks for files in environment [$environment]"
  TO="${PROJECT_DIR}/inventory/${environment}/group_vars"

  echo "Remove all existing links in ${TO}"
  find ${TO}/ -type l -exec rm {} \;

  echo "ln -sf ${FROM}/* ${TO}/"
  ln -sf ${FROM}/* ${TO}/
done

