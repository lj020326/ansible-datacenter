
#!/usr/bin/env bash

## sites referenced:
##
##  https://communities.vmware.com/thread/546223
##
##  https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs
##  https://www.sslshopper.com/article-most-common-openssl-commands.html
##  https://www.ibm.com/support/knowledgecenter/en/SSWHYP_4.0.0/com.ibm.apimgmt.cmc.doc/task_apionprem_gernerate_self_signed_openSSL.html
##  https://redkestrel.co.uk/articles/openssl-commands/
##  https://www.thegeekstuff.com/2009/07/linux-apache-mod-ssl-generate-key-csr-crt-file/
##

echo "create the privatekey and certificate"
openssl req -nodes -new -x509 -keyout rui.key -out rui.crt -days 3650 -config openssl.cnf
cp -p rui.crt rui.pem

CERTDIRS="sso vc ngc logbrowser vco vum"

for dir in $CERTDIRS
do
	mkdir -p ${dir}
    echo "copy certs to directory [$dir]"
    cp -p rui.{key,pem} ${dir}/
done

