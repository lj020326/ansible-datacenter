#!/usr/bin/env bash

## ref: https://stackoverflow.com/questions/3685548/java-keytool-easy-way-to-add-server-cert-from-url-port
## ref: https://superuser.com/questions/97201/how-to-save-a-remote-server-ssl-certificate-locally-as-a-file
## ref: https://serverfault.com/questions/661978/displaying-a-remote-ssl-certificate-details-using-cli-tools

#set -x

VERSION="2024.2.1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "SCRIPT_DIR=[${SCRIPT_DIR}]"

SCRIPT_NAME=$(basename "$0")
SCRIPT_NAME="${SCRIPT_NAME%.*}"
logFile="${SCRIPT_NAME}.log"

INSTALL_JDK_CACERT=1
SETUP_PYTHON_CACERTS_ONLY=0

SITE_LIST_DEFAULT=("pfsense.johnson.int")
SITE_LIST_DEFAULT+=("media.johnson.int:5000")
SITE_LIST_DEFAULT+=("media.johnson.int")
SITE_LIST_DEFAULT+=("admin.dettonville.int")
SITE_LIST_DEFAULT+=("pypi.python.org")
SITE_LIST_DEFAULT+=("files.pythonhosted.org")
SITE_LIST_DEFAULT+=("bootstrap.pypa.io")
SITE_LIST_DEFAULT+=("galaxy.ansible.com")

KEYTOOL=keytool
USER_KEYSTORE="${HOME}/.keystore"

## https://stackoverflow.com/questions/26988262/best-way-to-find-the-os-name-and-version-on-a-unix-linux-platform#26988390
UNAME=$(uname -s | tr "[:upper:]" "[:lower:]")
PLATFORM=""
DISTRO=""

CACERT_TRUST_DIR=/etc/pki/ca-trust/extracted
CACERT_TRUST_IMPORT_DIR=/etc/pki/ca-trust/source/anchors
CACERT_BUNDLE=${CACERT_TRUST_DIR}/openssl/ca-bundle.trust.crt
CACERT_TRUST_FORMAT="pem"

LOG_ERROR=0
LOG_WARN=1
LOG_INFO=2
LOG_TRACE=3
LOG_DEBUG=4

#LOG_LEVEL=${LOG_DEBUG}
LOG_LEVEL=${LOG_INFO}

function logError() {
  if [ $LOG_LEVEL -ge $LOG_ERROR ]; then
  	echo -e "[ERROR]: ==> ${1}"
  fi
}
function logWarn() {
  if [ $LOG_LEVEL -ge $LOG_WARN ]; then
  	echo -e "[WARN ]: ==> ${1}"
  fi
}
function logInfo() {
  if [ $LOG_LEVEL -ge $LOG_INFO ]; then
  	echo -e "[INFO ]: ==> ${1}"
  fi
}
function logTrace() {
  if [ $LOG_LEVEL -ge $LOG_TRACE ]; then
  	echo -e "[TRACE]: ==> ${1}"
  fi
}
function logDebug() {
  if [ $LOG_LEVEL -ge $LOG_DEBUG ]; then
  	echo -e "[DEBUG]: ==> ${1}"
  fi
}

function setLogLevel() {
  local LOGLEVEL=$1

  case "${LOGLEVEL}" in
    ERROR*)
      LOG_LEVEL=$LOG_ERROR
      ;;
    WARN*)
      LOG_LEVEL=$LOG_WARN
      ;;
    INFO*)
      LOG_LEVEL=$LOG_INFO
      ;;
    TRACE*)
      LOG_LEVEL=$LOG_TRACE
      ;;
    DEBUG*)
      LOG_LEVEL=$LOG_DEBUG
      ALWAYS_SHOW_TEST_RESULTS=1
      ;;
    *)
      abort "Unknown loglevel of [${LOGLEVEL}] specified"
  esac

}


function pip_install_certifi() {
  local LOG_PREFIX="pip_install_certifi():"

  PIP_INSTALL_CMD="pip install certifi"
  logInfo "${LOG_PREFIX} ${PIP_INSTALL_CMD}"
  eval "${PIP_INSTALL_CMD}"
}

function get_java_keystore() {
  local LOG_PREFIX="get_java_keystore():"

#  logDebug "${LOG_PREFIX} JAVA_HOME=${JAVA_HOME}"
  ## default jdk location
  if [ -z "${JAVA_HOME}" ]; then
    ## ref: https://stackoverflow.com/questions/394230/how-to-detect-the-os-from-a-bash-script
    if [[ "$UNAME" == "darwin"* ]]; then
      JAVA_HOME=$(/usr/libexec/java_home)
    elif [[ "$UNAME" == "cygwin" || "$UNAME" == "msys" ]]; then
      JAVA_HOME=$(/usr/libexec/java_home)
    fi
  fi

  if [ -d "${JAVA_HOME}" ]; then
    if [ -d "${JAVA_HOME}/lib/security" ]; then
      JDK_CERT_DIR=${JAVA_HOME}/lib/security
    elif [ -d "${JAVA_HOME}/jre/lib/security" ]; then
      JDK_CERT_DIR=${JAVA_HOME}/jre/lib/security
    fi
#    logDebug "${LOG_PREFIX} JDK_CERT_DIR=${JDK_CERT_DIR}"
  fi
  local JAVA_CACERTS="$JDK_CERT_DIR/cacerts"
#  logDebug "${LOG_PREFIX} JAVA_CACERTS=${JAVA_CACERTS}"

  echo "${JAVA_CACERTS}"
}

function get_host_cert() {
  local LOG_PREFIX="get_host_cert():"
  local HOST=$1
  local PORT=$2
  local CACERTS_SRC=$3
  local ALIAS="${HOST}_${PORT}"

  logInfo "${LOG_PREFIX} Fetching certs from host:port ${HOST}:${PORT}"

  if [ -z "$HOST" ]; then
    logError "${LOG_PREFIX} Please specify the server name to import the certificate in from, eventually followed by the port number, if other than 443."
    exit 1
  fi

  set -e

#  local FIND_CERT_FILES_CMD="find ${CACERTS_SRC}/ -name cert*.crt"
#  logInfo "${LOG_PREFIX} [${FIND_CERT_FILES_CMD}]"
#  eval "${FIND_CERT_FILES_CMD}"

  ############
  ## To avoid "ssl alert number 40"
  ## It is usually related to a server with several virtual hosts to serve,
  ## where you need to/should tell which host you want to connect to in order for the TLS handshake to succeed.
  ##
  ## Specify the exact host name you want with -servername parameter.
  ##
  ## ref: https://stackoverflow.com/questions/9450120/openssl-hangs-and-does-not-exit
  ## ref: https://stackoverflow.com/questions/53965049/handshake-failure-ssl-alert-number-40
  logDebug "${LOG_PREFIX} Fetching *.crt format certs from host:port ${HOST}:${PORT}"
#  local FETCH_CRT_CERT_COMMAND="echo QUIT | openssl s_client -connect ${HOST}:${PORT} -servername ${HOST} 1>${CACERTS_SRC}/${ALIAS}.crt"
  local FETCH_CRT_CERT_COMMAND="echo QUIT | openssl s_client -connect ${HOST}:${PORT} -servername ${HOST} </dev/null 2>/dev/null 1>${CACERTS_SRC}/${ALIAS}.crt"
  logInfo "${LOG_PREFIX} [${FETCH_CRT_CERT_COMMAND}]"
  eval "${FETCH_CRT_CERT_COMMAND}"

  logDebug "${LOG_PREFIX} Fetching *.pem format certs from host:port ${HOST}:${PORT}"
  FETCH_PEM_CERT_COMMAND="echo QUIT | openssl s_client -showcerts -servername ${HOST} -connect ${HOST}:${PORT}"
  FETCH_PEM_CERT_COMMAND+=" </dev/null 2>/dev/null | openssl x509 -outform PEM > ${CACERTS_SRC}/${ALIAS}.pem"
  logInfo "${LOG_PREFIX} [${FETCH_PEM_CERT_COMMAND}]"
  eval "${FETCH_PEM_CERT_COMMAND}"

  logInfo "${LOG_PREFIX} Extracting certs from cert chain for ${HOST}:${PORT} "
  ## ref: https://unix.stackexchange.com/questions/368123/how-to-extract-the-root-ca-and-subordinate-ca-from-a-certificate-chain-in-linux
  openssl s_client -showcerts -verify 5 -connect "${HOST}:${PORT}" -servername "${HOST}" </dev/null 2>/dev/null \
    | awk -v certdir="${CACERTS_SRC}" '/BEGIN/,/END/{ if(/BEGIN/){a++}; out="cert"a".crt"; print >(certdir "/" out)}' && \
  for cert in ${CACERTS_SRC}/cert*.crt; do
    #    nameprefix=$(echo "${cert%.*}")
    nameprefix="${cert%.*}"
    logDebug "${LOG_PREFIX} nameprefix for cert ${cert} ==> ${nameprefix}"
    newname="${nameprefix}".$(openssl x509 -noout -subject -in $cert | sed -n 's/\s//g; s/^.*CN=\(.*\)$/\1/; s/[ ,.*]/_/g; s/__/_/g; s/^_//g;p')."${CACERT_TRUST_FORMAT}"
    logInfo "${LOG_PREFIX} cert ==> ${newname}"
    mv "${cert}" "${newname}"
#    cp -p "${cert}" "${newname}"
  done

  ## create cert chain pem for import to java cacerts
  ## ref: https://stackoverflow.com/questions/24563694/jenkins-unable-to-find-valid-certification-path-to-requested-target-error-whil
  local FIND_CERTS_CMD="find ${CACERTS_SRC}/ -name \"cert*.${CACERT_TRUST_FORMAT}\" -type f -exec printf '%s ' {} + | sort"
  logDebug "${LOG_PREFIX} [${FIND_CERTS_CMD}]"
  local SITE_CERT_LIST=$(eval "${FIND_CERTS_CMD}")
  logInfo "${LOG_PREFIX} SITE_CERT_LIST=[${SITE_CERT_LIST}]"
  local CAT_CMD="cat ${SITE_CERT_LIST} > ${CACERTS_SRC}/full_chain.${CACERT_TRUST_FORMAT}"
  logInfo "${LOG_PREFIX} [${CAT_CMD}]"
  eval "${CAT_CMD}"
  openssl x509 -in "${CACERTS_SRC}/full_chain.${CACERT_TRUST_FORMAT}" -out "${CACERTS_SRC}/full_chain_sanitized.${CACERT_TRUST_FORMAT}"

}

function import_jdk_cert() {
  local LOG_PREFIX="import_jdk_cert():"
  local KEYSTORE=$1
  local CACERTS_SRC=$2
  local ALIAS=$3
  local KEYSTORE_PASS=${4:-"changeit"}

  logInfo "${LOG_PREFIX} Adding certs to keystore at [${KEYSTORE}]"

  if $KEYTOOL -cacerts -list -cacerts -storepass "${KEYSTORE_PASS}" -alias "${ALIAS}" >/dev/null; then
    logInfo "${LOG_PREFIX} Key with alias ${ALIAS} already found, removing old one..."
#    CMD_RESULT=$(eval "${KEYTOOL} -delete -alias ${ALIAS} -keystore ${KEYSTORE} -storepass ${KEYSTORE_PASS}")
    CMD_RESULT=$(eval "${KEYTOOL} -delete -alias ${ALIAS} -cacerts -storepass ${KEYSTORE_PASS}")
    RET_STATUS=$?
    if [ "${RET_STATUS}" -eq 0 ]; then
      echo "${CMD_RESULT}"
      :
    else
      logError "${LOG_PREFIX} Unable to remove the existing certificate for ${ALIAS} ($RET_STATUS)"
      echo "${CMD_RESULT}"
      exit 1
    fi
  fi

  logInfo "${LOG_PREFIX} Keytool importing ${CACERT_TRUST_FORMAT} formatted cert"

#    local KEYTOOL_COMMAND="${KEYTOOL} -import -noprompt -trustcacerts -cacerts \
#  local KEYTOOL_COMMAND="${KEYTOOL} -import -noprompt -trustcacerts \
#    -keystore ${KEYSTORE} \
#    -storepass ${KEYSTORE_PASS} \
#    -alias ${ALIAS} \
#    -file ${CACERTS_SRC}/full_chain_sanitized.${CACERT_TRUST_FORMAT}"

  local KEYTOOL_COMMAND="${KEYTOOL} -import -noprompt -cacerts -trustcacerts \
    -storepass ${KEYSTORE_PASS} \
    -alias ${ALIAS} \
    -file ${CACERTS_SRC}/full_chain.${CACERT_TRUST_FORMAT}"

  logInfo "${LOG_PREFIX} KEYTOOL_COMMAND=${KEYTOOL_COMMAND}"
  CMD_RESULT=$(eval "${KEYTOOL_COMMAND}")
  RET_STATUS=$?

  if [ "${RET_STATUS}" -eq 0 ]; then
    echo "${CMD_RESULT}"
    :
  else
    logError "${LOG_PREFIX} Unable to import the certificate for $ALIAS ($RET_STATUS)"
    echo "${CMD_RESULT}"
    exit 1
  fi

}

function install_java_cacerts() {
  local LOG_PREFIX="install_java_cacerts():"
  local CACERTS_SRC=$1
  local ALIAS=$2
  local KEYSTORE_PASS=${3:-"changeit"}

  logInfo "${LOG_PREFIX} Get default java JDK cacert location"

  logInfo "${LOG_PREFIX} JAVA_HOME=${JAVA_HOME}"
  #local JDK_KEYSTORE=$JDK_CERT_DIR/cacerts
  local JDK_KEYSTORE=$(get_java_keystore)
  logInfo "${LOG_PREFIX} JDK_KEYSTORE=${JDK_KEYSTORE}"

  if [ ! -e "${JDK_KEYSTORE}" ]; then
    logInfo "${LOG_PREFIX} JDK_KEYSTORE [$JDK_KEYSTORE] not found!"
    exit 1
  else
    logInfo "${LOG_PREFIX} JDK_KEYSTORE found at [$JDK_KEYSTORE]"
  fi

  ### Now build list of cacert targets to update
  logInfo "${LOG_PREFIX} updating JDK certs at [${JDK_KEYSTORE}]..."
  import_jdk_cert "${JDK_KEYSTORE}" "${CACERTS_SRC}" "${ALIAS}" "${KEYSTORE_PASS}"

  if [ -f "${USER_KEYSTORE}" ]; then
    logInfo "${LOG_PREFIX} updating certs at [$USER_KEYSTORE]..."
    import_jdk_cert "${USER_KEYSTORE}" "${CACERTS_SRC}" "${ALIAS}" "${KEYSTORE_PASS}"
  fi
}

function install_cert_to_truststore() {
  local LOG_PREFIX="install_cert_to_truststore():"
  local HOST=$1
  local PORT=$2
  local CACERTS_SRC=$3
  local KEYSTORE_PASS=${4:-"changeit"}

  if [[ "$UNAME" == "linux"* ]]; then
    local ROOT_CERT=$(find ${CACERTS_SRC}/ -name cert*.${CACERT_TRUST_FORMAT} | sort -nr | head -1)
#    logInfo "${LOG_PREFIX} copy ROOT_CERT ${ROOT_CERT} to CACERT_TRUST_IMPORT_DIR=${CACERT_TRUST_IMPORT_DIR}"
#    cp -p "${ROOT_CERT}" "${CACERT_TRUST_IMPORT_DIR}/"

    local CAT_CMD="cat ${SITE_CERT_LIST} > ${CACERTS_SRC}/full_chain.${CACERT_TRUST_FORMAT}"

    logInfo "${LOG_PREFIX} copy certs to CACERT_TRUST_IMPORT_DIR=${CACERT_TRUST_IMPORT_DIR}"

    local COPY_CMD="cp ${SITE_CERT_LIST} ${CACERT_TRUST_IMPORT_DIR}/"
    logInfo "${LOG_PREFIX} [${COPY_CMD}]"
    eval "${COPY_CMD}"

#    cp -p "${CACERTS_SRC}/"cert*."${CACERT_TRUST_FORMAT}" "${CACERT_TRUST_IMPORT_DIR}/"
    logInfo "${LOG_PREFIX} Running [${CACERT_TRUST_COMMAND}]"
    eval "${CACERT_TRUST_COMMAND}"

  elif [[ "$UNAME" == "darwin"* ]]; then
#    logInfo "${LOG_PREFIX} Adding cert to macOS system keychain"
#    #    sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" "/private/tmp/securly_SHA-256.crt"
#    sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" ${CACERTS_SRC}/${ALIAS}.crt

    logInfo "${LOG_PREFIX} Adding site cert to the current user's trust cert chain"
#    sudo security add-trusted-cert -d -r trustRoot -k "${HOME}/Library/Keychains/login.keychain" ${CACERTS_SRC}/${ALIAS}.crt

    # shellcheck disable=SC2206
    certs=(${CACERTS_SRC}/cert*.pem)
    ca_root_cert=${certs[-1]}
    logInfo "${LOG_PREFIX} Add the site root cert to the current user's trust cert chain ==> [${ca_root_cert}]"

    ## ref: https://apple.stackexchange.com/questions/80623/import-certificates-into-the-system-keychain-via-the-command-line
#    MACOS_CACERT_TRUST_COMMAND="sudo security add-trusted-cert -d -r trustRoot -k ${HOME}/Library/Keychains/login.keychain ${ca_root_cert}"
    MACOS_CACERT_TRUST_COMMAND="sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ${ca_root_cert}"

    logInfo "${LOG_PREFIX} [${MACOS_CACERT_TRUST_COMMAND}]"
    eval "${MACOS_CACERT_TRUST_COMMAND}"

##    for cert in ${CACERTS_SRC}/cert*.pem; do
##    for ((i=${#files[@]}-1; i>=0; i--)); do
#    certs=(${CACERTS_SRC}/cert*.pem)
#    for ((cert=${#certs[@]}-1; i>=0; i--)); do
#      logInfo "${LOG_PREFIX} Adding cert to the system keychain ==> [${cert}]"
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
#    local ROOT_CERT=$(ls -1 ${CACERTS_SRC}/cert*.pem | sort -nr | head -1)
    local ROOT_CERT=$(find ${CACERTS_SRC}/ -name cert*.pem | sort -nr | head -1)

    local WIN_CACERT_TRUST_COMMAND="certutil -addstore root ${ROOT_CERT}"
    logInfo "${LOG_PREFIX} [${WIN_CACERT_TRUST_COMMAND}]"
    eval "${WIN_CACERT_TRUST_COMMAND}"

    ## ref: https://serverfault.com/questions/722563/how-to-make-firefox-trust-system-ca-certificates?newreg=9c67967e3aa248f489c8c9b2cc4ac776
    #certutil -addstore Root ${CERT_DIR}/${HOST}.pem
    ## ref: https://superuser.com/questions/1031444/imPORTing-pem-certificates-on-windows-7-on-the-command-line/1032179
    #certutil –addstore -enterprise –f "Root" "${CERT_DIR}/${HOST}.pem"
    #certutil –addstore -enterprise –f "Root" "${ROOT_CERT}"

  fi

}

function install_site_cert() {
  local LOG_PREFIX="install_site_cert():"
  local SITE=$1
  local INSTALL_JDK_CACERT=${2-0}
  local KEYSTORE_PASS=${3:-"changeit"}

  #local DATE=`date +&%%m%d%H%M%S`
  local DATE=$(date +%Y%m%d)

  logInfo "${LOG_PREFIX} SITE=${SITE}"

  IFS=':' read -r -a array <<< "${SITE}"
  local HOST=${array[0]}
  local PORT=${array[1]:-443}

  logInfo "${LOG_PREFIX} HOST=[$HOST] PORT=[$PORT]"

  local ENDPOINT="${HOST}:${PORT}"
  local ALIAS="${HOST}_${PORT}"

  ## ref: https://knowledgebase.garapost.com/index.php/2020/06/05/how-to-get-ssl-certificate-fingerprint-and-serial-number-using-openssl-command/
  ## ref: https://stackoverflow.com/questions/13823706/capture-multiline-output-as-array-in-bash
#  local CERT_INFO=($(echo QUIT | openssl s_client -connect $HOST:$PORT </dev/null 2>/dev/null | openssl x509 -serial -fingerprint -sha256 -noout | cut -d"=" -f2 | sed s/://g))
  local CERT_INFO=($(echo QUIT | openssl s_client -connect "${HOST}:${PORT}" -servername "${HOST}" </dev/null 2>/dev/null | openssl x509 -serial -fingerprint -sha256 -noout | cut -d"=" -f2 | sed s/://g))
  local CERT_SERIAL=${CERT_INFO[0]}
  local CERT_FINGERPRINT=${CERT_INFO[1]}

  logDebug "${LOG_PREFIX} CERT_SERIAL=${CERT_SERIAL}"
  logDebug "${LOG_PREFIX} CERT_FINGERPRINT=${CERT_FINGERPRINT}"

  #local CACERTS_SRC=${HOME}/.cacerts/$ALIAS/$DATE
  #local CACERTS_SRC=${HOME}/.cacerts/$ALIAS/$CERT_SERIAL/$CERT_FINGERPRINT
#  local CACERTS_SRC=/tmp/.cacerts/$ALIAS/$CERT_SERIAL/$CERT_FINGERPRINT
  local CACERTS_SRC=/tmp/.cacerts/$ALIAS

  logInfo "${LOG_PREFIX} CACERTS_SRC=${CACERTS_SRC}"

  logDebug "${LOG_PREFIX} Recreate tmp cert dir ${CACERTS_SRC}"
  rm -fr "${CACERTS_SRC}"
  mkdir -p "${CACERTS_SRC}"

#  local FIND_CERTS_CMD="find ${CACERTS_SRC}/ -name cert*.crt"
#  logDebug "${LOG_PREFIX} [${FIND_CERTS_CMD}]"
#  eval "${FIND_CERTS_CMD}"

  local TMP_OUT=/tmp/${SCRIPT_NAME}.output

  logDebug "${LOG_PREFIX} Get host cert for ${HOST}:${PORT}"
  get_host_cert "${HOST}" "${PORT}" "${CACERTS_SRC}"

  local FIND_CERTS_CMD="find ${CACERTS_SRC}/ -name \"cert*.${CACERT_TRUST_FORMAT}\" -type f -exec printf '%s ' {} + | sort"
  logDebug "${LOG_PREFIX} [${FIND_CERTS_CMD}]"
  local SITE_CERT_LIST=$(eval "${FIND_CERTS_CMD}")
  logInfo "${LOG_PREFIX} SITE_CERT_LIST=[${SITE_CERT_LIST}]"

  logInfo "${LOG_PREFIX} Adding cert to the system truststore.."
  install_cert_to_truststore "${HOST}" "${PORT}" "${CACERTS_SRC}" "${KEYSTORE_PASS}"

  if [ "$INSTALL_JDK_CACERT" -eq 1 ]; then
    if [ -n "${JAVA_HOME}" ]; then
      install_java_cacerts "${CACERTS_SRC}" "${ALIAS}" "${KEYSTORE_PASS}"
    fi
  fi

  logInfo "${LOG_PREFIX} **** Finished ****"
}

function setup_python_cacerts() {
  local LOG_PREFIX="setup_python_cacerts():"

  ## ref: https://stackoverflow.com/questions/40684543/how-to-make-python-use-ca-certificates-from-mac-os-truststore
  pip_install_certifi

  local PYTHON_SSL_CERT_FILE=$(python3 -m certifi)
  local PYTHON_SSL_CERT_DIR=$(dirname "${PYTHON_SSL_CERT_FILE}")

  logInfo "${LOG_PREFIX} PYTHON_SSL_CERT_DIR=${PYTHON_SSL_CERT_DIR}"
  if [[ -n "${PYTHON_SSL_CERT_DIR}" && -n "${PYTHON_SSL_CERT_FILE}" ]]; then

    if [[ "$UNAME" == "darwin"* ]]; then
      ## ref: https://stackoverflow.com/questions/40684543/how-to-make-python-use-ca-certificates-from-mac-os-truststore
      MACOS_CACERT_EXPORT_COMMAND="sudo security export -t certs -f pemseq -k /Library/Keychains/System.keychain -o ${PYTHON_SSL_CERT_DIR}/systemBundleCA.pem"
      logInfo "${LOG_PREFIX} Running [${MACOS_CACERT_EXPORT_COMMAND}]"
      eval "${MACOS_CACERT_EXPORT_COMMAND}"
    fi
    mv "${PYTHON_SSL_CERT_FILE}" "${PYTHON_SSL_CERT_FILE}.bak"
    logInfo "${LOG_PREFIX} Appending system cacerts to python cacerts"
    if [[ "$UNAME" == "darwin"* ]]; then
      cat "${PYTHON_SSL_CERT_FILE}.bak" "${PYTHON_SSL_CERT_DIR}/systemBundleCA.pem" > "${PYTHON_SSL_CERT_FILE}"
    else
      cat "${PYTHON_SSL_CERT_FILE}.bak" "${CACERT_BUNDLE}" > "${PYTHON_SSL_CERT_FILE}"
    fi
  fi
}

function init_cacert_vars() {
  local LOG_PREFIX="init_cacert_vars():"

  if [ -z "${JAVA_HOME}" ] || [ ! -d "${JAVA_HOME}" ]; then
    ## ref: https://stackoverflow.com/questions/1117398/java-home-directory-in-linux
    JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
  fi
  logInfo "${LOG_PREFIX} JAVA_HOME=${JAVA_HOME}"

  ## ref: https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
  case "${UNAME}" in
      linux*)
        if type "lsb_release" > /dev/null 2>&1; then
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
#            DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
            DISTRO=$LINUX_OS_DIST
            CACERT_TRUST_COMMAND="update-ca-certificates"
            CACERT_TRUST_FORMAT="crt"
            ;;
          *redhat* | *"red hat"* | *centos* | *fedora* )
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

  logDebug "LINUX_OS_DIST=${OS_DIST}"
  logDebug "PLATFORM=[${PLATFORM}]"
  logDebug "DISTRO=[${DISTRO}]"
  logDebug "CACERT_TRUST_DIR=${CACERT_TRUST_DIR}"
  logDebug "CACERT_TRUST_IMPORT_DIR=${CACERT_TRUST_IMPORT_DIR}"
  logDebug "CACERT_BUNDLE=${CACERT_BUNDLE}"
  logDebug "CACERT_TRUST_COMMAND=${CACERT_TRUST_COMMAND}"

}

function usage() {
  echo "Usage: ${0} [options] [[HOST1:PORT1] [HOST2:PORT2] ...]"
  echo ""
  echo "  Options:"
  echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG] : run with specified log level (default INFO)"
  echo "       -v : show script version"
  echo "       -p : setup python cacerts only"
  echo "       -h : help"
  echo ""
  echo "  Examples:"
	echo "       ${0} "
	echo "       ${0} -L DEBUG"
  echo "       ${0} -v"
	echo "       ${0} bitbucket.example.org.org:8443 updates.jenkins.io:443"
	echo "       ${0} -L DEBUG updates.jenkins.io:443"
	[ -z "$1" ] || exit "$1"
}

function main() {

  if [[ "$UNAME" != "cygwin" && "$UNAME" != "msys" ]]; then
    if [ "$EUID" -ne 0 ]; then
      echo "Must run this script as root. run 'sudo $SCRIPT_NAME'"
      exit
    fi
  fi

  while getopts "L:r:vph" opt; do
      case "${opt}" in
          L) setLogLevel "${OPTARG}" ;;
          v) echo "${VERSION}" && exit ;;
          p) SETUP_PYTHON_CACERTS_ONLY=1 ;;
          h) usage 1 ;;
          \?) usage 2 ;;
          *) usage ;;
      esac
  done
  shift $((OPTIND-1))

  __SITE_LIST=("${SITE_LIST_DEFAULT[@]}")
  if [ $# -gt 0 ]; then
    __SITE_LIST=("$@")
  fi

  init_cacert_vars

  logInfo "UNAME=${UNAME}"

  if [ "${SETUP_PYTHON_CACERTS_ONLY}" -eq 0 ]; then
    if [ -d "${CACERT_TRUST_DIR}" ]; then
      logInfo "Remove any broken/invalid sym links from ${CACERT_TRUST_DIR}/"
      find "${CACERT_TRUST_DIR}/" -xtype l -delete
    fi

    logDebug "Add site certs [${__SITE_LIST[*]}] to cacerts"
    for SITE in "${__SITE_LIST[@]}"; do
      logDebug "SITE=${SITE}"
      install_site_cert "${SITE}" "${INSTALL_JDK_CACERT}"
    done
  fi

  setup_python_cacerts

}

main "$@"
