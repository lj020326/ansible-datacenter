#!/usr/bin/env bash

## sites referenced:
##
##  https://www.sslshopper.com/article-most-common-openssl-commands.html
##  https://www.ibm.com/support/knowledgecenter/en/SSWHYP_4.0.0/com.ibm.apimgmt.cmc.doc/task_apionprem_gernerate_self_signed_openSSL.html
##  https://redkestrel.co.uk/articles/openssl-commands/
##  https://www.thegeekstuff.com/2009/07/linux-apache-mod-ssl-generate-key-csr-crt-file/
##

CERT_DIR=certs
SUBJECT="/C=US/ST=New York/L=New York City/O=Global Security/OU=IT Department/CN=example.com"
ALIASNAME="myalias123"
PASSWD="password123"
DAYS_TO_EXPIRE=365

#cd $CERT_DIR
mkdir -p $CERT_DIR

echo "create the privatekey and certificate"
#openssl req -newkey rsa:2048 -nodes -keyout privatekey.pem -x509 -days 365 -out certificate.pem -subj "/C=US/ST=New York/L=New York City/O=Global Security/OU=IT Department/CN=example.com"
openssl req -newkey rsa:2048 -nodes -keyout $CERT_DIR/privatekey.pem -x509 -days 365 -out $CERT_DIR/certificate.pem -subj "$SUBJECT"

#echo "create the CSR"
##openssl req -new -key privatekey.pem -out csr.pem -subj "/C=US/ST=New York/L=New York City/O=Global Security/OU=IT Department/CN=example.com"
#openssl req -new -key privatekey.pem -out csr.pem -subj "/C=US/ST=New York/L=New York City/O=Global Security/OU=IT Department/CN=example.com"

echo "Generate a certificate signing request (CSR) based on an existing certificate"
openssl x509 -x509toreq -in $CERT_DIR/certificate.pem -out $CERT_DIR/csr.pem -signkey $CERT_DIR/privatekey.pem

#echo "create the privatekey and CSR"
## to generate a new private key and Certificate Signing Request
#openssl req -out csr.pem -new -newkey rsa:2048 -nodes -keyout privatekey.pem
#openssl req -out csr.pem -new -newkey rsa:2048 -nodes -keyout privatekey.pem -days ${DAYS_TO_EXPIRE} -subj "${SUBJECT}"
#openssl req -out csr.pem -new -newkey rsa:2048 -nodes -keyout privatekey.pem -x509 -sha256 -days 365 -out certificate.pem  -subj "${SUBJECT}"

echo "Verify the CSR"
echo "****"
openssl req -text -noout -verify -in $CERT_DIR/csr.pem
echo "****"

#echo "create the p12"
##openssl pkcs12 -inkey privatekey.pem -in certificate.pem -export -out certificate.p12 -name myaliasname123 -passout pass:password123
##openssl pkcs12 -inkey privatekey.pem -export -out certificate.p12 -name ${ALIASNAME} -passout pass:"${PASSWD}"
#openssl pkcs12 -inkey privatekey.pem -export -out certificate.p12 -name ${ALIASNAME} -passout pass:password123

echo "Combine your key and certificate in a PKCS#12 (P12) bundle"
#openssl pkcs12 -inkey privatekey.pem -in certificate.pem -export -out certificate.p12 -passout pass:password123
openssl pkcs12 -inkey $CERT_DIR/privatekey.pem -in $CERT_DIR/certificate.pem -export -out $CERT_DIR/certificate.p12 -name "${ALIASNAME}" -passout "pass:${PASSWD}"

echo "Validate the P12 file..."
echo "****"
openssl pkcs12 -in $CERT_DIR/certificate.p12 -noout -info -passin "pass:${PASSWD}"

echo "****"
echo "Create package with certs"
tar -zcvf certs.tgz "${CERT_DIR}"


