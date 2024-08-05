#!/usr/bin/env bash

PLAYBOOK="${1:-bootstrap_vm_template.yml}"

ANSIBLE_STAGING_DIR=/var/tmp/packer-provisioner-ansible-local

export PATH=$PATH:~/.venv/ansible/bin

cd "${ANSIBLE_STAGING_DIR}"

#ANSIBLE_COLLECTIONS_PATH="${ANSIBLE_COLLECTIONS_PATH}":"${ANSIBLE_STAGING_DIR}/galaxy_collections" \
#  PATH=${PATH}:~/.venv/ansible/bin \
#  ansible-galaxy collection install \
#    -r requirements.packer.yml \
#    -p galaxy_collections

ANSIBLE_COLLECTIONS_PATH="${ANSIBLE_COLLECTIONS_PATH}:${ANSIBLE_STAGING_DIR}/galaxy_collections" \
  PATH="${PATH}:~/.venv/ansible/bin" \
  ansible-playbook "${PLAYBOOK}" \
    --tag vm-template \
    --vault-password-file=~/.vault_pass \
    -e @./vars/vault.yml \
    -c local \
    -i xenv_hosts.yml
