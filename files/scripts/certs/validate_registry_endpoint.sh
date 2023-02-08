#!/usr/bin/env bash

TARGET_HOST=${1:-media.johnson.int}
TARGET_PORT=${2:-5000}
#CONTEXT_PATH=${3:-"v2/"}
CONTEXT_PATH=${3:-"v2/_catalog"}

DOCKER_REGISTRY_USERNAME=${DOCKER_REGISTRY_USERNAME:-"testuser"}
DOCKER_REGISTRY_PASSWORD=${DOCKER_REGISTRY_PASSWORD:-"testpassword"}

CREDS=${DOCKER_REGISTRY_USERNAME}:${DOCKER_REGISTRY_PASSWORD}

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "SCRIPT_DIR=${SCRIPT_DIR}"

#${SCRIPT_DIR}/validate_ssl_endpoint.sh -c ${CREDS} -p ${CONTEXT_PATH} ${TARGET_HOST} ${TARGET_PORT}
cmd="${SCRIPT_DIR}/validate_ssl_endpoint.sh -c ${CREDS} -p ${CONTEXT_PATH} ${TARGET_HOST} ${TARGET_PORT}"
echo "${cmd}"
${cmd}
