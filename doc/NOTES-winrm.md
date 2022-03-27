
How to use ansible for remote windows admin
===

## setup windows machines for ansible remote admin

### Install pywinrm on control node(s) [^1]

```shell
pip install pywinrm
```

### Enable winRM [^2]

First enable winRM on windows workstation machine(s). 

Assuming we have powershell >=v7.0:


Open powershell and run:
```powershell
c:\> Enable-PSRemoting
      [-Force]
      [-SkipNetworkProfileCheck]
      [-WhatIf]
      [-Confirm]
      [<CommonParameters>]
```

Here is another method to setup the winrm listener(s) that might work [^4]:

```
c:\> winrm quickconfig
```

### How to enable winRM for older powershell versions < v7.0
If using older version of powershell, use [this script](https://github.com/ansible/ansible/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1) to enable/setup winRM listeners.

### Verify listeners are running on windows client machine/workstation

```
c:\> winrm enumerate winrm/config/listener
```

### Verify connectivity [^3][^4]

Before connecting to remote server it is necessary to test remote WINRM connectivity with PowerShell. We need to use Test- WS command for it.

```
Test-WSMan -ComputerName Test1-Win2k12
```

If you get the below response, then the WinRM connection is successful.

```
PS C:\Users\Administrator> Test-WSMan -ComputerName Test1-Win2k12
wsmid               :    http://schemas.dmtf.org/wbem/wsman/identity/1/wsmanidentity.xsd  
ProtocolVersion     :    http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd
ProductVendor       :    Microsoft Corporation
ProductVersion      :    OS: 0.0.0 SP: 0.0 Stack: 3.0
```

If PSremoting is not enabled or WinRM is blocked by the firewall, you will get an error message.

## How to setup HTTPS SSL listener

If you’re already running remote commands with PowerShell Remoting (PSRemoting), you know how convenient the feature is. You’re able to connect to one or more remote computers and manage them like they were local. PSRemoting depends on Windows Remote Management (WinRm) to make it happen, and if you’re not using WinRM over SSL, you might be opening yourself up to some security issues.


### Configuring WinRM with a Self-Signed Certificate [^5]

```
powershell.exe -ExecutionPolicy ByPass -File .\ConfigureRemotingForAnsible.ps1 -ForceNewSSLCert -Password P@ssword123
```

The newly created ansible user cert will be written to $env:TMP.


## 

Using the option to disable/skip CA Check as described [here](https://adamtheautomator.com/winrm-ssl/)

```shell
PS WSMan:\localhost\Client>
PS WSMan:\localhost\Client> $PSSessionOption = New-PSSessionOption -SkipCACheck
PS WSMan:\localhost\Client>
PS WSMan:\localhost\Client> Enter-PSSession -ComputerName ljlaptop.johnson.int -Credential (Get-Credential) -SessionOpti
on $PSSessionOption  -UseSSL

cmdlet Get-Credential at command pipeline position 1
Supply values for the following parameters:
Credential
[ljlaptop.johnson.int]: PS C:\Users\Lee\Documents>
[ljlaptop.johnson.int]: PS C:\Users\Lee\Documents> exit
PS WSMan:\localhost\Client>
PS WSMan:\localhost\Client>
```

## Reference

* https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html
* https://docs.ansible.com/ansible/latest/user_guide/windows_winrm.html
* https://www.ansible.com/blog/connecting-to-a-windows-host
* https://stackoverflow.com/questions/38259422/in-ansible-how-to-connect-to-windows-host
* https://stackoverflow.com/questions/45696024/how-to-connect-to-windows-node-using-openssh-and-ansible
* https://docs.microsoft.com/en-us/azure/developer/ansible/vm-configure-windows?tabs=ansible
* https://www.bloggingforlogging.com/2017/11/23/using-packer-to-create-windows-images/
* https://docs.microsoft.com/en-us/azure/developer/ansible/vm-configure-windows?tabs=ansible
* https://github.com/ansible/ansible/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1
* https://newbedev.com/powershell-v2-remoting-how-do-you-enable-unencrypted-traffic
* http://woshub.com/powershell-remoting-over-https/
* http://www.dhruvsahni.com/verifying-winrm-connectivity
* https://stackoverflow.com/questions/66671945/ansible-playbook-error-the-powershell-shell-family-is-incompatible-with-the-sud

## Footnotes

[^1]: [pywinrm](https://docs.ansible.com/ansible/latest/user_guide/windows_winrm.html#what-is-winrm)

[^2]: [Enable-PSRemoting (Microsoft.PowerShell.Core) - PowerShell | Microsoft Docs](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting)

[^3]: [Test WinRM connectivity using PowerShell](https://www.tutorialspoint.com/how-to-test-winrm-connectivity-using-powershell)

[^4]: [Verifying WinRM Connectivity](http://www.dhruvsahni.com/verifying-winrm-connectivity)

[^5]: [How to Set up PSRemoting with WinRM and SSL [Step by Step]](https://adamtheautomator.com/winrm-ssl/)

