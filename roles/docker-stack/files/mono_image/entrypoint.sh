#!/bin/bash

export CACERTS_FILE=${CACERTS_FILE-"/config/certs/ca-certificates.crt"}

if [ ! -f "${CACERTS_FILE}" ]; then
  echo "Using image ca-certificates..."
else
  echo "Synchronizing ca-certificates from ${CACERTS_FILE}"
  cert-sync ${CACERTS_FILE}
fi

exec /init
