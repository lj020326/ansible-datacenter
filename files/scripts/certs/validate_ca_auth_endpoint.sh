#!/usr/bin/env bash

TARGET_HOST=${1:-media.johnson.int}
TARGET_PORT=${2:-5000}
#CONTEXT_PATH=${3:-"v2/"}
CONTEXT_PATH=${3:-"v2/_catalog"}

ENDPOINT=${TARGET_HOST}:${TARGET_PORT}

USERNAME=${4:-"testuser"}
PASSWORD=${5:-"testpassword"}

CREDS=${USERNAME}:${PASSWORD}
CURL_CRED_ARGS="-u ${CREDS}"

UNAME=$(/bin/uname -s | tr "[:upper:]" "[:lower:]")
PLATFORM=""
DISTRO=""

#CACERT_TRUST_DIR=/etc/ssl/certs
#CACERT_TRUST_DIR=/etc/pki/ca-trust/extracted/pem
#CACERT=${CACERT_TRUST_DIR}/tls-ca-bundle.pem
#CACERT_TRUST_DIR=/etc/pki/ca-trust/extracted/openssl
#CACERT=${CACERT_TRUST_DIR}/ca-bundle.trust.crt
CACERT_TRUST_DIR=/etc/pki/ca-trust/extracted
CACERT=${CACERT_TRUST_DIR}/openssl/ca-bundle.trust.crt

## ref: https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
case "${UNAME}" in
    linux*)
      PLATFORM=Linux
      if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
          CACERT_TRUST_DIR=/etc/pki/tls/certs
          CACERT=${CACERT_TRUST_DIR}/ca-bundle.crt
          DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
      # Otherwise, use release info file
      elif [ -f /etc/system-release ]; then
          CACERT_TRUST_DIR=/usr/ssl/certs
          CACERT=${CACERT_TRUST_DIR}/ca-bundle.crt
          DISTRO=$(cat /etc/system-release)
      # Otherwise, use release info file
      else
          CACERT_TRUST_DIR=/usr/ssl/certs
          CACERT=${CACERT_TRUST_DIR}/ca-bundle.crt
          DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
      fi
      ;;
    darwin*)
      PLATFORM=DARWIN;;
    cygwin*)
      PLATFORM=CYGWIN;;
    mingw64*)
      PLATFORM=MINGW64;;
    mingw32*)
      PLATFORM=MINGW32;;
    msys*)
      PLATFORM=MSYS;;
    *)
      PLATFORM="UNKNOWN:${UNAME}"
esac

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
#echo "curl -u ${CREDS} --capath ${CACERT_TRUST_DIR} --cacert ${CACERT} -vIsS https://${ENDPOINT}/${CONTEXT_PATH}"
#curl -u ${CREDS} --capath ${CACERT_TRUST_DIR} --cacert ${CACERT} -vIsS https://${ENDPOINT}/${CONTEXT_PATH}

echo "curl -u ${CREDS} --capath ${CACERT_TRUST_DIR} --cacert ${CACERT} -vs https://${ENDPOINT}/${CONTEXT_PATH} | jq"
curl -u ${CREDS} --capath ${CACERT_TRUST_DIR} --cacert ${CACERT} -vs https://${ENDPOINT}/${CONTEXT_PATH} | jq
