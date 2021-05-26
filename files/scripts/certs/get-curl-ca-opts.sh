#!/usr/bin/env bash

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

if [ -f /etc/ssl/certs/ca-certificates.crt ]; then
    CACERT_TRUST_DIR=/etc/ssl/certs
    CACERT=${CACERT_TRUST_DIR}/ca-certificates.crt
elif [ -f /usr/ssl/certs/ca-bundle.crt ]; then
    CACERT_TRUST_DIR=/usr/ssl/certs
    CACERT=${CACERT_TRUST_DIR}/ca-bundle.crt
fi
DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)

## ref: https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
case "${UNAME}" in
    linux*)
      PLATFORM=Linux
      if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
          if [ -f /etc/pki/tls/certs/ca-bundle.crt ]; then
            CACERT_TRUST_DIR=/etc/pki/tls/certs
            CACERT=${CACERT_TRUST_DIR}/ca-bundle.crt
          fi
          DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
      # Otherwise, use release info file
      elif [ -f /etc/system-release ]; then
          if [ -f /usr/ssl/certs/ca-bundle.crt ]; then
            CACERT_TRUST_DIR=/usr/ssl/certs
            CACERT=${CACERT_TRUST_DIR}/ca-bundle.crt
          fi
          DISTRO=$(cat /etc/system-release)
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

CURL_CA_OPTS="--capath ${CACERT_TRUST_DIR} --cacert ${CACERT}"
