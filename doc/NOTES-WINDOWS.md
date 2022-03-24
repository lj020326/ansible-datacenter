
How to use ansible for remote windows admin
===

## setup windows machines for ansible remote admin

### Enable winRM [1]

First enable winRM on windows workstation machine(s). 

Assuming we have powershell >=v7.0:


Open powershell and run:
```powershell
Enable-PSRemoting
      [-Force]
      [-SkipNetworkProfileCheck]
      [-WhatIf]
      [-Confirm]
      [<CommonParameters>]
```

### How to enable winRM for older powershell versions < v7.0
If using older version of powershell, use [this script](https://github.com/ansible/ansible/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1) to enable/setup winRM listeners.

### Verify connectivity [2]

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




## 



## Reference

[1] [Enable-PSRemoting (Microsoft.PowerShell.Core) - PowerShell | Microsoft Docs](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting)

[2] [Test WinRM connectivity using PowerShell](https://www.tutorialspoint.com/how-to-test-winrm-connectivity-using-powershell)
