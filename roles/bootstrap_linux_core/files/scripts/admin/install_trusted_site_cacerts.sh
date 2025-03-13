#!/usr/bin/env bash

## ref: https://stackoverflow.com/questions/3685548/java-keytool-easy-way-to-add-server-cert-from-url-port
## ref: https://superuser.com/questions/97201/how-to-save-a-remote-server-ssl-certificate-locally-as-a-file
## ref: https://serverfault.com/questions/661978/displaying-a-remote-ssl-certificate-details-using-cli-tools

#set -x

VERSION="2025.3.2"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "SCRIPT_DIR=[${SCRIPT_DIR}]"

SCRIPT_NAME=$(basename "$0")
SCRIPT_NAME="${SCRIPT_NAME%.*}"
logFile="${SCRIPT_NAME}.log"

INSTALL_JDK_CACERT=0
INSTALL_SYSTEM_CACERTS=1
INSTALL_DOCKER_CACERT=0
INSTALL_PYTHON_CACERTS=0

SITE_LIST_DEFAULT=()
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

#### LOGGING RELATED
LOG_ERROR=0
LOG_WARN=1
LOG_INFO=2
LOG_TRACE=3
LOG_DEBUG=4

#LOG_LEVEL=${LOG_DEBUG}
LOG_LEVEL=${LOG_INFO}

function abort() {
  logError "%s\n" "$@"
  exit 1
}

function logError() {
  if [ $LOG_LEVEL -ge $LOG_ERROR ]; then
  	logMessage "${LOG_ERROR}" "${1}"
  fi
}
function logWarn() {
  if [ $LOG_LEVEL -ge $LOG_WARN ]; then
  	logMessage "${LOG_WARN}" "${1}"
  fi
}
function logInfo() {
  if [ $LOG_LEVEL -ge $LOG_INFO ]; then
  	logMessage "${LOG_INFO}" "${1}"
  fi
}
function logTrace() {
  if [ $LOG_LEVEL -ge $LOG_TRACE ]; then
  	logMessage "${LOG_TRACE}" "${1}"
  fi
}
function logDebug() {
  if [ $LOG_LEVEL -ge $LOG_DEBUG ]; then
  	logMessage "${LOG_DEBUG}" "${1}"
  fi
}

function logMessage() {
  local LOG_MESSAGE_LEVEL="${1}"
  local LOG_MESSAGE="${2}"
  ## remove first item from FUNCNAME array
#  local CALLING_FUNCTION_ARRAY=("${FUNCNAME[@]:2}")
  ## Get the length of the array
  local CALLING_FUNCTION_ARRAY_LENGTH=${#FUNCNAME[@]}
  local CALLING_FUNCTION_ARRAY=("${FUNCNAME[@]:2:$((CALLING_FUNCTION_ARRAY_LENGTH - 3))}")
#  echo "CALLING_FUNCTION_ARRAY[@]=${CALLING_FUNCTION_ARRAY[@]}"

  local CALL_ARRAY_LENGTH=${#CALLING_FUNCTION_ARRAY[@]}
  local REVERSED_CALL_ARRAY=()
  for (( i = CALL_ARRAY_LENGTH - 1; i >= 0; i-- )); do
    REVERSED_CALL_ARRAY+=( "${CALLING_FUNCTION_ARRAY[i]}" )
  done
#  echo "REVERSED_CALL_ARRAY[@]=${REVERSED_CALL_ARRAY[@]}"

#  local CALLING_FUNCTION_STR="${CALLING_FUNCTION_ARRAY[*]}"
  ## ref: https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-a-bash-array-into-a-delimited-string#17841619
  local SEPARATOR=":"
  local CALLING_FUNCTION_STR=$(printf "${SEPARATOR}%s" "${REVERSED_CALL_ARRAY[@]}")
  local CALLING_FUNCTION_STR=${CALLING_FUNCTION_STR:${#SEPARATOR}}

  case "${LOG_MESSAGE_LEVEL}" in
    $LOG_ERROR*)
      LOG_LEVEL_STR="ERROR"
      ;;
    $LOG_WARN*)
      LOG_LEVEL_STR="WARN"
      ;;
    $LOG_INFO*)
      LOG_LEVEL_STR="INFO"
      ;;
    $LOG_TRACE*)
      LOG_LEVEL_STR="TRACE"
      ;;
    $LOG_DEBUG*)
      LOG_LEVEL_STR="DEBUG"
      ;;
    *)
      abort "Unknown LOG_MESSAGE_LEVEL of [${LOG_MESSAGE_LEVEL}] specified"
  esac

  local LOG_LEVEL_PADDING_LENGTH=5
  local PADDED_LOG_LEVEL=$(printf "%-${LOG_LEVEL_PADDING_LENGTH}s" "${LOG_LEVEL_STR}")

  local LOG_PREFIX="${CALLING_FUNCTION_STR}():"
  echo -e "[${PADDED_LOG_LEVEL}]: ==> ${LOG_PREFIX} ${LOG_MESSAGE}"
}

function setLogLevel() {
  LOG_LEVEL_STR=$1

  case "${LOG_LEVEL_STR}" in
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
      ;;
    *)
      abort "Unknown LOG_LEVEL_STR of [${LOG_LEVEL_STR}] specified"
  esac

}

function handle_cmd_return_code() {
  local RUN_COMMAND=$1

  logInfo "${RUN_COMMAND}"
  COMMAND_RESULT=$(eval "${RUN_COMMAND}")
#  COMMAND_RESULT=$(eval "${RUN_COMMAND} > /dev/null 2>&1")
  local RETURN_STATUS=$?

  if [[ $RETURN_STATUS -eq 0 ]]; then
    logDebug "${COMMAND_RESULT}"
    logDebug "SUCCESS!"
  else
    logError "ERROR (${RETURN_STATUS})"
    echo "${COMMAND_RESULT}"
    exit 1
  fi

}

function isInstalled() {
    command -v "${1}" >/dev/null 2>&1 || return 1
}

function pip_install_certifi() {
  PIP_INSTALL_CMD="pip install certifi"
  logInfo "${PIP_INSTALL_CMD}"
  eval "${PIP_INSTALL_CMD}"
}

function get_java_keystore() {
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
#    logDebug "JDK_CERT_DIR=${JDK_CERT_DIR}"
  fi
  local JAVA_CACERTS="${JDK_CERT_DIR}/cacerts"
#  logDebug "JAVA_CACERTS=${JAVA_CACERTS}"

  echo "${JAVA_CACERTS}"
}

function get_host_cert() {
  local HOST=$1
  local PORT=$2
  local CACERTS_SRC=$3
  local ALIAS="${HOST}_${PORT}"

  logInfo "Fetching certs from host:port ${HOST}:${PORT}"

  if [ -z "$HOST" ]; then
    logError "Must specify the host name to import the certificate in from, eventually followed by the port number, if other than 443."
    exit 1
  fi

  set -e

#  logInfo "**** get_host_cert() START : find ${CACERTS_SRC}/ -name cert*.crt"
#  eval "find ${CACERTS_SRC}/ -name cert*.crt"

#  if [ -e "$CACERTS_SRC/$ALIAS.crt" ]; then
#    rm -f "$CACERTS_SRC/$ALIAS.crt"
#  fi
#  if [ -e "$CACERTS_SRC/$ALIAS.pem" ]; then
#    rm -f "$CACERTS_SRC/$ALIAS.pem"
#  fi

  ############
  ## To avoid "ssl alert number 40"
  ## It is usually related to a server with several virtual hosts to serve,
  ## where you need to/should tell which host you want to connect to in order for the TLS handshake to succeed.
  ##
  ## Specify the exact host name you want with -servername parameter.
  ##
  ## ref: https://stackoverflow.com/questions/9450120/openssl-hangs-and-does-not-exit
  ## ref: https://stackoverflow.com/questions/53965049/handshake-failure-ssl-alert-number-40
  logDebug "Fetching *.crt format certs from host:port ${HOST}:${PORT}"
#  local FETCH_CRT_CERT_COMMAND="echo QUIT | openssl s_client -connect ${HOST}:${PORT} -servername ${HOST} 1>${CACERTS_SRC}/${ALIAS}.crt"
  local FETCH_CRT_CERT_COMMAND="echo QUIT | openssl s_client -connect ${HOST}:${PORT} -servername ${HOST} </dev/null 2>/dev/null 1>${CACERTS_SRC}/${ALIAS}.crt"
  logInfo "${FETCH_CRT_CERT_COMMAND}"
  eval "${FETCH_CRT_CERT_COMMAND}"

  logDebug "Fetching *.pem format certs from host:port ${HOST}:${PORT}"
  FETCH_PEM_CERT_COMMAND="echo QUIT | openssl s_client -showcerts -servername ${HOST} -connect ${HOST}:${PORT}"
  FETCH_PEM_CERT_COMMAND+=" </dev/null 2>/dev/null | openssl x509 -outform PEM > ${CACERTS_SRC}/${ALIAS}.pem"
  logInfo "${FETCH_PEM_CERT_COMMAND}"
  eval "${FETCH_PEM_CERT_COMMAND}"

  logInfo "Extracting certs from cert chain for ${HOST}:${PORT} "
  ## ref: https://unix.stackexchange.com/questions/368123/how-to-extract-the-root-ca-and-subordinate-ca-from-a-certificate-chain-in-linux
  openssl s_client -showcerts -verify 5 -connect "${HOST}:${PORT}" -servername "${HOST}" </dev/null 2>/dev/null \
    | awk -v certdir="${CACERTS_SRC}" '/BEGIN/,/END/{ if(/BEGIN/){a++}; out="cert"a".crt"; print >(certdir "/" out)}' && \
  for cert in ${CACERTS_SRC}/cert*.crt; do
    #    nameprefix=$(echo "${cert%.*}")
    nameprefix="${cert%.*}"
    logDebug "nameprefix for cert ${cert} ==> ${nameprefix}"
    newname="${nameprefix}".$(openssl x509 -noout -subject -in $cert | sed -n 's/\s//g; s/^.*CN=\(.*\)$/\1/; s/[ ,.*]/_/g; s/__/_/g; s/^_//g;p')."${CACERT_TRUST_FORMAT}"
    logDebug "cert ==> ${newname}"
    mv "${cert}" "${newname}"
#    cp -p "${cert}" "${newname}"
  done

  ## create cert chain pem for import to java cacerts
  ## ref: https://stackoverflow.com/questions/24563694/jenkins-unable-to-find-valid-certification-path-to-requested-target-error-whil
  local FIND_CERTS_CMD="find ${CACERTS_SRC}/ -name \"cert*.${CACERT_TRUST_FORMAT}\" -type f -exec printf '%s ' {} + | sort"
  logDebug "${FIND_CERTS_CMD}"
  local SITE_CERT_LIST=$(eval "${FIND_CERTS_CMD}")
  logInfo "SITE_CERT_LIST=[${SITE_CERT_LIST}]"
  local CAT_CMD="cat ${SITE_CERT_LIST} > ${CACERTS_SRC}/full_chain.${CACERT_TRUST_FORMAT}"
  logInfo "${CAT_CMD}"
  eval "${CAT_CMD}"
  openssl x509 -in "${CACERTS_SRC}/full_chain.${CACERT_TRUST_FORMAT}" -out "${CACERTS_SRC}/full_chain_sanitized.${CACERT_TRUST_FORMAT}"

}

function import_jdk_cert() {
  local KEYSTORE=$1
  local CACERTS_SRC=$2
  local ALIAS=$3
  local KEYSTORE_PASS=${4:-"changeit"}

  logInfo "Adding certs to keystore at [${KEYSTORE}]"

  if $KEYTOOL -cacerts -list -storepass "${KEYSTORE_PASS}" -alias "${ALIAS}" >/dev/null; then
    logInfo "Key with alias ${ALIAS} already found, removing old one..."

#   KEYTOOL_COMMAND="${KEYTOOL} -delete -alias ${ALIAS} -keystore ${KEYSTORE} -storepass ${KEYSTORE_PASS}"
    KEYTOOL_COMMAND="${KEYTOOL} -delete -alias ${ALIAS} -cacerts -storepass ${KEYSTORE_PASS}"
    handle_cmd_return_code "${KEYTOOL_COMMAND}"
  fi

  logInfo "Keytool importing ${CACERT_TRUST_FORMAT} formatted cert"

#    KEYTOOL_COMMAND="${KEYTOOL} -import -noprompt -trustcacerts -cacerts \
#  KEYTOOL_COMMAND="${KEYTOOL} -import -noprompt -trustcacerts \
#    -keystore ${KEYSTORE} \
#    -storepass ${KEYSTORE_PASS} \
#    -alias ${ALIAS} \
#    -file ${CACERTS_SRC}/full_chain_sanitized.${CACERT_TRUST_FORMAT}"

  KEYTOOL_COMMAND="${KEYTOOL} -import -noprompt -cacerts -trustcacerts \
    -storepass ${KEYSTORE_PASS} \
    -alias ${ALIAS} \
    -file ${CACERTS_SRC}/full_chain.${CACERT_TRUST_FORMAT}"

  handle_cmd_return_code "${KEYTOOL_COMMAND}"

}

function install_java_cacerts() {
  local CACERTS_SRC=$1
  local ALIAS=$2
  local KEYSTORE_PASS=${3:-"changeit"}

  logInfo "Get default java JDK cacert location"

  logInfo "JAVA_HOME=${JAVA_HOME}"
  #local JDK_KEYSTORE=$JDK_CERT_DIR/cacerts
  local JDK_KEYSTORE=$(get_java_keystore)
  logInfo "JDK_KEYSTORE=${JDK_KEYSTORE}"

  if [ ! -e "${JDK_KEYSTORE}" ]; then
    logInfo "JDK_KEYSTORE [$JDK_KEYSTORE] not found!"
    exit 1
  else
    logInfo "JDK_KEYSTORE found at [$JDK_KEYSTORE]"
  fi

  ### Now build list of cacert targets to update
  logInfo "updating JDK certs at [${JDK_KEYSTORE}]..."
  import_jdk_cert "${JDK_KEYSTORE}" "${CACERTS_SRC}" "${ALIAS}" "${KEYSTORE_PASS}"

  if [ -f "${USER_KEYSTORE}" ]; then
    logInfo "updating certs at [$USER_KEYSTORE]..."
    import_jdk_cert "${USER_KEYSTORE}" "${CACERTS_SRC}" "${ALIAS}" "${KEYSTORE_PASS}"
  fi
}

# ref: https://stackoverflow.com/questions/50768317/docker-pull-certificate-signed-by-unknown-authority
# ref: https://docs.docker.com/desktop/faqs/macfaqs/#how-do-i-add-tls-certificates
# ref: https://stackoverflow.com/questions/50768317/docker-pull-certificate-signed-by-unknown-authority
function install_docker_cacert() {
  local LOG_PREFIX="install_docker_cacert():"
  local CACERTS_SRC=$1
  local ENDPOINT=$2

  local DOCKER_CERT_DIR="/etc/docker/certs.d/${ENDPOINT}"
  mkdir -p "${DOCKER_CERT_DIR}"

  # shellcheck disable=SC2206
  CERTS=(${CACERTS_SRC}/cert*.pem)
  CA_ROOT_CERT=${CERTS[-1]}
  logInfo "Located site root cert for ${ENDPOINT} ==> [${CA_ROOT_CERT}]"

  logInfo "Copy ${ENDPOINT} site root cert to DOCKER_CERT_DIR=${DOCKER_CERT_DIR}"

  local COPY_CMD="cp ${CA_ROOT_CERT} ${DOCKER_CERT_DIR}/"
  logInfo "[${COPY_CMD}]"
  eval "${COPY_CMD}"

  if [[ "$UNAME" == "darwin"* ]]; then
    local DOCKER_USER_CERT_DIR="${HOME}/.docker/certs.d/${ENDPOINT}"
    mkdir -p "${DOCKER_USER_CERT_DIR}"
    logInfo "Copy ${ENDPOINT} site root cert to DOCKER_USER_CERT_DIR=${DOCKER_USER_CERT_DIR}"
    ## ref: https://docs.docker.com/desktop/faqs/macfaqs/#how-do-i-add-tls-certificates
    local COPY_CMD="cp ${CA_ROOT_CERT} ${DOCKER_USER_CERT_DIR}/"
    logInfo "[${COPY_CMD}]"
    eval "${COPY_CMD}"
  fi
}

function install_cert_to_truststore() {
  local HOST=$1
  local PORT=$2
  local CACERTS_SRC=$3
  local KEYSTORE_PASS=${4:-"changeit"}

  if [[ "$UNAME" == "linux"* ]]; then
    local ROOT_CERT=$(find ${CACERTS_SRC}/ -name cert*.${CACERT_TRUST_FORMAT} | sort -nr | head -1)
#    logInfo "copy ROOT_CERT ${ROOT_CERT} to CACERT_TRUST_IMPORT_DIR=${CACERT_TRUST_IMPORT_DIR}"
#    cp -p "${ROOT_CERT}" "${CACERT_TRUST_IMPORT_DIR}/"

    local CAT_CMD="cat ${SITE_CERT_LIST} > ${CACERTS_SRC}/full_chain.${CACERT_TRUST_FORMAT}"

    logInfo "copy certs to CACERT_TRUST_IMPORT_DIR=${CACERT_TRUST_IMPORT_DIR}"

    local COPY_CMD="cp ${SITE_CERT_LIST} ${CACERT_TRUST_IMPORT_DIR}/"
    logInfo "[${COPY_CMD}]"
    eval "${COPY_CMD}"

#    cp -p "${CACERTS_SRC}/"cert*."${CACERT_TRUST_FORMAT}" "${CACERT_TRUST_IMPORT_DIR}/"
    logInfo "Running [${CACERT_TRUST_COMMAND}]"
    eval "${CACERT_TRUST_COMMAND}"

  elif [[ "$UNAME" == "darwin"* ]]; then
#    logInfo "Adding cert to macOS system keychain"
#    #    sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" "/private/tmp/securly_SHA-256.crt"
#    sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" ${CACERTS_SRC}/${ALIAS}.crt

    logInfo "Adding site cert to the current user's trust cert chain"
#    sudo security add-trusted-cert -d -r trustRoot -k "${HOME}/Library/Keychains/login.keychain" ${CACERTS_SRC}/${ALIAS}.crt

    # shellcheck disable=SC2206
    certs=(${CACERTS_SRC}/cert*.pem)
    ca_root_cert=${certs[-1]}
    logInfo "Add the site root cert to the current user's trust cert chain ==> [${ca_root_cert}]"

    ## ref: https://apple.stackexchange.com/questions/80623/import-certificates-into-the-system-keychain-via-the-command-line
#    MACOS_CACERT_TRUST_COMMAND="sudo security add-trusted-cert -d -r trustRoot -k ${HOME}/Library/Keychains/login.keychain ${ca_root_cert}"
    MACOS_CACERT_TRUST_COMMAND="sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ${ca_root_cert}"

    logInfo "[${MACOS_CACERT_TRUST_COMMAND}]"
    eval "${MACOS_CACERT_TRUST_COMMAND}"

##    for cert in ${CACERTS_SRC}/cert*.pem; do
##    for ((i=${#files[@]}-1; i>=0; i--)); do
#    certs=(${CACERTS_SRC}/cert*.pem)
#    for ((cert=${#certs[@]}-1; i>=0; i--)); do
#      logInfo "Adding cert to the system keychain ==> [${cert}]"
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
    logInfo "[${WIN_CACERT_TRUST_COMMAND}]"
    eval "${WIN_CACERT_TRUST_COMMAND}"

    ## ref: https://serverfault.com/questions/722563/how-to-make-firefox-trust-system-ca-certificates?newreg=9c67967e3aa248f489c8c9b2cc4ac776
    #certutil -addstore Root ${CERT_DIR}/${HOST}.pem
    ## ref: https://superuser.com/questions/1031444/imPORTing-pem-certificates-on-windows-7-on-the-command-line/1032179
    #certutil –addstore -enterprise –f "Root" "${CERT_DIR}/${HOST}.pem"
    #certutil –addstore -enterprise –f "Root" "${ROOT_CERT}"

  fi

}

function install_site_cert() {
  local SITE=$1
  local KEYSTORE_PASS=${2:-"changeit"}

  #local DATE=`date +&%%m%d%H%M%S`
  local DATE=$(date +%Y%m%d)

  logInfo "SITE=${SITE}"

  IFS=':' read -r -a array <<< "${SITE}"
  local HOST=${array[0]}
  local PORT=${array[1]:-443}

  logInfo "HOST=[$HOST] PORT=[$PORT]"

  local ENDPOINT="${HOST}:${PORT}"
  local ALIAS="${HOST}_${PORT}"

  ## ref: https://knowledgebase.garapost.com/index.php/2020/06/05/how-to-get-ssl-certificate-fingerprint-and-serial-number-using-openssl-command/
  ## ref: https://stackoverflow.com/questions/13823706/capture-multiline-output-as-array-in-bash
#  local CERT_INFO=($(echo QUIT | openssl s_client -connect $HOST:$PORT </dev/null 2>/dev/null | openssl x509 -serial -fingerprint -sha256 -noout | cut -d"=" -f2 | sed s/://g))
  local CERT_INFO=($(echo QUIT | openssl s_client -connect "${HOST}:${PORT}" -servername "${HOST}" </dev/null 2>/dev/null | openssl x509 -serial -fingerprint -sha256 -noout | cut -d"=" -f2 | sed s/://g))
  local CERT_SERIAL=${CERT_INFO[0]}
  local CERT_FINGERPRINT=${CERT_INFO[1]}

  logDebug "CERT_SERIAL=${CERT_SERIAL}"
  logDebug "CERT_FINGERPRINT=${CERT_FINGERPRINT}"

  #local CACERTS_SRC=${HOME}/.cacerts/$ALIAS/$DATE
  #local CACERTS_SRC=${HOME}/.cacerts/$ALIAS/$CERT_SERIAL/$CERT_FINGERPRINT
#  local CACERTS_SRC=/tmp/.cacerts/$ALIAS/$CERT_SERIAL/$CERT_FINGERPRINT
  local CACERTS_SRC=/tmp/.cacerts/$ALIAS

  logInfo "CACERTS_SRC=${CACERTS_SRC}"

  logDebug "Recreate tmp cert dir ${CACERTS_SRC}"
  rm -fr "${CACERTS_SRC}"
  mkdir -p "${CACERTS_SRC}"

#  local FIND_CERTS_CMD="find ${CACERTS_SRC}/ -name cert*.crt"
#  logDebug "[${FIND_CERTS_CMD}]"
#  eval "${FIND_CERTS_CMD}"

  local TMP_OUT=/tmp/${SCRIPT_NAME}.output

  logDebug "Get host cert for ${HOST}:${PORT}"
  get_host_cert "${HOST}" "${PORT}" "${CACERTS_SRC}"

  local FIND_CERTS_CMD="find ${CACERTS_SRC}/ -name \"cert*.${CACERT_TRUST_FORMAT}\" -type f -exec printf '%s ' {} + | sort"
  logDebug "[${FIND_CERTS_CMD}]"
  local SITE_CERT_LIST=$(eval "${FIND_CERTS_CMD}")
  logInfo "SITE_CERT_LIST=[${SITE_CERT_LIST}]"

  logInfo "Adding cert to the system truststore.."
  install_cert_to_truststore "${HOST}" "${PORT}" "${CACERTS_SRC}" "${KEYSTORE_PASS}"

  if [ "$INSTALL_JDK_CACERT" -eq 1 ]; then
    if [ -n "${JAVA_HOME}" ]; then
      install_java_cacerts "${CACERTS_SRC}" "${ALIAS}" "${KEYSTORE_PASS}"
    fi
  fi
  if [ "$INSTALL_DOCKER_CACERT" -eq 1 ]; then
    if [ -n "${JAVA_HOME}" ]; then
      install_docker_cacert "${CACERTS_SRC}" "${ENDPOINT}"
    fi
  fi

  logInfo "**** Finished ****"
}

function setup_python_cacerts() {
  local LOG_PREFIX="setup_python_cacerts():"

#  ## ref: https://stackoverflow.com/questions/40684543/how-to-make-python-use-ca-certificates-from-mac-os-truststore
#  pip_install_certifi
#
  local PYTHON_SSL_CERT_FILE=$(python3 -m certifi)
  # ref: https://askubuntu.com/a/1296373/1157235
#  local PYTHON_SSL_CERT_FILE=$(python3 -c 'import ssl; print(ssl.get_default_verify_paths().openssl_cafile)')
  local PYTHON_SSL_CERT_DIR=$(dirname "${PYTHON_SSL_CERT_FILE}")

  logInfo "PYTHON_SSL_CERT_DIR=${PYTHON_SSL_CERT_DIR}"
  if [[ -n "${PYTHON_SSL_CERT_DIR}" && -n "${PYTHON_SSL_CERT_FILE}" ]]; then

    if [[ "$UNAME" == "darwin"* ]]; then
      ## ref: https://stackoverflow.com/questions/40684543/how-to-make-python-use-ca-certificates-from-mac-os-truststore
      MACOS_CACERT_EXPORT_COMMAND="sudo security export -t certs -f pemseq -k /Library/Keychains/System.keychain -o ${PYTHON_SSL_CERT_DIR}/systemBundleCA.pem"
      logInfo "Running [${MACOS_CACERT_EXPORT_COMMAND}]"
      eval "${MACOS_CACERT_EXPORT_COMMAND}"
    fi
    if [ -f "${PYTHON_SSL_CERT_FILE}" ]; then
      mv "${PYTHON_SSL_CERT_FILE}" "${PYTHON_SSL_CERT_FILE}.bak"
    else
      cp -p "${CACERT_BUNDLE}" "${PYTHON_SSL_CERT_FILE}.bak"
    fi
    logInfo "Appending system cacerts to python cacerts"
    if [[ "$UNAME" == "darwin"* ]]; then
      cat "${PYTHON_SSL_CERT_FILE}.bak" "${PYTHON_SSL_CERT_DIR}/systemBundleCA.pem" > "${PYTHON_SSL_CERT_FILE}"
    else
      cat "${PYTHON_SSL_CERT_FILE}.bak" "${CACERT_BUNDLE}" > "${PYTHON_SSL_CERT_FILE}"
    fi
  fi
}

function init_cacert_vars() {
  local LOG_PREFIX="init_cacert_vars():"

  if [[ -z "$(isInstalled java)" ]]; then
    if [ -z "${JAVA_HOME}" ] || [ ! -d "${JAVA_HOME}" ]; then
      ## ref: https://stackoverflow.com/questions/1117398/java-home-directory-in-linux
      JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
    fi
    logInfo "JAVA_HOME=${JAVA_HOME}"
  fi

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
  echo "Usage: ${0} [options] [[ENDPOINT_CONFIG1] [ENDPOINT_CONFIG2] ...]"
  echo ""
  echo "       ENDPOINT_CONFIG[n] is a colon delimited tuple with SITE_HOSTNAME:SITE_PORT"
  echo ""
  echo "  Options:"
  echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG] : run with specified log level (default INFO)"
  echo "       -v : show script version"
  echo "       -d : setup cacert in docker client config (/etc/docker/certs.d/) (default skip)"
  echo "       -p : setup python cacerts (default skip)"
  echo "       -s : skip installing system cacerts"
  echo "       -h : help"
  echo ""
  echo "  Examples:"
	echo "       ${0} "
  echo "       ${0} -v"
	echo "       ${0} -L DEBUG"
	echo "       ${0} cacert.example.com,443"
	echo "       ${0} -L DEBUG updates.jenkins.io:443"
	echo "       ${0} cacert.example.com,443 ca.example.int:443 registry.example.int:5000"
	echo "       ${0} bitbucket.example.org.org:8443 updates.jenkins.io:443"
	[ -z "$1" ] || exit "$1"
}

function main() {

  if [[ "$UNAME" != "cygwin" && "$UNAME" != "msys" ]]; then
    if [ "$EUID" -ne 0 ]; then
      echo "Must run this script as root. run 'sudo $SCRIPT_NAME'"
      exit
    fi
  fi

  while getopts "L:vdpsh" opt; do
      case "${opt}" in
          L) setLogLevel "${OPTARG}" ;;
          v) echo "${VERSION}" && exit ;;
          d) INSTALL_DOCKER_CACERT=1 ;;
          p) INSTALL_PYTHON_CACERTS=1 ;;
          s) INSTALL_SYSTEM_CACERTS=0 ;;
          h) usage 1 ;;
          \?) usage 2 ;;
          *) usage ;;
      esac
  done
  shift $((OPTIND-1))

  local __SITE_LIST=("${SITE_LIST_DEFAULT[@]}")
  if [ $# -gt 0 ]; then
    __SITE_LIST=("$@")
  fi

  logInfo "__SITE_LIST=${__SITE_LIST[*]}"

  init_cacert_vars

  logInfo "UNAME=${UNAME}"
  logInfo "LINUX_OS_DIST=${LINUX_OS_DIST}"
  logInfo "PLATFORM=[${PLATFORM}]"
  logInfo "DISTRO=[${DISTRO}]"
  logInfo "CACERT_TRUST_DIR=${CACERT_TRUST_DIR}"
  logInfo "CACERT_TRUST_IMPORT_DIR=${CACERT_TRUST_IMPORT_DIR}"
  logInfo "CACERT_BUNDLE=${CACERT_BUNDLE}"
  logInfo "CACERT_TRUST_COMMAND=${CACERT_TRUST_COMMAND}"

  if [ "${INSTALL_PYTHON_CACERTS}" -eq 1 ]; then
    setup_python_cacerts
  fi

  if [ "${INSTALL_SYSTEM_CACERTS}" -eq 1 ]; then
    if [ -d "${CACERT_TRUST_DIR}" ]; then
      logInfo "Remove any broken/invalid sym links from ${CACERT_TRUST_DIR}/"
      find "${CACERT_TRUST_DIR}/" -xtype l -delete
    fi

    logInfo "Add site certs to cacerts"
    for ENDPOINT_CONFIG in "${__SITE_LIST[@]}"; do
      logDebug "ENDPOINT_CONFIG=${ENDPOINT_CONFIG}"
      install_site_cert "${ENDPOINT_CONFIG}"
    done
  fi
}

main "$@"
