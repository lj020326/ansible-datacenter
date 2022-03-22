#################################################################################
# Power On the Powered Off VMs (poweronvms.ps1)
#
# This script is a partner script to the poweroffvms.ps1 script.  Basically this
# script will look at the csv file that was dumped by poweroffvms.ps1 and power
# on all of the VMs in the file.  It's meant to be run automatically on startup
# but don't worry, it won't always try and power things on, it only will go if
# the power off dump file exists.
#
# This script does have a 'partner' script that powers the VMs off, you can
# grab that script at http://blog.mwpreston.net/shares/
#
# Created By: Mike Preston, 2012 - With a whole lot of help from Eric Wright 
#                                  (@discoposse)
#
# Variables:  $vcenter - The IP/DNS of your vCenter Server
#             $username/password - credentials for your vCenter Server
#             $serverfile - name of the file that poweroffvms.ps1 dumps
#             $myImportantVMs - list of VMS to be powered on first
#
#
# Usage: ./poweronvms.ps1
#       
#
#################################################################################


#Add-PSSnapin VMware.VimAutomation.Core
#Import-Module PowerShellLogging 

if ((-not (Get-Variable -Name PSScriptRoot -ValueOnly -ErrorAction SilentlyContinue)) -and
    ($scriptBlockFile = $MyInvocation.MyCommand.ScriptBlock.File)) {
     $PSScriptRoot = $MyInvocation.MyCommand.ScriptBlock.File
}

Write-Debug "PSScriptRoot=$PSScriptRoot"

.$PSScriptRoot\LoadConfig $PSScriptRoot\poweronvms.config
. $PSScriptRoot\MyPowerCliLib.ps1

function Perform-PowerOn {
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
		# list of vm's that are first to power on - nas/nfs shares, etc
		$myImportantVMs,
		[string]
		# datastores to wait for before powering on VMs
		$requiredDatastores,
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

	Write-Verbose "Enable Log4Posh"
	$global:logger = Enable-Log4Posh @PSBoundParameters
	$logFileName = $global:logger.Logger.Appenders.File
	$functionName = $MyInvocation.MyCommand	

	Write-Output "Starting $functionName"

	##some variables
	#$date = ( get-date ).ToString('yyyyMMdd-HHmmss')

	try {
		#check if the power on file exists - if it does, then there was a power outage... or someone ran it manually GRRRRR
		Write-Verbose "Checking to see if Power Off dump file exists....." 

		if (-not (Test-Path $serverfile)) {
			throw "File ($serverfile) Not Found - aborting..."
		}

		Write-Verbose "File Found" 
		Write-Verbose ""

		#connect to vcenter
		Login-VCenter $vcenter
		Write-Verbose ""

		Write-Verbose "Phase 1 - exit standby by starting VM Host $vmhost..." 
		Start-VmHostList $vmhost

		Write-Verbose ""
		Write-Verbose "Phase 2 - Starting the most important VMs first" 
		Write-Verbose ""

		$vmlist = Get-VM $myImportantVMs | Select Name 
		Start-VmList $vmlist

		Write-Verbose "Waiting until $requiredDatastores are available" 
		$timer = New-Object System.Diagnostics.Stopwatch
		$timer.Start()
		$timeout = 120
		while ((Get-Datastore $requiredDatastores | where-object {$_.State -ne "Available" } ) )
		{
			$CurrentTime = $timer.Elapsed
			$timeElapsed = ([int] $CurrentTime.TotalSeconds).ToString() 
			Write-Verbose "waited $timeElapsed seconds for datastore startup" 
			# wait up to timeout seconds - then break
			if ( $CurrentTime.TotalSeconds -ge $timeout) {
				## throw terminating exception 
	#			$errorRecord = New-ErrorRecord System.InvalidOperationException TimeOut `
	#			    OperationTimeout $required_datastore -Message "wait for $required_datastore exceeded timeout of $timeout seconds, timing out now" 
	#		    Write-Error -ErrorRecord $errorRecord
	#			$PSCmdlet.ThrowTerminatingError($errorRecord)

				$errorMsg = "wait for $required_datastore exceeded timeout of $timeout seconds, timing out now" 
			    Write-Error $errorMsg
				throw $errorMsg
			}
			Start-Sleep -Seconds 5
		}

		$timer.Stop()

		$timeElapsed = ([int] $timer.Elapsed.TotalSeconds).ToString() 
		Write-Verbose "Datastores $required_datastore started after $timeElapsed seconds!" 

		Write-Verbose ""
		Write-Verbose "Phase 3 - Starting the remaining VMs" 
		Write-Verbose ""
		$vmlist = Import-CSV $serverfile
		$vmlist = $vmlist | Where-Object {$myImportantVMs -notcontains $_.name}
		if ($vmlist) {
			Write-Verbose "vmlist = $(($vmlist).name)"
			Start-VmList $vmlist
		}

		Write-Verbose "Power on completed, I will now rename the dump file...." 
		$DateStamp = get-date -uformat "%Y-%m-%d@%H-%M-%S"  
		$fileObj = get-item $serverfile
		$extOnly = $fileObj.extension
		$nameOnly = $fileObj.Name.Replace( $fileObj.Extension,'')
		rename-item "$serverfile" "$nameOnly-$DateStamp$extOnly"
		Write-Verbose "File has been renamed to $nameOnly-$DateStamp$extOnly"   
		
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
		
#		Send-Report $subject $logFileName 
		Send-Report -logFileName $logFileName @PSBoundParameters
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

Perform-PowerOn @appSettings

