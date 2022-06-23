#!/bin/sh

PROJECT_DIR="$( git rev-parse --show-toplevel )"
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

echo "PROJECT_DIR=${PROJECT_DIR}"

echo "Test 01 - CSV"
python -m library.export_dicts "${SCRIPT_DIR}/export_dicts.test1.args.json" | jq

#echo "Test 02 - Markdown"
#python -m library.export_dicts "${SCRIPT_DIR}/export_dicts.test2.args.json" | jq
#
#echo "Test 03 - CSV with headers"
#python -m library.export_dicts "${SCRIPT_DIR}/export_dicts.test3.args.json" | jq
#
#echo "Test 04 - Markdown with headers"
#python -m library.export_dicts "${SCRIPT_DIR}/export_dicts.test4.args.json" | jq
