#!/usr/bin/env bash

## ref: https://serverfault.com/questions/661978/displaying-a-remote-ssl-certificate-details-using-cli-tools
site=${1:-gitea.admin.dettonville.int:443}

echo "site=${site}"

IFS=':' read -r -a array <<< "${site}"
host=${array[0]}
port=${array[1]}

## ref: https://stackoverflow.com/questions/7885785/using-openssl-to-get-the-certificate-from-a-server
#openssl s_client -showcerts \
#    -servername ${host} \
#    -connect ${site} 2>/dev/null \
#    | openssl x509 -inform pem -noout -text

openssl s_client -showcerts \
    -servername ${host} \
    -connect ${site} 2>/dev/null \
    | openssl x509 -noout -text
