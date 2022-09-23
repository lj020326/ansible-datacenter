#!/usr/bin/env bash


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "SCRIPT_DIR=[${SCRIPT_DIR}]"

#set -x

## ref: https://stackoverflow.com/questions/3685548/java-keytool-easy-way-to-add-server-cert-from-url-port
##

SCRIPT_NAME=`basename $0`

if [ "$EUID" -ne 0 ]; then
    echo "Must run this script as root. run 'sudo $SCRIPT_NAME'"
    exit
fi

#HOST=myhost.example.com
#HOST=artifactory.dev.dettonville.int
#HOST=www.jetbrains.com

HOST=${1:-"repository.dettonville.int"}
PORT=${2:-"443"}
KEYSTORE_PASS=${3:-"changeit"}

#DATE=`date +&%%m%d%H%M%S`
DATE=`date +%Y%m%d`

IDE_KEYSTORE_LIST=$(find ${HOME}/Library/Caches/ -type f -name cacerts)
#IDE_KEYSTORE="${HOME}/Library/Caches/IdeaIC2017.3/tasks/cacerts"

KEYTOOL=keytool

ALIAS=$HOST:$PORT

CACERTS_SRC=${HOME}/.cacerts/$ALIAS/$DATE

if [ ! -d $CACERTS_SRC ]; then
    mkdir -p $CACERTS_SRC
fi

TMP_OUT=/tmp/${SCRIPT_NAME}.output

### functions followed by main

function get_java_keystore() {
    ## default jdk location
    JAVA_HOME=$(/usr/libexec/java_home)
    CERT_DIR=${JAVA_HOME}/lib/security/cacerts
    if [ ! -d $CERT_DIR ]; then
        CERT_DIR=${JAVA_HOME}/jre/lib/security
    fi

#    echo "CERT_DIR=[$CERT_DIR]"

    echo $CERT_DIR/cacerts
}


function get_host_cert() {
    local HOST=$1
    local PORT=$2

    echo "retrieving certs from host:port ${HOST}:${PORT}"

    if [ -z "$HOST" ]
        then
        echo "ERROR: Please specify the server name to import the certificate in from, eventually followed by the port number, if other than 443."
        exit 1
        fi

    set -e

    if [ -e "$CACERTS_SRC/$ALIAS.pem" ]
    then
        rm -f $CACERTS_SRC/$ALIAS.pem
    fi

        if openssl s_client -connect $HOST:$PORT 1>$CACERTS_SRC/$ALIAS.crt 2>$TMP_OUT </dev/null
            then
            :
            else
            cat $CACERTS_SRC/$ALIAS.crt
            cat $TMP_OUT
            exit 1
            fi

        if sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' <$CACERTS_SRC/$ALIAS.crt > $CACERTS_SRC/$ALIAS.pem
            then
            :
            else
            echo "ERROR: Unable to extract the certificate from $CACERTS_SRC/$ALIAS.crt ($?)"
            cat $TMP_OUT
            exit 1
            fi

}


function import_jdk_cert() {
    KEYSTORE=$1

    echo --- Adding certs to keystore at [$KEYSTORE]

    if $KEYTOOL -list -keystore $KEYSTORE -storepass ${KEYSTORE_PASS} -alias $ALIAS >/dev/null
        then
        echo "Key of $HOST already found, removing old one..."
        if $KEYTOOL -delete -alias $ALIAS -keystore $KEYSTORE -storepass ${KEYSTORE_PASS} >$TMP_OUT
            then
            :
            else
            echo "ERROR: Unable to remove the existing certificate for $ALIAS ($?)"
            cat $TMP_OUT
            exit 1
            fi
        fi

    {
        echo "importing pem"
        ${KEYTOOL} -import -trustcacerts -noprompt -keystore ${KEYSTORE} -storepass ${KEYSTORE_PASS} -alias ${ALIAS} -file ${CACERTS_SRC}/${ALIAS}.pem >$TMP_OUT
    } || {  # catch
        echo "*** failed to import pem - so lets try to import the crt instead..."
        ${KEYTOOL} -import -trustcacerts -noprompt -keystore ${KEYSTORE} -storepass ${KEYSTORE_PASS} -alias ${ALIAS} -file ${CACERTS_SRC}/${ALIAS}.pem >$TMP_OUT && ${KEYTOOL} -import -trustcacerts -noprompt -keystore ${KEYSTORE} -storepass ${KEYSTORE_PASS} -alias ${ALIAS} -file ${CACERTS_SRC}/${ALIAS}.crt >$TMP_OUT
    }

#    if ${KEYTOOL} -import -trustcacerts -noprompt -keystore ${KEYSTORE} -storepass ${KEYSTORE_PASS} -alias ${ALIAS} -file ${CACERTS_SRC}/${ALIAS}.pem >$TMP_OUT
    if [ $? ]
        then
        :
        else
        echo "ERROR: Unable to import the certificate for $ALIAS ($?)"
        cat $TMP_OUT
        exit 1
        fi

}

main() {

    echo "Running for HOST=[$HOST] PORT=[$PORT] KEYSTORE_PASS=[$KEYSTORE_PASS]..."

    echo "Get default java JDK cacert location"
    #JDK_KEYSTORE=$CERT_DIR/cacerts
    JDK_KEYSTORE=$(get_java_keystore)

    if [ ! -e $JDK_KEYSTORE ]; then
        echo "JDK_KEYSTORE [$JDK_KEYSTORE] not found!"
        exit 1
    else
        echo "JDK_KEYSTORE found at [$JDK_KEYSTORE]"
    fi

    echo "Get host cert"
    get_host_cert ${HOST} ${PORT}

    ### Now build list of cacert targets to update
    echo "updating JDK certs at [$JDK_KEYSTORE]..."
    import_jdk_cert $JDK_KEYSTORE

    echo "updating IDE certs at [$IDE_KEYSTORE_LIST]..."
    for ide_cacert_loc in ${IDE_KEYSTORE_LIST}
    do
        import_jdk_cert $ide_cacert_loc
    done

    # FYI: the default keystore is located in ~/.keystore
    DEFAULT_KEYSTORE="~/.keystore"
    if [ -f $DEFAULT_KEYSTORE ]; then
        echo "updating default certs at [$DEFAULT_KEYSTORE]..."
        import_jdk_cert $DEFAULT_KEYSTORE
    fi

    echo "Adding cert to macOS system keychain"
    ROOT_CERT=$(ls -1 ${CACERTS_SRC}/cert*.pem | sort -nr | head -1)
    echo "Add the site root cert to the current user's trust cert chain ==> [${ROOT_CERT}]"
    ## ref: https://apple.stackexchange.com/questions/80623/import-certificates-into-the-system-keychain-via-the-command-line
    sudo security add-trusted-cert -d -r trustRoot -k "${HOME}/Library/Keychains/login.keychain" ${ROOT_CERT}

    echo "**** Finished ****"
}

main
