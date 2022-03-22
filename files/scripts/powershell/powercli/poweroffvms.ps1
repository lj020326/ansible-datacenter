#################################################################################
# Power off VMs (poweroffvms.ps1)
#
# This is a complete update to my previous shutdown script.  No longer do we
# loop through the esx hosts and shut down VMs per host.  We now just shut them
# all down up front.  Also, no more $vmstoleaveon variable.  I'm assuming here 
# that your vCenter is not virtual.  If it is you can most likely grab version
# 1 of this script and take the code to leave the vCenter host till last.  Maybe
# someday I'll get around to updating it to merge the two...but for now, this is
# it!
#
# This script does have a 'partner' script that powers the VMs back on, you can
# grab that script at http://blog.mwpreston.net/shares/
#
# Created By: Mike Preston, 2012 - With a whole lot of help from Eric Wright 
#                                  (@discoposse)
#
# Variables:  $mysecret - a secret word to actually make the script run, stops 
#                         the script from running when double click DISASTER
#             $vcenter - The IP/DNS of your vCenter Server
#             $username/password - credentials for your vCenter Server
#             $serverfile - path to csv file to store powered on vms
#					  used for the poweronvms.ps1 script.
#             $cluster - Name of specific cluster to target within vCenter
#             $datacenter - Name of specific datacenter to target within vCenter
#
#
# Usage: ./poweroffvms.ps1 "keyword"
#        Intended to be ran in the command section of the APC Powerchute Network
#        Shutdown program before the shutdown sequence has started.
#
#################################################################################

#param($keyword)

#Add-PSSnapin VMware.VimAutomation.Core
#Import-Module PowerShellLogging 

if ((-not (Get-Variable -Name PSScriptRoot -ValueOnly -ErrorAction SilentlyContinue)) -and
    ($scriptBlockFile = $MyInvocation.MyCommand.ScriptBlock.File)) {
     $PSScriptRoot = $MyInvocation.MyCommand.ScriptBlock.File
}

Write-Debug "PSScriptRoot=$PSScriptRoot"

.$PSScriptRoot\LoadConfig $PSScriptRoot\poweroffvms.config
. $PSScriptRoot\MyPowerCliLib.ps1

function Perform-PowerOff {
	<#
	.SYNOPSIS
	      This function powers off all the running vm's on a vmhost and then shuts down the vmhost
	#>
	[CmdletBinding()]
	Param
	(
		[string] 
		## serverfile is file that will store list of vm's that have been shut off 
		$serverFile,
		[string]
		# Path of the configuration file of log4net
		$logConfigFilePath,
		[Alias("Dll")]
		[string]
		# Path of Log4net dll 
		$log4netDllPath,
		[string]
		# vcenter server to connect to
		$vcenter,
		[string] 
		# vmhost to shut down
		$vmhost,
		[string] 
		# list of vm's that are last to shut off - nas/nfs shares, etc
		$vmslast2stop,
		[string] 
		# secret required to run script
		$secret,
		[string]
		# subject of email sent after done
		$subject,
		[string]
		# email address of sender
		$emailFrom,
		[string]
		# email address of recipient
		$emailTo,  
		[string]
		# dns of smtp server
		$smtpServer,
        [Parameter(ValueFromRemainingArguments = $true)]
        $remainingArgs
	)

	Write-Debug "serverfile = $serverfile"
	Write-Debug "log4netDllPath = $log4netDllPath"
	Write-Debug "logConfigFilePath = $logConfigFilePath"

	Write-Verbose "Enable Log4Posh"
	$global:logger = Enable-Log4Posh @PSBoundParameters
	$logFileName = $global:logger.Logger.Appenders.File
	$functionName = $MyInvocation.MyCommand	

	Write-Output "Starting $functionName"
	
	Write-Verbose "A Powerchute network shutdown command has been sent to the vCenter Server." 
	Write-Verbose "This script will shutdown all of the VMs and hosts located in $datacenter" 
	Write-Verbose "Upon completion, this server ($vcenter) will also be shutdown gracefully" 
	Write-Verbose ""
	Write-Verbose "This script has also has a counterpart (powervmsbackon.ps1) which should" 
	Write-Verbose "be setup to run during the startup of this machine ($vcenter). " 
	Write-Verbose "This will ensure that your VMs are powered back on once power is restored!" 

	try {
		
		#if ($keyword -ne $secret) 
		#{ 
		#    Write-Verbose "You haven't passed the proper detonation sequence...ABORTING THE SCRIPT" 
		#    exit
		#}

		#connect to vcenter
		Write-Verbose ""
		Login-VCenter $vcenter
		Write-Verbose ""

		#Get a list of all powered on VMs - used for powering back on....
		Get-VMHost $vmhost | Get-VM | where-object {$_.PowerState -eq "PoweredOn"} | Select Name | Export-CSV $serverfile

		##change DRS Automation level to partially automated...
		#Write-Verbose "Changing cluster DRS Automation Level to Partially Automated" 
		#Get-Cluster $cluster | Set-Cluster -DrsAutomation PartiallyAutomated -confirm:$false 

		###change the HA Level
		#Write-Verbose ""
		#Write-Verbose "Disabling HA on the cluster..." + "`r`n" 
		#Write-Verbose ""
		#Get-Cluster $cluster | Set-Cluster -HAEnabled:$false -confirm:$false 

		Write-Verbose ""
		Write-Verbose "Phase 1 - get VMs - we will do this instead of parsing the file in case a VM was powered in the nanosecond that it took to get here.... :)" 
		Write-Verbose ""
		$poweredonguests = Get-VMHost $vmhost | Get-VM | where-object {$_.PowerState -eq "PoweredOn" -and $vmslast2stop -notcontains $_.name} 
		if ($poweredonguests) {
			PowerOff-VmList $poweredonguests
		}

		Write-Verbose "Phase 2 - hard stop for any non-priority VMs still left on....night night..." 
		Write-Verbose ""
		$poweredonguests = Get-VMHost $vmhost | Get-VM | where-object {$_.PowerState -eq "PoweredOn" -and $vmslast2stop -notcontains $_.name} 
		if ($poweredonguests) {
			PowerOff-VmList $poweredonguests $true
		}

		Write-Verbose "Phase 3 - priority VM shutdown - shutdown all remaining ..." 
		$poweredonguests = Get-VMHost $vmhost | Get-VM | where-object {$_.PowerState -eq "PoweredOn" } 
		if ($poweredonguests) {
			PowerOff-VmList $poweredonguests
		}

		Write-Verbose "Phase 4 - now its time to shut down the hosts" 
		$esxhosts = Get-VMHost $vmhost
		PowerOff-VmHost $esxhosts

	}
	Catch [Exception] {
		Write-Output "$($_.Exception.ToString()). $($_.InvocationInfo.PositionMessage)"
		Write-Error "$($_.Exception.ToString()). $($_.InvocationInfo.PositionMessage)"
	}
	Finally {
		## disconnect - silently continue just in case we are not connect when the exception was thrown
		try { Disconnect-VIServer $vcenter -Confirm:$false -ErrorAction SilentlyContinue } catch { }
		Write-Output "Finished $functionName"

		# Disable logging before the script exits (good practice, but the LogFile will be garbage collected 
		# so long as this variable was not in the Global Scope, as a backup in case the script crashes 
		# or you somehow forget to call Disable-LogFile). 
		Disable-Log4Posh 
		
		Send-Report -logFileName $logFileName @PSBoundParameters
#		Send-Report $logFileName @PSBoundParameters
	}
}

##
## start main script 
##

#$WarningPreference = 'SilentlyContinue' 
#$VerbosePreference = 'SilentlyContinue' 
#$DebugPreference = 'SilentlyContinue' 
$VerbosePreference = 'Continue' 
$DebugPreference = 'Continue' 

#$scriptname = (split-path $MyInvocation.MyCommand.Definition -Leaf)

Perform-PowerOff @appSettings

