#!/usr/bin/env bash

# Enable strict mode for better error handling
set -euo pipefail

# Trap to clean up SSH agent and temporary files on exit
cleanup() {
  if [ -n "${SSH_AGENT_PID:-}" ]; then
    echo "==> Stopping SSH agent (PID: $SSH_AGENT_PID)"
    eval "$(ssh-agent -k)" >/dev/null 2>&1
  fi
  test "${KEEP_TEMP_DIR:-0}" = 1 || rm -rf "${TEMP_DIR:-}"
  rm -f "${TEMP_VARS:-}" "${TEMP_RENDERED_KEY:-}" "${TEMP_KEY:-}"
}
trap cleanup EXIT

# Requirements have to be installed prior to running ansible-playbook
# because plugins and requirements are loaded before the task runs
# pip install -r requirements.txt

VERSION="2025.9.20"

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
TEST_VARS_FILE="test-vars.yml"

INSTALL_GALAXY_COLLECTIONS=0
UPGRADE_GALAXY_COLLECTIONS=1

USE_SOURCE_COLLECTIONS=0
SOURCE_COLLECTIONS_PATH="${REPO_PARENT_DIR}/requirements_collections"

echo "SCRIPT_DIR=[${SCRIPT_DIR}]"
echo "SCRIPT_NAME=[${SCRIPT_NAME}]"
echo "REPO_PARENT_DIR=${REPO_PARENT_DIR}"
echo "REPO_DIR=${REPO_DIR}"
echo "VAULT_FILEPATH=${VAULT_FILEPATH}"
echo "VAULT_ID=${VAULT_ID}"

ANSIBLE_COLLECTION_REQUIREMENTS="${REPO_DIR}/collections/requirements.yml"
#ANSIBLE_COLLECTION_REQUIREMENTS="${REPO_DIR}/collections/requirements.test.yml"

export LOCAL_COLLECTIONS_PATH="${HOME}/.ansible/collections"
#export LOCAL_COLLECTIONS_PATH="${HOME}/.ansible"
#export ANSIBLE_ROLES_PATH=./
#export ANSIBLE_COLLECTIONS_PATH="${LOCAL_COLLECTIONS_PATH}:${REPO_DIR}/collections:${REPO_PARENT_DIR}/requirements_collections"
#export ANSIBLE_COLLECTIONS_PATH="${REPO_DIR}/collections:${REPO_PARENT_DIR}/requirements_collections"
#export ANSIBLE_COLLECTIONS_PATH="${REPO_PARENT_DIR}/requirements_collections"
#export ANSIBLE_COLLECTIONS_PATH="${REPO_DIR}/collections"
#export ANSIBLE_COLLECTIONS_PATH="${REPO_DIR}/collections:${LOCAL_COLLECTIONS_PATH}"
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

# SSH agent setup
start_ssh_agent() {
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
  # Render ansible_ssh_private_key using Ansible to resolve templates
  TEMP_RENDERED_KEY=$(mktemp)
  set +e
  ansible localhost -m debug -a "var=ansible_ssh_private_key" -e "@${VAULT_FILEPATH}" --vault-id "${VAULT_ID}@${VAULTPASS_FILEPATH}" > "${TEMP_RENDERED_KEY}.out" 2> "${TEMP_RENDERED_KEY}.err"
  RENDER_EXIT=$?
  set -e
  if [ $RENDER_EXIT -ne 0 ]; then
    echo "Error: Failed to render ansible_ssh_private_key:"
    cat "${TEMP_RENDERED_KEY}.err"
    rm -f "${TEMP_RENDERED_KEY}" "${TEMP_RENDERED_KEY}.out" "${TEMP_RENDERED_KEY}.err"
    return 1
  fi
  # Extract the rendered key from debug output
  TEMP_KEY=$(mktemp)
  grep '"ansible_ssh_private_key":' "${TEMP_RENDERED_KEY}.out" | sed 's/.*"ansible_ssh_private_key": "\(.*\)".*/\1/' | sed 's/\\n/\n/g' > "$TEMP_KEY" 2> "${TEMP_KEY}.err"
  if [ ! -s "$TEMP_KEY" ]; then
    echo "Warning: Failed to extract rendered key or key is empty"
    cat "${TEMP_KEY}.err"
    rm -f "${TEMP_RENDERED_KEY}" "${TEMP_RENDERED_KEY}.out" "${TEMP_RENDERED_KEY}.err" "$TEMP_KEY" "${TEMP_KEY}.err"
    return 1
  fi
  rm -f "${TEMP_RENDERED_KEY}.out" "${TEMP_RENDERED_KEY}.err" "${TEMP_KEY}.err"
  # Validate and process the key
  python3 - <<EOF
import re
with open('$TEMP_KEY', 'r') as f:
    key_content = f.read()
print("Extracted key length:", len(key_content))
print("Key preview:", key_content[:100])
# Validate key format
if re.match(r'^-{5}BEGIN.*PRIVATE KEY-{5}', key_content) and re.search(r'-{5}END.*PRIVATE KEY-{5}\n?$', key_content):
    print("Key format valid")
else:
    print("Invalid key format: does not match BEGIN/END PRIVATE KEY")
    import sys
    sys.exit(1)
EOF
  if [ $? -ne 0 ]; then
    echo "Warning: Invalid SSH key format after rendering"
    rm -f "$TEMP_KEY"
    return 1
  fi
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
      echo "Warning: Invalid SSH key format in ansible_ssh_private_key"
      rm -f "$TEMP_KEY"
      return 1
    fi
  else
    echo "Warning: Empty or missing SSH key in ansible_ssh_private_key"
    rm -f "$TEMP_KEY"
    return 1
  fi
}

# Install Galaxy collections if needed
install_galaxy_collections() {
  echo "==> ansible-galaxy --version"
  ansible-galaxy --version

  ## ref: https://github.com/ansible/ansible/issues/79557#issuecomment-1344168449
  echo "==> Install Galaxy collection requirements"
#  GALAXY_INSTALL_CMD=("env ANSIBLE_GALAXY_IGNORE=true env GALAXY_IGNORE_CERTS=true")
#  GALAXY_INSTALL_CMD=("ansible-galaxy" "collection" "install")
#  GALAXY_INSTALL_CMD+=("--ignore-certs")
#  GALAXY_INSTALL_CMD+=("--force")

  GALAXY_INSTALL_CMD=("ansible-galaxy" "collection" "install")
  if [[ "${UPGRADE_GALAXY_COLLECTIONS}" -eq 1 ]]; then
    GALAXY_INSTALL_CMD+=("--upgrade")
  fi
  GALAXY_INSTALL_CMD+=("-r" "${ANSIBLE_COLLECTION_REQUIREMENTS}")
  GALAXY_INSTALL_CMD+=("-p" "${LOCAL_COLLECTIONS_PATH}")

  if [[ "${UPGRADE_GALAXY_COLLECTIONS}" -eq 1 ]]; then
    GALAXY_INSTALL_CMD+=("--clear-response-cache")
  fi

  echo "==> ${GALAXY_INSTALL_CMD[*]}"
  if ! eval "${GALAXY_INSTALL_CMD[*]} > /dev/null"; then
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

  # Start SSH agent and load key
  start_ssh_agent || {
    echo "==> Falling back to null SSH key vars (Jenkins-like behavior)"
    TEMP_VARS=$(mktemp)
    cat > "$TEMP_VARS" << EOF
{
  "ansible_ssh_private_key_file": null,
  "ansible_ssh_private_key": null
}
EOF
    PLAYBOOK_ARGS+=("-e" "@$TEMP_VARS")
  }
  # Null inline key vars to force agent usage, mimicking Jenkins
  TEMP_VARS=$(mktemp)
  cat > "$TEMP_VARS" << EOF
{
  "ansible_ssh_private_key_file": null,
  "ansible_ssh_private_key": null
}
EOF
  PLAYBOOK_ARGS+=("-e" "@$TEMP_VARS")
  if [[ "${INSTALL_GALAXY_COLLECTIONS}" -eq 1 || "${UPGRADE_GALAXY_COLLECTIONS}" -eq 1 ]]; then
    install_galaxy_collections
  fi

  echo "==> ansible-galaxy collection list"
  ansible-galaxy collection list

  echo "==> ansible --version"
  ansible --version

  echo "==> Playbook arguments: ${PLAYBOOK_ARGS[*]}"
  PLAYBOOK_CMD=("ansible-playbook")
#  PLAYBOOK_CMD+=("-e" "@${TEST_VARS_FILE}")
  PLAYBOOK_CMD+=("-e" "@${VAULT_FILEPATH}")
  PLAYBOOK_CMD+=("--vault-id" "${VAULT_ID}@${VAULTPASS_FILEPATH}")
#  PLAYBOOK_CMD+=("--vault-password-file" "${VAULTPASS_FILEPATH}")
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
