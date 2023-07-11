#!/usr/bin/env bash

#UNAME=$(/bin/uname -s | tr "[:upper:]" "[:lower:]")
UNAME=$(uname -s | tr "[:upper:]" "[:lower:]")
PLATFORM=""
DISTRO=""

CACERT_TRUST_DIR=/etc/pki/ca-trust/extracted
CACERT_TRUST_IMPORT_DIR=/etc/pki/ca-trust/source/anchors
CACERT_BUNDLE=${CACERT_TRUST_DIR}/openssl/ca-bundle.trust.crt
CACERT_TRUST_FORMAT="pem"

## ref: https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
case "${UNAME}" in
    linux*)
      if type "lsb_release" > /dev/null; then
        LINUX_OS_DIST=$(lsb_release -a | tr "[:upper:]" "[:lower:]")
      else
        LINUX_OS_DIST=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr "[:upper:]" "[:lower:]")
      fi
      PLATFORM=Linux
      case "${LINUX_OS_DIST}" in
        *ubuntu* | *debian*)
          # Debian Family
          #CACERT_TRUST_DIR=/usr/ssl/certs
          CACERT_TRUST_DIR=/etc/ssl/certs
          CACERT_TRUST_IMPORT_DIR=/usr/local/share/ca-certificates
          CACERT_BUNDLE=${CACERT_TRUST_DIR}/ca-certificates.crt
          DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
          CACERT_TRUST_COMMAND="update-ca-certificates"
          CACERT_TRUST_FORMAT="crt"
          ;;
        *redhat* | *centos* | *fedora* )
          # RedHat Family
          CACERT_TRUST_DIR=/etc/pki/tls/certs
          #CACERT_TRUST_IMPORT_DIR=/etc/pki/ca-trust/extracted/openssl
          #CACERT_BUNDLE=${CACERT_TRUST_DIR}/ca-bundle.trust.crt
          #CACERT_TRUST_DIR=/etc/pki/ca-trust/extracted/pem
          CACERT_TRUST_IMPORT_DIR=/etc/pki/ca-trust/source/anchors
          CACERT_BUNDLE=${CACERT_TRUST_DIR}/tls-ca-bundle.pem
          DISTRO=$(cat /etc/system-release)
          CACERT_TRUST_COMMAND="update-ca-trust extract"
          CACERT_TRUST_FORMAT="pem"
          ;;
        *)
          # Otherwise, use release info file
          CACERT_TRUST_DIR=/usr/ssl/certs
          CACERT_TRUST_IMPORT_DIR=/etc/pki/ca-trust/source/anchors
          CACERT_BUNDLE=${CACERT_TRUST_DIR}/ca-bundle.crt
          DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
          CACERT_TRUST_COMMAND="update-ca-certificates"
          CACERT_TRUST_FORMAT="pem"
      esac
      ;;
    darwin*)
      PLATFORM=DARWIN
      CACERT_TRUST_DIR=/etc/ssl
      CACERT_TRUST_IMPORT_DIR=/usr/local/share/ca-certificates
      CACERT_BUNDLE=${CACERT_TRUST_DIR}/cert.pem
      ;;
    cygwin* | mingw64* | mingw32* | msys*)
      PLATFORM=MSYS
      ## https://packages.msys2.org/package/ca-certificates?repo=msys&variant=x86_64
      CACERT_TRUST_DIR=/etc/pki/ca-trust/extracted
      CACERT_TRUST_IMPORT_DIR=/etc/pki/ca-trust/source/anchors
      CACERT_BUNDLE=${CACERT_TRUST_DIR}/openssl/ca-bundle.trust.crt
      ;;
    *)
      PLATFORM="UNKNOWN:${UNAME}"
esac

writeToLog "UNAME=${UNAME}"
writeToLog "LINUX_OS_DIST=${OS_DIST}"
writeToLog "PLATFORM=[${PLATFORM}]"
writeToLog "DISTRO=[${DISTRO}]"
writeToLog "CACERT_TRUST_DIR=${CACERT_TRUST_DIR}"
writeToLog "CACERT_TRUST_IMPORT_DIR=${CACERT_TRUST_IMPORT_DIR}"
writeToLog "CACERT_BUNDLE=${CACERT_BUNDLE}"
writeToLog "CACERT_TRUST_COMMAND=${CACERT_TRUST_COMMAND}"

CURL_CA_OPTS="--capath ${CACERT_TRUST_DIR} --cacert ${CACERT_BUNDLE}"
echo "==> CURL_CA_OPTS=${CURL_CA_OPTS}"
