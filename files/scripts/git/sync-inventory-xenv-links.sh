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
  TO="${PROJECT_DIR}/inventory/${environment}"
  cd ${TO}/

  echo "Remove all existing links in ${TO}"
  find . -type l -exec rm {} \;

  echo "Create host related links"
  ln -sf ../host_vars ./
  if [[ "${environment}" == "dev" ]]; then
    ln -sf ../*.ini ./
    ln -sf ../*.py ./
  fi

  cd group_vars
  echo "ln -sf ../../group_vars/* ./"
  ln -sf ../../group_vars/* ./

  ECHO "Create all dir if does not exist"
  mkdir -p all

#  mv ${TO}/all.yml ${TO}/all/000_cross_env_vars.yml
  rm -f all.yml
  ln -sf ../../../group_vars/all.yml ./all/000_cross_env_vars.yml
done

