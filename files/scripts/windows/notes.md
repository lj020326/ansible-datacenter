
source: https://docs.microsoft.com/en-us/windows/deployment/update/windows-update-resources

references:
    - https://social.technet.microsoft.com/Forums/windows/en-US/868957b3-2c7c-4141-8ee0-79f92762e1e8/package-kb4019472-failed-to-be-changed-to-the-installed-state-status-0x800f080d?forum=win10itprosecurity
    - https://docs.microsoft.com/en-us/windows/deployment/update/windows-update-resources
    - https://gallery.technet.microsoft.com/scriptcenter/Reset-WindowsUpdateps1-e0c5eb78
    - https://gallery.technet.microsoft.com/scriptcenter/Reset-WindowsUpdateps1-e0c5eb78/file/182059/1/Reset-WindowsUpdate.ps1
    - https://community.spiceworks.com/topic/2161156-unable-to-run-wuauclt-exe
    - https://www.urtech.ca/2018/11/solved-easily-script-windows-10-to-download-install-and-restart-for-windows-updates/
    - https://social.technet.microsoft.com/Forums/en-US/ac7f9793-b9fe-4a77-95f8-5a421ac98504/usoclientexe-documentation?forum=win10itprogeneral
    - https://dennisbabkin.com/utilities/#ShutdownWithUpdates
    - https://docs.microsoft.com/en-us/windows/deployment/update/waas-restart


```shell
PS C:\WINDOWS\system32>

cd C:\Users\Lee\Downloads
.\Reset-WindowsUpdate.ps1
Get-ExecutionPolicy -List
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Get-ExecutionPolicy -List
.\Reset-WindowsUpdate.ps1
Unblock-File .\Reset-WindowsUpdate.ps1
.\Reset-WindowsUpdate.ps1
.\Reset-WindowsUpdate.ps1
cd C:\Users\Lee\Downloads
.\Reset-WindowsUpdate.ps1
which SHUTDOWNWITHUPDATES
which USOClient
cd C:\Users\Lee\Downloads
.\Reset-WindowsUpdate.ps1

PS C:\WINDOWS\system32>

```
