#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/" && git rev-parse --show-toplevel )"

echo "SCRIPT_DIR=[${SCRIPT_DIR}]"
echo "PROJECT_DIR=${PROJECT_DIR}"

ansible-playbook -i "${PROJECT_DIR}/inventory/prod/hosts.ini" \
  "${PROJECT_DIR}/tests/test-inventory-update-hosts.yml" \
  --vault-password-file ~/.vault_pass
