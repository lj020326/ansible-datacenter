
# Get rid of Certificate Warnings

![VCSA-certificate-warning](./img/VCSA-certificate-warning.png)  

**You might be aware that Platform Services Controller vSphere contains a Certificate Authority (CA). If you want your browser to trust those certificates, you can add the root certificate to your local trusted store.


1.  Copy the certificate from the VCSA to your local workstation. The certificate is located at:  
    **/var/lib/vmware/vmca/root.cer  
    **
2.  Right-Click the Certificate and select **Install Certificate**![VCSA-install-root-certificate](./img/VCSA-install-root-certificate.png)
3.  Press **Next >**
4.  Select **Place all certificates in the following store**
5.  Click **Browse...**
6.  Select Trusted Root Certificate Authorities  
    ![VCSA-install-root-certificate-store](./img/VCSA-install-root-certificate-store.png)
7.  Press **OK** and finish the wizard
8.  Press **Yes** when you receive a Security Warning.

The certificate warning should now be gone.

