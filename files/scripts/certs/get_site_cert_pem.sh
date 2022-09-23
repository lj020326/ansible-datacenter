#!/usr/bin/env bash

## ref: https://superuser.com/questions/97201/how-to-save-a-remote-server-ssl-certificate-locally-as-a-file
## ref: https://serverfault.com/questions/661978/displaying-a-remote-ssl-certificate-details-using-cli-tools
site=${1:-heimdall.media.johnson.int:443}

echo "site=${site}"

IFS=':' read -r -a array <<< "${site}"
host=${array[0]}
port=${array[1]}

openssl s_client -showcerts \
    -servername ${host} \
    -connect ${site} </dev/null 2>/dev/null \
	| openssl x509 -outform PEM > ${host}.pem

