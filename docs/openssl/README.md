
# Openssl info

## How to reset ca-certificates bundle

How to reset ca-certificates bundle:

	centos/redhat
		https://access.redhat.com/solutions/1549003

## Most common openssl commands

Most common openssl commands:

	https://www.sslshopper.com/article-most-common-openssl-commands.html

## Get cert info from site

Get cert info from site:

### All cert info

```shell
openssl s_client -showcerts -servername jenkins.admin.dettonville.int -connect jenkins.admin.dettonville.int:8443 2>/dev/null | openssl x509 -inform pem -noout -text

openssl s_client -showcerts -servername gitea.admin.dettonville.int -connect gitea.admin.dettonville.int:8443 2>/dev/null | openssl x509 -inform pem -noout -text

openssl s_client -showcerts -servername gitea.media.johnson.int -connect gitea.media.johnson.int:443 2>/dev/null | openssl x509 -inform pem -noout -text

```

### cert serial number

```shell
openssl s_client -showcerts -servername jenkins.admin.dettonville.int -connect jenkins.admin.dettonville.int:8443 2>/dev/null | openssl x509 -inform pem -noout -serial
```

## Get cert info from site

Get cert info from site:

ref: https://serverfault.com/questions/661978/displaying-a-remote-ssl-certificate-details-using-cli-tools

```shell
site=heimdall.media.johnson.int:443
echo "site=${site}"

IFS=':' read -r -a array <<< "${site}"
host=${array[0]}
port=${array[1]}

openssl s_client -showcerts \
	-servername ${host} \
	-connect ${site} 2>/dev/null \
	| openssl x509 -inform pem -noout -text

```


## Display/Check certificate info from cert file (pem/crt)

Display/Check certificate info from cert file (pem/crt):

```shell
openssl x509 -text -noout -in certificate.crt
## or
openssl x509 -text -noout -in caroot/ca.pem
```

## Check/display csr info

Check/display csr info:

```shell
openssl req -text -noout -in johnson.int.csr
```

## How to create ca cert chain with intermediate certs

How to create ca cert chain with intermediate certs:

	ref: https://stackoverflow.com/questions/13295585/openssl-certificate-verification-on-linux
	ref: https://stackoverflow.com/questions/53881437/invalid-ca-certificate-with-self-signed-certificate-chain

	Using ansible:
		ref: https://github.com/Jooho/ansible-role-generate-self-signed-cert
		ref: https://www.jeffgeerling.com/blog/2017/generating-self-signed-openssl-certs-ansible-24s-crypto-modules

1) Create root CA certificate by these commands:

    ```shell
    openssl genrsa -aes256 -out ca.key 4096
    openssl req -new -x509 -days 3000 -key ca.key -out ca.crt -config ca.conf
    ##openssl req -new -x509 -extensions v3_ca -days 3000 -key ca.key -out ca.crt -config ca.conf -extfile ca.conf
    ```

    ca.conf:
    ```ini
    [ req ]
    distinguished_name = req_distinguished_name
    x509_extensions = v3_ca
    dirstring_type = nobmp
    [ req_distinguished_name ]
    commonName = Common Name (eg, YOUR name)
    commonName_default = root
    [ v3_ca ]
    keyUsage=critical, keyCertSign
    subjectKeyIdentifier=hash
    authorityKeyIdentifier=keyid:always,issuer:always
    basicConstraints=critical,CA:TRUE,pathlen:1
    extendedKeyUsage=serverAuth
    ```

    More Basic Setup:
    ```shell
    openssl req -newkey rsa:2048 -sha256 -keyout rootkey.pem -out rootreq.pem
    openssl x509 -req -in rootreq.pem -sha256 -signkey rootkey.pem -out rootcert.pem
    ```

    Aside: Install CA certificate as trusted certificate by following commands:
    ```shell
    sudo mkdir /usr/share/ca-certificates/extra
    sudo cp rootcert.pem /usr/share/ca-certificates/extra/rootcert.crt
    sudo dpkg-reconfigure ca-certificates
    sudo update-ca-certificates
    ```

2) Create intermediate certificate signed by root CA by following commands:

    ```shell
    # intermediate cert signed with the root cert
    openssl genrsa -aes256 -out int.key 4096
    openssl req -new -key int.key -out int.csr -config intermediate.conf
    openssl x509 -req -days 3000 -in int.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out int.crt
    ```

    intermediate.conf:
    ```ini
    [ req ]
    distinguished_name = req_distinguished_name
    x509_extensions = ext
    [ req_distinguished_name ]
    commonName = Common Name (eg, YOUR name)
    commonName_default = int
    [ ext ]
    keyUsage=critical, keyCertSign
    subjectKeyIdentifier=hash
    authorityKeyIdentifier=keyid:always,issuer:always
    basicConstraints=CA:TRUE,pathlen:0
    extendedKeyUsage=serverAuth
    ```

    Other - Very Basic:
    ```shell
    openssl req -newkey rsa:2048 -sha256 -keyout skey.pem -out sreq.pem
    sudo openssl x509 -req -in sreq.pem -sha256 -CA /etc/ssl/certs/rootcert.pem -CAkey rootkey.pem -CAcreateserial -out scert.pem
    ```

3) Created leaf/client certificate signed by intermediate CA by following commands:

    ```shell
    openssl genrsa -aes256 -out leaf.key 4096
    openssl req -new -key leaf.key -out leaf.csr -config leaf.conf
    openssl x509 -req -days 3000 -in leaf.csr -CA int.crt -CAkey int.key -set_serial 01 -out leaf.crt
	
    cat ca.crt int.crt leaf.crt > all.crt
    ```

    leaf.conf:
    ```ini
    [ req ]
    distinguished_name = req_distinguished_name
    dirstring_type = nobmp
    [ req_distinguished_name ]
    commonName = Common Name (eg, YOUR name)
    commonName_default = leaf
    ```

    Other - Very Basic:
    ```shell
    openssl req -newkey rsa:2048 -sha256 -keyout ckey.pem -out creq.pem
    openssl x509 -req -in creq.pem -sha256 -CA scert.pem -CAkey skey.pem -CAcreateserial -out ccert.pem
    ```

Now, Chain Of Trust is working fine:

1) Verify root CA

    ```shell
    openssl verify ca.crt 
    ca.crt: OK
    #openssl verify rootcert.pem 
    #rootcert.pem: OK
    ```

2) Verify intermediate CA

    ```shell
    openssl verify int.crt 
    int.crt: OK
    #openssl verify scert.pem 
    #scert.pem: OK
    ```

3) Verify client certificate

    ```shell
    openssl verify -CAfile int.crt leaf.crt
    leaf.crt: OK
    #openssl verify -CAfile scert.pem ccert.pem
    #ccert.pem: OK
    ## 
    ## Warning, the certificate chain verification commands above are more permissive that you might expect! 
    ## By default, in addition to checking the given CAfile, they also check for any matching CAs in the system's certs directory 
    ## e.g. /etc/ssl/certs. 
    ## To prevent this behavior and make sure you're checking against your particular CA cert, also pass a -CApath option with a non-existant directory
    ## E.g., 
    ## openssl verify -CApath nosuchdir -CAfile scert.pem ccert.pem
    ##
    ```

4) Verify cert chain:
    ref: https://medium.com/@superseb/get-your-certificate-chain-right-4b117a9c0fce

    ```shell
    cat cert.pem intermediate.pem > chain.pem
    openssl verify -untrusted chain.pem cert.pem
    ```

    e.g.,

    ```shell
    root@admin2:[media.johnson.int]$ openssl verify -CAfile ../caroot/caroot.pem -untrusted ../johnson.int/johnson.int.pem  media.johnson.int.pem
    media.johnson.int.pem: OK
    root@admin2:[media.johnson.int]$
    ```

    Display cert chain info:
	
    ```shell
    root@admin2:[johnson.int]$ openssl crl2pkcs7 -nocrl -certfile nas2.chain.pem | openssl pkcs7 -print_certs -noout

    subject=C = US, ST = New York, L = CSH, O = Johnsonville Internal, OU = Mostly Impractical, CN = nas2
    issuer=C = US, ST = New York, L = CSH, O = Johnsonville Internal, OU = Mostly Impractical, CN = johnson.int
	
    subject=C = US, ST = New York, L = CSH, O = Johnsonville Internal, OU = Mostly Impractical, CN = johnson.int
    issuer=C = US, ST = New York, L = New York, O = Dettonville LLC, OU = Research, CN = Dettonville LLC
	
    subject=C = US, ST = New York, L = New York, O = Dettonville LLC, OU = Research, CN = Dettonville LLC
    issuer=C = US, ST = New York, L = New York, O = Dettonville LLC, OU = Research, CN = Dettonville LLC
	
    root@admin2:[johnson.int]$
    ```


## How to add ca to browser and windows OS using certutil

How to add ca to browser and windows OS using certutil:

- [how-to-set-up-and-configure-a-certificate-authority-ca-on-centos-8](./how-to-set-up-and-configure-a-certificate-authority-ca-on-centos-8.md)


## How to list all certificates in ubuntu ca bundle

To list all certificates in ubuntu ca bundle:
	ref: https://unix.stackexchange.com/questions/97244/list-all-available-ssl-ca-certificates

```shell
awk -v cmd='openssl x509 -noout -subject' '
	/BEGIN/{close(cmd)};{print | cmd}' < /etc/ssl/certs/ca-certificates.crt
```

## Using cfssl

Using cfssl:

```shell
cfssl genkey -initca intermediate.json | cfssljson -bare johnson.int

cfssl sign  -ca=/usr/share/ca-certs/caroot/ca.pem  \
	-ca-key=/usr/share/ca-certs/caroot/ca-key.pem  \
	--config=/usr/share/ca-certs/ca-config.json  \
	-profile=domain  \
	johnson.int.csr \
	| cfssljson -bare johnson.int

cfssl gencert -ca=johnson.int.pem -ca-key=johnson.int-key.pem --config=/usr/share/ca-certs/ca-config.json -profile=server nas2.json | cfssljson -bare nas2
cfssl certinfo -cert nas2.pem
cfssl certinfo -cert johnson.int.pem
```


## Using keytool

# Using keytool:

Using keytool:

- https://www.sslshopper.com/article-most-common-java-keytool-keystore-commands.html
- https://cheapsslsecurity.com/blog/various-types-ssl-commands-keytool/

### List Trusted CA Certs

```shell
keytool -list -v -keystore $JAVA_HOME/jre/lib/security/cacerts
```
