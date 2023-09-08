#!/usr/bin/env bash

################
## ref: https://github.com/lj020326/ansible-datacenter/blob/main/files/scripts/docker-registry/validate-registry-endpoint.sh
## ref: https://github.com/lj020326/ansible-datacenter/tree/main/docs/docker/how-the-docker-pull-command-works-under-the-covers-with-http-headers-to-illustrate-the-process.md
################

#TARGET_HOST=${1:-media.example.int}
#TARGET_PORT=${2:-5000}
TARGET_HOST=${1:-registry-1.docker.io}
TARGET_PORT=${2:-443}
DOCKER_REGISTRY_USERNAME=${3:-""}
DOCKER_REGISTRY_PASSWORD=${4:-""}

#CONTEXT_PATH=${3:-"v2/"}
CONTEXT_PATH=${3:-"v2/_catalog"}

ENDPOINT=${TARGET_HOST}:${TARGET_PORT}

if [ "${DOCKER_REGISTRY_USERNAME}" != "" ];then
  CURL_CREDS=${DOCKER_REGISTRY_USERNAME}:${DOCKER_REGISTRY_PASSWORD}
fi

SCRIPT_DIR="$(dirname "$0")"
source ${SCRIPT_DIR}/get-curl-ca-opts.sh

echo "UNAME=${UNAME}: PLATFORM=[${PLATFORM}] DISTRO=[${DISTRO}]"

echo "*******************"
echo "getting cert info from endpoint ${ENDPOINT}"
#openssl s_client -servername ${TARGET_HOST} -connect ${ENDPOINT} | openssl x509 -text -noout
#openssl s_client -servername ${TARGET_HOST} -connect ${ENDPOINT} | openssl x509 -text
openssl s_client -servername ${TARGET_HOST} -connect ${ENDPOINT} < /dev/null 2>/dev/null | openssl x509 -text -noout

## ref: https://stackoverflow.com/questions/7885785/using-openssl-to-get-the-certificate-from-a-server
#openssl s_client -connect ${ENDPOINT} -key our_private_key.pem -showcerts -cert our_server-signed_cert.pem

curlCmdNoSslVerify="curl"
if [[ -n ${CURL_CREDS} ]]; then
  curlCmdNoSslVerify+=" -u ${CURL_CREDS}"
fi
curlCmdNoSslVerify+=" -vkIsS https://${ENDPOINT}/${CONTEXT_PATH}"

echo "*******************"
echo "*******************"
echo "*******************"
echo "performing curl without cert validation on endpoint ${ENDPOINT}"
echo "curlCmdNoSslVerify=${curlCmdNoSslVerify}"
eval "${curlCmdNoSslVerify}"

curlCmd="curl"
if [[ -n ${CURL_CREDS} ]]; then
  curlCmd+=" -u ${CURL_CREDS}"
fi
curlCmd+=" ${CURL_CA_OPTS}"
curlCmd+=" -vs https://${ENDPOINT}/${CONTEXT_PATH} | jq"

echo "*******************"
echo "*******************"
echo "*******************"
echo "performing curl with cert validation on endpoint ${ENDPOINT}"
## ref: https://stackoverflow.com/questions/11548336/openssl-verify-return-code-20-unable-to-get-local-issuer-certificate/39536777
echo "curlCmd=${curlCmd}"
eval "${curlCmd}"
