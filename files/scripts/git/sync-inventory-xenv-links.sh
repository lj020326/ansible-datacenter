#!/usr/bin/env bash

## ref: https://unix.stackexchange.com/questions/573047/how-to-get-the-relative-path-between-two-directories
pnrelpath() {
  ## get the relative path between two directories
  set -- "${1%/}/" "${2%/}/" ''               ## '/'-end to avoid mismatch
  while [ "$1" ] && [ "$2" = "${2#"$1"}" ]    ## reduce $1 to shared path
  do  set -- "${1%/?*/}/"  "$2" "../$3"       ## source/.. target ../relpath
  done
  REPLY="${3}${2#"$1"}"                       ## build result
  # unless root chomp trailing '/', replace '' with '.'
  [ "${REPLY#/}" ] && REPLY="${REPLY%/}" || REPLY="${REPLY:-.}"
  echo "${REPLY}"
}

SCRIPT_DIR=$( cd "$( dirname "$0" )" && pwd )
PROJECT_DIR=$( cd "$SCRIPT_DIR/" && git rev-parse --show-toplevel )
INVENTORY_DIR="${PROJECT_DIR}/inventory"

echo "SCRIPT_DIR=${SCRIPT_DIR}"
echo "PROJECT_DIR=${PROJECT_DIR}"
echo "INVENTORY_DIR=${INVENTORY_DIR}"

ENVS="
dev
test
prod
"

IFS=$'\n'
for environment in ${ENVS}
do
  echo "Create symlinks for files in environment [$environment]"
  TO="${INVENTORY_DIR}/${environment}"
  cd ${TO}/

  echo "Remove all existing links in ${TO}"
  find . -type l -print -exec rm {} \;

  RELPATH=$(pnrelpath "$PWD" "$INVENTORY_DIR")
  echo "RELPATH=${RELPATH}"

  echo "Create host related links"
  ln -sf ${RELPATH}/host_vars ./
  if [[ "${environment}" == "dev" ]]; then
    ln -sf ${RELPATH}/*.ini ./
#    ln -sf ${RELPATH}/*.py ./
  fi

  cd group_vars

  echo "get the relative path between $PWD and $INVENTORY_DIR directories"
  RELPATH=$(pnrelpath "$PWD" "$INVENTORY_DIR")
  echo "RELPATH=${RELPATH}"

#  echo "ln -sf ../../group_vars/* ./"
#  ln -sf ../../group_vars/* ./

  echo "ln -sf ${RELPATH}/group_vars/* ./"
  ln -sf ${RELPATH}/group_vars/* ./
  rm -f all.yml

  ECHO "Create ${PWD}/all dir if does not exist"
  mkdir -p all

##  mv ${TO}/all.yml ${TO}/all/000_cross_env_vars.yml
#  rm -f all.yml
#  ln -sf ../../../group_vars/all.yml ./all/000_cross_env_vars.yml

  cd all
  echo "get the relative path between $PWD and $INVENTORY_DIR directories"
  RELPATH=$(pnrelpath "$PWD" "$INVENTORY_DIR")
  echo "RELPATH=${RELPATH}"

  ln -sf ${RELPATH}/group_vars/all.yml ./000_cross_env_vars.yml

done

echo "creating links for roles"
cd ${PROJECT_DIR}/roles/bootstrap-linux-user/files/
RELPATH=$(pnrelpath "$PWD" "${PROJECT_DIR}")
ln -sf ${RELPATH}/files/scripts/bashenv

echo "creating links for useful project scripts"
cd ${PROJECT_DIR}
chmod +x ./files/scripts/git/*.sh
ln -sf ./files/scripts/git/stash-*.sh ./
ln -sf ./files/scripts/git/sync-*.sh ./
