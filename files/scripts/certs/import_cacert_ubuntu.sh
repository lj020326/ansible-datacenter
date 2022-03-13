#!/usr/bin/env bash

#TARGET_HOST=${1:-download.docker.com}
#TARGET_PORT=${2:-443}

TARGET_HOST=${1:-registry.johnson.int}
TARGET_PORT=${2:-5000}

ENDPOINT_NAME=${TARGET_HOST}-${TARGET_PORT}
ENDPOINT=${TARGET_HOST}:${TARGET_PORT}

CERT_IMPORT_DIR=/usr/local/share/ca-certificates

sudo -i
curl -sL https://${ENDPOINT}/ > ${CERT_IMPORT_DIR}/ca-certificates.${ENDPOINT_NAME}.crt
#echo | openssl s_client -showcerts -servername ${TARGET_HOST} -connect ${ENDPOINT} 2>/dev/null \
#  | awk '/-----BEGIN CERTIFICATE-----/, /-----END CERTIFICATE-----/' >> ${CERT_IMPORT_DIR}/ca-certificates.${ENDPOINT_NAME}.crt
update-ca-certificates

