
# A Guide to Active Directory Ports and Authentication Protocols

Active Directory is a key part of any network infrastructure, it’s important to use the correct ports for the active directory communication. Understanding which ports are needed for active directory communication helps you to configure ports to allow them through the firewall.

An active directory port is a TCP or UDP port that services requests to an active directory domain controller. Active Directory Domain Controllers (DCs) use ports for communication and data transfer and the most common protocols are

-   Kerberos
-   LDAP
-   RPC
-   DNS
-   SMB Over IP

An administrator can configure which ports need to be open depending upon the requirements.

In this post, we will discuss active directory ports, active directory authentication ports, and ports needed for active directory replication.

Below are the active directory ports used for active directory communications:

-   TCP, UDP port 135 : RPC (Remote Procedure Call)
-   TCP, UDP port 137 : NetBIOS name service
-   UDP port 138 : DFSN, NetBIOS Datagram Service, NetLogon
-   TCP port 139 : DFSN, NetBIOS Session Service, NetLogon
-   TCP, UDP port 389 : LDAP
-   TCP port 636 : LDAP SSL
-   TCP, UDP port 445 : SMB, NetLogon, SamR
-   TCP 3268 port : Global Catalog LDAP
-   TCP 3269 port : Global Catalog LDAP SSL
-   TCP, UDP port : DNS
-   TCP, UDP port 88 : Kerberos
-   TCP, UDP port 1512 : WINS Resolution
-   TCP, UDP port 42 : WINS Replication
-   TCP Dynamic : RPC, DCOM, NetLogonR

**Cool Tip:** How to [get active directory groups and descriptions](https://shellgeek.com/powershell-list-active-directory-groups-and-description/) in PowerShell!

## Active Directory Replication Ports

Below are the active directory replication ports used for AD replication:

-   TCP port 135 : RPC ( Remote Procedure Call)
-   TCP, UDP port 389 : LDAP
-   TCP, UDP port 636 : LDAP SSL
-   TCP 3268 port : Global Catalog LDAP
-   TCP 3269 port : Global Catalog LDAP SSL
-   TCP, UDP port 53 : DNS
-   TCP, UDP port 88: Kerberos
-   TCP port 445 : SMB

## Active Directory Authentication Ports

Active Directory uses the below port for active directory authentication

-   UDP port 389 : LDAP
-   TCP port 53 : DNS
-   TCP, UDP port 88 : Kerberos
-   TCP, UDP port 445 : SMB over IP

## Using Active Directory Ports

Active directory ports help you to understand which ports to allow in the firewall. If these ports are not configured in the firewall, it may block the request in AD communication.

Below are the common problems with [Active Directory](https://shellgeek.com/what-is-active-directory-and-how-does-it-work/) ports

-   Replication traffic not successful on port 3268, or some other problems with replication.
-   LDAP is failing to authenticate users when using LDAPS over SSL.
-   Kerberos is failing to authenticate users when using TGS over SSL.
-   Replication is failing to occur over port 3268.
-   LDAP is failing to authenticate users when using LDAPS over SSL.
-   Kerberos is failing to authenticate users when using TGS over SSL.

**Cool Tip:** How to [get active directory users](https://shellgeek.com/get-aduser/) using Get-AdUser cmdlet in PowerShell!

## Conclusion

I hope the above article helps you to understand active directory ports and ports needed for active directory replication and authentication.

You can read more on using [PowerShell](https://shellgeek.com/powershell/) active directory modules cmdlet to get ad user, computers, domain controllers, and [PowerShell tips](https://shellgeek.com/powershell-tips/) to know more about file handling, hyper-v, PowerShell modules.

**AD Benefits:** Read more to know [Active Directory advantages and disadvantages](https://shellgeek.com/active-directory-advantages-and-disadvantages/)!

You can find more topics about PowerShell Active Directory commands and PowerShell basics on the [ShellGeek](https://shellgeek.com/) home page.

## References

* https://shellgeek.com/active-directory-ports-and-authentication-protocols/
* 