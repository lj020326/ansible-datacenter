#!/bin/bash

#export CACERTS_FILE=${CACERTS_FILE-"/config/certs/ca-certificates.crt"}
export CACERTS_FILE=${CACERTS_FILE-"/etc/ssl/certs/ca-certificates.crt"}

PATH=$PATH:/shared/bin

if [ ! -f "${CACERTS_FILE}" ]; then
  echo "Using image ca-certificates..."
else
  echo "Synchronizing ca-certificates from ${CACERTS_FILE}"
  cert-sync ${CACERTS_FILE}
fi
