#!/usr/bin/env bash

#set -eux

#source virtualenv.sh

# Requirements have to be installed prior to running ansible-playbook
# because plugins and requirements are loaded before the task runs

#pip install -r requirements.txt

#echo "==> ENV"
#echo "$(export -p | sed 's/declare -x //')"

VERSION="2025.8.14"

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
SCRIPT_NAME="$(basename "$0")"
SCRIPT_NAME_PREFIX="${SCRIPT_NAME%.*}"

#PLAYBOOK_DEFAULT="${SCRIPT_NAME%.*}.yml"
PLAYBOOK_DEFAULT="site.yml"

PROJECT_DIR="$( cd "$SCRIPT_DIR/" && git rev-parse --show-toplevel )"

## only needed if sourcing local private collections by source instead of galaxy
## NEEDED when there is are updates/changes to the dependent collections
## to be deployed along with the project repo update(s)
#PROJECT_PARENT_DIR="${PROJECT_DIR}/.."
PROJECT_PARENT_DIR=$(dirname "${PROJECT_DIR}")

VAULTPASS_FILEPATH="${HOME}/.vault_pass"
if [[ -f "${PROJECT_DIR}/.vault_pass" ]]; then
  VAULTPASS_FILEPATH="${PROJECT_DIR}/.vault_pass"
fi
VAULT_FILEPATH="./vars/vault.yml"

INSTALL_GALAXY_COLLECTIONS=0
UPGRADE_GALAXY_COLLECTIONS=0

USE_SOURCE_COLLECTIONS=0
SOURCE_COLLECTIONS_PATH="${PROJECT_PARENT_DIR}/requirements_collections"

echo "SCRIPT_DIR=[${SCRIPT_DIR}]"
echo "SCRIPT_NAME=[${SCRIPT_NAME}]"
#echo "PLAYBOOK=[${PLAYBOOK}]"
#echo "PROJECT_PARENT_DIR=${PROJECT_PARENT_DIR}"
echo "PROJECT_DIR=${PROJECT_DIR}"

echo "VAULT_FILEPATH=${VAULT_FILEPATH}"

ANSIBLE_COLLECTION_REQUIREMENTS="${PROJECT_DIR}/collections/requirements.yml"
#ANSIBLE_COLLECTION_REQUIREMENTS="${PROJECT_DIR}/tests/requirements.yml"

export LOCAL_COLLECTIONS_PATH="${HOME}/.ansible/collections"
#export LOCAL_COLLECTIONS_PATH="${HOME}/.ansible"
#export ANSIBLE_ROLES_PATH=./
#export ANSIBLE_COLLECTIONS_PATH="${LOCAL_COLLECTIONS_PATH}:${PROJECT_DIR}/collections:${PROJECT_PARENT_DIR}/requirements_collections"
#export ANSIBLE_COLLECTIONS_PATH="${PROJECT_DIR}/collections:${PROJECT_PARENT_DIR}/requirements_collections"
#export ANSIBLE_COLLECTIONS_PATH="${PROJECT_PARENT_DIR}/requirements_collections"
#export ANSIBLE_COLLECTIONS_PATH="${PROJECT_DIR}/collections"
#export ANSIBLE_COLLECTIONS_PATH="${PROJECT_DIR}/collections:${LOCAL_COLLECTIONS_PATH}"
export ANSIBLE_COLLECTIONS_PATH="${LOCAL_COLLECTIONS_PATH}"

if [[ "${USE_SOURCE_COLLECTIONS}" -eq 1 ]]; then
  export ANSIBLE_COLLECTIONS_PATH=${SOURCE_COLLECTIONS_PATH}:${ANSIBLE_COLLECTIONS_PATH}
fi

#export ANSIBLE_DEBUG=1
export ANSIBLE_KEEP_REMOTE_FILES=1
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

## ref: https://github.com/ansible/ansible/issues/79557#issuecomment-1344168449
#export ANSIBLE_GALAXY_IGNORE=true
#export GALAXY_IGNORE_CERTS=true

function install_galaxy_collections() {

  echo "==> ansible-galaxy --version"
  ansible-galaxy --version

    ## ref: https://github.com/ansible/ansible/issues/79557#issuecomment-1344168449
  echo "==> Install Galaxy collection requirements"
#  GALAXY_INSTALL_CMD=("env ANSIBLE_GALAXY_IGNORE=true env GALAXY_IGNORE_CERTS=true")
#  GALAXY_INSTALL_CMD+=("ansible-galaxy collection install")
#  GALAXY_INSTALL_CMD+=("--ignore-certs")
#  GALAXY_INSTALL_CMD+=("--force")

  GALAXY_INSTALL_CMD=("ansible-galaxy collection install")
  if [[ "${UPGRADE_GALAXY_COLLECTIONS}" -eq 1 ]]; then
    GALAXY_INSTALL_CMD+=("--upgrade")
  fi
  GALAXY_INSTALL_CMD+=("-r ${ANSIBLE_COLLECTION_REQUIREMENTS}")
  GALAXY_INSTALL_CMD+=("-p ${LOCAL_COLLECTIONS_PATH}")

  echo "==> ${GALAXY_INSTALL_CMD[*]}"
  eval "${GALAXY_INSTALL_CMD[*]}"

}

function main() {
  PLAYBOOK_ARGS=("${PLAYBOOK_DEFAULT}")
  if [ $# -gt 0 ]; then
    PLAYBOOK_ARGS=("$@")
  fi
  echo "==> PLAYBOOK_ARGS[*]=${PLAYBOOK_ARGS[*]}"

  rm -f ./ansible.log

  ## ref: https://stackoverflow.com/questions/40684543/how-to-make-python-use-ca-certificates-from-mac-os-truststore
  CERT_PATH=$(python -m certifi)
  export SSL_CERT_FILE=${CERT_PATH}
  export REQUESTS_CA_BUNDLE=${CERT_PATH}

  if [[ "${INSTALL_GALAXY_COLLECTIONS}" -eq 1 || "${UPGRADE_GALAXY_COLLECTIONS}" -eq 1 ]]; then
    install_galaxy_collections
  fi
  echo "==> ansible-galaxy collection list"
  ansible-galaxy collection list

  echo "==> ansible --version"
  ansible --version

  PLAYBOOK_CMD=("ansible-playbook")
#  PLAYBOOK_CMD+=("-e @${TEST_VARS_FILE}")
  PLAYBOOK_CMD+=("-e @${VAULT_FILEPATH}")
  PLAYBOOK_CMD+=("--vault-id ${VAULT_ID}@${VAULTPASS_FILEPATH}")
  PLAYBOOK_CMD+=("${PLAYBOOK_ARGS[@]}")

  echo "==> ${PLAYBOOK_CMD[*]}"
  eval "${PLAYBOOK_CMD[*]}"

}

main "$@"
