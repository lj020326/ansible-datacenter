#!/usr/bin/env bash

## ref: https://superuser.com/questions/97201/how-to-save-a-remote-server-ssl-certificate-locally-as-a-file
## ref: https://serverfault.com/questions/661978/displaying-a-remote-ssl-certificate-details-using-cli-tools
site=${1:-heimdall.media.johnson.int:443}

echo "site=${site}"

IFS=':' read -r -a array <<< "${site}"
host=${array[0]}
port=${array[1]}

CERT_DIR=${HOME}/.certs

mkdir -p ${CERT_DIR}

openssl s_client -showcerts \
    -servername ${host} \
    -connect ${site} </dev/null 2>/dev/null \
	| openssl x509 -outform PEM > ${CERT_DIR}/${host}.pem

## ref: https://serverfault.com/questions/722563/how-to-make-firefox-trust-system-ca-certificates?newreg=9c67967e3aa248f489c8c9b2cc4ac776
#certutil -addstore Root ${CERT_DIR}/${host}.pem

## ref: https://superuser.com/questions/1031444/importing-pem-certificates-on-windows-7-on-the-command-line/1032179
certutil –addstore -enterprise –f "Root" ${CERT_DIR}/${host}.pem
