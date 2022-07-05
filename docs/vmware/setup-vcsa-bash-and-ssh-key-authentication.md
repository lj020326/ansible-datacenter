
# VCSA Bash and SSH Key Authentication

The Linux Version of the vCenter Server is not new anymore but with vSphere the vCenter Server Appliance (VCSA) has overtaken the Windows Version in many aspects. The completely rewritten linked mode removes the need for a Windows-based vCenter and the scalability of both appliances are identical.

VCSA is delivered as appliance based on openSUSE. Nevertheless its a Linux, VMware want's you to use the GUI. Unless you are in a testing environment I would highly recommend to limit shell usage to the following usage scenarios:

-   During Service Requests under advice of VMware GSS
-   For advanced troubleshooting
-   When required for complex deployments (eg. [PSC 6.0 High Availability](http://kb.vmware.com/kb/2113315))

**VCSA Default Shell  
**When you login to the appliance with SSH you see a new proprietary shell. You should definitely make yourself familiar with this shell as it might be the only available shell in the future. Many default commands are already available here, so whenever possible, try to use the default shell.

The warning message displayed when you start the the "real" shell speaks for itself:

> **\---------- !!!! WARNING WARNING WARNING !!!! ----------**
> 
> **Your use of "pi shell" has been logged!**
> 
> **The "pi shell" is intended for advanced troubleshooting operations and while**  
> **supported in this release, is a deprecated interface, and may be removed in a**  
> **future version of the product. For alternative commands, exit the "pi shell"**  
> **and run the "help" command.**
> 
> **The "pi shell" command launches a root bash shell. Commands within the shell**  
> **are not audited, and improper use of this command can severely harm the**  
> **system.**
> 
> **Help us improve the product! If your scenario requires "pi shell," please**  
> **submit a Service Request, or post your scenario to the**  
> **communities.vmware.com/community/vmtn/server/vcenter/cloudvm forum.**

**VCSA and Public Key Authentication  
**The first step is to place you SSH public key onto the vCenter Server Appliance. Public Key authentication is an authentication method that relies on a generated public/private keypair and enables the login without entering a password. It's the most widely spread login method for Linux. If you are not familiar with SSH Public Key Authentication, read [this post](http://www.virten.net/2013/01/using-ssh-public-key-authentication-with-vma/) where I am explaining the basics.

1.  Login to the VCSA with your root password (Set during installation)
2.  Enable and start the Bash Shell
    
    ```
    Command> shell.set --enabled True
    Command> shell
    ```
    
    ![VCSA-welcome-screen](./img/VCSA-welcome-screen.png)
    
3.  Now we are inside the standard bash shell. Use the following commands to create a folder structure required for public key authentication.
    
    ```
    VCSA:~ # cd /root
    VCSA:~ # mkdir .ssh
    VCSA:~ # chmod 700 .ssh
    VCSA:~ # cd .ssh
    VCSA:~ # touch authorized_keys
    VCSA:~ # chmod 600 authorized_keys
    ```
    
4.  The authorized\_keys is a simple textfile where all public keys that are allowed to authenticate as root are listed. One per line. Add your key to the file by editing it with vi, or with echo/pipe:
    
    ```
    echo "ssh-rsa AAAAB[....] fgrehl" >> authorized_keys
    ```
    
    The file should look like this. One key per line in the format **ssh-rsa \[KEY\] \[COMMENT\]**:  
    [![sshkey_3](http://www.virten.net/wp-content/uploads/2013/01/sshkey_3.png)](http://www.virten.net/wp-content/uploads/2013/01/sshkey_3.png)
    
5.  That's it. You can now login to the vCenter Server Appliance with your SSH Key.

When you login with your SSH you are still prompted for a password. You do not have to enter a password. Just pres Enter.  
![VCSA-welcome-screen-with-ssh-key](./img/VCSA-welcome-screen-with-ssh-key.png)  
I also noticed problems with some vCenter related functions when you're using a key to login:

```
Command> api list
Must be connected to a server.
```

**Change the default Shell to Bash  
**If you want to change the default shell to bash, use the following command:

```
VCSA:~ # chsh -s /bin/bash
```

This will change the root user to use bash as the default shell. The configuration is written to the /etc/passwd file. You can see (and change) the configuration there.  
![VCSA-change-default-shell](./img/VCSA-change-default-shell.png)

With bash as default shell, WinSCP works flawlessly. You can use WinSCP to transfer data between your system and the VCSA:  
![VCSA-with-winscp](./img/VCSA-with-winscp.png)

Use the following command if you want to change the shell back to its default:

```
VCSA:~ # chsh -s /bin/appliancesh
```

**Get rid of Certificate Warnings  
![VCSA-certificate-warning](./img/VCSA-certificate-warning.png)  
**You might be aware that Platform Services Controller vSphere 6 contains a Certificate Authority (CA). If you want your browser to trust those certificates, you can add the root certificate to your local trusted store.

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

## Reference

* https://www.virten.net/2015/10/vcsa6-bash-and-ssh-key-authentication/
