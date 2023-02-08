#!/usr/bin/env bash

TARGET_HOST=${1:-media.johnson.int}
TARGET_PORT=${2:-5000}
#CONTEXT_PATH=${3:-"v2/"}
CONTEXT_PATH=${3:-"v2/_catalog"}

ENDPOINT=${TARGET_HOST}:${TARGET_PORT}

DOCKER_REGISTRY_USERNAME=${DOCKER_REGISTRY_USERNAME:-"testuser"}
DOCKER_REGISTRY_PASSWORD=${DOCKER_REGISTRY_PASSWORD:-"testpassword"}

CREDS=${DOCKER_REGISTRY_USERNAME}:${DOCKER_REGISTRY_PASSWORD}
CURL_CRED_ARGS="-u ${CREDS}"

SCRIPT_DIR="$(dirname "$0")"
source ${SCRIPT_DIR}/get_curl_ca_opts.sh

echo "UNAME=${UNAME}: PLATFORM=[${PLATFORM}] DISTRO=[${DISTRO}]"

echo "*******************"
echo "getting cert info from endpoint ${ENDPOINT}"
#openssl s_client -servername ${TARGET_HOST} -connect ${ENDPOINT} | openssl x509 -text -noout
#openssl s_client -servername ${TARGET_HOST} -connect ${ENDPOINT} | openssl x509 -text
openssl s_client -servername ${TARGET_HOST} -connect ${ENDPOINT} < /dev/null 2>/dev/null | openssl x509 -text -noout

## ref: https://stackoverflow.com/questions/7885785/using-openssl-to-get-the-certificate-from-a-server
#openssl s_client -connect ${ENDPOINT} -key our_private_key.pem -showcerts -cert our_server-signed_cert.pem

echo "*******************"
echo "*******************"
echo "*******************"
echo "performing curl without cert validation on endpoint ${ENDPOINT}"
echo "curl -u ${CREDS} -vkIsS https://${ENDPOINT}/${CONTEXT_PATH}"
curl -u ${CREDS} -vkIsS https://${ENDPOINT}/${CONTEXT_PATH}

echo "*******************"
echo "*******************"
echo "*******************"
echo "performing curl with cert validation on endpoint ${ENDPOINT}"
## ref: https://stackoverflow.com/questions/11548336/openssl-verify-return-code-20-unable-to-get-local-issuer-certificate/39536777
#echo "curl -u ${CREDS} ${CURL_CA_OPTS} -vIsS https://${ENDPOINT}/${CONTEXT_PATH}"
#curl -u ${CREDS} ${CURL_CA_OPTS} -vIsS https://${ENDPOINT}/${CONTEXT_PATH}

echo "curl -u ${CREDS} ${CURL_CA_OPTS} -vs https://${ENDPOINT}/${CONTEXT_PATH} | jq"
curl -u ${CREDS} ${CURL_CA_OPTS} -vs https://${ENDPOINT}/${CONTEXT_PATH} | jq
