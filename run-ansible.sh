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
#_UPGRADE_GALAXY_COLLECTIONS=1

echo "SCRIPT_DIR=[${SCRIPT_DIR}]"
echo "SCRIPT_NAME=[${SCRIPT_NAME}]"
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
  if [[ "${_UPGRADE_GALAXY_COLLECTIONS}" -eq 1 ]]; then
    GALAXY_INSTALL_CMD+=("--upgrade")
  fi
  GALAXY_INSTALL_CMD+=("-r" "${ANSIBLE_COLLECTION_REQUIREMENTS}")
  GALAXY_INSTALL_CMD+=("-p" "${LOCAL_COLLECTIONS_PATH}")

  if [[ "${_UPGRADE_GALAXY_COLLECTIONS}" -eq 1 ]]; then
    GALAXY_INSTALL_CMD+=("--clear-response-cache")
  fi

  echo "==> ${GALAXY_INSTALL_CMD[*]}"
  if ! eval "${GALAXY_INSTALL_CMD[*]} > /dev/null"; then
    echo "Error: Failed to install Galaxy collections"
    exit 1
  fi
}

usage() {
  retcode=${1-1}
  echo "" 1>&2
  echo "Usage: ${0} [options] [CLI commands]" 1>&2
  echo "" 1>&2
  echo "  Required:" 1>&2
  echo "     command:    ansible [ansible options]" 1>&2
  echo "                 ansible-playbook [ansible-playbook options]" 1>&2
  echo "                 kolla-ansible [kolla-ansible options]" 1>&2
  echo "                 shell_command [shell_command options]" 1>&2
  echo "" 1>&2
  echo "  Examples:" 1>&2
  echo "     ${0} ansible -m ping all"
  echo "     ${0} -r REMOTE_HOST ansible -i inventory/DEV/hosts.ini -m ping"
  echo "     ${0} -R ansible -i inventory/DEV/hosts.ini -m ping"
  echo "     ${0} ansible -i inventory/DEV/hosts.ini all -m ping"
  echo "     ${0} ansible -i inventory/DEV/hosts.ini openstack -m ping"
  echo "     ${0} ansible windows -i inventory/DEV/hosts.ini -m win_ping"
  echo "     ${0} ansible -i inventory/DEV/hosts.ini all -m ping"
  echo "     ${0} ansible-playbook site.yml --tags bootstrap-node --limit admin2"
  echo "     ${0} ansible-playbook site.yml --tags bootstrap-node-network --limit node01"
  echo "     ${0} ansible-playbook site.yml --tags bootstrap-node-mounts --limit media"
  echo "     ${0} ansible-playbook site.yml --tags bootstrap-openstack"
  echo "     ${0} ansible-playbook site.yml --tags bootstrap-openstack-cloud"
  echo "     ${0} ansible-playbook site.yml --tags docker-admin-node"
  echo "     ${0} ansible-playbook site.yml --tags docker-media-node"
  echo "     ${0} ansible-playbook site.yml --tags docker-samba-node"
  echo "     ${0} ansible-playbook site.yml --tags openstack-deploy-node"
  echo "     ${0} ansible-playbook site.yml --tags openstack-osclient"
  echo "     ${0} bash -x scripts/kolla-ansible/init-runonce.sh"
  echo "     ${0} bash -x scripts/kolla-ansible/test_ovs_network.sh"
  echo "     ${0} bash -x scripts/kolla-ansible/test_ovs_networks.sh"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini bootstrap-servers"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini deploy"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini destroy --yes-i-really-really-mean-it"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini post-deploy"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini prechecks"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini pull"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini reconfigure"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini restart"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini stop"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini stop --yes-i-really-really-mean-it"
  echo "     ${0} openstack server create --image cirros --flavor m1.tiny --key-name mykey --network demo-net demo1"
  echo "     ${0} scripts/kolla-ansible/init-runonce.sh"
  exit ${retcode}
}

main() {
  while getopts "t:hx" opt; do
    case "${opt}" in
    h) usage 1 ;;
    \?) usage 2 ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage 3
      ;;
    *)
      usage 4
      ;;
    esac
  done
  shift $((OPTIND - 1))

  if [ $# -eq 0 ]; then
    usage 1
  fi

  RUN_CMD=$1
  shift 1

  RUN_COMMAND_ARGS=()
  if [ $# -gt 0 ]; then
    RUN_COMMAND_ARGS=("$@")
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

  echo "==> ansible-galaxy collection list"
  ansible-galaxy collection list

  echo "==> ansible --version"
  ansible --version

  echo "==> Run command arguments: ${RUN_COMMAND_ARGS[*]}"
  if [[ "${RUN_CMD}" == *"ansible"* ]]; then
    # Start SSH agent and load key
    start_ssh_agent

    # Null inline key vars to force agent usage, mimicking Jenkins
    TEMP_VARS=$(mktemp)
    cat > "$TEMP_VARS" << EOF
{
  "ansible_ssh_private_key_file": null,
  "ansible_ssh_private_key": null
}
EOF

    RUN_COMMAND_ARGS+=("-e" "@$TEMP_VARS")
    RUN_COMMAND_ARGS+=("-e" "@${VAULT_FILEPATH}")
    RUN_COMMAND_ARGS+=("--vault-id" "${VAULT_ID}@${VAULTPASS_FILEPATH}")
#    RUN_COMMAND_ARGS+=("--vault-password-file" "${VAULTPASS_FILEPATH}")
  fi

  RUN_COMMAND_ARGS_WITH_ARGS=("${RUN_CMD}")
  if [[ "${#RUN_COMMAND_ARGS[@]}" -gt 0 ]]; then
    RUN_COMMAND_ARGS_WITH_ARGS+=("${RUN_COMMAND_ARGS[@]}")
  fi

  echo "==> ${RUN_COMMAND_ARGS_WITH_ARGS[*]}"
  if ! eval "${RUN_COMMAND_ARGS_WITH_ARGS[*]}"; then
    echo "Error: Ansible playbook execution failed"
    exit 1
  fi
}

main "$@"
