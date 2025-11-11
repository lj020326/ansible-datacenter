#!/usr/bin/env bash

# Enable strict mode for better error handling
set -euo pipefail

VERSION="2025.9.20"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$(basename "$0")"
REPO_DIR="$(cd "$SCRIPT_DIR/" && git rev-parse --show-toplevel)"
REPO_PARENT_DIR="$(dirname "${REPO_DIR}")"

VAULTPASS_FILEPATH="${HOME}/.vault_pass"
if [[ -f "${REPO_DIR}/.vault_pass" ]]; then
  VAULTPASS_FILEPATH="${REPO_DIR}/.vault_pass"
fi
if [[ ! -f "${VAULTPASS_FILEPATH}" ]]; then
  echo "Error: Vault password file ${VAULTPASS_FILEPATH} not found"
  exit 1
fi
VAULT_FILEPATH="./vars/vault.yml"
if [[ ! -f "${VAULT_FILEPATH}" ]]; then
  echo "Error: Vault file ${VAULT_FILEPATH} not found"
  exit 1
fi
VAULT_ID="dcc-vault"
TEST_VARS_FILE="test-vars.yml"

INSTALL_GALAXY_COLLECTIONS=0
UPGRADE_GALAXY_COLLECTIONS=0
USE_SOURCE_COLLECTIONS=0
SOURCE_COLLECTIONS_PATH="${REPO_PARENT_DIR}/requirements_collections"

echo "SCRIPT_DIR=[${SCRIPT_DIR}]"
echo "SCRIPT_NAME=[${SCRIPT_NAME}]"
echo "REPO_PARENT_DIR=${REPO_PARENT_DIR}"
echo "REPO_DIR=${REPO_DIR}"
echo "VAULT_FILEPATH=${VAULT_FILEPATH}"
echo "VAULT_ID=${VAULT_ID}"

ANSIBLE_COLLECTION_REQUIREMENTS="${REPO_DIR}/collections/requirements.yml"
export LOCAL_COLLECTIONS_PATH="${HOME}/.ansible/collections"
export ANSIBLE_COLLECTIONS_PATH="${LOCAL_COLLECTIONS_PATH}"
export ANSIBLE_LOG_PATH="./ansible.log"

if [[ "${USE_SOURCE_COLLECTIONS}" -eq 1 ]]; then
  export ANSIBLE_COLLECTIONS_PATH="${SOURCE_COLLECTIONS_PATH}:${ANSIBLE_COLLECTIONS_PATH}"
fi

export ANSIBLE_KEEP_REMOTE_FILES=1
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# Install Galaxy collections if needed
install_galaxy_collections() {
  echo "==> ansible-galaxy --version"
  ansible-galaxy --version
  GALAXY_INSTALL_CMD=("ansible-galaxy" "collection" "install")
  if [[ "${UPGRADE_GALAXY_COLLECTIONS}" -eq 1 ]]; then
    GALAXY_INSTALL_CMD+=("--upgrade")
  fi
  GALAXY_INSTALL_CMD+=("-r" "${ANSIBLE_COLLECTION_REQUIREMENTS}")
  GALAXY_INSTALL_CMD+=("-p" "${LOCAL_COLLECTIONS_PATH}")
  echo "==> ${GALAXY_INSTALL_CMD[*]}"
  if ! eval "${GALAXY_INSTALL_CMD[*]}"; then
    echo "Error: Failed to install Galaxy collections"
    exit 1
  fi
}

main() {
  PLAYBOOK_ARGS=()
  if [ $# -gt 0 ]; then
    PLAYBOOK_ARGS=("$@")
  fi
  rm -f "$ANSIBLE_LOG_PATH"
  # Set SSL certificate paths for Python
  CERT_PATH=$(python3 -m certifi 2>/dev/null || echo "")
  if [ -n "$CERT_PATH" ]; then
    export SSL_CERT_FILE=${CERT_PATH}
    export REQUESTS_CA_BUNDLE=${CERT_PATH}
  else
    echo "==> Warning: certifi module not found, SSL_CERT_FILE not set"
  fi
  if [[ "${INSTALL_GALAXY_COLLECTIONS}" -eq 1 || "${UPGRADE_GALAXY_COLLECTIONS}" -eq 1 ]]; then
    install_galaxy_collections
  fi
  echo "==> ansible-galaxy collection list"
  ansible-galaxy collection list
  echo "==> ansible --version"
  ansible --version
  echo "==> Playbook arguments: ${PLAYBOOK_ARGS[*]}"
  PLAYBOOK_CMD=("ansible-playbook")
  PLAYBOOK_CMD+=("-e" "@${VAULT_FILEPATH}")
  PLAYBOOK_CMD+=("--vault-id" "${VAULT_ID}@${VAULTPASS_FILEPATH}")
  if [[ "${#PLAYBOOK_ARGS[@]}" -gt 0 ]]; then
    PLAYBOOK_CMD+=("${PLAYBOOK_ARGS[@]}")
  fi
  echo "==> ${PLAYBOOK_CMD[*]}"
  if ! eval "${PLAYBOOK_CMD[*]}"; then
    echo "Error: Ansible playbook execution failed"
    exit 1
  fi
}

main "$@"
