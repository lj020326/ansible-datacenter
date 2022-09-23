#!/usr/bin/env bash


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "SCRIPT_DIR=[${SCRIPT_DIR}]"

#set -x

## ref: https://stackoverflow.com/questions/3685548/java-keytool-easy-way-to-add-server-cert-from-url-port
##

SCRIPT_NAME=`basename $0`

#if [ "$EUID" -ne 0 ]; then
#    echo "Must run this script as root. run 'sudo $SCRIPT_NAME'"
#    exit
#fi

#HOST=myhost.example.com
#HOST=artifactory.dev.dettonville.int
#HOST=www.jetbrains.com
#HOST=${1:-"repository.dettonville.int"}

HOST=${1:-"registry.admin.dettonville.int"}
PORT=${2:-"443"}

LOG_DATE=`date +%Y%m%d%H%M%S`
DATE=`date +%Y%m%d`

ALIAS=$HOST:$PORT

#CACERTS_SRC=${HOME}/.cacerts/$ALIAS/$DATE
CACERTS_SRC=${HOME}/.cacerts/$ALIAS

if [ ! -d $CACERTS_SRC ]; then
    mkdir -p $CACERTS_SRC
fi

TMP_OUT=/tmp/${SCRIPT_NAME}.${LOG_DATE}.output

### functions followed by main

function get_host_cert() {
    local HOST=$1
    local PORT=$2

    echo "retrieving cert chain certs from host:port ${HOST}:${PORT}"

    if [ -z "$HOST" ]
        then
        echo "ERROR: Please specify the server name to import the certificate in from, eventually followed by the port number, if other than 443."
        exit 1
    fi

    if [ -e "$CACERTS_SRC/$ALIAS.pem" ]; then
      rm -f $CACERTS_SRC/$ALIAS.pem
    fi

    echo "fetching and extracting certs from cert chain for ${HOST}:${PORT}"
    ## ref: https://unix.stackexchange.com/questions/368123/how-to-extract-the-root-ca-and-subordinate-ca-from-a-certificate-chain-in-linux
    ## ref: https://kulkarniamit.github.io/whatwhyhow/howto/verify-ssl-tls-certificate-signature.html
    openssl s_client -showcerts -verify 5 -connect $HOST:$PORT </dev/null | \
    awk -v certdir=$CACERTS_SRC '/BEGIN/,/END/{ if(/BEGIN/){a++}; out="cert"a".crt"; print >(certdir "/" out)}'
    for cert in ${CACERTS_SRC}/cert*.crt; do
      #    nameprefix=$(echo "${cert%.*}")
      nameprefix="${cert%.*}"
      newname=${nameprefix}.$(openssl x509 -noout -subject -in $cert | sed -n 's/\s//g; s/^.*CN=\(.*\)$/\1/; s/[ ,.*]/_/g; s/__/_/g; s/^_//g;p').pem
      #    mv $cert $CACERTS_SRC/$newname
      mv $cert $newname
    done

    echo "Done retrieving cert chain certs from host:port ${HOST}:${PORT}"
}

main() {

    echo "Running for HOST=[$HOST] PORT=[$PORT]"

    echo "Get host cert chain"
    get_host_cert ${HOST} ${PORT}

    certs=(${CACERTS_SRC}/cert*.pem)
    ca_root_cert=${certs[-1]}
    echo "Add the site root cert to the current user's trust cert chain ==> [${ca_root_cert}]"
    sudo security add-trusted-cert -d -r trustRoot -k "${HOME}/Library/Keychains/login.keychain" ${ca_root_cert}

##    files=(/var/logs/foo*.log)
##    for ((i=${#files[@]}-1; i>=0; i--)); do
##    for cert in ${CACERTS_SRC}/cert*.pem; do
#    ls ${CACERTS_SRC}/cert*.pem | tac | while read cert; do
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


    echo "**** Finished ****"
}

main
