#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/" && git rev-parse --show-toplevel )"

echo "SCRIPT_DIR=[${SCRIPT_DIR}]"
echo "PROJECT_DIR=${PROJECT_DIR}"

ansible-galaxy collection install --upgrade "dettonville.utils" "community.crypto"

PLAYBOOK_CMD="ansible-playbook ${PROJECT_DIR}/tests/test-verify-cert.yml"

echo "${PLAYBOOK_CMD}"
eval "${PLAYBOOK_CMD}"
