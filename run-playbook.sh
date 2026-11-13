#!/usr/bin/env bash

# Enable strict mode for better error handling
set -euo pipefail

# Requirements have to be installed prior to running ansible-playbook
# because plugins and requirements are loaded before the task runs
# pip install -r requirements.txt

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$(basename "$0")"

REPO_DIR="$(cd "$SCRIPT_DIR/" && git rev-parse --show-toplevel)"

## only needed if sourcing local private collections by source instead of galaxy
## NEEDED when there is are updates/changes to the dependent collections
## to be deployed along with the project repo update(s)
#REPO_PARENT_DIR="${REPO_DIR}/.."
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

_INSTALL_GALAXY_COLLECTIONS="${INSTALL_GALAXY_COLLECTIONS:-0}"
_UPGRADE_GALAXY_COLLECTIONS="${UPGRADE_GALAXY_COLLECTIONS:-0}"
_FORCE_GALAXY_COLLECTIONS="${FORCE_GALAXY_COLLECTIONS:-0}"

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

#export ANSIBLE_DEBUG=1
export ANSIBLE_KEEP_REMOTE_FILES=1
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

## ref: https://github.com/ansible/ansible/issues/79557#issuecomment-1344168449
#export ANSIBLE_GALAXY_IGNORE=true
#export GALAXY_IGNORE_CERTS=true

cleanup_tmpdir() {
  test "${KEEP_TEMP_DIR:-0}" = 1 || rm -rf "${TEMP_DIR:-}"
}

# Trap to clean up SSH agent and temporary files on exit
cleanup() {
  if [ -n "${SSH_AGENT_PID:-}" ]; then
    echo "==> Stopping SSH agent (PID: $SSH_AGENT_PID)"
    eval "$(ssh-agent -k)" >/dev/null 2>&1
  fi
  cleanup_tmpdir
  rm -f "${TEMP_VARS:-}" "${TEMP_KEY:-}"
}

# SSH agent setup using ANSIBLE_SSH_PRIVATE_KEY environment variable
start_ssh_agent() {
  if [ -z "${ANSIBLE_SSH_PRIVATE_KEY:-}" ]; then
    echo "Error: ANSIBLE_SSH_PRIVATE_KEY environment variable is not set or empty."
    return 1
  fi

  # Check if a user-managed SSH agent is running
  if [ -n "${SSH_AUTH_SOCK:-}" ] && [ -n "${SSH_AGENT_PID:-}" ] && kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
    echo "==> SSH agent already running (PID: $SSH_AGENT_PID, SOCK: $SSH_AUTH_SOCK)"
  else
    # Start a new agent, overriding any system agent
    unset SSH_AUTH_SOCK SSH_AGENT_PID
    echo "==> Starting new SSH agent"
    eval "$(ssh-agent -s)" || {
      echo "Error: Failed to start SSH agent"
      return 1
    }
  fi
  # Verify SSH agent is usable
  ssh-add -l >/dev/null 2>&1 || echo "==> SSH agent is empty"

  # Write private key from environment variable to a secure temp file
  TEMP_KEY=$(mktemp)
  printf "%s\n" "$ANSIBLE_SSH_PRIVATE_KEY" > "$TEMP_KEY"

  if [ -s "$TEMP_KEY" ]; then
    echo "==> Extracted key preview (first line):"
    head -n 1 "$TEMP_KEY"
    chmod 600 "$TEMP_KEY"
    # Test key validity
    if ssh-keygen -y -P "" -f "$TEMP_KEY" >/dev/null 2>&1; then
      if ssh-add "$TEMP_KEY" 2>/dev/null; then
        echo "==> Successfully added SSH key to agent"
        ssh-add -l
      else
        echo "Warning: Failed to add SSH key to agent (passphrase or format issue?)"
        rm -f "$TEMP_KEY"
        return 1
      fi
    else
      echo "Warning: Invalid SSH key format in ANSIBLE_SSH_PRIVATE_KEY"
      rm -f "$TEMP_KEY"
      return 1
    fi
  else
    echo "Warning: Empty or missing SSH key in ANSIBLE_SSH_PRIVATE_KEY"
    rm -f "$TEMP_KEY"
    return 1
  fi

  trap cleanup EXIT
}

# Install Galaxy collections if needed
function install_galaxy_collections() {
  echo "==> ansible-galaxy --version"
  ansible-galaxy --version

  ## ref: https://github.com/ansible/ansible/issues/79557#issuecomment-1344168449
  echo "==> Install Galaxy collection requirements"
#  GALAXY_INSTALL_CMD=("env ANSIBLE_GALAXY_IGNORE=true")
#  GALAXY_INSTALL_CMD+=("env GALAXY_IGNORE_CERTS=true")
#  GALAXY_INSTALL_CMD=("ansible-galaxy" "collection" "install")
#  GALAXY_INSTALL_CMD+=("--ignore-certs")
#  GALAXY_INSTALL_CMD+=("--force")

  GALAXY_INSTALL_CMD=("ansible-galaxy" "collection" "install")
  if [[ "${_FORCE_GALAXY_COLLECTIONS}" -eq 1 ]]; then
      GALAXY_INSTALL_CMD+=("--force")
  fi

  if [[ "${_UPGRADE_GALAXY_COLLECTIONS}" -eq 1 ]]; then
    GALAXY_INSTALL_CMD+=("--upgrade")
    GALAXY_INSTALL_CMD+=("--clear-response-cache")
  fi
  GALAXY_INSTALL_CMD+=("-r" "${ANSIBLE_COLLECTION_REQUIREMENTS}")
  GALAXY_INSTALL_CMD+=("-p" "${LOCAL_COLLECTIONS_PATH}")

  echo "==> ${GALAXY_INSTALL_CMD[*]}"
  if ! eval "${GALAXY_INSTALL_CMD[*]} > /dev/null"; then
    echo "Error: Failed to install Galaxy collections"
    exit 1
  fi
}

function main() {
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

  if [[ "${_INSTALL_GALAXY_COLLECTIONS}" -eq 1 || "${_UPGRADE_GALAXY_COLLECTIONS}" -eq 1 ]]; then
    install_galaxy_collections
  fi

  echo "==> ANSIBLE_COLLECTIONS_PATH=${ANSIBLE_COLLECTIONS_PATH}"
  echo "==> ansible-galaxy collection list"
  ansible-galaxy collection list

  echo "==> ansible --version"
  ansible --version

  # Start SSH agent and load key from environment variable
  start_ssh_agent

  # Null inline key vars to force agent usage
  TEMP_VARS=$(mktemp)
  cat > "$TEMP_VARS" << EOF
{
  "ansible_ssh_private_key_file": null,
  "ansible_ssh_private_key": null
}
EOF
  PLAYBOOK_ARGS+=("-e" "@$TEMP_VARS")

  echo "==> Playbook arguments: ${PLAYBOOK_ARGS[*]}"

  # Rely on ansible.cfg [defaults] for extra_vars and vault_password_file
  PLAYBOOK_CMD=("ansible-playbook")
  PLAYBOOK_CMD+=("--vault-id" "${VAULT_ID}@${VAULTPASS_FILEPATH}")
#  PLAYBOOK_CMD+=("--vault-password-file" "${VAULTPASS_FILEPATH}")
  PLAYBOOK_CMD+=("-e" "@${VAULT_FILEPATH}")
  if [[ "${#PLAYBOOK_ARGS[@]}" -gt 0 ]]; then
    PLAYBOOK_CMD+=("${PLAYBOOK_ARGS[*]}")
  fi

  echo "==> ${PLAYBOOK_CMD[*]}"
  if ! eval "${PLAYBOOK_CMD[*]}"; then
    echo "Error: Ansible playbook execution failed"
    exit 1
  fi
}

main "$@"
