#!/usr/bin/env bash

PLAYBOOK="${1:-bootstrap_vm_template.yml}"

ANSIBLE_STAGING_DIR=/var/tmp/packer-provisioner-ansible-local

export PATH=$PATH:~/.venv/ansible/bin

cd "${ANSIBLE_STAGING_DIR}" || exit

#ANSIBLE_COLLECTIONS_PATH="${ANSIBLE_COLLECTIONS_PATH}":"${ANSIBLE_STAGING_DIR}/galaxy_collections" \
#  PATH=${PATH}:~/.venv/ansible/bin \
#  ansible-galaxy collection install \
#    -r requirements.packer.yml \
#    -p galaxy_collections

PLAYBOOK_CMD=("ANSIBLE_COLLECTIONS_PATH=${ANSIBLE_COLLECTIONS_PATH}:${ANSIBLE_STAGING_DIR}/galaxy_collections")
PLAYBOOK_CMD+=("PATH=${PATH}:~/.venv/ansible/bin")
PLAYBOOK_CMD+=("ansible-playbook ${PLAYBOOK}")
PLAYBOOK_CMD+=("--tag vm-template")
PLAYBOOK_CMD+=("--vault-password-file=~/.vault_pass")
PLAYBOOK_CMD+=("-e @./vars/vault.yml")
PLAYBOOK_CMD+=("-c local")
#PLAYBOOK_CMD+=("-i xenv_hosts.yml")

echo "==> ${PLAYBOOK_CMD[*]}"
if ! eval "${PLAYBOOK_CMD[*]}"; then
  echo "Error: Ansible playbook execution failed"
  exit 1
fi
