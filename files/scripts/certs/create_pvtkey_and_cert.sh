#!/usr/bin/env bash

## sites referenced:
##
##  https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs
##  https://www.sslshopper.com/article-most-common-openssl-commands.html
##  https://www.ibm.com/support/knowledgecenter/en/SSWHYP_4.0.0/com.ibm.apimgmt.cmc.doc/task_apionprem_gernerate_self_signed_openSSL.html
##  https://redkestrel.co.uk/articles/openssl-commands/
##  https://www.thegeekstuff.com/2009/07/linux-apache-mod-ssl-generate-key-csr-crt-file/
##

SERVER_NAME=${1-media.johnson.int}

CERT_DIR=certs
SUBJECT="/C=US/ST=New York/L=New York City/O=Dettonville/OU=Internal/CN=${SERVER_NAME}"
DAYS_TO_EXPIRE=365

#cd $CERT_DIR
mkdir -p $CERT_DIR

echo "create the privatekey and certificate"
openssl req \
        -newkey rsa:2048 -nodes -keyout $CERT_DIR/${SERVER_NAME}.key \
        -x509 -days 365 -out $CERT_DIR/${SERVER_NAME}.crt \
        -subj "$SUBJECT"

