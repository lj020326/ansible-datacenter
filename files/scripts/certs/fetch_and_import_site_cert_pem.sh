#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$0")"
echo "SCRIPT_DIR=[${SCRIPT_DIR}]"

#${SCRIPT_DIR}/validate_ssl_endpoint.sh -c ${CREDS} -p ${CONTEXT_PATH} ${TARGET_HOST} ${TARGET_PORT}
cmd="${SCRIPT_DIR}/import_site_cert.sh ${@}"
echo "${cmd}"
${cmd}
