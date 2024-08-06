
# Regenerate a New VMCA Root Certificate and Replace All Certificates

You can regenerate the VMCA root certificate, and replace the local machine SSL certificate and the local solution user certificates with VMCA-signed certificates. When multiple vCenter Server instances are connected in Enhanced Linked Mode configuration, you must replace certificates on each vCenter Server.

When you replace the existing machine SSL certificate with a new VMCA-signed certificate, vSphere Certificate Manager prompts you for information and enters all values, except for the password and the IP address of the vCenter Server, into the certool.cfg file.

-   Password for administrator@vsphere.local
-   Two-letter country code
-   Company name
-   Organization name
-   Organization unit
-   State
-   Locality
-   IP address (optional)
-   Email
-   Host name, that is, the fully qualified domain name of the machine for which you want to replace the certificate. If the host name does not match the FQDN, certificate replacement does not complete correctly and your environment might end up in an unstable state.
-   IP address of vCenter Server.
-   VMCA name, that is, the fully qualified domain name of the machine on which the certificate configuration is running.

Note: As of vSphere 7.0 Update 3o, the OU (organizationalUnitName) field is no longer mandatory.

## Prerequisites

You must know the following information when you run vSphere Certificate Manager with this option.

-   Password for administrator@vsphere.local.
-   The FQDN of the machine for which you want to generate a new VMCA-signed certificate. All other properties default to the predefined values but can be changed.

## Procedure

1.  Log in to the vCenter Server and start the vSphere Certificate Manager.
    
    ```
    <p>/usr/lib/vmware-vmca/bin/certificate-manager</p>
    ```
    
2.  Select option 4, Regenerate a new VMCA Root Certificate and replace all certificates.
3.  Respond to the prompts.
    
    Certificate Manager generates a new VMCA root certificate based on your input and replaces all certificates on the system where you are running Certificate Manager. The replacement process is complete after Certificate Manager has restarted the services.
    
4.  To replace the machine SSL certificate, run vSphere Certificate Manager with option 3, Replace Machine SSL certificate with VMCA Certificate.
5.  To replace the solution user certificates, run Certificate Manager with option 6, Replace Solution user certificates with VMCA certificates.

## Reference

- https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.authentication.doc/GUID-D944C044-B682-4427-90F8-55B8770F21AF.html
- https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vcenterhost.doc/GUID-552CC9E8-441C-434A-88FC-3F50881245D7.html
