#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ANSIBLE_DATACENTER_REPO="$(cd "$SCRIPT_DIR/" && git rev-parse --show-toplevel)"

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
  RUN_ANSIBLE_COMMAND_ARRAY+=("-i ${ANSIBLE_INVENTORY_DIR}");
  RUN_ANSIBLE_COMMAND_ARRAY+=("-m debug");
  RUN_ANSIBLE_COMMAND_ARRAY+=("-a var=\"${ANSIBLE_VARIABLE_NAME}\"");
  RUN_ANSIBLE_COMMAND_ARRAY+=("${ANSIBLE_INVENTORY_HOST}");
  local RUN_ANSIBLE_COMMAND="${RUN_ANSIBLE_COMMAND_ARRAY[*]}";
  echo "${RUN_ANSIBLE_COMMAND}";
  eval "${RUN_ANSIBLE_COMMAND}"
}

ansible_debug_variable "${@}"
