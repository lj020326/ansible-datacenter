#!/usr/bin/env bash

#TARGET_HOST=${1:-download.docker.com}
#TARGET_PORT=${2:-443}

TARGET_HOST=${1:-media.johnson.int}
TARGET_PORT=${2:-5000}

ENDPOINT_NAME=${TARGET_HOST}.${TARGET_PORT}
ENDPOINT=${TARGET_HOST}:${TARGET_PORT}

FETCH_CERT_DIR=./

## ref: https://stackoverflow.com/questions/26590439/how-to-add-an-enterprise-certificate-authority-ca-to-git-on-cygwin-and-some-l
#curl -sL https://${ENDPOINT}/ > ${CERT_IMPORT_DIR}/ca-certificates.${ENDPOINT_NAME}.crt
#update-ca-trust

#echo | openssl s_client -showcerts -servername ${TARGET_HOST} -connect ${ENDPOINT} 2>/dev/null \
#  | awk '/-----BEGIN CERTIFICATE-----/, /-----END CERTIFICATE-----/' >> ${FETCH_CERT_DIR}/${ENDPOINT_NAME}.crt

## ref: https://stackoverflow.com/questions/9450120/openssl-hangs-and-does-not-exit
echo QUIT | openssl s_client -showcerts -servername ${TARGET_HOST} -connect ${ENDPOINT} | \
  openssl x509 -outform PEM > ${FETCH_CERT_DIR}/${ENDPOINT_NAME}.crt

