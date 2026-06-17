#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
#ANSIBLE_DATACENTER_REPO="$(cd "$SCRIPT_DIR/" && git rev-parse --show-toplevel)"
ANSIBLE_DATACENTER_REPO="${SCRIPT_DIR}"
ANSIBLE_INVENTORY_PATH="inventory/PROD"

ensure_ansible_path() {
  # If ansible is already in the PATH, we are good to go
  if command -v ansible &> /dev/null; then
    return 0
  fi

  # Define potential lookup paths in order of preference
  local check_paths=(
    "${HOME}/.venv/ansible/bin"
    "${HOME}/.pyenv/shims"
  )

  for path_dir in "${check_paths[@]}"; do
    if [ -x "${path_dir}/ansible" ]; then
      export PATH="${path_dir}:${PATH}"
      return 0
    fi
  done

  # If we reach this point, ansible wasn't found anywhere
  echo "Error: 'ansible' command not found in PATH or standard virtual environments." >&2
  exit 1
}

ansible_debug_variable() {
  local ANSIBLE_INVENTORY_HOST=${1:-"control01"};
  local ANSIBLE_VARIABLE_NAME=${2:-"group_names"};

  local RUN_ANSIBLE_COMMAND_ARRAY=();
  RUN_ANSIBLE_COMMAND_ARRAY+=("ansible");
  if [ -f "${ANSIBLE_DATACENTER_REPO}/.vault_pass" ]; then
      RUN_ANSIBLE_COMMAND_ARRAY+=("--vault-password-file ${ANSIBLE_DATACENTER_REPO}/.vault_pass");
  else
      if [ -f "${HOME}/.vault_pass" ]; then
          RUN_ANSIBLE_COMMAND_ARRAY+=("--vault-password-file ${HOME}/.vault_pass");
      fi;
  fi;
  RUN_ANSIBLE_COMMAND_ARRAY+=("-e @${ANSIBLE_DATACENTER_REPO}/vars/vault.yml");
  if [ -f "${ANSIBLE_DATACENTER_REPO}/vars/test-vars.yml" ]; then
      RUN_ANSIBLE_COMMAND_ARRAY+=("-e @${ANSIBLE_DATACENTER_REPO}/vars/test-vars.yml");
  fi;
  RUN_ANSIBLE_COMMAND_ARRAY+=("-i ${ANSIBLE_INVENTORY_PATH}");
  RUN_ANSIBLE_COMMAND_ARRAY+=("-m debug");
  RUN_ANSIBLE_COMMAND_ARRAY+=("-a var=\"${ANSIBLE_VARIABLE_NAME}\"");
  RUN_ANSIBLE_COMMAND_ARRAY+=("${ANSIBLE_INVENTORY_HOST}");
  local RUN_ANSIBLE_COMMAND="${RUN_ANSIBLE_COMMAND_ARRAY[*]}";
  echo "${RUN_ANSIBLE_COMMAND}";
  eval "${RUN_ANSIBLE_COMMAND}"
}

# Ensure Ansible is available before executing the main function
ensure_ansible_path
ansible_debug_variable "${@}"
