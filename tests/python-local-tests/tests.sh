#!/bin/bash

TEST_TARGET=$1

PROJECT_DIR="$( git rev-parse --show-toplevel )"
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

echo "PROJECT_DIR=${PROJECT_DIR}"

TEST_SIZE=$(ls -1 "${SCRIPT_DIR}/${TEST_TARGET}/" | wc -l)

echo "TEST_SIZE=${TEST_SIZE}"

for ((i=1; i<=$TEST_SIZE; i++))
do
  echo "Running Test $i ==> python -m library.${TEST_TARGET} ${SCRIPT_DIR}/${TEST_TARGET}/test${i}.args.json"
  python -m "library.${TEST_TARGET}" "${SCRIPT_DIR}/${TEST_TARGET}/test${i}.args.json" | jq
done
