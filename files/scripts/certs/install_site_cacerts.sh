#!/usr/bin/env bash

## ref: https://stackoverflow.com/questions/3685548/java-keytool-easy-way-to-add-server-cert-from-url-port
## ref: https://superuser.com/questions/97201/how-to-save-a-remote-server-ssl-certificate-locally-as-a-file
## ref: https://serverfault.com/questions/661978/displaying-a-remote-ssl-certificate-details-using-cli-tools

#set -x


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "SCRIPT_DIR=[${SCRIPT_DIR}]"

SCRIPT_NAME=$(basename $0)
SCRIPT_NAME="${SCRIPT_NAME%.*}"
logFile="${SCRIPT_NAME}.log"

INSTALL_JDK_CACERT=0

SITE_LIST_DEFAULT="
media.johnson.int:5000
media.johnson.int
admin.dettonville.int
pypi.python.org
files.pythonhosted.org
bootstrap.pypa.io
galaxy.ansible.com
"

#SITE_LIST_DEFAULT="
#pypi.python.org:443
#files.pythonhosted.org:443
#bootstrap.pypa.io:443
#galaxy.ansible.com:443
#"

__SITE_LIST="${CA_SITE_LIST:-${SITE_LIST_DEFAULT}}"

### functions followed by main

writeToLog() {
  echo -e "==> ${1}" | tee -a "${logFile}"
  #    echo -e "${1}" >> "${logFile}"
}


if [[ "$UNAME" != "cygwin" && "$UNAME" != "msys" ]]; then
  if [ "$EUID" -ne 0 ]; then
    echo "Must run this script as root. run 'sudo $SCRIPT_NAME'"
    exit
  fi
fi

## https://stackoverflow.com/questions/26988262/best-way-to-find-the-os-name-and-version-on-a-unix-linux-platform#26988390
UNAME=$(uname -s | tr "[:upper:]" "[:lower:]")
PLATFORM=""
DISTRO=""

CACERT_TRUST_DIR=/etc/pki/ca-trust/extracted
CACERT_BUNDLE=${CACERT_TRUST_DIR}/openssl/ca-bundle.trust.crt
CACERT_TRUST_FORMAT="pem"

## ref: https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
case "${UNAME}" in
    linux*)
      LINUX_OS_DIST=$(lsb_release -a | tr "[:upper:]" "[:lower:]")
      PLATFORM=Linux
      case "${LINUX_OS_DIST}" in
        *ubuntu* | *debian*)
          # Debian Family
          #CACERT_TRUST_DIR=/usr/ssl/certs
          #CACERT_BUNDLE=${CACERT_TRUST_DIR}/ca-bundle.crt
#          CACERT_TRUST_DIR=/etc/ssl/certs
          CACERT_TRUST_DIR=/usr/local/share/ca-certificates/
          CACERT_BUNDLE=${CACERT_TRUST_DIR}/ca-certificates.crt
          DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
          CACERT_TRUST_COMMAND="update-ca-certificates"
          CACERT_TRUST_FORMAT="crt"
          ;;
        *redhat* | *centos* | *fedora* )
          # RedHat Family
          #CACERT_TRUST_DIR=/etc/pki/tls/certs
          #CACERT_TRUST_DIR=/etc/pki/ca-trust/extracted/openssl
          #CACERT_BUNDLE=${CACERT_TRUST_DIR}/ca-bundle.trust.crt
          #CACERT_TRUST_DIR=/etc/pki/ca-trust/extracted/pem
          CACERT_TRUST_DIR=/etc/pki/ca-trust/source/anchors/
          CACERT_BUNDLE=${CACERT_TRUST_DIR}/tls-ca-bundle.pem
          DISTRO=$(cat /etc/system-release)
          CACERT_TRUST_COMMAND="update-ca-trust extract"
          CACERT_TRUST_FORMAT="pem"
          ;;
        *)
          # Otherwise, use release info file
          CACERT_TRUST_DIR=/usr/ssl/certs
          CACERT_BUNDLE=${CACERT_TRUST_DIR}/ca-bundle.crt
          DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
          CACERT_TRUST_COMMAND="update-ca-certificates"
          CACERT_TRUST_FORMAT="pem"
      esac
      ;;
    darwin*)
      PLATFORM=DARWIN
      CACERT_TRUST_DIR=/etc/ssl
      CACERT_BUNDLE=${CACERT_TRUST_DIR}/cert.pem
      ;;
    cygwin* | mingw64* | mingw32* | msys*)
      PLATFORM=MSYS
      ## https://packages.msys2.org/package/ca-certificates?repo=msys&variant=x86_64
      CACERT_TRUST_DIR=/etc/pki/ca-trust/extracted
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
writeToLog "CACERT_BUNDLE=${CACERT_BUNDLE}"
writeToLog "CACERT_TRUST_COMMAND=${CACERT_TRUST_COMMAND}"

function get_java_keystore() {
  ## default jdk location
  if [ -z "$JAVA_HOME" ]; then
    ## ref: https://stackoverflow.com/questions/394230/how-to-detect-the-os-from-a-bash-script
    if [[ "$UNAME" == "darwin"* ]]; then
      JAVA_HOME=$(/usr/libexec/java_home)
    elif [[ "$UNAME" == "cygwin" || "$UNAME" == "msys" ]]; then
      JAVA_HOME=$(/usr/libexec/java_home)
      #        else
      #                # Unknown.
    fi
  fi
  CERT_DIR=${JAVA_HOME}/lib/security
  if [ ! -d $CERT_DIR ]; then
    CERT_DIR=${JAVA_HOME}/jre/lib/security
  fi

  #echo "CERT_DIR=[$CERT_DIR]"
  JAVA_CACERTS="$CERT_DIR/cacerts"

  echo "${JAVA_CACERTS}"
}

function get_host_cert() {
  local HOST=$1
  local PORT=$2
  local CACERTS_SRC=$3

  writeToLog "Fetching certs from host:port ${HOST}:${PORT}"

  if [ -z "$HOST" ]; then
    writeToLog "ERROR: Please specify the server name to import the certificate in from, eventually followed by the port number, if other than 443."
    exit 1
  fi

  set -e

  if [ -e "$CACERTS_SRC/$ALIAS.pem" ]; then
    rm -f $CACERTS_SRC/$ALIAS.pem
  fi

  ## ref: https://stackoverflow.com/questions/9450120/openssl-hangs-and-does-not-exit
  writeToLog "Fetching *.crt format certs from host:port ${HOST}:${PORT}"
  FETCH_CRT_CERT_COMMAND="echo QUIT | openssl s_client -connect ${HOST}:${PORT} 1>${CACERTS_SRC}/${ALIAS}.crt"
  writeToLog "FETCH_CRT_CERT_COMMAND=${FETCH_CRT_CERT_COMMAND}"
  eval "${FETCH_CRT_CERT_COMMAND}"

  writeToLog "Fetching *.pem format certs from host:port ${HOST}:${PORT}"
#  echo QUIT | openssl s_client -showcerts -servername ${HOST} -connect ${HOST}:${PORT} </dev/null 2>/dev/null \
#  	| openssl x509 -outform PEM > $CACERTS_SRC/$ALIAS.pem

  FETCH_PEM_CERT_COMMAND="echo QUIT | openssl s_client -showcerts -servername ${HOST} -connect ${HOST}:${PORT} </dev/null 2>/dev/null \
  	| openssl x509 -outform PEM > $CACERTS_SRC/$ALIAS.pem"
  writeToLog "FETCH_PEM_CERT_COMMAND=${FETCH_PEM_CERT_COMMAND}"
  eval "${FETCH_PEM_CERT_COMMAND}"

  writeToLog "Extracting certs from cert chain for ${HOST}:${PORT}"
  ## ref: https://unix.stackexchange.com/questions/368123/how-to-extract-the-root-ca-and-subordinate-ca-from-a-certificate-chain-in-linux
  openssl s_client -showcerts -verify 5 -connect $HOST:$PORT </dev/null | awk -v certdir=$CACERTS_SRC '/BEGIN/,/END/{ if(/BEGIN/){a++}; out="cert"a".crt"; print >(certdir "/" out)}' && \
  for cert in ${CACERTS_SRC}/cert*.crt; do
    #    nameprefix=$(echo "${cert%.*}")
    nameprefix="${cert%.*}"
    newname="${nameprefix}".$(openssl x509 -noout -subject -in $cert | sed -n 's/\s//g; s/^.*CN=\(.*\)$/\1/; s/[ ,.*]/_/g; s/__/_/g; s/^_//g;p')."${CACERT_TRUST_FORMAT}"
    #    mv $cert $CACERTS_SRC/$newname
    mv "${cert}" "${newname}"
  done

}

function import_jdk_cert() {
  KEYSTORE=$1
  local CACERTS_SRC=$2

  writeToLog "Adding certs to keystore at [${KEYSTORE}]"

  if $KEYTOOL -cacerts -list -keystore "$KEYSTORE" -storepass "${KEYSTORE_PASS}" -alias "${ALIAS}" >/dev/null; then
    writeToLog "Key with alias ${ALIAS} already found, removing old one..."
    if $KEYTOOL -cacerts -delete -alias "${ALIAS}" -keystore "${KEYSTORE}" -storepass "${KEYSTORE_PASS}" >"${TMP_OUT}"; then
      :
    else
      writeToLog "ERROR: Unable to remove the existing certificate for $ALIAS ($?)"
      cat "${TMP_OUT}"
      exit 1
    fi
  fi

  {
    writeToLog "Keytool importing pem formatted cert"
#    KEYTOOL_COMMAND="${KEYTOOL} -import -trustcacerts -noprompt -cacerts \
#      -keystore ${KEYSTORE} \
#      -storepass ${KEYSTORE_PASS} \
#      -alias ${ALIAS} \
#      -file ${CACERTS_SRC}/${ALIAS}.pem"
#      writeToLog "KEYTOOL_COMMAND=${KEYTOOL_COMMAND}"
    KEYTOOL_COMMAND="${KEYTOOL} -import -trustcacerts -noprompt \
      -keystore ${KEYSTORE} \
      -storepass ${KEYSTORE_PASS} \
      -alias ${ALIAS} \
      -file ${CACERTS_SRC}/${ALIAS}.pem"
      writeToLog "KEYTOOL_COMMAND=${KEYTOOL_COMMAND}"
      ${KEYTOOL_COMMAND}
  } || { # catch
    writeToLog "*** Failed to import pem - so try importing the crt formatted cert instead..."
    writeToLog "Keytool importing crt formatted cert"
    KEYTOOL_COMMAND="${KEYTOOL} -import -trustcacerts -noprompt \
      -keystore ${KEYSTORE} \
      -storepass ${KEYSTORE_PASS} \
      -alias ${ALIAS} \
      -file ${CACERTS_SRC}/${ALIAS}.crt"
      writeToLog "KEYTOOL_COMMAND=${KEYTOOL_COMMAND}"
      ${KEYTOOL_COMMAND}
  }

  #    if ${KEYTOOL} -import -trustcacerts -noprompt -keystore ${KEYSTORE} -storepass ${KEYSTORE_PASS} -alias ${ALIAS} -file ${CACERTS_SRC}/${ALIAS}.pem >$TMP_OUT
  if [ $? ]; then
    :
  else
    writeToLog "ERROR: Unable to import the certificate for $ALIAS ($?)"
    cat $TMP_OUT
    exit 1
  fi

}

install_site_cert() {
  SITE=$1
  INSTALL_JDK_CACERT=${2-0}

  KEYSTORE_PASS=${3:-"changeit"}
  KEYTOOL=keytool

  #DATE=`date +&%%m%d%H%M%S`
  DATE=$(date +%Y%m%d)

  writeToLog "SITE=${SITE}"

  IFS=':' read -r -a array <<< "${SITE}"
  HOST=${array[0]}
  PORT=${array[1]:-443}

  writeToLog "Running for HOST=[$HOST] PORT=[$PORT] KEYSTORE_PASS=[$KEYSTORE_PASS]..."

  ENDPOINT="${HOST}:${PORT}"
  ALIAS="${HOST}:${PORT}"

  if [[ "$UNAME" == "cygwin" || "$UNAME" == "msys" ]]; then
    ALIAS="${HOST}_${PORT}"
  fi

  ## ref: https://knowledgebase.garapost.com/index.php/2020/06/05/how-to-get-ssl-certificate-fingerprint-and-serial-number-using-openssl-command/
  ## ref: https://stackoverflow.com/questions/13823706/capture-multiline-output-as-array-in-bash
  CERT_INFO=($(echo QUIT | openssl s_client -connect $HOST:$PORT </dev/null 2>/dev/null | openssl x509 -serial -fingerprint -sha256 -noout | cut -d"=" -f2 | sed s/://g))
  CERT_SERIAL=${CERT_INFO[0]}
  CERT_FINGERPRINT=${CERT_INFO[1]}

  #CACERTS_SRC=${HOME}/.cacerts/$ALIAS/$DATE
  #CACERTS_SRC=${HOME}/.cacerts/$ALIAS/$CERT_SERIAL/$CERT_FINGERPRINT
  CACERTS_SRC=/tmp/.cacerts/$ALIAS/$CERT_SERIAL/$CERT_FINGERPRINT

  if [ ! -d $CACERTS_SRC ]; then
    mkdir -p $CACERTS_SRC
  fi

  TMP_OUT=/tmp/${SCRIPT_NAME}.output

  writeToLog "Get host cert"
  get_host_cert "${HOST}" "${PORT}" "${CACERTS_SRC}"

  if [ "$INSTALL_JDK_CACERT" -ne 0 ]; then
    writeToLog "Get default java JDK cacert location"
    #JDK_KEYSTORE=$CERT_DIR/cacerts
    JDK_KEYSTORE=$(get_java_keystore)

    if [ ! -e "${JDK_KEYSTORE}" ]; then
      writeToLog "JDK_KEYSTORE [$JDK_KEYSTORE] not found!"
      exit 1
    else
      writeToLog "JDK_KEYSTORE found at [$JDK_KEYSTORE]"
    fi

    ### Now build list of cacert targets to update
    writeToLog "updating JDK certs at [$JDK_KEYSTORE]..."
    import_jdk_cert "$JDK_KEYSTORE" "${CACERTS_SRC}"

    # FYI: the default keystore is located in ~/.keystore
    DEFAULT_KEYSTORE="~/.keystore"
    if [ -f $DEFAULT_KEYSTORE ]; then
      writeToLog "updating default certs at [$DEFAULT_KEYSTORE]..."
      import_jdk_cert $DEFAULT_KEYSTORE
    fi
  fi

  writeToLog "Adding cert to the system keychain.."
  if [[ "$UNAME" == "darwin"* ]]; then
#    writeToLog "Adding cert to macOS system keychain"
#    #    sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" "/private/tmp/securly_SHA-256.crt"
#    sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" ${CACERTS_SRC}/${ALIAS}.crt

    writeToLog "Adding site cert to the current user's trust cert chain"
#    sudo security add-trusted-cert -d -r trustRoot -k "${HOME}/Library/Keychains/login.keychain" ${CACERTS_SRC}/${ALIAS}.crt

    # shellcheck disable=SC2206
    certs=(${CACERTS_SRC}/cert*.pem)
    ca_root_cert=${certs[-1]}
    writeToLog "Add the site root cert to the current user's trust cert chain ==> [${ca_root_cert}]"

    MACOS_CACERT_TRUST_COMMAND="security add-trusted-cert -d -r trustRoot -k ${HOME}/Library/Keychains/login.keychain ${ca_root_cert}"
    writeToLog "MACOS_CACERT_TRUST_COMMAND=${MACOS_CACERT_TRUST_COMMAND}"
    eval "${MACOS_CACERT_TRUST_COMMAND}"

##    for cert in ${CACERTS_SRC}/cert*.pem; do
##    files=(/var/logs/foo*.log)
##    for ((i=${#files[@]}-1; i>=0; i--)); do
#    certs=(${CACERTS_SRC}/cert*.pem)
#    for ((cert=${#certs[@]}-1; i>=0; i--)); do
#      writeToLog "Adding cert to the system keychain ==> [${cert}]"
#      #    nameprefix=$(echo "${cert%.*}")
#      nameprefix="${cert%.*}"
#
#      ## ref: https://apple.stackexchange.com/questions/80623/import-certificates-into-the-system-keychain-via-the-command-line
##      sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" ${cert}
#
#      ## To add to only the current user's trust cert chain
#      sudo security add-trusted-cert -d -r trustRoot -k "${HOME}/Library/Keychains/login.keychain" ${cert}
#
#    done

  elif [[ "$UNAME" == "cygwin" || "$UNAME" == "msys" ]]; then
    ## ref: https://docs.microsoft.com/en-us/troubleshoot/windows-server/identity/valid-root-ca-certificates-untrusted
#    ROOT_CERT=$(ls -1 ${CACERTS_SRC}/cert*.pem | sort -nr | head -1)
    ROOT_CERT=$(find ${CACERTS_SRC}/ -name cert*.pem | sort -nr | head -1)

    WIN_CACERT_TRUST_COMMAND="certutil -addstore root ${ROOT_CERT}"
    writeToLog "WIN_CACERT_TRUST_COMMAND=${WIN_CACERT_TRUST_COMMAND}"
    eval "${WIN_CACERT_TRUST_COMMAND}"

    ## ref: https://serverfault.com/questions/722563/how-to-make-firefox-trust-system-ca-certificates?newreg=9c67967e3aa248f489c8c9b2cc4ac776
    #certutil -addstore Root ${CERT_DIR}/${HOST}.pem
    ## ref: https://superuser.com/questions/1031444/imPORTing-pem-certificates-on-windows-7-on-the-command-line/1032179
    #certutil –addstore -enterprise –f "Root" "${CERT_DIR}/${HOST}.pem"
    #certutil –addstore -enterprise –f "Root" "${ROOT_CERT}"

  elif [[ "$UNAME" == "linux"* ]]; then
    ROOT_CERT=$(find ${CACERTS_SRC}/ -name cert*.${CACERT_TRUST_FORMAT} | sort -nr | head -1)
    writeToLog "copy ROOT_CERT ${ROOT_CERT} to CACERT_TRUST_DIR=${CACERT_TRUST_DIR}"
#    cp -p "${ROOT_CERT}" "${CACERT_TRUST_DIR}/"
    cp -p "${CACERTS_SRC}"/*."${CACERT_TRUST_FORMAT}" "${CACERT_TRUST_DIR}/"
    writeToLog "CACERT_TRUST_COMMAND=${CACERT_TRUST_COMMAND}"
    eval "${CACERT_TRUST_COMMAND}"
  fi

  writeToLog "**** Finished ****"
}


echo '==> Add site certs to cacerts'
IFS=$'\n'
for SITE in ${__SITE_LIST}
do

  install_site_cert "${SITE}" "${INSTALL_JDK_CACERT}"

done
