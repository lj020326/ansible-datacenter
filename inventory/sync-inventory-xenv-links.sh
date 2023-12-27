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

#SCRIPT_DIR=$( cd "$( dirname "$0" )" && pwd )
PROJECT_DIR=$( git rev-parse --show-toplevel )
INVENTORY_DIR="${PROJECT_DIR}/inventory"

#echo "SCRIPT_DIR=${SCRIPT_DIR}"
echo "PROJECT_DIR=${PROJECT_DIR}"
echo "INVENTORY_DIR=${INVENTORY_DIR}"

ENVS="
PROD
QA
DEV
"

## For `SPECIAL_LINKS` use the following format to specify any special links
## [linkName]:[linkSource]
##
## NOTE:
## The `create_host_links_yml` function will automatically create links for any hosts files with pattern `*.yml`
## at the inventory top/root level directory across all environments specified in the `ENVS` var.
##
## Since the filename pattern is `*.yml` at the top level, the `xenv_infra_hosts.yml` hosts file will
## setup by `create_host_links_yml` function
##
## Use `SPECIAL_LINKS` for links that are specified in other/non-root locations/subdirs
## and to be shared across a subset of inventory directories and not all.
##
## E.g., assuming there was a sub-directory `NONPROD` with `NONPROD/nonprod_xenv_hosts.yml`
## then use `create_special_links` to setup those links as follows
##
#SPECIAL_LINKS="
#SANDBOX/nonprod_xenv_hosts.yml:../NONPROD/xenv_infra_hosts.yml
#DEV/nonprod_xenv_hosts.yml:../NONPROD/xenv_infra_hosts.yml
#QA/nonprod_xenv_hosts.yml:../NONPROD/xenv_infra_hosts.yml
#"

##############################
## The `create_host_links_yml` function will automatically create links for any hosts files with pattern `*.yml`
## at the inventory top/root level directory across all environments specified in the `ENVS` var.
##
## Since the filename pattern is `*.yml` at the top level, the `xenv_infra_hosts.yml` hosts file will
## setup by `create_host_links_yml` function
create_host_links_yml() {
  INVENTORY_DIR=$1
  ENVS=$2

  BASE_DIRECTORY="${INVENTORY_DIR}"

  echo "BASE_DIRECTORY=[$BASE_DIRECTORY]"

  ##
  ## for each PATH iteration create a soft link back to all files found in the respective base directory (Sandbox/Prod)
  ##
  IFS=$'\n'
  for environment in ${ENVS}
  do
    echo "#######################################################"
    echo "#######################################################"
    echo "##### Create host (*.yml) symlinks for files in environment [$environment]"

    ENV_DIR="${INVENTORY_DIR}/${environment}"
    echo "ENV_DIR=${ENV_DIR}"
    echo "cd ${ENV_DIR}"
    cd "${ENV_DIR}"/

    echo "get the relative path between $PWD and $BASE_DIRECTORY directories"
    RELPATH=$(pnrelpath "$PWD" "$BASE_DIRECTORY")
    echo "RELPATH=${RELPATH}"

    echo "Remove all existing host links in ${ENV_DIR}"
    find . -maxdepth 1 -type l -print -exec rm {} \;

    echo "ln -sf ${RELPATH}/*.yml ./"
    ln -sf "${RELPATH}"/*.yml ./

  done

}

create_groupvars_links_yml() {
  INVENTORY_DIR=$1
  ENVS=$2

  BASE_DIRECTORY="${INVENTORY_DIR}"

  echo "BASE_DIRECTORY=[$BASE_DIRECTORY]"

  ##
  ## for each PATH iteration create a soft link back to all files found in the respective base directory (Sandbox/Prod)
  ##
  IFS=$'\n'
  for environment in ${ENVS}
  do
    echo "#######################################################"
    echo "#######################################################"
    echo "##### Create group_vars/*.yml symlinks for files in environment [$environment]"

    ENV_DIR="${INVENTORY_DIR}/${environment}"
    echo "ENV_DIR=${ENV_DIR}"
    echo "cd ${ENV_DIR}"
    cd ${ENV_DIR}/

    mkdir -p group_vars
    cd group_vars

    echo "get the relative path between $PWD and $BASE_DIRECTORY directories"
    RELPATH=$(pnrelpath "$PWD" "$BASE_DIRECTORY")
    echo "RELPATH=${RELPATH}"

    echo "Remove all existing group_var links in ${ENV_DIR}"
    find . -type l -print -exec rm {} \;

    echo "ln -sf ${RELPATH}/group_vars/*.yml ./"
    ln -sf ${RELPATH}/group_vars/*.yml ./

#    rm -f all.yml
    echo "Create ${PWD}/all dir if does not exist"
    mkdir -p all

    cd all
    RELPATH=$(pnrelpath "$PWD" "$BASE_DIRECTORY")
    echo "group_vars/all/ => RELPATH=${RELPATH}"

    echo "Remove all existing group_var links in ${ENV_DIR}/group_vars/all/"
    find all/. -type l -print -exec rm {} \;

    echo "ln -sf ${RELPATH}/group_vars/all/*.yml ./"
    ln -sf ${RELPATH}/group_vars/all/*.yml ./

## NOTES:
##   regarding the filename changed from `000_cross_env_vars.yml` to `all.yml`:
##
##   This means with this change that the filename is:
##   a) simpler to implement in the sync - the logic is simpler in that is just links all of whatever exists in the parent `groups_vars/all/*.yml`.
##   b) simpler to follow each link to the respective source file in the parent `group_vars/all/*.yml` and
##   c) simpler to understand what is happening overall
##
## That said, the rename/move each `${CHILD_INV}/group_vars/all/all.yml` to `${CHILD_INV}/group_vars/all/000_cross_env_vars.yml` is easy to do.
## Not sure I like it much though 😐.
##
## The real reason the initial name `000_cross_env_vars.yml` was used was residue from observing the initial example from
## the [source article at digitalocean here](https://www.digitalocean.com/community/tutorials/how-to-manage-multistage-environments-with-ansible).
##
## As such, I did not feel the need to continue to keep to this specific naming convention going forward since:
##
## 1. the name `${CHILD_INV}/group_vars/all/all.yml -> ../../group_vars/all/all.yml` should be more consistent to the actual parent file name.
## 2. now as we evolve towards having multiple parent `group_vars/all/*.yml` files, it becomes less relevant to have a specific _special name_ for a single `all.yml` file.
## 3. and if anything, leading to confusion as to why that specific file has a different name as opposed to the remaining parent `group_vars/all/*.yml` var files which are all global.
##
##
## LIMITATIONS FOUND DURING TESTING:
##
## Ideally, the `env-specific.yml` should always trump/overwrite the other global variable files with a lower ASCII-order name for any specific settings.
##
## > When you put multiple inventory sources in a directory, Ansible merges them in ASCII order according to the filenames
## > source: https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#managing-inventory-variable-load-order
##
## This was the consideration in the naming convention/approach used in [this article at digitalocean](https://www.digitalocean.com/community/tutorials/how-to-manage-multistage-environments-with-ansible).
##
## However, during testing it was found that the current ansible version does not appear to support merging variable files in `group_vars/all/*.yml` in ASCII order according to the filenames.
##
## For example, when testing when a variable appears in 1 or more of the global `group_var/all/000_*.yml` files and also appears in the `group_vars/env-specific.yml`, with a test_variable (named `trace_global_var` below), it is found that it does not work as expected.
##
## E.g.,
## SANDBOX/group_vars/all/000_cross_env.yml:
## ```yaml
## trace_global_var: i-am-set-by-all
## ```
##
## SANDBOX/group_vars/all/env-specific.yml:
## ```yaml
## trace_global_var: i-am-set-by-SANDBOX
## ```
##
## ```shell
## $ ansible -i SANDBOX/ -m debug -a var=trace_global_var localhost
## localhost | SUCCESS => {
##     "trace_global_var": "i-am-set-by-all"
## }
## ```
##
## The implied constraint here is for any global variables that are expected to be set at the child inventory level that they must only be set in the CHILD inventory `env-specific.yml` and not at the parent inventory `group_vars/all.yml` level; otherwise, the correct variable value will not prevail in the way expected.
##
## The additional implied is that ASCII-ordered variable file naming does not work/matter in this `group_vars/all/*.yml` use case.
##
#    ln -sf ${RELPATH}/group_vars/all.yml ./000_cross_env_vars.yml
#    mv ./all.yml ./000_cross_env_vars.yml
    touch ./env_specific.yml

  done

}

create_hostvars_links_yml() {
  INVENTORY_DIR=$1
  ENVS=$2

  BASE_DIRECTORY="${INVENTORY_DIR}"

  echo "BASE_DIRECTORY=[$BASE_DIRECTORY]"

  ##
  ## for each PATH iteration create a soft link back to all files found in the respective base directory (Sandbox/Prod)
  ##
  IFS=$'\n'
  for environment in ${ENVS}
  do
    echo "#######################################################"
    echo "#######################################################"
    echo "##### Create host_vars symlinks for files in environment [$environment]"

    ENV_DIR="${INVENTORY_DIR}/${environment}"
    echo "ENV_DIR=${ENV_DIR}"
    echo "cd ${ENV_DIR}"
    cd ${ENV_DIR}/

    echo "get the relative path between $PWD and $BASE_DIRECTORY directories"
    RELPATH=$(pnrelpath "$PWD" "$BASE_DIRECTORY")
    echo "RELPATH=${RELPATH}"

    echo "ln -sf ${RELPATH}/host_vars ./"
    ln -sf ${RELPATH}/host_vars ./

  done

}

######################
## The `create_special_links` function will automatically create links
## for `SPECIAL_LINKS` specified in other/non-root locations/subdirs.
##
## This is particularly useful for links shared across a subset of inventory directories and not all
## as well as maintaining any env-specific links if there is a need to do so.
##
## E.g., assuming there was a sub-directory `NONPROD` with `NONPROD/nonprod_xenv_hosts.yml`
## then use `create_special_links` to setup those links as follows
##
##SPECIAL_LINKS="
##SANDBOX/nonprod_xenv_hosts.yml:../NONPROD/xenv_infra_hosts.yml
##DEV/nonprod_xenv_hosts.yml:../NONPROD/xenv_infra_hosts.yml
##QA/nonprod_xenv_hosts.yml:../NONPROD/xenv_infra_hosts.yml
##"
create_special_links() {
  INVENTORY_DIR=$1
  SPECIAL_LINKS=$2
  BASE_DIRECTORY="${INVENTORY_DIR}/${ENV_BASE}"
  echo "BASE_DIRECTORY=[$BASE_DIRECTORY]"

  ##
  ## for each PATH iteration create a soft link back to all files found in the respective base directory (Sandbox/Prod)
  ##
  IFS=$'\n'
  for special_link in ${SPECIAL_LINKS}
  do

    echo "#######################################################"
    echo "#######################################################"
    echo "##### Create SPECIAL_LINKS symlinks for special_link [$special_link]"
    # split sub-list if available
    if [[ $special_link == *":"* ]]
    then
      # ref: https://stackoverflow.com/questions/12317483/array-of-arrays-in-bash
      # split server name from sub-list
#      linkInfoArray=(${special_link//:/})
      IFS=":" read -a linkInfoArray <<< $special_link
      link=${linkInfoArray[0]}
      linkSource=${linkInfoArray[1]}

      echo "link=[$link]"
      echo "linkSource=[$linkSource]"

      linkName=$(basename "${link}")
      environment=$(dirname "${link}")

      echo "linkName=[$linkName]"
      echo "environment=[$environment]"

      ENV_DIR="${INVENTORY_DIR}/${environment}"
      echo "ENV_DIR=${ENV_DIR}"
      echo "cd ${ENV_DIR}"
      cd "${ENV_DIR}"/

      echo "Remove existing link in ${ENV_DIR}"
      find . -maxdepth 1 -name "${linkName}" -type l -print -exec rm {} \;

      echo "ln -sf ${linkSource} ${linkName}"
      ln -sf "${linkSource}" "${linkName}"
    fi

  done

}

create_host_links_yml "${INVENTORY_DIR}" "${ENVS}"

create_groupvars_links_yml "${INVENTORY_DIR}" "${ENVS}"

create_hostvars_links_yml "${INVENTORY_DIR}" "${ENVS}"

## only run if SPECIAL_LINKS is defined
if [[ -n "${SPECIAL_LINKS}" ]]; then
  create_special_links "${INVENTORY_DIR}" "${SPECIAL_LINKS}"
fi
