#Requires -Version 3.0

# Configure a Windows host for remote management with Ansible
# -----------------------------------------------------------
#
# This script checks the current WinRM (PS Remoting) configuration and makes
# the necessary changes to allow Ansible to connect, authenticate and
# execute PowerShell commands.
#
# All events are logged to the Windows EventLog, useful for unattended runs.
#
# Use option -Verbose in order to see the verbose output messages.
#
# Use option -CertValidityDays to specify how long this certificate is valid
# starting from today. So you would specify -CertValidityDays 3650 to get
# a 10-year valid certificate.
#
# Use option -ForceNewSSLCert if the system has been SysPreped and a new
# SSL Certificate must be forced on the WinRM Listener when re-running this
# script. This is necessary when a new SID and CN name is created.
#
# Use option -EnableCredSSP to enable CredSSP as an authentication option.
#
# Use option -DisableBasicAuth to disable basic authentication.
#
# Use option -SkipNetworkProfileCheck to skip the network profile check.
# Without specifying this the script will only run if the device's interfaces
# are in DOMAIN or PRIVATE zones.  Provide this switch if you want to enable
# WinRM on a device with an interface in PUBLIC zone.
#
# Use option -SubjectName to specify the CN name of the certificate. This
# defaults to the system's hostname and generally should not be specified.

# Written by Trond Hindenes <trond@hindenes.com>
# Updated by Chris Church <cchurch@ansible.com>
# Updated by Michael Crilly <mike@autologic.cm>
# Updated by Anton Ouzounov <Anton.Ouzounov@careerbuilder.com>
# Updated by Nicolas Simond <contact@nicolas-simond.com>
# Updated by Dag Wieërs <dag@wieers.com>
# Updated by Jordan Borean <jborean93@gmail.com>
# Updated by Erwan Quélin <erwan.quelin@gmail.com>
# Updated by David Norman <david@dkn.email>
#
# Version 1.0 - 2014-07-06
# Version 1.1 - 2014-11-11
# Version 1.2 - 2015-05-15
# Version 1.3 - 2016-04-04
# Version 1.4 - 2017-01-05
# Version 1.5 - 2017-02-09
# Version 1.6 - 2017-04-18
# Version 1.7 - 2017-11-23
# Version 1.8 - 2018-02-23
# Version 1.9 - 2018-09-21

# Support -Verbose option
[CmdletBinding()]

Param (
    [string]$SubjectName = $env:COMPUTERNAME,
    [int]$CertValidityDays = 1095,
    [switch]$SkipNetworkProfileCheck,
    $CreateSelfSignedCert = $true,
    [switch]$ForceNewSSLCert,
    [switch]$GlobalHttpFirewallAccess,
    [switch]$DisableBasicAuth = $false,
    [switch]$EnableCredSSP,
    [string]$certPath = "C:\temp",
    [string]$username = "ansible",
    [string]$password = "P@ssword123"
)

Function Write-ProgressLog {
    $Message = $args[0]
    #Write-EventLog -LogName Application -Source $EventSource -EntryType Information -EventId 1 -Message $Message
}

Function Write-VerboseLog {
    $Message = $args[0]
    Write-Verbose $Message
    Write-ProgressLog $Message
}

Function Write-HostLog {
    $Message = $args[0]
    Write-Output $Message
    Write-ProgressLog $Message
}

function Create-NewLocalAdmin {
    [CmdletBinding()]
    param (
        [string] $NewLocalAdmin,
        [securestring] $Password
    )
    begin {
    }
    process {
        New-LocalUser "$NewLocalAdmin" -Password $Password -FullName "$NewLocalAdmin" -Description "Temporary local admin"
        Write-Verbose "$NewLocalAdmin local user crated"
        Add-LocalGroupMember -Group "Administrators" -Member "$NewLocalAdmin"
        Write-Verbose "$NewLocalAdmin added to the local administrator group"
    }
    end {
    }
}

Function New-SelfSignedCert {
    Param (
        [string]$SubjectName,
        [int]$ValidDays = 1095
    )

    $hostnonFQDN = $env:computerName
    $hostFQDN = [System.Net.Dns]::GetHostByName(($env:computerName)).Hostname

    ## ref: https://docs.microsoft.com/en-us/powershell/module/pki/new-selfsignedcertificate?view=windowsserver2022-ps
    ## ref: https://adamtheautomator.com/winrm-ssl/
    $certObj = New-SelfSignedCertificate `
        -Type Custom `
        -Subject "CN=$SubjectName" `
        -TextExtension '2.5.29.37={text}1.3.6.1.5.5.7.3.1' `
        -DnsName "$hostnonFQDN", "$hostFQDN" `
        -KeyUsage DigitalSignature `
        -KeyAlgorithm RSA `
        -KeyLength 4096 `
        -NotBefore (Get-Date).AddDays(-1) `
        -NotAfter (Get-Date).AddDays($ValidDays)

    Write-Host  "certObj=$certObj"

    return $certObj.Thumbprint
}

Function New-LegacySelfSignedCert {
    Param (
        [string]$SubjectName,
        [int]$ValidDays = 1095,
        [string]$certPath
    )

    $hostnonFQDN = $env:computerName
    $hostFQDN = [System.Net.Dns]::GetHostByName(($env:computerName)).Hostname
    $SignatureAlgorithm = "SHA256"

    $name = New-Object -COM "X509Enrollment.CX500DistinguishedName.1"
    $name.Encode("CN=$SubjectName", 0)

    $key = New-Object -COM "X509Enrollment.CX509PrivateKey.1"
    $key.ProviderName = "Microsoft Enhanced RSA and AES Cryptographic Provider"
    $key.KeySpec = 1
    $key.Length = 4096
    $key.SecurityDescriptor = "D:PAI(A;;0xd01f01ff;;;SY)(A;;0xd01f01ff;;;BA)(A;;0x80120089;;;NS)"
    $key.MachineContext = 1
    $key.Create()

    $serverauthoid = New-Object -COM "X509Enrollment.CObjectId.1"
    $serverauthoid.InitializeFromValue("1.3.6.1.5.5.7.3.1")
    $ekuoids = New-Object -COM "X509Enrollment.CObjectIds.1"
    $ekuoids.Add($serverauthoid)
    $ekuext = New-Object -COM "X509Enrollment.CX509ExtensionEnhancedKeyUsage.1"
    $ekuext.InitializeEncode($ekuoids)

    $cert = New-Object -COM "X509Enrollment.CX509CertificateRequestCertificate.1"
    $cert.InitializeFromPrivateKey(2, $key, "")
    $cert.Subject = $name
    $cert.Issuer = $cert.Subject
    $cert.NotBefore = (Get-Date).AddDays(-1)
    $cert.NotAfter = $cert.NotBefore.AddDays($ValidDays)

    $SigOID = New-Object -ComObject X509Enrollment.CObjectId
    $SigOID.InitializeFromValue(([Security.Cryptography.Oid]$SignatureAlgorithm).Value)

    [string[]] $AlternativeName += $hostnonFQDN
    $AlternativeName += $hostFQDN
    $IAlternativeNames = New-Object -ComObject X509Enrollment.CAlternativeNames

    foreach ($AN in $AlternativeName) {
        $AltName = New-Object -ComObject X509Enrollment.CAlternativeName
        $AltName.InitializeFromString(0x3, $AN)
        $IAlternativeNames.Add($AltName)
    }

    $SubjectAlternativeName = New-Object -ComObject X509Enrollment.CX509ExtensionAlternativeNames
    $SubjectAlternativeName.InitializeEncode($IAlternativeNames)

    [String[]]$KeyUsage = ("DigitalSignature", "KeyEncipherment")
    $KeyUsageObj = New-Object -ComObject X509Enrollment.CX509ExtensionKeyUsage
    $KeyUsageObj.InitializeEncode([int][Security.Cryptography.X509Certificates.X509KeyUsageFlags]($KeyUsage))
    $KeyUsageObj.Critical = $true

    $cert.X509Extensions.Add($KeyUsageObj)
    $cert.X509Extensions.Add($ekuext)
    $cert.SignatureInformation.HashAlgorithm = $SigOID
    $CERT.X509Extensions.Add($SubjectAlternativeName)
    $cert.Encode()

    $enrollment = New-Object -COM "X509Enrollment.CX509Enrollment.1"
    $enrollment.InitializeFromRequest($cert)
    $certdata = $enrollment.CreateRequest(0)
    $enrollment.InstallResponse(2, $certdata, 0, "")

#    # extract/return the thumbprint from the generated cert
#    $parsed_cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
#    $parsed_cert.Import([System.Text.Encoding]::UTF8.GetBytes($certdata))

    # Export the public key
#    $pem_output = @()
#    $pem_output += "-----BEGIN CERTIFICATE-----"
#    $pem_output += [System.Convert]::ToBase64String($certdata) -replace ".{64}", "$&`n"
#    $pem_output += "-----END CERTIFICATE-----"
#    [System.IO.File]::WriteAllLines("$certPath\cert.pem", $pem_output)
    [System.IO.File]::WriteAllLines("$certPath\cert.pem", $certdata)

    # Import key into Machine's store
    $cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2
    $cert.Import("$certPath\cert.pem")

    # Export the private key in a PFX file
    [System.IO.File]::WriteAllBytes("$certPath\cert.pfx", $cert.Export("Pfx"))

    return $cert.Thumbprint
}

## ref: https://stackoverflow.com/questions/71443402/error-creating-a-self-signed-certificate-for-use-with-winrm-https
Function New-SelfSignedCert2 {

    Param (
        [string]$SubjectName,
        [int]$ValidDays = 1095,
        [string]$certPath,
        [string]$username
    )

    # Delete all HTTPS listeners
    Get-ChildItem -Path WSMan:\localhost\Listener | Where-Object { $_.Keys -contains "Transport=HTTPS" } | Remove-Item -Recurse -Force

#    # Set the name of the local user that will have the key mapped
#    $username = "ansible"
#    $certPath = "C:\temp"

    # Instead of generating a file, the cert will be added to the personal
    # LocalComputer folder in the certificate store
    $cert = New-SelfSignedCertificate -Type Custom `
        -Subject "CN=$SubjectName" `
        -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2","2.5.29.17={text}upn=$username@localhost") `
        -KeyUsage DigitalSignature,KeyEncipherment `
        -KeyAlgorithm RSA `
        -KeyLength 2048

    # Export the public key
    $pem_output = @()
    $pem_output += "-----BEGIN CERTIFICATE-----"
    $pem_output += [System.Convert]::ToBase64String($cert.RawData) -replace ".{64}", "$&`n"
    $pem_output += "-----END CERTIFICATE-----"
    [System.IO.File]::WriteAllLines("$certPath\cert.pem", $pem_output)

    # Export the private key in a PFX file
    [System.IO.File]::WriteAllBytes("$certPath\cert.pfx", $cert.Export("Pfx"))

    # Import key into Machine's store
    $cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2
    $cert.Import("$certPath\cert.pem")

    $store_name = [System.Security.Cryptography.X509Certificates.StoreName]::Root
    $store_location = [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
    $store = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Store -ArgumentList $store_name, $store_location
    $store.Open("MaxAllowed")
    $store.Add($cert)
    $store.Close()

    # Import the client certificate
    $cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2
    $cert.Import("$certPath\cert.pem")

    $store_name = [System.Security.Cryptography.X509Certificates.StoreName]::TrustedPeople
    $store_location = [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
    $store = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Store -ArgumentList $store_name, $store_location
    $store.Open("MaxAllowed")
    $store.Add($cert)
    $store.Close()

    # Map the certificate to the Ansible user
#    $username = "ansible"
#    $password = ConvertTo-SecureString -String "P@ssword123" -AsPlainText -Force
#    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

    # This is the issuer thumbprint which in the case of a self generated cert
    # is the public key thumbprint, additional logic may be required for other
    # scenarios
    $thumbprint = (Get-ChildItem -Path cert:\LocalMachine\root | Where-Object { $_.Subject -eq "CN=$username" }).Thumbprint

#    New-Item -Path WSMan:\localhost\ClientCertificate `
#        -Subject "$username@localhost" `
#        -URI * `
#        -Issuer $thumbprint `
#        -Credential $credential `
#        -Force
#
#    # Create a new HTTPS listener
#    $selector_set = @{
#        Address = "*"
#        Transport = "HTTPS"
#    }
#    $value_set = @{
#        CertificateThumbprint = "$thumbprint"
#    }
#
#    New-WSManInstance -ResourceURI "winrm/config/Listener" -SelectorSet $selector_set -ValueSet $value_set

    return $cert.Thumbprint

}


Function Enable-GlobalHttpFirewallAccess {
    Write-Verbose "Forcing global HTTP firewall access"
    # this is a fairly naive implementation; could be more sophisticated about rule matching/collapsing
    $fw = New-Object -ComObject HNetCfg.FWPolicy2

    # try to find/enable the default rule first
    $add_rule = $false
    $matching_rules = $fw.Rules | Where-Object { $_.Name -eq "Windows Remote Management (HTTP-In)" }
    $rule = $null
    If ($matching_rules) {
        If ($matching_rules -isnot [Array]) {
            Write-Verbose "Editing existing single HTTP firewall rule"
            $rule = $matching_rules
        }
        Else {
            # try to find one with the All or Public profile first
            Write-Verbose "Found multiple existing HTTP firewall rules..."
            $rule = $matching_rules | ForEach-Object { $_.Profiles -band 4 }[0]

            If (-not $rule -or $rule -is [Array]) {
                Write-Verbose "Editing an arbitrary single HTTP firewall rule (multiple existed)"
                # oh well, just pick the first one
                $rule = $matching_rules[0]
            }
        }
    }

    If (-not $rule) {
        Write-Verbose "Creating a new HTTP firewall rule"
        $rule = New-Object -ComObject HNetCfg.FWRule
        $rule.Name = "Windows Remote Management (HTTP-In)"
        $rule.Description = "Inbound rule for Windows Remote Management via WS-Management. [TCP 5985]"
        $add_rule = $true
    }

    $rule.Profiles = 0x7FFFFFFF
    $rule.Protocol = 6
    $rule.LocalPorts = 5985
    $rule.RemotePorts = "*"
    $rule.LocalAddresses = "*"
    $rule.RemoteAddresses = "*"
    $rule.Enabled = $true
    $rule.Direction = 1
    $rule.Action = 1
    $rule.Grouping = "Windows Remote Management"

    If ($add_rule) {
        $fw.Rules.Add($rule)
    }

    Write-Verbose "HTTP firewall rule $($rule.Name) updated"
}

# Setup error handling.
Trap {
    $_
    Exit 1
}
$ErrorActionPreference = "Stop"

# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator


# Check to see if we are currently running "as Administrator"
if (-Not $myWindowsPrincipal.IsInRole($adminRole)) {
    Write-Output "ERROR: You need elevated Administrator privileges in order to run this script."
    Write-Output "       Start Windows PowerShell by using the Run as Administrator option."
    Exit 2
}

$EventSource = $MyInvocation.MyCommand.Name
If (-Not $EventSource) {
    $EventSource = "Powershell CLI"
}

If ([System.Diagnostics.EventLog]::Exists('Application') -eq $False -or [System.Diagnostics.EventLog]::SourceExists($EventSource) -eq $False) {
    #New-EventLog -LogName Application -Source $EventSource
    #Write-EventLog -LogName Application -Source $EventSource
}

# Detect PowerShell version.
If ($PSVersionTable.PSVersion.Major -lt 3) {
    Write-ProgressLog "PowerShell version 3 or higher is required."
    Throw "PowerShell version 3 or higher is required."
}

# Find and start the WinRM service.
Write-Verbose "Verifying WinRM service."
If (!(Get-Service "WinRM")) {
    Write-ProgressLog "Unable to find the WinRM service."
    Throw "Unable to find the WinRM service."
}
ElseIf ((Get-Service "WinRM").Status -ne "Running") {
    Write-Verbose "Setting WinRM service to start automatically on boot."
    Set-Service -Name "WinRM" -StartupType Automatic
    Write-ProgressLog "Set WinRM service to start automatically on boot."
    Write-Verbose "Starting WinRM service."
    Start-Service -Name "WinRM" -ErrorAction Stop
    Write-ProgressLog "Started WinRM service."

}

# WinRM should be running; check that we have a PS session config.
If (!(Get-PSSessionConfiguration -Verbose:$false) -or (!(Get-ChildItem WSMan:\localhost\Listener))) {
    If ($SkipNetworkProfileCheck) {
        Write-Verbose "Enabling PS Remoting without checking Network profile."
        Enable-PSRemoting -SkipNetworkProfileCheck -Force -ErrorAction Stop
        Write-ProgressLog "Enabled PS Remoting without checking Network profile."
    }
    Else {
        Write-Verbose "Enabling PS Remoting."
        Enable-PSRemoting -Force -ErrorAction Stop
        Write-ProgressLog "Enabled PS Remoting."
    }
}
Else {
    Write-Verbose "PS Remoting is already enabled."
}



# Ensure LocalAccountTokenFilterPolicy is set to 1
# https://github.com/ansible/ansible/issues/42978
$token_path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$token_prop_name = "LocalAccountTokenFilterPolicy"
$token_key = Get-Item -Path $token_path
$token_value = $token_key.GetValue($token_prop_name, $null)
if ($token_value -ne 1) {
    Write-Verbose "Setting LocalAccountTOkenFilterPolicy to 1"
    if ($null -ne $token_value) {
        Remove-ItemProperty -Path $token_path -Name $token_prop_name
    }
    New-ItemProperty -Path $token_path -Name $token_prop_name -Value 1 -PropertyType DWORD > $null
}

## ref: https://www.scriptinglibrary.com/languages/powershell/create-a-local-admin-account-with-powershell/
## ref: https://github.com/PaoloFrigo/scriptinglibrary
## ref: https://github.com/lj020326/ansible-datacenter/blob/main/files/scripts/powershell/Create-NewLocalAdmin.ps1
$passwordSec = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $passwordSec

$ObjLocalUser = $null

try {
    Write-Verbose "Searching for $($username) in LocalUser DataBase"
    $ObjLocalUser = Get-LocalUser $username
    Write-Verbose "User $($username) was found"
}
catch [Microsoft.PowerShell.Commands.UserNotFoundException] {
    "User $($username) was not found" | Write-Warning
}
catch {
    "An unspecifed error occured" | Write-Error
    Exit # Stop Powershell!
}

#Create the user if it was not found (Example)
if (!$ObjLocalUser) {
    Write-Verbose "Creating new local admin user $username already active."
    Create-NewLocalAdmin -NewLocalAdmin $username -Password $Password -Verbose
}

# Make sure there is a SSL listener.
$listeners = Get-ChildItem WSMan:\localhost\Listener
If (!($listeners | Where-Object { $_.Keys -like "TRANSPORT=HTTPS" }) -or $ForceNewSSLCert) {

    # We cannot use New-SelfSignedCertificate on 2012R2 and earlier

#    ## ref: https://docs.microsoft.com/en-us/windows/win32/sysinfo/operating-system-version
#    ## ref: https://ss64.com/ps/syntax-ver.html
#    ## ref: https://devblogs.microsoft.com/scripting/use-powershell-to-find-operating-system-version/
#    $major_os_version = [System.Environment]::OSVersion.Version.Major
#    Write-Host  "major_os_version=$major_os_version"
#
#    If ($major_os_version -le 6)
#    {
#        $thumbprint = New-LegacySelfSignedCert -SubjectName $SubjectName -ValidDays $CertValidityDays
#    }
#    else {
##        $thumbprint = New-SelfSignedCert -SubjectName $SubjectName -ValidDays $CertValidityDays
#        $thumbprint = New-SelfSignedCert2 -SubjectName $SubjectName -ValidDays $CertValidityDays, $certPath, $username
#    }

    $thumbprint = New-LegacySelfSignedCert -SubjectName $SubjectName -ValidDays $CertValidityDays
    Write-HostLog "Self-signed SSL certificate generated; thumbprint: $thumbprint"

    # Map the certificate to the Ansible user
    New-Item -Path WSMan:\localhost\ClientCertificate `
        -Subject "$username@localhost" `
        -URI * `
        -Issuer $thumbprint `
        -Credential $credential `
        -Force

    # Create the hashtables of settings to be used.
    $valueset = @{
        Hostname = $SubjectName
        CertificateThumbprint = $thumbprint
    }
    $valueset

    $selectorset = @{
        Transport = "HTTPS"
        Address = "*"
    }
    $selectorset

    If (($listeners | Where-Object { $_.Keys -like "TRANSPORT=HTTPS" }) -and $ForceNewSSLCert) {
        Write-Verbose "SSL listener is already active, removing existing cert and replacing with new cert"
        Remove-WSManInstance -ResourceURI 'winrm/config/Listener' -SelectorSet $selectorset
    }

    Write-Verbose "Enabling SSL listener."
    New-WSManInstance -ResourceURI 'winrm/config/Listener' -SelectorSet $selectorset -ValueSet $valueset
    Write-ProgressLog "Enabled SSL listener."
}
Else {
    Write-Verbose "SSL listener is already active."

#    # Force a new SSL cert on Listener if the $ForceNewSSLCert
#    If ($ForceNewSSLCert) {
#
#        # We cannot use New-SelfSignedCertificate on 2012R2 and earlier
##        $thumbprint = New-LegacySelfSignedCert -SubjectName $SubjectName -ValidDays $CertValidityDays
#        $thumbprint = New-SelfSignedCert -SubjectName $SubjectName -ValidDays $CertValidityDays
#        Write-HostLog "Self-signed SSL certificate generated; thumbprint: $thumbprint"
#
#        $valueset = @{
#            CertificateThumbprint = $thumbprint
#            Hostname = $SubjectName
#        }
#
#        # Delete the listener for SSL
#        $selectorset = @{
#            Address = "*"
#            Transport = "HTTPS"
#        }
#        Remove-WSManInstance -ResourceURI 'winrm/config/Listener' -SelectorSet $selectorset
#
#        # Add new Listener with new SSL cert
#        New-WSManInstance -ResourceURI 'winrm/config/Listener' -SelectorSet $selectorset -ValueSet $valueset
#    }
}

# Check for basic authentication.
$basicAuthSetting = Get-ChildItem WSMan:\localhost\Service\Auth | Where-Object { $_.Name -eq "Basic" }

If ($DisableBasicAuth) {
    If (($basicAuthSetting.Value) -eq $true) {
        Write-Verbose "Disabling basic auth support."
        Set-Item -Path "WSMan:\localhost\Service\Auth\Basic" -Value $false
        Write-ProgressLog "Disabled basic auth support."
    }
    Else {
        Write-Verbose "Basic auth is already disabled."
    }
}
Else {
    If (($basicAuthSetting.Value) -eq $false) {
        Write-Verbose "Enabling basic auth support."
        Set-Item -Path "WSMan:\localhost\Service\Auth\Basic" -Value $true
        Write-ProgressLog "Enabled basic auth support."
    }
    Else {
        Write-Verbose "Basic auth is already enabled."
    }
}

# If EnableCredSSP if set to true
If ($EnableCredSSP) {
    # Check for CredSSP authentication
    $credsspAuthSetting = Get-ChildItem WSMan:\localhost\Service\Auth | Where-Object { $_.Name -eq "CredSSP" }
    If (($credsspAuthSetting.Value) -eq $false) {
        Write-Verbose "Enabling CredSSP auth support."
        Enable-WSManCredSSP -role server -Force
        Write-ProgressLog "Enabled CredSSP auth support."
    }
}

If ($GlobalHttpFirewallAccess) {
    Enable-GlobalHttpFirewallAccess
}

# Configure firewall to allow WinRM HTTPS connections.
$fwtest1 = netsh advfirewall firewall show rule name="Allow WinRM HTTPS"
$fwtest2 = netsh advfirewall firewall show rule name="Allow WinRM HTTPS" profile=any
If ($fwtest1.count -lt 5) {
    Write-Verbose "Adding firewall rule to allow WinRM HTTPS."
    netsh advfirewall firewall add rule profile=any name="Allow WinRM HTTPS" dir=in localport=5986 protocol=TCP action=allow
    Write-ProgressLog "Added firewall rule to allow WinRM HTTPS."
}
ElseIf (($fwtest1.count -ge 5) -and ($fwtest2.count -lt 5)) {
    Write-Verbose "Updating firewall rule to allow WinRM HTTPS for any profile."
    netsh advfirewall firewall set rule name="Allow WinRM HTTPS" new profile=any
    Write-ProgressLog "Updated firewall rule to allow WinRM HTTPS for any profile."
}
Else {
    Write-Verbose "Firewall rule already exists to allow WinRM HTTPS."
}

# Test a remoting connection to localhost, which should work.
$httpResult = Invoke-Command -ComputerName "localhost" -ScriptBlock { $using:env:COMPUTERNAME } -ErrorVariable httpError -ErrorAction SilentlyContinue
$httpsOptions = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck

$httpsResult = New-PSSession -UseSSL -ComputerName "localhost" -SessionOption $httpsOptions -ErrorVariable httpsError -ErrorAction SilentlyContinue

If ($httpResult -and $httpsResult) {
    Write-Verbose "HTTP: Enabled | HTTPS: Enabled"
}
ElseIf ($httpsResult -and !$httpResult) {
    Write-Verbose "HTTP: Disabled | HTTPS: Enabled"
}
ElseIf ($httpResult -and !$httpsResult) {
    Write-Verbose "HTTP: Enabled | HTTPS: Disabled"
}
Else {
    Write-ProgressLog "Unable to establish an HTTP or HTTPS remoting session."
    Throw "Unable to establish an HTTP or HTTPS remoting session."
}
Write-VerboseLog "PS Remoting has been successfully configured for Ansible."
