
# Get started with OpenSSH

-   Article
-   12/16/2021
-   4 minutes to read
-   14 contributors

### Is this page helpful?

Yes No

Any additional feedback?

Feedback will be sent to Microsoft: By pressing the submit button, your feedback will be used to improve Microsoft products and services. [Privacy policy.](https://privacy.microsoft.com/en-us/privacystatement)

Submit

Thank you.

### In this article

1.  [Install OpenSSH using Windows Settings](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/_generated_background_page.html#install-openssh-using-windows-settings)
2.  [Install OpenSSH using PowerShell](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/_generated_background_page.html#install-openssh-using-powershell)
3.  [Start and configure OpenSSH Server](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/_generated_background_page.html#start-and-configure-openssh-server)
4.  [Connect to OpenSSH Server](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/_generated_background_page.html#connect-to-openssh-server)
5.  [OpenSSH configuration files](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/_generated_background_page.html#openssh-configuration-files)
6.  [Uninstall OpenSSH using Windows Settings](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/_generated_background_page.html#uninstall-openssh-using-windows-settings)
7.  [Uninstall OpenSSH using PowerShell](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/_generated_background_page.html#uninstall-openssh-using-powershell)

> Applies to: Windows Server 2022, Windows Server 2019, Windows 10 (build 1809 and later)

OpenSSH is a connectivity tool for remote login that uses the SSH protocol. It encrypts all traffic between client and server to eliminate eavesdropping, connection hijacking, and other attacks.

An OpenSSH-compatible client can be used to connect to Windows Server and Windows client devices.

Important

If you downloaded OpenSSH from the GitHub repo at [PowerShell/openssh-portable](https://github.com/PowerShell/OpenSSH-Portable), follow the instructions listed there, not the ones in this article.

## [](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/_generated_background_page.html#install-openssh-using-windows-settings)Install OpenSSH using Windows Settings

Both OpenSSH components can be installed using Windows Settings on Windows Server 2019 and Windows 10 devices.

To install the OpenSSH components:

1.  Open **Settings**, select **Apps > Apps & Features**, then select **Optional Features**.
    
2.  Scan the list to see if the OpenSSH is already installed. If not, at the top of the page, select **Add a feature**, then:
    
    -   Find **OpenSSH Client**, then click **Install**
    -   Find **OpenSSH Server**, then click **Install**

Once setup completes, return to **Apps > Apps & Features** and **Optional Features** and you should see OpenSSH listed.

Note

Installing OpenSSH Server will create and enable a firewall rule named `OpenSSH-Server-In-TCP`. This allows inbound SSH traffic on port 22. If this rule is not enabled and this port is not open, connections will be refused or reset.

## [](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/_generated_background_page.html#install-openssh-using-powershell)Install OpenSSH using PowerShell

To install OpenSSH using PowerShell, run PowerShell as an Administrator. To make sure that OpenSSH is available, run the following cmdlet:

PowerShell Copy

```
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
```

This should return the following output if neither are already installed:

Copy

```
Name  : OpenSSH.Client~~~~0.0.1.0
State : NotPresent

Name  : OpenSSH.Server~~~~0.0.1.0
State : NotPresent
```

Then, install the server or client components as needed:

PowerShell Copy

```
# Install the OpenSSH Client
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

Both of these should return the following output:

Copy

```
Path          :
Online        : True
RestartNeeded : False
```

## [](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/_generated_background_page.html#start-and-configure-openssh-server)Start and configure OpenSSH Server

To start and configure OpenSSH Server for initial use, open PowerShell as an administrator, then run the following commands to start the `sshd service`:

PowerShell Copy

```
# Start the sshd service
Start-Service sshd

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'

# Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}
```

## [](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/_generated_background_page.html#connect-to-openssh-server)Connect to OpenSSH Server

Once installed, you can connect to OpenSSH Server from a Windows 10 or Windows Server 2019 device with the OpenSSH client installed using PowerShell as follows. Be sure to run PowerShell as an administrator:

PowerShell Copy

```
ssh username@servername
```

Once connected, you get a message similar to the following:

Copy

```
The authenticity of host 'servername (10.00.00.001)' can't be established.
ECDSA key fingerprint is SHA256:(<a large string>).
Are you sure you want to continue connecting (yes/no)?
```

Selecting **yes** adds that server to the list of known SSH hosts on your Windows client.

You are prompted for the password at this point. As a security precaution, your password will not be displayed as you type.

Once connected, you will see the Windows command shell prompt:

Copy

```
domain\username@SERVERNAME C:\Users\username>
```

## [](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/_generated_background_page.html#openssh-configuration-files)OpenSSH configuration files

OpenSSH has configuration files for both server and client settings. OpenSSH is open-source and is added to Windows Server and Windows Client operating systems, starting with Windows Server 2019 and Windows 10 (build 1809). As a result, documentation for OpenSSH configuration files is not repeated here. Client configuration files and can be found on the [ssh\_config manual page](https://man.openbsd.org/ssh_config) and for OpenSSH Server configuration files can be found on the [sshd\_config manual page](https://man.openbsd.org/sshd_config). Further Windows-specific OpenSSH Server configuration is detailed in [OpenSSH Server configuration for Windows](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/_generated_background_page.htmlopenssh_server_configuration#windows-configurations-in-sshd_config).

In Windows, the OpenSSH Client (ssh) reads configuration data from a configuration file in the following order:

1.  By launching ssh.exe with the -F parameter, specifying a path to a configuration file and an entry name from that file.
2.  A user's configuration file at %userprofile%\\.ssh\\config.
3.  The system-wide configuration file at %programdata%\\ssh\\ssh\_config.

Open SSH Server (sshd) reads configuration data from %programdata%\\ssh\\sshd\_config by default, or a different configuration file may be specified by launching sshd.exe with the -f parameter. If the file is absent, sshd generates one with the default configuration when the service is started.

## [](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/_generated_background_page.html#uninstall-openssh-using-windows-settings)Uninstall OpenSSH using Windows Settings

To uninstall OpenSSH using Windows Settings:

1.  Open **Settings**, then go to **Apps > Apps & Features**.
2.  Go to **Optional Features**.
3.  In the list, select **OpenSSH Client** or **OpenSSH Server**.
4.  Select **Uninstall**.

## [](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/_generated_background_page.html#uninstall-openssh-using-powershell)Uninstall OpenSSH using PowerShell

To uninstall the OpenSSH components using PowerShell, use the following commands:

PowerShell Copy

```
# Uninstall the OpenSSH Client
Remove-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Uninstall the OpenSSH Server
Remove-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

You may need to restart Windows afterwards if the service was in use at the time it was uninstalled.

___

## Recommended content

-   [OpenSSH Server configuration for Windows](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_server_configuration)
    
    Configuration information about OpenSSH Server for Windows Server and Windows.
    
-   [OpenSSH key management for Windows](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement)
    
    OpenSSH Server key management for Windows using the Windows tools or PowerShell.
    
-   [Windows Terminal SSH](https://docs.microsoft.com/en-us/windows/terminal/tutorials/ssh)
    
    In this tutorial, learn how to set up an SSH connection in Windows Terminal.
    
-   [Overview about OpenSSH for Windows](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_overview)
    
    Overview about the OpenSSH tools used by administrators of Linux and other non-Windows for cross-platform management of remote systems.
    
-   [Run SSH Command](https://docs.microsoft.com/en-us/system-center/orchestrator/standard-activities/run-ssh-command)
    
    This articles describes the functionality of Run SSH Command activity.
    
-   [Vagrant and Hyper-V -- Tips and Tricks](https://docs.microsoft.com/en-us/virtualization/community/team-blog/2017/20170706-vagrant-and-hyper-v-tips-and-tricks)
    
-   [Disable Hyper-V to run virtualization software - Windows Client](https://docs.microsoft.com/en-us/troubleshoot/windows-client/application-management/virtualization-apps-not-work-with-hyper-v)
    
    Discusses an issue in which virtualization applications don't work together with Hyper-V, Device Guard, and Credential Guard. Provides a resolution.
    

