#!/usr/bin/env bash

env PATH=$PATH:~/.venv/ansible/bin \
  ansible-playbook bootstrap-vm-template.yml \
    --limit vm_template \
    --vault-password-file=~/.vault_pass \
    -e @./vars/vault.yml \
    -c local \
    -i hosts.yml
