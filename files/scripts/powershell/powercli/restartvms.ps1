#################################################################################
# Restart VMs (restartvms.ps1)
#
# This script resets, or if not vmtools equipped, restarts the running VMS on 
# a chosen esxi host 
#
# Created By: Lee Johnson, 2015 - With a whole lot of help from Mike Preston & Eric Wright 
#                                  (@discoposse)
#
# Variables:  $mysecret - a secret word to actually make the script run, stops 
#                         the script from running when double click DISASTER
#             $vcenter - The IP/DNS of your vCenter Server
#             $username/password - credentials for your vCenter Server
#             $filename - path to csv file to store powered on vms
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

param($keyword)

function func_log([string] $msg, [System.ConsoleColor] $foregroundColor) {
		$msg += "`r`n" 
		if ($foregroundColor) {
			Write-Host $msg -ForegroundColor $foregroundColor
		} else {
			Write-Host $msg 
		}
		return $msg 
}

function func_sendReport ( [string]$report ) {
	#Send out an email with the names  
	$emailFrom = "admin@dettonville.org"  
	$emailTo = "admin@dettonville.org"  
	$subject = "List of restarted servers"  
	$smtpServer = "mail1.johnson.local"  
	$smtp = new-object Net.Mail.SmtpClient($smtpServer)  
	$smtp.Send($emailFrom, $emailTo, $subject, $report)  
}


function func_logon ([string] $server ) {
	#connect to vcenter
	$msg = func_log "Connecting to vCenter - $server ...."
	$success = Connect-VIServer $server 

	if ($success) { 
		$msg += func_log "Connected!" Green
	}
	else
	{
	    $msg += func_log "Connection to $vcenter failed, Aborting script" Red
		func_sendReport $msg
	    exit
	}
	Write-Host ""
	return $msg
}

function func_restartvms([object[]]$vmlist) {
	$msg=""
	$taskTab = @{}

	if ($vmlist.count -eq 0) {
		$msg += func_log "no VMs to restart"
		return $msg
	}
	
	func_log "and now, let's restart guests...."
	ForEach ( $guest in $vmlist ) 
	{
		$msg += func_log "Processing $guest - checking for VMware tools install..." Green 
	    $guestinfo = get-view -Id $guest.ID
	    if ($guestinfo.config.Tools.ToolsVersion -eq 0)
	    {
	        $msg += func_log "No VMware tools detected in $guest , hard restart on this one" Yellow
	        $taskTab[(Restart-VM $guest -Confirm:$false -RunAsync).Id] = $guest
	    }
	    else {
			$msg += func_log "VMware tools detected.  I will gracefully restart $guest"
			Restart-VMGuest $guest -Confirm:$false
	    }
	}
	
	# track restart VM status to completion or timeout
	$runningTasks = $taskTab.Count

	$timer = New-Object System.Diagnostics.Stopwatch
	$timer.Start()

	# wait 1 minute max
	$timeout = 2 * 60 
	
	while($runningTasks -gt 0){
		$CurrentTime = $timer.Elapsed
		$timeElapsed = ([int] $CurrentTime.TotalSeconds).ToString() 
		$msg += func_log "waited $timeElapsed seconds" Yellow
		Get-Task | % {
			$guest = $taskTab[$_.Id]
			if($taskTab.ContainsKey($_.Id) -and $_.State -eq "Success"){
		        $msg += func_log "VM $guest restarted gracefully" Green
				$taskTab.Remove($_.Id)
				$runningTasks--
			}
			elseif($taskTab.ContainsKey($_.Id) -and $_.State -eq "Error"){
		        $msg += func_log "VM $guest failed to restart gracefully" Red
				$taskTab.Remove($_.Id)
				$runningTasks--
			}
		}
		# wait up to timeout seconds - then break
		if ( $CurrentTime.TotalSeconds -ge $timeout) {
		    $msg += func_log "VMs still running after $timeout seconds, so timeout..."
			break;
		}
		Start-Sleep -Seconds 15
	}

	while ((Get-VM $vmlist | where-object {$_.PowerState -ne "PoweredOn" -and $vmlist -notcontains $_.Name } ) )
	{
		$CurrentTime = $timer.Elapsed
		$timeElapsed = ([int] $CurrentTime.TotalSeconds).ToString() 
		$msg += func_log "waited $timeElapsed seconds for power on" Yellow
		# wait up to timeout seconds - then break
		if ( $CurrentTime.TotalSeconds -ge $timeout) {
		    $msg += func_log "wait for VM host power on exceeded timeout of $timeout seconds, timing out now"
			break;
		}
		Start-Sleep -Seconds 5
	}

	$timer.Stop()

	$timeElapsed = ([int] $timer.Elapsed.TotalSeconds).ToString() 
	$msg += func_log "All VMs started after $timeElapsed seconds!" Green

	return $msg
}

## now for the script

#Add-PSSnapin VMware.VimAutomation.Core
#some variables
$vcenter = "vcenter50.johnson.local"
#$username = "user"
#$password = "password"
$cluster = "prod-cluster"
#$datacenter = "datacenterName"
$vmhost = "esx3.johnson.local"
$filename = "c:\apps\powershell\resetvms.csv"
#$vmslast2stop = "samba1"
#$mysecret = "abracadabra"
$mysecret = "test"
$msg=""

Write-Host "This script will restart all of the VMs and hosts located on $vmhost" -Foregroundcolor yellow
Write-Host ""
Sleep 5

#if ($keyword -ne $mysecret) 
#{ 
#    Write-Host "You haven't passed the proper detonation sequence...ABORTING THE SCRIPT" -ForegroundColor red
#    exit
#}

#connect to vcenter
$msg += func_logon $vcenter
Write-Host ""

#get VMs 
Write-Host ""
$msg += func_log "Retrieving a list of powered on guests...." Green
Write-Host ""
$poweredonguests = Get-VMHost $vmhost | Get-VM | where-object {$_.PowerState -eq "PoweredOn" -and $_.name -notlike "samba*"} 

$msg += func_log "now, let's start restarting some guests...."
$msg += func_restartvms $poweredonguests

Write-Host ""
$msg += func_log "All VMs restarted except samba"
$msg += func_log "Shutting down samba..."
Write-Host ""

$poweredonguests = Get-VMHost $vmhost | Get-VM | where-object {$_.PowerState -eq "PoweredOn" -and $_.name -like "samba*"} 

$msg += func_log "now, let's start restarting samba1 guests...."
$msg += func_restartvms $poweredonguests

Write-Host ""
$msg += func_log "Samba VMs restarted"
Write-Host ""

func_sendReport $msg

Disconnect-VIServer $vcenter -Confirm:$false
