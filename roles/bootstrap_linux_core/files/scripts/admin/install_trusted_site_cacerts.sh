#!/usr/bin/env bash

## ref: https://stackoverflow.com/questions/3685548/java-keytool-easy-way-to-add-server-cert-from-url-port
## ref: https://superuser.com/questions/97201/how-to-save-a-remote-server-ssl-certificate-locally-as-a-file
## ref: https://serverfault.com/questions/661978/displaying-a-remote-ssl-certificate-details-using-cli-tools

#set -x

VERSION="2025.11.23"

#SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(dirname "$0")"
SCRIPT_NAME="$(basename "$0")"
SCRIPT_NAME_PREFIX="${SCRIPT_NAME%.*}"

INSTALL_JDK_CACERTS=1
INSTALL_SYSTEM_CACERTS=1
INSTALL_DOCKER_CACERTS=0
INSTALL_PYTHON_CACERTS=1

USE_TEMP_DIR=0
KEEP_TEMP_DIR=1

## ref: https://www.pixelstech.net/article/1577768087-Create-temp-file-in-Bash-using-mktemp-and-trap
## ref: https://stackoverflow.com/questions/4632028/how-to-create-a-temporary-directory
#TEMP_DIR=$(mktemp -d "${SCRIPT_NAME_PREFIX}_XXXXXX" -p "/tmp")

## keep track of the last executed command
#trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
## echo an error message before exiting
#trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT
#trap 'rm -fr "$TEMP_DIR"' EXIT

SITE_LIST_DEFAULT=()
SITE_LIST_DEFAULT+=("pfsense.johnson.int")
SITE_LIST_DEFAULT+=("stepca.admin.johnson.int")
SITE_LIST_DEFAULT+=("stepca.admin.dettonville.int")
SITE_LIST_DEFAULT+=("vcsa.dettonville.int")
#SITE_LIST_DEFAULT+=("gitea.admin.dettonville.int")
SITE_LIST_DEFAULT+=("admin.dettonville.int")
SITE_LIST_DEFAULT+=("media.johnson.int")
SITE_LIST_DEFAULT+=("media.johnson.int:5000")
SITE_LIST_DEFAULT+=("diskstation01.johnson.int:5001")
SITE_LIST_DEFAULT+=("pypi.python.org")
SITE_LIST_DEFAULT+=("files.pythonhosted.org")
SITE_LIST_DEFAULT+=("bootstrap.pypa.io")
SITE_LIST_DEFAULT+=("galaxy.ansible.com")
SITE_LIST_DEFAULT+=("repo.maven.apache.org")

KEYTOOL=keytool
JDK_USER_KEYSTORE="${HOME}/.keystore"

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

declare -A LOGLEVEL_TO_STR
LOGLEVEL_TO_STR["${LOG_ERROR}"]="ERROR"
LOGLEVEL_TO_STR["${LOG_WARN}"]="WARN"
LOGLEVEL_TO_STR["${LOG_INFO}"]="INFO"
LOGLEVEL_TO_STR["${LOG_TRACE}"]="TRACE"
LOGLEVEL_TO_STR["${LOG_DEBUG}"]="DEBUG"

# string formatters
if [[ -t 1 ]]
then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_orange="$(tty_mkbold 33)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

function reverse_array() {
  local -n ARRAY_SOURCE_REF=$1
  local -n REVERSED_ARRAY_REF=$2
  # Iterate over the keys of the LOGLEVEL_TO_STR array
  for KEY in "${!ARRAY_SOURCE_REF[@]}"; do
    # Get the value associated with the current key
    VALUE="${ARRAY_SOURCE_REF[$KEY]}"
    # Add the reversed key-value pair to the REVERSED_ARRAY_REF array
    REVERSED_ARRAY_REF[$VALUE]="$KEY"
  done
}

declare -A LOGLEVELSTR_TO_LEVEL
reverse_array LOGLEVEL_TO_STR LOGLEVELSTR_TO_LEVEL

#LOG_LEVEL=${LOG_DEBUG}
LOG_LEVEL=${LOG_INFO}

function log_error() {
  if [ $LOG_LEVEL -ge $LOG_ERROR ]; then
  	log_message "${LOG_ERROR}" "${1}"
  fi
}

function log_warn() {
  if [ $LOG_LEVEL -ge $LOG_WARN ]; then
  	log_message "${LOG_WARN}" "${1}"
  fi
}

function log_info() {
  if [ $LOG_LEVEL -ge $LOG_INFO ]; then
  	log_message "${LOG_INFO}" "${1}"
  fi
}

function log_trace() {
  if [ $LOG_LEVEL -ge $LOG_TRACE ]; then
  	log_message "${LOG_TRACE}" "${1}"
  fi
}

function log_debug() {
  if [ $LOG_LEVEL -ge $LOG_DEBUG ]; then
  	log_message "${LOG_DEBUG}" "${1}"
  fi
}

function shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"
  do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

function chomp() {
  printf "%s" "${1/"$'\n'"/}"
}

function ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

function abort() {
  log_error "$@"
  exit 1
}

function warn() {
  log_warn "$@"
#  log_warn "$(chomp "$1")"
#  printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")" >&2
}

#function abort() {
#  printf "%s\n" "$@" >&2
#  exit 1
#}

function error() {
  log_error "$@"
#  printf "%s\n" "$@" >&2
##  echo "$@" 1>&2;
}

function fail() {
  error "$@"
  exit 1
}

function log_message() {
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
  local CALLING_FUNCTION_STR
  CALLING_FUNCTION_STR=$(printf "${SEPARATOR}%s" "${REVERSED_CALL_ARRAY[@]}")
  CALLING_FUNCTION_STR=${CALLING_FUNCTION_STR:${#SEPARATOR}}

  ## ref: https://stackoverflow.com/a/13221491
  if [ "${LOGLEVEL_TO_STR[${LOG_MESSAGE_LEVEL}]+abc}" ]; then
    LOG_LEVEL_STR="${LOGLEVEL_TO_STR[${LOG_MESSAGE_LEVEL}]}"
  else
    abort "Unknown log level of [${LOG_MESSAGE_LEVEL}]"
  fi

  local LOG_LEVEL_PADDING_LENGTH=5

  local PADDED_LOG_LEVEL
  PADDED_LOG_LEVEL=$(printf "%-${LOG_LEVEL_PADDING_LENGTH}s" "${LOG_LEVEL_STR}")

  local LOG_PREFIX="${CALLING_FUNCTION_STR}():"
  local __LOG_MESSAGE="${LOG_PREFIX} ${LOG_MESSAGE}"
#  echo -e "[${PADDED_LOG_LEVEL}]: ==> ${__LOG_MESSAGE}"
  if [ "${LOG_MESSAGE_LEVEL}" -eq $LOG_INFO ]; then
    printf "${tty_blue}[${PADDED_LOG_LEVEL}]: ==> ${LOG_PREFIX}${tty_reset} %s\n" "${LOG_MESSAGE}" >&2
#    printf "${tty_blue}[${PADDED_LOG_LEVEL}]: ==>${tty_reset} %s\n" "${__LOG_MESSAGE}" >&2
#    printf "${tty_blue}[${PADDED_LOG_LEVEL}]: ==>${tty_bold} %s${tty_reset}\n" "${__LOG_MESSAGE}"
  elif [ "${LOG_MESSAGE_LEVEL}" -eq $LOG_WARN ]; then
    printf "${tty_orange}[${PADDED_LOG_LEVEL}]: ==> ${LOG_PREFIX}${tty_bold} %s${tty_reset}\n" "${LOG_MESSAGE}" >&2
#    printf "${tty_orange}[${PADDED_LOG_LEVEL}]: ==>${tty_bold} %s${tty_reset}\n" "${__LOG_MESSAGE}" >&2
#    printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")" >&2
  elif [ "${LOG_MESSAGE_LEVEL}" -le $LOG_ERROR ]; then
    printf "${tty_red}[${PADDED_LOG_LEVEL}]: ==> ${LOG_PREFIX}${tty_bold} %s${tty_reset}\n" "${LOG_MESSAGE}" >&2
#    printf "${tty_red}[${PADDED_LOG_LEVEL}]: ==>${tty_bold} %s${tty_reset}\n" "${__LOG_MESSAGE}" >&2
#    printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")" >&2
  else
    printf "${tty_bold}[${PADDED_LOG_LEVEL}]: ==> ${LOG_PREFIX}${tty_reset} %s\n" "${LOG_MESSAGE}" >&2
#    printf "[${PADDED_LOG_LEVEL}]: ==> %s\n" "${LOG_PREFIX} ${LOG_MESSAGE}"
  fi
}

function set_log_level() {
  LOG_LEVEL_STR=$1

  ## ref: https://stackoverflow.com/a/13221491
  if [ "${LOGLEVELSTR_TO_LEVEL[${LOG_LEVEL_STR}]+abc}" ]; then
    LOG_LEVEL="${LOGLEVELSTR_TO_LEVEL[${LOG_LEVEL_STR}]}"
  else
    abort "Unknown log level of [${LOG_LEVEL_STR}]"
  fi

}

function execute() {
  log_info "${*}"
  if ! "$@"
  then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

function execute_eval_command() {
  local RUN_COMMAND="${*}"

  log_debug "${RUN_COMMAND}"
  COMMAND_RESULT=$(eval "${RUN_COMMAND}")
#  COMMAND_RESULT=$(eval "${RUN_COMMAND} > /dev/null 2>&1")
  local RETURN_STATUS=$?

  if [[ $RETURN_STATUS -eq 0 ]]; then
    if [[ $COMMAND_RESULT != "" ]]; then
      log_debug $'\n'"${COMMAND_RESULT}"
    fi
    log_debug "SUCCESS!"
  else
    log_error "ERROR (${RETURN_STATUS})"
#    echo "${COMMAND_RESULT}"
    abort "$(printf "Failed during: %s" "${RUN_COMMAND}")"
  fi

}

function is_installed() {
  command -v "${1}" >/dev/null 2>&1 || return 1
}

function pip_install_certifi() {
  PIP_INSTALL_CMD="pip install certifi"
  log_info "${PIP_INSTALL_CMD}"
  eval "${PIP_INSTALL_CMD}"
}

function get_java_keystore() {
  local __JAVA_HOME=${1:-""}

  ## remove extra trailing slash if present
  __JAVA_HOME="${__JAVA_HOME%/}"

  ## default jdk location
  if [ -z "${__JAVA_HOME}" ]; then
    ## ref: https://stackoverflow.com/questions/394230/how-to-detect-the-os-from-a-bash-script
    if [[ "$UNAME" == "darwin"* ]]; then
      __JAVA_HOME=$(/usr/libexec/java_home)
    elif [[ "$UNAME" == "cygwin" || "$UNAME" == "msys" ]]; then
      __JAVA_HOME=$(/usr/libexec/java_home)
    else
      ## ref: https://stackoverflow.com/questions/11936685/how-to-obtain-the-location-of-cacerts-of-the-default-java-installation
      __JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
    fi
  fi

  if [ -d "${__JAVA_HOME}" ]; then
    if [ -d "${__JAVA_HOME}/lib/security" ]; then
      JDK_CERT_DIR="${__JAVA_HOME}/lib/security"
    elif [ -d "${__JAVA_HOME}/jre/lib/security" ]; then
      JDK_CERT_DIR="${__JAVA_HOME}/jre/lib/security"
    fi
#    log_debug "JDK_CERT_DIR=${JDK_CERT_DIR}"
  fi

  local JAVA_CACERTS=""
  if [ -n "${JDK_CERT_DIR}" ]; then
    JAVA_CACERTS="${JDK_CERT_DIR}/cacerts"
  fi
#  log_debug "JAVA_CACERTS=${JAVA_CACERTS}"

  echo "${JAVA_CACERTS}"
}

function get_site_cert_list() {
  local CA_CERTS_SRC="${1}"

  ## create cert chain pem for import to java ca certs
  ## ref: https://stackoverflow.com/questions/24563694/jenkins-unable-to-find-valid-certification-path-to-requested-target-error-whil
  local FIND_CERTS_CMD="find ${CA_CERTS_SRC}/ -name \"cert*.${CACERT_TRUST_FORMAT}\" -type f -exec printf '%s ' {} + | sort"
  log_debug "${FIND_CERTS_CMD}"
  local SITE_CERT_LIST=$(eval "${FIND_CERTS_CMD}")

  echo "${SITE_CERT_LIST}"
}

function fetch_site_cert_chain() {
  local HOST=$1
  local PORT=$2
  local CA_CERTS_SRC=$3

  log_debug "HOST=${HOST}"
  log_debug "PORT=${PORT}"
  log_debug "CA_CERTS_SRC=${CA_CERTS_SRC}"

  ## ref: https://knowledgebase.garapost.com/index.php/2020/06/05/how-to-get-ssl-certificate-fingerprint-and-serial-number-using-openssl-command/
  ## ref: https://stackoverflow.com/questions/13823706/capture-multiline-output-as-array-in-bash
#  local CERT_INFO=($(echo QUIT | openssl s_client -connect $HOST:$PORT </dev/null 2>/dev/null | openssl x509 -serial -fingerprint -sha256 -noout | cut -d"=" -f2 | sed s/://g))
  local CERT_INFO=($(echo QUIT | openssl s_client -connect "${HOST}:${PORT}" -servername "${HOST}" </dev/null 2>/dev/null | openssl x509 -serial -fingerprint -sha256 -noout | cut -d"=" -f2 | sed s/://g))
  local CERT_SERIAL=${CERT_INFO[0]}
  local CERT_FINGERPRINT=${CERT_INFO[1]}

  log_debug "CERT_SERIAL=${CERT_SERIAL}"
  log_debug "CERT_FINGERPRINT=${CERT_FINGERPRINT}"

  #local CA_CERTS_SRC=${HOME}/.cacerts/$ALIAS/$DATE
  #local CA_CERTS_SRC=${HOME}/.cacerts/$ALIAS/$CERT_SERIAL/$CERT_FINGERPRINT
#  local CA_CERTS_SRC=/tmp/.cacerts/$ALIAS/$CERT_SERIAL/$CERT_FINGERPRINT
#  local CA_CERTS_SRC=/tmp/.cacerts/$ALIAS

  log_debug "CA_CERTS_SRC=${CA_CERTS_SRC}"

  log_debug "Recreate tmp cert dir ${CA_CERTS_SRC}"
  rm -fr "${CA_CERTS_SRC}"
  mkdir -p "${CA_CERTS_SRC}"

  log_debug "Get host cert for ${HOST}:${PORT}"
#  local HOST=$1
#  local PORT=$2
#  local CA_CERTS_SRC=$3
  local ALIAS="${HOST}_${PORT}"

  log_info "Fetching certs from host:port ${HOST}:${PORT}"

  if [ -z "$HOST" ]; then
    log_error "Must specify the host name to import the certificate in from, eventually followed by the port number, if other than 443."
    exit 1
  fi

  set -e

#  log_info "**** START : find ${CA_CERTS_SRC}/ -name cert*.crt"
#  eval "find ${CA_CERTS_SRC}/ -name cert*.crt"

#  if [ -e "$CA_CERTS_SRC/$ALIAS.crt" ]; then
#    rm -f "$CA_CERTS_SRC/$ALIAS.crt"
#  fi
#  if [ -e "$CA_CERTS_SRC/$ALIAS.pem" ]; then
#    rm -f "$CA_CERTS_SRC/$ALIAS.pem"
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
  log_debug "Fetching *.crt format certs from host:port ${HOST}:${PORT}"
#  local FETCH_CRT_CERT_COMMAND="echo QUIT | openssl s_client -connect ${HOST}:${PORT} -servername ${HOST} 1>${CA_CERTS_SRC}/${ALIAS}.crt"
  local FETCH_CRT_CERT_COMMAND="echo QUIT | openssl s_client -connect ${HOST}:${PORT} -servername ${HOST} </dev/null 2>/dev/null 1>${CA_CERTS_SRC}/${ALIAS}.crt"
#  log_info "${FETCH_CRT_CERT_COMMAND}"
#  eval "${FETCH_CRT_CERT_COMMAND}"
  execute_eval_command "${FETCH_CRT_CERT_COMMAND}"

  log_debug "Fetching *.pem format certs from host:port ${HOST}:${PORT}"
  FETCH_PEM_CERT_COMMAND="echo QUIT | openssl s_client -showcerts -servername ${HOST} -connect ${HOST}:${PORT}"
  FETCH_PEM_CERT_COMMAND+=" </dev/null 2>/dev/null | openssl x509 -outform PEM > ${CA_CERTS_SRC}/${ALIAS}.pem"
#  log_info "${FETCH_PEM_CERT_COMMAND}"
#  eval "${FETCH_PEM_CERT_COMMAND}"
  execute_eval_command "${FETCH_PEM_CERT_COMMAND}"

  ## ref: https://stackoverflow.com/questions/21297853/how-to-determine-ssl-cert-expiration-date-from-a-pem-encoded-certificate
#  local CERT_EXPIRATION_DATE=$(openssl x509 -enddate -noout -in ${CA_CERTS_SRC}/${ALIAS}.pem | cut -d= -f 2)
  local CERT_EXPIRATION_DATE="$(date --date="$(openssl x509 -enddate -noout -in ${CA_CERTS_SRC}/${ALIAS}.pem | cut -d= -f 2)" --iso-8601)"
  log_debug "CERT_EXPIRATION_DATE=${CERT_EXPIRATION_DATE}"

  log_info "Extracting certs from cert chain for ${HOST}:${PORT} "
  ## ref: https://unix.stackexchange.com/questions/368123/how-to-extract-the-root-ca-and-subordinate-ca-from-a-certificate-chain-in-linux
  openssl s_client -showcerts -verify 5 -connect "${HOST}:${PORT}" -servername "${HOST}" </dev/null 2>/dev/null \
    | awk -v certdir="${CA_CERTS_SRC}" '/BEGIN/,/END/{ if(/BEGIN/){a++}; out="cert"a".crt"; print >(certdir "/" out)}' && \
  for cert in ${CA_CERTS_SRC}/cert*.crt; do
    #    cert_name_prefix=$(echo "${cert%.*}")
    cert_name_prefix="${cert%.*}"
    log_debug "cert_name_prefix for cert ${cert} ==> ${cert_name_prefix}"
    cert_name_new="${cert_name_prefix}".$(openssl x509 -noout -subject -in $cert | \
      sed -n 's/\s//g; s/^.*CN=\(.*\)$/\1/; s/[ ,.*]/_/g; s/__/_/g; s/^_//g;p')."${CACERT_TRUST_FORMAT}"
    log_debug "cert ==> ${cert_name_new}"
    mv "${cert}" "${cert_name_new}"
#    cp -p "${cert}" "${cert_name_new}"
  done

  local SITE_CERT_LIST=$(get_site_cert_list "${CA_CERTS_SRC}")

  log_info "SITE_CERT_LIST=[${SITE_CERT_LIST}]"
  local CAT_CMD="cat ${SITE_CERT_LIST} > ${CA_CERTS_SRC}/full_chain.${CACERT_TRUST_FORMAT}"
#  log_info "${CAT_CMD}"
#  eval "${CAT_CMD}"
  execute_eval_command "${CAT_CMD}"
  openssl x509 -in "${CA_CERTS_SRC}/full_chain.${CACERT_TRUST_FORMAT}" -out "${CA_CERTS_SRC}/full_chain_sanitized.${CACERT_TRUST_FORMAT}"

  local FIND_CERTS_CMD="find ${CA_CERTS_SRC}/ -name cert*.crt"
#  log_debug "[${FIND_CERTS_CMD}]"
#  eval "${FIND_CERTS_CMD}"
  execute_eval_command "${FIND_CERTS_CMD}"
}

function import_jdk_cert() {
  local KEYSTORE=$1
  local CA_CERTS_SRC=$2
  local ALIAS=$3
  local KEYSTORE_PASS=${4:-"changeit"}

  log_info "Adding certs to keystore at [${KEYSTORE}]"

#  if $KEYTOOL -cacerts -list -storepass "${KEYSTORE_PASS}" -alias "${ALIAS}" >/dev/null; then
  if $KEYTOOL -list -storepass "${KEYSTORE_PASS}" -alias "${ALIAS}" >/dev/null; then
    log_info "Key with alias ${ALIAS} already found, removing old one..."

#   KEYTOOL_COMMAND="${KEYTOOL} -delete -alias ${ALIAS} -keystore ${KEYSTORE} -storepass ${KEYSTORE_PASS}"
#    KEYTOOL_COMMAND="${KEYTOOL} -delete -alias ${ALIAS} -cacerts -storepass ${KEYSTORE_PASS}"
    KEYTOOL_COMMAND="${KEYTOOL} -delete -alias ${ALIAS} -storepass ${KEYSTORE_PASS}"
    execute_eval_command "${KEYTOOL_COMMAND}"
  fi

  log_info "Keytool importing ${CACERT_TRUST_FORMAT} formatted cert"

#    KEYTOOL_COMMAND="${KEYTOOL} -import -noprompt -trustcacerts -cacerts \
#  KEYTOOL_COMMAND="${KEYTOOL} -import -noprompt -trustcacerts \
#    -keystore ${KEYSTORE} \
#    -storepass ${KEYSTORE_PASS} \
#    -alias ${ALIAS} \
#    -file ${CA_CERTS_SRC}/full_chain_sanitized.${CACERT_TRUST_FORMAT}"

#  KEYTOOL_COMMAND="${KEYTOOL} -import -noprompt -cacerts -trustcacerts \
  KEYTOOL_COMMAND="${KEYTOOL} -import -noprompt -trustcacerts \
    -storepass ${KEYSTORE_PASS} \
    -alias ${ALIAS} \
    -file ${CA_CERTS_SRC}/full_chain.${CACERT_TRUST_FORMAT}"

  execute_eval_command "${KEYTOOL_COMMAND}"

}

function install_java_cacerts() {
  local CA_CERTS_SRC=$1
  local ALIAS=$2
  local KEYSTORE_PASS=${3:-"changeit"}
  local __JAVA_HOME=${4:-""}

  log_info "Get default java JDK cacert location"

  log_debug "__JAVA_HOME=${__JAVA_HOME}"

  local JDK_KEYSTORE=$(get_java_keystore "${__JAVA_HOME}")
  log_debug "JDK_KEYSTORE=${JDK_KEYSTORE}"

  if [ ! -e "${JDK_KEYSTORE}" ]; then
    abort "JDK_KEYSTORE [$JDK_KEYSTORE] not found!"
  else
    log_debug "JDK_KEYSTORE found at [$JDK_KEYSTORE]"
  fi

  ### Now build list of cacert targets to update
  log_info "updating JDK certs at [${JDK_KEYSTORE}]..."
  import_jdk_cert "${JDK_KEYSTORE}" "${CA_CERTS_SRC}" "${ALIAS}" "${KEYSTORE_PASS}"

  if [ -f "${JDK_USER_KEYSTORE}" ]; then
    log_info "updating certs at [$JDK_USER_KEYSTORE]..."
    import_jdk_cert "${JDK_USER_KEYSTORE}" "${CA_CERTS_SRC}" "${ALIAS}" "${KEYSTORE_PASS}"
  fi
}

# ref: https://stackoverflow.com/questions/50768317/docker-pull-certificate-signed-by-unknown-authority
# ref: https://docs.docker.com/desktop/faqs/macfaqs/#how-do-i-add-tls-certificates
# ref: https://stackoverflow.com/questions/50768317/docker-pull-certificate-signed-by-unknown-authority
function install_docker_cacert() {
  local LOG_PREFIX="install_docker_cacert():"
  local CA_CERTS_SRC=$1
  local ENDPOINT=$2

  local DOCKER_CERT_DIR="/etc/docker/certs.d/${ENDPOINT}"
  mkdir -p "${DOCKER_CERT_DIR}"

  # shellcheck disable=SC2206
  CERTS=(${CA_CERTS_SRC}/cert*.pem)
  CA_ROOT_CERT=${CERTS[-1]}
  log_info "Located site root cert for ${ENDPOINT} ==> [${CA_ROOT_CERT}]"

  log_info "Copy ${ENDPOINT} site root cert to DOCKER_CERT_DIR=${DOCKER_CERT_DIR}"

  local COPY_CMD="cp ${CA_ROOT_CERT} ${DOCKER_CERT_DIR}/"
  log_info "[${COPY_CMD}]"
  eval "${COPY_CMD}"

  if [[ "$UNAME" == "darwin"* ]]; then
    local DOCKER_USER_CERT_DIR="${HOME}/.docker/certs.d/${ENDPOINT}"
    mkdir -p "${DOCKER_USER_CERT_DIR}"
    log_info "Copy ${ENDPOINT} site root cert to DOCKER_USER_CERT_DIR=${DOCKER_USER_CERT_DIR}"
    ## ref: https://docs.docker.com/desktop/faqs/macfaqs/#how-do-i-add-tls-certificates
    local COPY_CMD="cp ${CA_ROOT_CERT} ${DOCKER_USER_CERT_DIR}/"
    log_info "[${COPY_CMD}]"
    eval "${COPY_CMD}"
  fi
}

function install_cert_to_truststore() {
  local HOST=$1
  local PORT=$2
  local CA_CERTS_SRC=$3
  local KEYSTORE_PASS=${4:-"changeit"}

  local SITE_CERT_LIST=$(get_site_cert_list "${CA_CERTS_SRC}")
  log_info "SITE_CERT_LIST=[${SITE_CERT_LIST}]"

  if [[ "$UNAME" == "linux"* ]]; then
    local ROOT_CERT=$(find ${CA_CERTS_SRC}/ -name cert*.${CACERT_TRUST_FORMAT} | sort -nr | head -1)
#    log_info "copy ROOT_CERT ${ROOT_CERT} to CACERT_TRUST_IMPORT_DIR=${CACERT_TRUST_IMPORT_DIR}"
#    cp -p "${ROOT_CERT}" "${CACERT_TRUST_IMPORT_DIR}/"

    log_info "copy certs to CACERT_TRUST_IMPORT_DIR=${CACERT_TRUST_IMPORT_DIR}"

    local COPY_CMD="cp ${SITE_CERT_LIST} ${CACERT_TRUST_IMPORT_DIR}/"
#    log_info "[${COPY_CMD}]"
#    eval "${COPY_CMD}"
    execute_eval_command "${COPY_CMD}"

#    cp -p "${CA_CERTS_SRC}/"cert*."${CACERT_TRUST_FORMAT}" "${CACERT_TRUST_IMPORT_DIR}/"
#    log_info "Running [${CACERT_TRUST_COMMAND}]"
#    eval "${CACERT_TRUST_COMMAND}"
    execute_eval_command "${CACERT_TRUST_COMMAND}"

  elif [[ "$UNAME" == "darwin"* ]]; then
#    log_info "Adding cert to macOS system keychain"
#    #    sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" "/private/tmp/securly_SHA-256.crt"
#    sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" ${CA_CERTS_SRC}/${ALIAS}.crt

    log_info "Adding site cert to the current user's trust cert chain"
#    sudo security add-trusted-cert -d -r trustRoot -k "${HOME}/Library/Keychains/login.keychain" ${CA_CERTS_SRC}/${ALIAS}.crt

    # shellcheck disable=SC2206
    certs=(${CA_CERTS_SRC}/cert*.pem)
    ca_root_cert=${certs[-1]}
    log_info "Add the site root cert to the current user's trust cert chain ==> [${ca_root_cert}]"

    ## ref: https://apple.stackexchange.com/questions/80623/import-certificates-into-the-system-keychain-via-the-command-line
#    MACOS_CACERT_TRUST_COMMAND="sudo security add-trusted-cert -d -r trustRoot -k ${HOME}/Library/Keychains/login.keychain ${ca_root_cert}"
    MACOS_CACERT_TRUST_COMMAND="sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ${ca_root_cert}"

#    log_info "[${MACOS_CACERT_TRUST_COMMAND}]"
#    eval "${MACOS_CACERT_TRUST_COMMAND}"
    execute_eval_command "${MACOS_CACERT_TRUST_COMMAND}"

  elif [[ "$UNAME" == "cygwin" || "$UNAME" == "msys" ]]; then
    ## ref: https://docs.microsoft.com/en-us/troubleshoot/windows-server/identity/valid-root-ca-certificates-untrusted
#    local ROOT_CERT=$(ls -1 ${CA_CERTS_SRC}/cert*.pem | sort -nr | head -1)
    local ROOT_CERT=$(find ${CA_CERTS_SRC}/ -name cert*.pem | sort -nr | head -1)

    local WIN_CACERT_TRUST_COMMAND="certutil -addstore root ${ROOT_CERT}"
#    log_info "[${WIN_CACERT_TRUST_COMMAND}]"
#    eval "${WIN_CACERT_TRUST_COMMAND}"
    execute_eval_command "${WIN_CACERT_TRUST_COMMAND}"

    ## ref: https://serverfault.com/questions/722563/how-to-make-firefox-trust-system-ca-certificates?newreg=9c67967e3aa248f489c8c9b2cc4ac776
    #certutil -addstore Root ${CERT_DIR}/${HOST}.pem
    ## ref: https://superuser.com/questions/1031444/imPORTing-pem-certificates-on-windows-7-on-the-command-line/1032179
    #certutil –addstore -enterprise –f "Root" "${CERT_DIR}/${HOST}.pem"
    #certutil –addstore -enterprise –f "Root" "${ROOT_CERT}"

  fi

}

function setup_python_cacerts() {

  TIMESTAMP=$(date +%s)
  TEMP_PUBLIC="/tmp/public_roots.pem"
  TEMP_TRUSTED="/tmp/trusted_certs.pem"
  TEMP_COMBINED="/tmp/combined_ca.pem"

  OPENSSL_CAFILE=$(python3 -c 'import ssl; print(ssl.get_default_verify_paths().openssl_cafile)' 2>/dev/null || echo "")
  CERTIFI_CAFILE=$(python3 -m certifi 2>/dev/null || echo "")

  log_info "Paths: OpenSSL=${OPENSSL_CAFILE}, certifi=${CERTIFI_CAFILE}"

  # Step 1: Fetch fresh public roots
  log_info "Fetching fresh public roots from curl.se..."
  curl -s https://curl.se/ca/cacert.pem > "$TEMP_PUBLIC"
  cert_count=$(grep -c '^-----BEGIN CERTIFICATE-----' "$TEMP_PUBLIC" || echo "0")
  log_info "Fetched public roots: $cert_count certs."

  if [[ $cert_count -lt 100 ]]; then
    log_error "Fetched too few public certs ($cert_count)—network issue?"
    exit 1
  fi

  # Step 2: Export trusted certs from System Keychain
  log_info "Exporting trusted certs from Keychain..."
  if [[ "$UNAME" == "darwin"* ]]; then
    sudo security export -k /Library/Keychains/System.keychain -t certs -f pemseq -o "$TEMP_TRUSTED"
    if [[ ! -s "$TEMP_TRUSTED" ]]; then
      log_error "Export failed—check sudo/Keychain access."
      exit 1
    fi
  else
    cp -p "${CACERT_BUNDLE}" "${TEMP_TRUSTED}"
  fi

  trusted_count=$(grep -c '^-----BEGIN CERTIFICATE-----' "$TEMP_TRUSTED" || echo "0")
  log_info "Exported Keychain trusted certs: $trusted_count certs."

  # Step 3: Combine (simple cat; duplicates harmless for OpenSSL)
  log_info "Combining (no dedupe)..."
  cat "$TEMP_PUBLIC" "$TEMP_TRUSTED" > "$TEMP_COMBINED"
  total_count=$(grep -c '^-----BEGIN CERTIFICATE-----' "$TEMP_COMBINED" || echo "0")
  log_info "Combined total certs: $total_count."

  if [[ $total_count -lt 100 ]]; then
    log_error "Too few total certs ($total_count)—check exports."
    exit 1
  fi

  # Step 4: Backup & Update
  log_info "Updating bundles..."
  for BUNDLE in "$OPENSSL_CAFILE" "$CERTIFI_CAFILE"; do
    ## if any of the python bundles are using the system ca certs, then skip
    if [[ "$BUNDLE" == "${CACERT_BUNDLE}" ]]; then
      log_info "skipping - specified python bundle already uses system certs at ${CACERT_BUNDLE}"
    else
      if [[ -n "$BUNDLE" ]]; then
        cp -p "$BUNDLE" "${BUNDLE}.bak.${TIMESTAMP}" 2>/dev/null || true
        cp "$TEMP_COMBINED" "$BUNDLE"
        log_info "Updated $BUNDLE (backup: ${BUNDLE}.bak.${TIMESTAMP})."
      fi
    fi
  done

  # Step 5: Validation
  log_info "Validating bundle..."
  if openssl crl2pkcs7 -nocrl -certfile "$OPENSSL_CAFILE" >/dev/null 2>&1; then
    log_info "Bundle parses OK with OpenSSL."
  else
    log_error "Bundle parse failed—check for malformed PEM."
    exit 1
  fi

  # Cleanup
  rm -f "$TEMP_PUBLIC" "$TEMP_TRUSTED" "$TEMP_COMBINED"

}

function init_ca_vars() {
  local LOG_PREFIX="init_ca_vars():"

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

  log_debug "LINUX_OS_DIST=${OS_DIST}"
  log_debug "PLATFORM=${PLATFORM}"
  log_debug "DISTRO=${DISTRO}"
  log_debug "CACERT_TRUST_DIR=${CACERT_TRUST_DIR}"
  log_debug "CACERT_TRUST_IMPORT_DIR=${CACERT_TRUST_IMPORT_DIR}"
  log_debug "CACERT_BUNDLE=${CACERT_BUNDLE}"
  log_debug "CACERT_TRUST_COMMAND=${CACERT_TRUST_COMMAND}"

}

function install_site_certs() {
  local __INSTALL_SYSTEM_CACERTS=${1-0}
  local __INSTALL_DOCKER_CACERTS=${2-0}
  local __INSTALL_JDK_CACERTS=${3-0}
  local __INSTALL_PYTHON_CACERTS=${4-0}
  local __JAVA_HOME=${5-""}

  shift 5
  local __SITE_LIST=("$@")

  log_debug "__INSTALL_SYSTEM_CACERTS=${__INSTALL_SYSTEM_CACERTS}"
  log_debug "__INSTALL_DOCKER_CACERTS=${__INSTALL_DOCKER_CACERTS}"
  log_debug "__INSTALL_JDK_CACERTS=${__INSTALL_JDK_CACERTS}"
  log_debug "__INSTALL_PYTHON_CACERTS=${__INSTALL_PYTHON_CACERTS}"
  log_debug "__JAVA_HOME=${__JAVA_HOME}"

  if [ "${__INSTALL_SYSTEM_CACERTS}" -eq 1 ]; then
    if [ -d "${CACERT_TRUST_DIR}" ]; then
      log_info "Remove any broken/invalid sym links from ${CACERT_TRUST_DIR}/"
      find "${CACERT_TRUST_DIR}/" -xtype l -delete
    fi
  fi
  #local DATE=`date +&%%m%d%H%M%S`
  local DATE=$(date +%Y%m%d)

  for ENDPOINT_CONFIG in "${__SITE_LIST[@]}"; do
    log_debug "ENDPOINT_CONFIG=${ENDPOINT_CONFIG}"

    IFS=':' read -r -a array <<< "${ENDPOINT_CONFIG}"
    local HOST=${array[0]}
    local PORT=${array[1]:-443}

    log_debug "HOST=$HOST"
    log_debug "PORT=$PORT"

    local ENDPOINT="${HOST}:${PORT}"
    local ALIAS="${HOST}_${PORT}"

    local CA_CERTS_BASE_DIR="${HOME}/tmp/cacerts"

    if [ "${USE_TEMP_DIR}" -eq 1 ]; then
      #TEMP_DIR=$(mktemp -d "${SCRIPT_NAME_PREFIX}_XXXXXX" -p "${HOME}/tmp")
      TEMP_DIR=$(mktemp -d -p "${HOME}/tmp" "${SCRIPT_NAME_PREFIX}_XXXXXX")

      function cleanup_tmpdir() {
        test "${KEEP_TEMP_DIR:-0}" = 1 || rm -rf "${TEMP_DIR}"
      }

      trap cleanup_tmpdir INT TERM EXIT

      log_debug "TEMP_DIR=$TEMP_DIR"

      CA_CERTS_BASE_DIR="${TEMP_DIR}"
    fi

    mkdir -p "${CA_CERTS_BASE_DIR}"
    local CA_CERTS_SRC="${CA_CERTS_BASE_DIR}/${ALIAS}"

    log_info "CA_CERTS_SRC=${CA_CERTS_SRC}"
    log_info "ALIAS=${ALIAS}"
    log_info "ENDPOINT=${ENDPOINT}"

    fetch_site_cert_chain "${HOST}" "${PORT}" "${CA_CERTS_SRC}"

    if [ "${__INSTALL_SYSTEM_CACERTS}" -eq 1 ]; then
      install_cert_to_truststore "${HOST}" "${PORT}" "${CA_CERTS_SRC}" "${KEYSTORE_PASS}"
    fi
    if [ "${__INSTALL_JDK_CACERTS}" -eq 1 ]; then
      install_java_cacerts "${CA_CERTS_SRC}" "${ALIAS}" "${KEYSTORE_PASS}" "${__JAVA_HOME}"
    fi
    if [ "${__INSTALL_DOCKER_CACERTS}" -eq 1 ]; then
      install_docker_cacert "${CA_CERTS_SRC}" "${ENDPOINT}"
    fi
  done

  if [ "${__INSTALL_PYTHON_CACERTS}" -eq 1 ]; then
    setup_python_cacerts
  fi
}


function usage() {
  echo "Usage: ${SCRIPT_NAME} [options] [[ENDPOINT_CONFIG1] [ENDPOINT_CONFIG2] ...]"
  echo ""
  echo "       ENDPOINT_CONFIG[n] is a colon delimited tuple with SITE_HOSTNAME:SITE_PORT"
  echo ""
  echo "  Options:"
  echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG] : run with specified log level (default: '${LOGLEVEL_TO_STR[${LOG_LEVEL}]}')"
  echo "       -v : show script version"
  echo "       -d : setup cacerts in docker client config (/etc/docker/certs.d/) (default skip)"
  echo "       -i : skip java cacerts setup (default does not skip)"
  echo "       -j : specify JAVA_HOME (default sourced from environment variable if set)"
  echo "       -p : setup python cacerts (default skip)"
  echo "       -s : skip installing system cacerts (default does not skip)"
  echo "       -h : help"
  echo ""
  echo "  Examples:"
	echo "       ${SCRIPT_NAME} "
  echo "       ${SCRIPT_NAME} -v"
	echo "       ${SCRIPT_NAME} -L DEBUG"
	echo "       ${SCRIPT_NAME} cacert.example.com:443"
	echo "       ${SCRIPT_NAME} -L DEBUG updates.jenkins.io:443"
	echo "       ${SCRIPT_NAME} cacert.example.com:443 ca.example.int:443 registry.example.int:5000"
	echo "       ${SCRIPT_NAME} bitbucket.example.org.org:8443 updates.jenkins.io:443"
	echo "       ${SCRIPT_NAME} -s www.jetbrains.com"
	echo "       ${SCRIPT_NAME} -s -j /Applications/IntelliJ\ IDEA\ CE.app/Contents/jbr/Contents/Home/ www.jetbrains.com"
	[ -z "$1" ] || exit "$1"
}

function main() {

  if [[ "$UNAME" != "cygwin" && "$UNAME" != "msys" ]]; then
    if [ "$EUID" -ne 0 ]; then
      echo "Must run this script as root. run 'sudo $SCRIPT_NAME'"
      exit
    fi
  fi

  while getopts "L:vdij:psh" opt; do
      case "${opt}" in
          L) set_log_level "${OPTARG}" ;;
          v) echo "${VERSION}" && exit ;;
          d) INSTALL_DOCKER_CACERTS=1 ;;
          i) INSTALL_JDK_CACERTS=0 ;;
          j) JAVA_HOME="${OPTARG}" ;;
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

  log_info "__SITE_LIST=${__SITE_LIST[*]}"

  init_ca_vars

  log_info "UNAME=${UNAME}"
  log_debug "LINUX_OS_DIST=${LINUX_OS_DIST}"
  log_debug "PLATFORM=${PLATFORM}"
  log_debug "DISTRO=${DISTRO}"
  log_debug "CACERT_TRUST_DIR=${CACERT_TRUST_DIR}"
  log_debug "CACERT_TRUST_IMPORT_DIR=${CACERT_TRUST_IMPORT_DIR}"
  log_debug "CACERT_BUNDLE=${CACERT_BUNDLE}"
  log_debug "CACERT_TRUST_COMMAND=${CACERT_TRUST_COMMAND}"

  log_debug "JAVA_HOME=$JAVA_HOME"
  log_debug "TEMP_DIR=$TEMP_DIR"

  install_site_certs "${INSTALL_SYSTEM_CACERTS}" \
    "${INSTALL_DOCKER_CACERTS}" \
    "${INSTALL_JDK_CACERTS}" \
    "${INSTALL_PYTHON_CACERTS}" \
    "${JAVA_HOME}" \
    "${__SITE_LIST[@]}"
}

main "$@"
