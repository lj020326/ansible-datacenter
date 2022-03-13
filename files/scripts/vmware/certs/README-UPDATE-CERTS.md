
refs:

    - https://communities.vmware.com/thread/546223
    - http://wiki.cacert.org/FAQ/subjectAltName
    - https://kb.vmware.com/s/article/2057340
    - https://kb.vmware.com/s/article/2044696


In case someone runs into this again - we resolved this by recreating the self signed certificates for vCenter Service, Inventory Service and the Web Client Service. Below are the main steps we followed.

 

Set up three directories for the three services (vCenter, IS, and WC) and create an openssl.cnf file in each directory that contains the following:

 
```ini
[req]

default_bits = 2048
default_keyfile = rui.key
distinguished_name = req_distinguished_name

#Don't encrypt the key

encrypt_key = no
prompt = no
string_mask = nombstr
x509_extensions = v3_req

 

[ req_distinguished_name ]

countryName = CA
stateOrProvinceName = Ontario
localityName = Toronto
0.organizationName = Company Name
organizationalUnitName = vCenterServer

emailAddress = ssl-certificates@company.com
commonName = vCenter-FQDN

[v3_req]

# Extensions to add to a certificate request
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = vCenter-Short
DNS.2 = vCenter-FQDN
IP.1 = vCenter-IP

```


Note that I changed the FQDNs and IPs above (e.g., vCenter-IP is the actual IP of the vCenter).

The organizationalUnitName attribute must be set differently for each service - (vCenterServer, vCenterWebClient, vCenterInventoryService).

 

Once you have these three config files for the three services create the certs and keys by running the following command in each directory (you may need to change the location of openssl):

"c:\Program Files\VMware\Infrastructure\Inventory Service\bin\openssl.exe" req -nodes -new -x509 -keyout rui.key -out rui.crt -days 3650 -config openssl.cnf

 

Now you should have a rui.key and rui.crt file in each of the three directories. You should be able to look at those certs in Windows and see the subjectAltName containing two DNS entries (short and long) and an IP entry.

 

Rename the rui.crt file to rui.pem for all three certs.

 

Now, download the SSL Certificate Automation Tool 5.5 and closely follow the process from KB 2057340 to replace the certificates with the ones you just created.

 

Make sure you edit the ssl-environment.bat file with the locations of the different certs that you previously created, for the different services.

 

Be patient . The steps take a while as they restart the different processes and services. After each step the menu to select the next step came back so we could proceed.

 

Once we did all this and the certs were successfully updated the migration assistant precheck ran without issues. We have not proceed to the the vCenter upgrade yet, but the assistant was ready for the upgrade step.

 
```shell


Selected services: Single Sign-On, Inventory Service, vCenter Server, vCenter Orchestrator, Web Client, Log Browser, vSphere Upd
Detailed Plan to follow:

1. Go to the machine with Single Sign-On installed and - Update the Single Sign-On SSL certificate.
2. Go to the machine with Inventory Service installed and - Update Inventory Service trust to Single Sign-On.
3. Go to the machine with Inventory Service installed and - Update the Inventory Service SSL certificate.
4. Go to the machine with vCenter Server installed and - Update vCenter Server trust to Single Sign-On.
5. Go to the machine with vCenter Server installed and - Update the vCenter Server SSL certificate.
6. Go to the machine with vCenter Server installed and - Update vCenter Server trust to Inventory Service.
7. Go to the machine with Inventory Service installed and - Update the Inventory Service trust to vCenter Server.
8. Go to the machine with vCenter Orchestrator installed and - Update vCenter Orchestrator trust to Single Sign-On.
9. Go to the machine with vCenter Orchestrator installed and - Update vCenter Orchestrator trust to vCenter Server.
10. Go to the machine with vCenter Orchestrator installed and - Update the vCenter Orchestrator SSL certificate.
11. Go to the machine with vSphere Web Client installed and - Update vSphere Web Client trust to Single Sign-On.
12. Go to the machine with vSphere Web Client installed and - Update vSphere Web Client trust to Inventory Service.
13. Go to the machine with vSphere Web Client installed and - Update vSphere Web Client trust to vCenter Server.
14. Go to the machine with vSphere Web Client installed and - Update the vSphere Web Client SSL certificate.
15. Go to the machine with Log Browser installed and - Update the Log Browser trust to Single Sign-On.
16. Go to the machine with Log Browser installed and - Update the Log Browser SSL certificate.
17. Go to the machine with vSphere Update Manager installed and - Update the vSphere Update Manager SSL certificate.
18. Go to the machine with vSphere Update Manager installed and - Update vSphere Update Manager trust to vCenter Server.



```
