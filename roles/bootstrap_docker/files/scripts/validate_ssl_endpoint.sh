#!/usr/bin/env bash

SCRIPT_NAME=$(basename $0)
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "SCRIPT_DIR=${SCRIPT_DIR}"

CREDENTIALS=""
CONTEXT_PATH=""

usage() {
  retcode=${1:-1}
  echo "" 1>&2
  echo "Usage: ${SCRIPT_NAME} [options] host [port]" 1>&2
  echo "" 1>&2
  echo "     options:" 1>&2
  echo "       -c : provide credentials (username:password) to use for endpoint" 1>&2
  echo "       -p : provide context path to use for endpoint (e.g., 'v2/_catalog', 'api/v3', etc) " 1>&2
  echo "       -h : help" 1>&2
  echo "     host: hostname/ip of the endpoint to test (e.g., host01.example.int, 192.168.10.10, etc)" 1>&2
  echo "     port: port of the endpoint to test, default to 443 (e.g., 443, 5000, etc)" 1>&2
  echo "" 1>&2
  echo "  Examples:" 1>&2
  echo "     ${SCRIPT_NAME} gitlab.example.int" 1>&2
  echo "     ${SCRIPT_NAME} host01.example.int 443" 1>&2
  echo "     ${SCRIPT_NAME} -c username:password leader.example.int" 1>&2
  echo "     ${SCRIPT_NAME} -c foo:bar -p v2/catalog registry.example.int" 1>&2
  echo "" 1>&2
  exit ${retcode}
}

while getopts "c:p:h" opt; do
    case "${opt}" in
        c) CREDENTIALS=${OPTARG} ;;
        p) CONTEXT_PATH=${OPTARG} ;;
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
fi

echo "CONTEXT_PATH=${CONTEXT_PATH}"
echo "CREDENTIALS=${CREDENTIALS}"
echo "TARGET_HOST=${TARGET_HOST}"
echo "TARGET_PORT=${TARGET_PORT}"
echo "ENDPOINT=${ENDPOINT}"


echo "Setting env related CACERT variables"
source ${SCRIPT_DIR}/get_curl_ca_opts.sh

echo "*******************"
echo "getting cert info from endpoint ${ENDPOINT}"
openssl s_client -servername ${TARGET_HOST} -connect ${ENDPOINT} < /dev/null 2>/dev/null | openssl x509 -text -noout

## ref: https://stackoverflow.com/questions/7885785/using-openssl-to-get-the-certificate-from-a-server
#openssl s_client -connect ${ENDPOINT} -key our_private_key.pem -showcerts -cert our_server-signed_cert.pem

echo "*******************"
echo "*******************"
echo "*******************"
echo "performing curl without cert validation on endpoint ${ENDPOINT}"
curlCmd="curl -vkIsSL ${CURL_CRED_ARGS} https://${ENDPOINT}/${CONTEXT_PATH}"
echo "${curlCmd}"
${curlCmd}

echo "*******************"
echo "*******************"
echo "*******************"
echo "performing curl with cert validation on endpoint ${ENDPOINT}"
## ref: https://stackoverflow.com/questions/11548336/openssl-verify-return-code-20-unable-to-get-local-issuer-certificate/39536777
#echo "curl -vIsS --capath ${CACERT_TRUST_DIR} --cacert ${CACERT} https://${ENDPOINT}/${CONTEXT_PATH}"
#curl -vIsS --capath ${CACERT_TRUST_DIR} --cacert ${CACERT} https://${ENDPOINT}/${CONTEXT_PATH}
#curl -vIsSL --capath ${CACERT_TRUST_DIR} --cacert ${CACERT} -vsSL https://${ENDPOINT}/${CONTEXT_PATH}

curlCmd="curl -vs ${CURL_CRED_ARGS} ${CURL_CA_OPTS} https://${ENDPOINT}/${CONTEXT_PATH}"
echo "${curlCmd} | jq"
${curlCmd} | jq
