#!/usr/bin/env bash

#UNAME=$(/bin/uname -s | tr "[:upper:]" "[:lower:]")
UNAME=$(uname -s | tr "[:upper:]" "[:lower:]")
PLATFORM=""
DISTRO=""

CACERT_TRUST_DIR=/etc/pki/ca-trust/extracted
CACERT=${CACERT_TRUST_DIR}/openssl/ca-bundle.trust.crt

## ref: https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
case "${UNAME}" in
    linux*)
      PLATFORM=Linux
      if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
          #CACERT_TRUST_DIR=/usr/ssl/certs
          #CACERT=${CACERT_TRUST_DIR}/ca-bundle.crt
          CACERT_TRUST_DIR=/etc/ssl/certs
          CACERT=${CACERT_TRUST_DIR}/ca-certificates.crt
          DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
      # Otherwise, use release info file
      elif [ -f /etc/system-release ]; then
          #CACERT_TRUST_DIR=/etc/pki/tls/certs
          #CACERT_TRUST_DIR=/etc/pki/ca-trust/extracted/openssl
          #CACERT=${CACERT_TRUST_DIR}/ca-bundle.trust.crt
          CACERT_TRUST_DIR=/etc/pki/ca-trust/extracted/pem
          CACERT=${CACERT_TRUST_DIR}/tls-ca-bundle.pem
          DISTRO=$(cat /etc/system-release)
      # Otherwise, use release info file
      else
          CACERT_TRUST_DIR=/usr/ssl/certs
          CACERT=${CACERT_TRUST_DIR}/ca-bundle.crt
          DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
      fi
      ;;
    darwin*)
      PLATFORM=DARWIN
      CACERT_TRUST_DIR=/etc/ssl
      CACERT=${CACERT_TRUST_DIR}/cert.pem
      ;;
    cygwin* | mingw64* | mingw32* | msys*)
      PLATFORM=MSYS
      ## https://packages.msys2.org/package/ca-certificates?repo=msys&variant=x86_64
      CACERT_TRUST_DIR=/etc/pki/ca-trust/extracted
      CACERT=${CACERT_TRUST_DIR}/openssl/ca-bundle.trust.crt
      ;;
    *)
      PLATFORM="UNKNOWN:${UNAME}"
esac

echo "UNAME=${UNAME}: PLATFORM=[${PLATFORM}] DISTRO=[${DISTRO}]"
echo "CACERT_TRUST_DIR=${CACERT_TRUST_DIR}"
echo "CACERT=${CACERT}"

CURL_CA_OPTS="--capath ${CACERT_TRUST_DIR} --cacert ${CACERT}"
echo "CURL_CA_OPTS=${CURL_CA_OPTS}"
