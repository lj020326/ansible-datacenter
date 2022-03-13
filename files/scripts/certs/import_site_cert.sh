#!/usr/bin/env bash

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "scriptDir=[${scriptDir}]"

#set -x

## ref: https://stackoverflow.com/questions/3685548/java-keytool-easy-way-to-add-server-cert-from-url-port
##

scriptName=$(basename $0)
#scriptName="${0%.*}"
logFile="${scriptName}.log"

if [[ "$OSTYPE" != "cygwin" && "$OSTYPE" != "msys" ]]; then
  if [ "$EUID" -ne 0 ]; then
    echo "Must run this script as root. run 'sudo $SCRIPT_NAME'"
    exit
  fi
fi

#HOST=myhost.example.com
#HOST=artifactory.dev.dettonville.int
#HOST=www.jetbrains.com
#HOST=${1-"repository.dettonville.int"}
#PORT=${2-"443"}

HOST=${1-"archiva.admin.dettonville.int"}
PORT=${2-"8443"}
KEYSTORE_PASS=${3-"changeit"}

#DATE=`date +&%%m%d%H%M%S`
DATE=$(date +%Y%m%d)

KEYTOOL=keytool

ALIAS="${HOST}:${PORT}"

if [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
  ALIAS="${HOST}_${PORT}"
fi

## ref: https://knowledgebase.garapost.com/index.php/2020/06/05/how-to-get-ssl-certificate-fingerprint-and-serial-number-using-openssl-command/
## ref: https://stackoverflow.com/questions/13823706/capture-multiline-output-as-array-in-bash
CERT_INFO=($(openssl s_client -connect $HOST:$PORT </dev/null 2>/dev/null | openssl x509 -serial -fingerprint -sha256 -noout | cut -d"=" -f2 | sed s/://g))
CERT_SERIAL=${CERT_INFO[0]}
CERT_FINGERPRINT=${CERT_INFO[1]}

#CACERTS_SRC=${HOME}/.cacerts/$ALIAS/$DATE
CACERTS_SRC=${HOME}/.cacerts/$ALIAS/$CERT_SERIAL/$CERT_FINGERPRINT

if [ ! -d $CACERTS_SRC ]; then
  mkdir -p $CACERTS_SRC
fi

TMP_OUT=/tmp/${SCRIPT_NAME}.output

### functions followed by main

writeToLog() {
  echo -e "${1}" | tee -a "${logFile}"
  #    echo -e "${1}" >> "${logFile}"
}

function get_java_keystore() {
  ## default jdk location
  if [ -z "$JAVA_HOME" ]; then
    ## ref: https://stackoverflow.com/questions/394230/how-to-detect-the-os-from-a-bash-script
    if [[ "$OSTYPE" == "darwin"* ]]; then
      JAVA_HOME=$(/usr/libexec/java_home)
    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
      JAVA_HOME=$(/usr/libexec/java_home)
      #        else
      #                # Unknown.
    fi
  fi
  CERT_DIR=${JAVA_HOME}/lib/security
  if [ ! -d $CERT_DIR ]; then
    CERT_DIR=${JAVA_HOME}/jre/lib/security
  fi

  #    writeToLog "CERT_DIR=[$CERT_DIR]"

  writeToLog $CERT_DIR/cacerts
}

function get_host_cert() {
  local HOST=$1
  local PORT=$2

  writeToLog "retrieving certs from host:port ${HOST}:${PORT}"

  if [ -z "$HOST" ]; then
    writeToLog "ERROR: Please specify the server name to import the certificate in from, eventually followed by the port number, if other than 443."
    exit 1
  fi

  set -e

  if [ -e "$CACERTS_SRC/$ALIAS.pem" ]; then
    rm -f $CACERTS_SRC/$ALIAS.pem
  fi

  if openssl s_client -connect $HOST:$PORT 1>$CACERTS_SRC/$ALIAS.crt 2>$TMP_OUT </dev/null; then
    :
  else
    cat $CACERTS_SRC/$ALIAS.crt
    cat $TMP_OUT
    exit 1
  fi

  if sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' <$CACERTS_SRC/$ALIAS.crt >$CACERTS_SRC/$ALIAS.pem; then
    :
  else
    writeToLog "ERROR: Unable to extract the certificate from $CACERTS_SRC/$ALIAS.crt ($?)"
    cat $TMP_OUT
    exit 1
  fi

  writeToLog "extracting certs from cert chain for ${HOST}:${PORT}"
  ## ref: https://unix.stackexchange.com/questions/368123/how-to-extract-the-root-ca-and-subordinate-ca-from-a-certificate-chain-in-linux
  openssl s_client -showcerts -verify 5 -connect $HOST:$PORT </dev/null | awk -v certdir=$CACERTS_SRC '/BEGIN/,/END/{ if(/BEGIN/){a++}; out="cert"a".crt"; print >(certdir "/" out)}' && \
  for cert in ${CACERTS_SRC}/cert*.crt; do
    #    nameprefix=$(echo "${cert%.*}")
    nameprefix="${cert%.*}"
    newname=${nameprefix}.$(openssl x509 -noout -subject -in $cert | sed -n 's/\s//g; s/^.*CN=\(.*\)$/\1/; s/[ ,.*]/_/g; s/__/_/g; s/^_//g;p').pem
    #    mv $cert $CACERTS_SRC/$newname
    mv $cert $newname
  done

}

function import_jdk_cert() {
  KEYSTORE=$1

  writeToLog --- Adding certs to keystore at [$KEYSTORE]

  if $KEYTOOL -list -keystore $KEYSTORE -storepass ${KEYSTORE_PASS} -alias $ALIAS >/dev/null; then
    writeToLog "Key of $HOST already found, removing old one..."
    if $KEYTOOL -delete -alias $ALIAS -keystore $KEYSTORE -storepass ${KEYSTORE_PASS} >$TMP_OUT; then
      :
    else
      writeToLog "ERROR: Unable to remove the existing certificate for $ALIAS ($?)"
      cat $TMP_OUT
      exit 1
    fi
  fi

  {
    writeToLog "importing pem"
    ${KEYTOOL} -import -trustcacerts -noprompt -keystore ${KEYSTORE} -storepass ${KEYSTORE_PASS} -alias ${ALIAS} -file ${CACERTS_SRC}/${ALIAS}.pem >$TMP_OUT
  } || { # catch
    writeToLog "*** failed to import pem - so lets try to import the crt instead..."
    ${KEYTOOL} -import -trustcacerts -noprompt -keystore ${KEYSTORE} -storepass ${KEYSTORE_PASS} -alias ${ALIAS} -file ${CACERTS_SRC}/${ALIAS}.pem >$TMP_OUT && ${KEYTOOL} -import -trustcacerts -noprompt -keystore ${KEYSTORE} -storepass ${KEYSTORE_PASS} -alias ${ALIAS} -file ${CACERTS_SRC}/${ALIAS}.crt >$TMP_OUT
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

main() {

  writeToLog "Running for HOST=[$HOST] PORT=[$PORT] KEYSTORE_PASS=[$KEYSTORE_PASS]..."

  writeToLog "Get default java JDK cacert location"
  #JDK_KEYSTORE=$CERT_DIR/cacerts
  JDK_KEYSTORE=$(get_java_keystore)

  if [ ! -e $JDK_KEYSTORE ]; then
    writeToLog "JDK_KEYSTORE [$JDK_KEYSTORE] not found!"
    exit 1
  else
    writeToLog "JDK_KEYSTORE found at [$JDK_KEYSTORE]"
  fi

  writeToLog "Get host cert"
  get_host_cert ${HOST} ${PORT}

  ### Now build list of cacert targets to update
  writeToLog "updating JDK certs at [$JDK_KEYSTORE]..."
  import_jdk_cert $JDK_KEYSTORE

  # FYI: the default keystore is located in ~/.keystore
  DEFAULT_KEYSTORE="~/.keystore"
  if [ -f $DEFAULT_KEYSTORE ]; then
    writeToLog "updating default certs at [$DEFAULT_KEYSTORE]..."
    import_jdk_cert $DEFAULT_KEYSTORE
  fi

  writeToLog "Adding cert to the system keychain.."
  if [[ "$OSTYPE" == "darwin"* ]]; then
#    echo "Adding cert to macOS system keychain"
#    #    sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" "/private/tmp/securly_SHA-256.crt"
#    sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" ${CACERTS_SRC}/${ALIAS}.crt

    echo "Adding site cert to the current user's trust cert chain"
#    sudo security add-trusted-cert -d -r trustRoot -k "${HOME}/Library/Keychains/login.keychain" ${CACERTS_SRC}/${ALIAS}.crt

    certs=(${CACERTS_SRC}/cert*.pem)
    ca_root_cert=${certs[-1]}
    echo "Add the site root cert to the current user's trust cert chain ==> [${ca_root_cert}]"
    sudo security add-trusted-cert -d -r trustRoot -k "${HOME}/Library/Keychains/login.keychain" ${ca_root_cert}

##    for cert in ${CACERTS_SRC}/cert*.pem; do
##    files=(/var/logs/foo*.log)
##    for ((i=${#files[@]}-1; i>=0; i--)); do
#    certs=(${CACERTS_SRC}/cert*.pem)
#    for ((cert=${#certs[@]}-1; i>=0; i--)); do
#      echo "Adding cert to the system keychain ==> [${cert}]"
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

  elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
    ## ref: https://docs.microsoft.com/en-us/troubleshoot/windows-server/identity/valid-root-ca-certificates-untrusted
    ROOT_CERT=$(ls -1 ${CACERTS_SRC}/cert*.pem | sort -nr | head -1)
    certutil -addstore root ${ROOT_CERT}
  fi

  writeToLog "**** Finished ****"
}

main
