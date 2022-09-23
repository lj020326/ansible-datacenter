#!/usr/bin/env bash

## sites referenced:
##
##  https://www.sslshopper.com/article-most-common-openssl-commands.html
##  https://www.ibm.com/support/knowledgecenter/en/SSWHYP_4.0.0/com.ibm.apimgmt.cmc.doc/task_apionprem_gernerate_self_signed_openSSL.html
##  https://redkestrel.co.uk/articles/openssl-commands/
##  https://www.thegeekstuff.com/2009/07/linux-apache-mod-ssl-generate-key-csr-crt-file/
##

CERT_DIR=certs
#SUBJECT="/C=US/ST=New York/L=New York City/O=MC-API/OU=Product/CN=dettonville.int"
SUBJECT="/C=US/ST=New York/L=New York City/O=MC-API/OU=Product/CN=${HOSTNAME}.corp.dettonville.org"
DAYS_TO_EXPIRE=365
#SITENAME=${1:-"${HOSTNAME}.corp.dettonville.org"}
SITENAME=${1:-"${HOSTNAME}"}

#cd $CERT_DIR
mkdir -p ${CERT_DIR}

echo "create the privatekey and certificate"
openssl req -newkey rsa:2048 -nodes -keyout ${CERT_DIR}/test.key -x509 -days $DAYS_TO_EXPIRE -out ${CERT_DIR}/test.crt -subj "$SUBJECT"

## https://support.asperasoft.com/hc/en-us/articles/216128468-OpenSSL-commands-to-check-and-verify-your-SSL-certificate-key-and-CSR
echo "Check certificate and return information about it (signing authority, expiration date, etc.):"
openssl x509 -in ${CERT_DIR}/test.crt -text -noout

echo "Check the SSL key and verify the consistency:"
openssl rsa -in ${CERT_DIR}/test.key -check

#echo "Verify the CSR and print CSR data filled in when generating the CSR:"
#openssl req -text -noout -verify -in ${CERT_DIR}/test.csr

echo "Verify a certificate and key matches"
echo "These two commands print out md5 checksums of the certificate and key; the checksums can be compared to verify that the certificate and key match."
echo "crt md5:"
openssl x509 -noout -modulus -in ${CERT_DIR}/test.crt| openssl md5
echo "key md5:"
openssl rsa -noout -modulus -in ${CERT_DIR}/test.key| openssl md5



