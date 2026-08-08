#!/usr/bin/env bash

SCRIPT_NAME=$(basename $0)
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

CREDENTIALS=""
CONTEXT_PATH=""
LOG_LEVEL="INFO" # Default logging level

# --- Logging Functions ---
log_info() {
  echo -e "[INFO] $1"
}

log_debug() {
  if [[ "${LOG_LEVEL}" == "DEBUG" ]]; then
    echo -e "[DEBUG] $1"
  fi
}

usage() {
  retcode=${1:-1}
  echo "" 1>&2
  echo "Usage: ${SCRIPT_NAME} [options] host [port]" 1>&2
  echo "" 1>&2
  echo "     options:" 1>&2
  echo "       -c : provide credentials (username:password) to use for endpoint" 1>&2
  echo "       -p : provide context path to use for endpoint (e.g., 'v2/_catalog', 'api/v3', etc) " 1>&2
  echo "       -v : enable debug logging (shows variable printouts and curl verbose trace)" 1>&2
  echo "       -h : help" 1>&2
  echo "     host: hostname/ip of the endpoint to test (e.g., host01.example.int, 192.168.10.10, etc)" 1>&2
  echo "     port: port of the endpoint to test, default to 443 (e.g., 443, 5000, etc)" 1>&2
  echo "" 1>&2
  echo "  Examples:" 1>&2
  echo "     ${SCRIPT_NAME} gitlab.example.int" 1>&2
  echo "     ${SCRIPT_NAME} -v host01.example.int 443" 1>&2
  echo "     ${SCRIPT_NAME} -c username:password master.example.int" 1>&2
  echo "     ${SCRIPT_NAME} -c foo:bar -p v2/catalog registry.example.int" 1>&2
  echo "" 1>&2
  exit ${retcode}
}

while getopts "c:p:vh" opt; do
    case "${opt}" in
        c) CREDENTIALS=${OPTARG} ;;
        p) CONTEXT_PATH=${OPTARG} ;;
        v) LOG_LEVEL="DEBUG" ;;
        h) usage 1 ;;
        \?) usage 2 ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage 3
            ;;
        *)
            usage 4
            ;;
    esac
done
shift $((OPTIND-1))

if [ $# -lt 1 ]; then
    echo "required host not specified" >&2
    usage 5
fi

TARGET_HOST=${1:-gitea.admin.dettonville.int}
TARGET_PORT=${2:-443}

ENDPOINT="${TARGET_HOST}:${TARGET_PORT}"

CURL_CRED_ARGS=""
if [[ "${CREDENTIALS}" != "" ]]; then
  CURL_CRED_ARGS="-u ${CREDENTIALS}"
  CURL_CRED_ARGS_MASKED="-u ***:***"
fi

log_debug "SCRIPT_DIR=${SCRIPT_DIR}"
log_debug "CONTEXT_PATH=${CONTEXT_PATH}"
log_debug "TARGET_HOST=${TARGET_HOST}"
log_debug "TARGET_PORT=${TARGET_PORT}"
log_debug "ENDPOINT=${ENDPOINT}"

log_debug "Setting env related CACERT variables"

## https://stackoverflow.com/questions/26988262/best-way-to-find-the-os-name-and-version-on-a-unix-linux-platform#26988390
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
      if type "lsb_release" > /dev/null 2>&1; then
        LINUX_OS_DIST=$(lsb_release -a | tr "[:upper:]" "[:lower:]")
      else
        LINUX_OS_DIST=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr "[:upper:]" "[:lower:]")
      fi
      PLATFORM=LINUX
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
        *redhat* | *"red hat"* | *centos* | *fedora* )
          # RedHat Family
          CACERT_TRUST_DIR=/etc/pki/tls/certs
          #CACERT_TRUST_IMPORT_DIR=/etc/pki/ca-trust/extracted/openssl
          #CACERT_BUNDLE=${CACERT_TRUST_DIR}/ca-bundle.trust.crt
          #CACERT_TRUST_DIR=/etc/pki/ca-trust/extracted/pem
          CACERT_TRUST_IMPORT_DIR=/etc/pki/ca-trust/source/anchors
          #CACERT_BUNDLE=${CACERT_TRUST_DIR}/tls-ca-bundle.pem
          CACERT_BUNDLE=${CACERT_TRUST_DIR}/ca-bundle.trust.crt
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

log_debug "==> UNAME=${UNAME}"
log_debug "==> LINUX_OS_DIST=${OS_DIST}"
log_debug "==> PLATFORM=[${PLATFORM}]"
log_debug "==> DISTRO=[${DISTRO}]"
log_debug "==> CACERT_TRUST_DIR=${CACERT_TRUST_DIR}"
log_debug "==> CACERT_TRUST_IMPORT_DIR=${CACERT_TRUST_IMPORT_DIR}"
log_debug "==> CACERT_BUNDLE=${CACERT_BUNDLE}"
log_debug "==> CACERT_TRUST_COMMAND=${CACERT_TRUST_COMMAND}"

CURL_CA_OPTS="--capath ${CACERT_TRUST_DIR} --cacert ${CACERT_BUNDLE}"
log_debug "==> CURL_CA_OPTS=${CURL_CA_OPTS}"

# Define dynamic flags depending on LOG_LEVEL
if [[ "${LOG_LEVEL}" == "DEBUG" ]]; then
  CURL_VISIBILITY_FLAGS="-v"
  # Show certificate data only in debug/verbose mode
  log_info "==========================="
  log_info "*** certificate information for endpoint: ${ENDPOINT}"
  openssl s_client -servername "${TARGET_HOST}" -connect "${ENDPOINT}" < /dev/null 2>/dev/null | openssl x509 -text -noout
else
  # Use verbose flag internally anyway so we always capture details on failure,
  # but we suppress standard output using redirection unless needed.
  CURL_VISIBILITY_FLAGS="-v"
fi

# Define a reusable filter to mask the Authorization header (covers both standard verbose and HTTP/2 trace formats)
MASK_AUTH_FILTER="sed -E -e 's/([Aa]uthorization: [Bb]asic) [A-Za-z0-9+\/=_=-]+/\1 ********************/g' -e 's/(\[authorization: [Bb]asic) [A-Za-z0-9+\/=_=-]+(\])/\1 ********************\2/g'"

# Setup a secure temporary file to catch the output traces
CURL_OUTPUT_TMP=$(mktemp)
trap 'rm -f "${CURL_OUTPUT_TMP}"' EXIT

# ==============================================================================
# TEST 1: Without Certificate Validation
# ==============================================================================
log_info "==========================="
log_info "*** curl w/auth w/o certificate validation for endpoint: ${ENDPOINT}"

CURL_CMD="curl -kIsSL ${CURL_VISIBILITY_FLAGS} ${CURL_CRED_ARGS} https://${ENDPOINT}/${CONTEXT_PATH}"
CURL_CMD_MASKED="curl -kIsSL ${CURL_VISIBILITY_FLAGS} ${CURL_CRED_ARGS_MASKED} https://${ENDPOINT}/${CONTEXT_PATH}"
log_info "Running: ${CURL_CMD_MASKED}"

# Redirect stderr (and stdout headers) to temporary file
eval "${CURL_CMD}" > "${CURL_OUTPUT_TMP}" 2>&1
TEST1_RC=$?

if [ ${TEST1_RC} -eq 0 ]; then
  # If it succeeded, only display the details if LOG_LEVEL is explicitly DEBUG
  if [[ "${LOG_LEVEL}" == "DEBUG" ]]; then
    eval "${MASK_AUTH_FILTER}" < "${CURL_OUTPUT_TMP}" >&2
  fi
  log_info ">> TEST RESULT (No Cert Validation): SUCCESS"
else
  # On failure, dump the captured trace filtered via our masking filter
  eval "${MASK_AUTH_FILTER}" < "${CURL_OUTPUT_TMP}" >&2
  log_info ">> TEST RESULT (No Cert Validation): FAIL (Exit Code: ${TEST1_RC})"
fi

# ==============================================================================
# TEST 2: With Certificate Validation
# ==============================================================================
printf "\n"
log_info "==========================="
log_info "*** curl w/auth w/certificate validation for endpoint: ${ENDPOINT}"

if [[ "$PLATFORM" == "LINUX" ]]; then
  CURL_CMD="curl -sSL ${CURL_VISIBILITY_FLAGS} ${CURL_CRED_ARGS} ${CURL_CA_OPTS} https://${ENDPOINT}/${CONTEXT_PATH}"
  CURL_CMD_MASKED="curl -sSL ${CURL_VISIBILITY_FLAGS} ${CURL_CRED_ARGS_MASKED} ${CURL_CA_OPTS} https://${ENDPOINT}/${CONTEXT_PATH}"
elif [[ "$UNAME" == "darwin"* ]]; then
  CURL_CMD="curl -sSL ${CURL_VISIBILITY_FLAGS} ${CURL_CRED_ARGS} https://${ENDPOINT}/${CONTEXT_PATH}"
  CURL_CMD_MASKED="curl -sSL ${CURL_VISIBILITY_FLAGS} ${CURL_CRED_ARGS_MASKED} https://${ENDPOINT}/${CONTEXT_PATH}"
else
  CURL_CMD="curl -sSL ${CURL_VISIBILITY_FLAGS} ${CURL_CRED_ARGS} https://${ENDPOINT}/${CONTEXT_PATH}"
  CURL_CMD_MASKED="curl -sSL ${CURL_VISIBILITY_FLAGS} ${CURL_CRED_ARGS_MASKED} https://${ENDPOINT}/${CONTEXT_PATH}"
fi
log_info "Running: ${CURL_CMD_MASKED}"

# Clear temp file before next test run
> "${CURL_OUTPUT_TMP}"

eval "${CURL_CMD}" > "${CURL_OUTPUT_TMP}" 2>&1
TEST2_RC=$?

if [ ${TEST2_RC} -eq 0 ]; then
  if [[ "${LOG_LEVEL}" == "DEBUG" ]]; then
    eval "${MASK_AUTH_FILTER}" < "${CURL_OUTPUT_TMP}" >&2
  fi
  log_info ">> TEST RESULT (With Cert Validation): SUCCESS"
else
  eval "${MASK_AUTH_FILTER}" < "${CURL_OUTPUT_TMP}" >&2
  log_info ">> TEST RESULT (With Cert Validation): FAIL (Exit Code: ${TEST2_RC})"
fi
