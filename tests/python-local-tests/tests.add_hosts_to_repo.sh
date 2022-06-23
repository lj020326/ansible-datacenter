#!/bin/sh

PROJECT_DIR="$( git rev-parse --show-toplevel )"
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

echo "PROJECT_DIR=${PROJECT_DIR}"
echo "SCRIPT_DIR=${SCRIPT_DIR}"

cd "${PROJECT_DIR}"

echo "Test 01 - yaml"
python -m library.add_hosts_to_repo "${SCRIPT_DIR}/add_hosts_to_repo.test1.args.json" | jq

