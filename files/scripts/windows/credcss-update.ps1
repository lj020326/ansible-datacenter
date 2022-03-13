## CredCSS update
## ref: https://docs.microsoft.com/en-us/troubleshoot/azure/virtual-machines/credssp-encryption-oracle-remediation
## ref: https://sysally.com/blog/how-to-fix-credssp-authentication-error-in-rdp/

#Create a download location
md c:\temp


##Download the KB file
$source = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/05/windows10.0-kb4103721-x64_fcc746cd817e212ad32a5606b3db5a3333e030f8.msu"
$destination = "c:\temp\windows10.0-kb4103721-x64_fcc746cd817e212ad32a5606b3db5a3333e030f8.msu"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($source,$destination)


#Install the KB
expand -F:* $destination C:\temp\
dism /ONLINE /add-package /packagepath:"c:\temp\Windows10.0-KB4103721-x64.cab"


#Add the vulnerability key to allow unpatched clients
REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters" /v AllowEncryptionOracle /t REG_DWORD /d 2


#Restart the VM to complete the installations/settings
shutdown /r /t 0 /f
