
Import-Module Log4Posh 

function Send-Report {
	[CmdletBinding()]
	param(
		[string]$subject, 
		[string]$emailFrom,
		[string]$emailTo,  
		[string]$smtpServer,
		[string]$logFileName,
        [Parameter(ValueFromRemainingArguments = $true)]
        $remainingArgs
	)
	$report = (Get-Content $logFileName) -join "`n"

	#Send out an email with the names  
	$smtp = new-object Net.Mail.SmtpClient($smtpServer)  
	$smtp.Send($emailFrom, $emailTo, $subject, $report)  
}

function Login-VCenter ([string] $server ) {
	#connect to vcenter
	write-verbose "Connecting to vCenter - $server ...."
	$success = Connect-VIServer $server 

	if ($success) { 
		write-verbose "Connected!" 
		write-verbose ""
	}
	else
	{
		## throw a terminating exception since can't login prevents all subsequent processing
#		$errorRecord = New-ErrorRecord System.InvalidOperationException FailedLogin`
#		    InvalidOperation $server -Message "Could not connect to vicenter server '$server'."
#	    Write-Error -ErrorRecord $errorRecord 
#		$PSCmdlet.ThrowTerminatingError($errorRecord)

		$errorMsg = "Could not connect to vicenter server '$server'."
	    Write-Error $errorMsg 
		throw $errorMsg
	}
}

function Start-VmList([object[]]$vmlist, [int] $timeout =180 ) {
	$taskTab = @{}
	
	if (-not ($vmlist) -or ($vmlist.count -eq 0)) {
		write-verbose "no VMs to start"
		return
	}
	
	$vmlist = Get-VM $vmlist.name 

	$tasklist = New-Object System.Collections.ArrayList
	
	write-verbose "Starting following guests: $($vmlist).name)"
	ForEach ( $guest in $vmlist ) 
	{
		$vmname = $guest.name
		if ($guest.PowerState -eq "PoweredOn") {
            write-verbose "Skipping $vmname - already powered on" 
			continue
		}
        $task = Start-VM $vmname -RunAsync:$true -Confirm:$false
		$taskid = $task.Id
		write-verbose "$vmname startup task launched: task.ID = $taskid"  
        $taskTab[$vmname] = $task
	}
	
	# track restart VM status to completion or timeout
	$runningTasks = $taskTab.Count
	write-verbose "runningTasks = $runningTasks"

	$timer = New-Object System.Diagnostics.Stopwatch
	$timer.Start()
	
	while($runningTasks -gt 0){
		$CurrentTime = $timer.Elapsed
		$timeElapsed = ([int] $CurrentTime.TotalSeconds).ToString() 
		write-verbose "waited $timeElapsed seconds" 
		
		$vmlist | Where-Object {$taskTab.keys -contains $_.name } | % {
			$vmname = $_.name
			$task = $taskTab.Item($vmname)
			$taskid = $task.Id
			$state = $task.State
			write-verbose "vmname = ${vmname}: task.ID = $taskid and task.State = $state"
			if($task.State -eq "Success"){
		        write-verbose "VM $vmname started" 
				$taskTab.Remove($vmname)
				$runningTasks--
			}
			elseif($task.State -eq "Error"){
		        write-verbose "VM $vmname failed to start" 
				$taskTab.Remove($vmname)
				$runningTasks--
			}
		}
		# wait up to timeout seconds - then break
		if ( $CurrentTime.TotalSeconds -ge $timeout) {
			## report non-terminating exception 
#			$errorRecord = New-ErrorRecord System.InvalidOperationException TimeOut `
#			    OperationTimeout $taskTab.Keys -Message "wait for start task for VMs ${taskTab.Keys} exceeded timeout of $timeout seconds, timing out now"
#		    Write-Error -ErrorRecord $errorRecord

			Write-Error "wait for start task for VMs ${taskTab.Keys} exceeded timeout of $timeout seconds, timing out now"
			break
		}
		Start-Sleep -Seconds 5
	}

	write-verbose "All VMs started, now waiting for PowerState to achieve 'PowerOn' status" 

	while ((Get-VM $vmlist.name | where-object {$_.PowerState -ne "PoweredOn"} ) )
	{
		$CurrentTime = $timer.Elapsed
		$timeElapsed = ([int] $CurrentTime.TotalSeconds).ToString() 
		write-verbose "waited $timeElapsed seconds for power on" 
		if ( $CurrentTime.TotalSeconds -ge $timeout) {
			## report non-terminating exception 
#			$errorRecord = New-ErrorRecord System.InvalidOperationException TimeOut `
#			    OperationTimeout $taskTab.Keys -Message "wait for VM power-on exceeded timeout of $timeout seconds, timing out now"
#		    Write-Error -ErrorRecord $errorRecord

			Write-Error "wait for VM power-on exceeded timeout of $timeout seconds, timing out now"
			break;
		}
		Start-Sleep -Seconds 5
	}

	$timer.Stop()

	$timeElapsed = ([int] $timer.Elapsed.TotalSeconds).ToString() 
	write-verbose "All VMs started after $timeElapsed seconds!" 
}

function Start-VmHostList([object[]]$vmhostlist, [int] $timeout=400) {
	$taskTab = @{}

	if ($vmhostlist.count -eq 0) {
		write-verbose "no hosts to start"
		return $msg
	}

	write-verbose "Restart hosts...."
	ForEach ( $vmhost in $vmhostlist ) 
	{
		if ((Get-VMHost $vmhost).PowerState -eq "PoweredOn") {
            write-verbose "Skipping $vmhost - already powered on" 
			continue
		}
		write-verbose "Setting timeout to 480 seconds"  
		Set-PowerCLIConfiguration -Confirm:$false -WebOperationTimeoutSeconds 480
		
		write-verbose "Starting $vmhost..."  
		$taskTab[(Start-VMHost $vmhost -Confirm:$false -RunAsync:$true).Id] = $vmhost
	}
	
	write-verbose "track VM Host start status to completion or timeout of $timeout seconds"
	$runningTasks = $taskTab.Count

	$timer = New-Object System.Diagnostics.Stopwatch
	$timer.Start()

	while($runningTasks -gt 0){
		$CurrentTime = $timer.Elapsed
		$timeElapsed = ([int] $CurrentTime.TotalSeconds).ToString() 
		write-verbose "waited $timeElapsed seconds" 
		Get-Task | Where-Object {$taskTab.keys -contains $_.id } | % {
			$task = $_
			$taskid = $task.id
			$state = $task.state
			$vmhost = $taskTab.item($taskid)
			write-verbose "vmhost ${vmhost}: task.ID = $taskid and task.State = $state"
			if($taskTab.ContainsKey($_.Id) -and $_.State -eq "Success"){
				$vmhost = $taskTab[$_.Id]
		        write-verbose "VM Host $vmhost restarted after $timeElapsed seconds" 
				$taskTab.Remove($_.Id)
				$runningTasks--
			}
			elseif($taskTab.ContainsKey($_.Id) -and $_.State -eq "Error"){
				$vmhost = $taskTab[$_.Id]
		        write-verbose "VM Host $vmhost failed to restart" 
				$taskTab.Remove($_.Id)
				$runningTasks--
			}
		}
		
		# wait up to timeout seconds - then break
		if ( $CurrentTime.TotalSeconds -ge $timeout) {
			## report non-terminating exception 
#			$errorRecord = New-ErrorRecord System.InvalidOperationException TimeOut `
#			    OperationTimeout $taskTab.keys -Message "wait for VM host start exceeded timeout of $timeout seconds, timing out now"
#		    Write-Error -ErrorRecord $errorRecord

			Write-Error "wait for VM host start exceeded timeout of $timeout seconds, timing out now"
			break
		}
		Start-Sleep -Seconds 15
	}

	write-verbose "All VM Hosts started, now waiting for PowerState to achieve 'PowerOn' status" 

	while ((Get-VMHost $vmhostlist | where-object {$_.PowerState -ne "PoweredOn" } ) )
	{
		$CurrentTime = $timer.Elapsed
		$timeElapsed = ([int] $CurrentTime.TotalSeconds).ToString() 
		write-verbose "waited $timeElapsed seconds for power on" 
		# wait up to timeout seconds - then break
		if ( $CurrentTime.TotalSeconds -ge $timeout) {
			## report non-terminating exception 
#			$errorRecord = New-ErrorRecord System.InvalidOperationException TimeOut `
#			    OperationTimeout $vmhostlist -Message "wait for VM host power on exceeded timeout of $timeout seconds, timing out now"
#		    Write-Error -ErrorRecord $errorRecord

			Write-Error "wait for VM host power on exceeded timeout of $timeout seconds, timing out now"
			break
		}
		Start-Sleep -Seconds 5
	}

	$timer.Stop()

	$timeElapsed = ([int] $timer.Elapsed.TotalSeconds).ToString() 
	write-verbose "All ESXi hosts started after $timeElapsed seconds!" 
}

function PowerOff-VmList([object[]]$vmlist, [Boolean] $hardoff = $false, [int] $timeout = 60 ) {
	$taskTab = @{}
	
	if ($vmlist.count -eq 0) {
		write-verbose "no VMs to stop"
		return $msg
	}

	write-verbose "power off vm guests for guests: $vmlist...."
	ForEach ( $guest in $vmlist ) 
	{
		$vmname = $guest.name
		write-verbose "Processing $guest - checking for VMware tools install..."  
	    $guestinfo = get-view -Id $guest.ID
		write-verbose "guestinfo.guest.toolsVersionStatus = ${guestinfo.guest.toolsVersionStatus}"
	    if ($guestinfo.config.Tools.ToolsVersion -eq 0 `
			-or $guestinfo.guest.toolsVersionStatus -eq "guestToolsUnmanaged" `
			-or $guestinfo.guest.toolsRunningStatus -ne "guestToolsRunning" `
			-or $hardoff)
	    {
	        write-verbose "No VMware tools detected in $guest , hard restart on this one" 
			$task = Stop-VM $guest -confirm:$false -RunAsync:$true
			$taskid = $task.Id
			write-verbose "$vmname stop-vm task launched: task.ID = $taskid"  
	        $taskTab[$taskid] = $guest
	    }
	    else {
			write-verbose "VMware tools detected.  I will attempt to gracefully shutdown $guest"
			Shutdown-VMGuest $guest -Confirm:$false | Out-Null
	    }
	}
	
	# track restart VM status to completion or timeout
	$runningTasks = $taskTab.Count

	$timer = New-Object System.Diagnostics.Stopwatch
	$timer.Start()

	while($runningTasks -gt 0){
		$CurrentTime = $timer.Elapsed
		$timeElapsed = ([int] $CurrentTime.TotalSeconds).ToString() 
		write-verbose "waited $timeElapsed seconds" 
		
		Get-Task | Where-Object {$taskTab.keys -contains $_.id } | % {
			$task = $_
			$taskid = $task.Id
			$guest = $taskTab.Item($taskid)
			$state = $task.State
			write-verbose "VM ${guest}: task.ID = $taskid and task.State = $state"

			if($task.State -eq "Success"){
		        write-verbose "VM $guest stopped" 
				$taskTab.Remove($vmname)
				$runningTasks--
			}
			elseif($task.State -eq "Error"){
				## report non-terminating exception 
#				$errorRecord = New-ErrorRecord System.InvalidOperationException TimeOut `
#				    InvalidOperation $guest -Message "VM $guest failed to start" 
#			    Write-Error -ErrorRecord $errorRecord

				Write-Error "VM $guest failed to start" 
				$taskTab.Remove($vmname)
				$runningTasks--
			}
		}
		# wait up to timeout seconds - then break
		if ( $CurrentTime.TotalSeconds -ge $timeout) {
			## report non-terminating exception 
#			$errorRecord = New-ErrorRecord System.InvalidOperationException TimeOut `
#			    OperationTimeout $runningTasks -Message "wait for $runningTasks VM stop tasks exceeded timeout of $timeout seconds, timing out now"
#		    Write-Error -ErrorRecord $errorRecord
			$errorMsg = "wait for $runningTasks VM stop tasks exceeded timeout of $timeout seconds, timing out now"
		    Write-Error $errorMsg
			break
		}
		Start-Sleep -Seconds 5
	}

	while ((Get-VM $vmlist | where-object {$_.PowerState -eq "PoweredOn" } ) )
	{
		$CurrentTime = $timer.Elapsed
		$timeElapsed = ([int] $CurrentTime.TotalSeconds).ToString() 
		write-verbose "waited $timeElapsed seconds" 
		# wait up to timeout seconds - then break
		if ( $CurrentTime.TotalSeconds -ge $timeout) {
			## report non-terminating exception 
#			$errorRecord = New-ErrorRecord System.InvalidOperationException TimeOut `
#			    OperationTimeout $vmlist -Message "wait for VM guest stop exceeded timeout of $timeout seconds, timing out now"
#		    Write-Error -ErrorRecord $errorRecord

			Write-Error "wait for VM guest stop exceeded timeout of $timeout seconds, timing out now"
			break;
		}
		Start-Sleep -Seconds 5
	}

	$timer.Stop()

	$timeElapsed = ([int] $timer.Elapsed.TotalSeconds).ToString() 
	write-verbose "All VMs stopped after $timeElapsed seconds!" 
}

function PowerOff-VmHost([object[]]$vmhostlist, [int] $timeout=400) {
	$taskTab = @{}
	
	if ($vmhostlist.count -eq 0) {
		write-verbose "no hosts to stop"
		return $msg
	}
	
	write-verbose "Stopping VM hosts...."
	ForEach ( $vmhost in $vmhostlist ) 
	{
		write-verbose "Stopping $vmhost..."  
		$taskTab[(Suspend-VMHost $vmhost -Confirm:$false -RunAsync:$true).Id] = $vmhost
	}
	
	$runningTasks = $taskTab.Count
	$timer = New-Object System.Diagnostics.Stopwatch
	$timer.Start()

	while($runningTasks -gt 0){
		$CurrentTime = $timer.Elapsed
		$timeElapsed = ([int] $CurrentTime.TotalSeconds).ToString() 
		write-verbose "waited $timeElapsed seconds" 

		Get-Task | Where-Object {$taskTab.keys -contains $_.id } | % {
			$task = $_
			$taskid = $task.Id
			$vmhost = $taskTab.Item($taskid)
			$state = $task.State
			write-verbose "VMHost ${vmhost}: task.ID = $taskid and task.State = $state"
			
			if($taskTab.ContainsKey($_.Id) -and $_.State -eq "Success"){
		        write-verbose "VM Host $vmhost shut-down after $timeElapsed seconds" 
				$taskTab.Remove($_.Id)
				$runningTasks--
			}
			elseif($taskTab.ContainsKey($_.Id) -and $_.State -eq "Error"){
				## report non-terminating exception 
#				$errorRecord = New-ErrorRecord System.InvalidOperationException FailedOperation `
#				    InvalidOperation $vmhost -Message "VM Host $vmhost failed to shut-down" 
#			    Write-Error -ErrorRecord $errorRecord

				Write-Error "VM Host $vmhost failed to shut-down" 
				$taskTab.Remove($_.Id)
				$runningTasks--
			}
		}
		# wait up to timeout seconds - then break
		if ( $CurrentTime.TotalSeconds -ge $timeout) {
			## report non-terminating exception 
#			$errorRecord = New-ErrorRecord System.InvalidOperationException TimeOut `
#			    OperationTimeout $taskTab.keys -Message "wait for VM host suspend exceeded timeout of $timeout seconds, timing out now"
#		    Write-Error -ErrorRecord $errorRecord

			Write-Error "wait for VM host suspend exceeded timeout of $timeout seconds, timing out now"
			break
		}
		Start-Sleep -Seconds 15
	}

	while ((Get-VMHost $vmhostlist | where-object {$_.PowerState -ne "Standby" } ) )
	{
		$CurrentTime = $timer.Elapsed
		$timeElapsed = ([int] $CurrentTime.TotalSeconds).ToString() 
		write-verbose "waited $timeElapsed seconds" 
		# wait up to timeout seconds - then break
		if ( $CurrentTime.TotalSeconds -ge $timeout) {
			## report non-terminating exception 
#			$errorRecord = New-ErrorRecord System.InvalidOperationException TimeOut `
#			    OperationTimeout $vmhostlist -Message "wait for VM host power off exceeded timeout of $timeout seconds, timing out now"
#		    Write-Error -ErrorRecord $errorRecord

			Write-Error "wait for VM host power off exceeded timeout of $timeout seconds, timing out now"
			break;
		}
		Start-Sleep -Seconds 5
	}

	$timer.Stop()

	$timeElapsed = ([int] $timer.Elapsed.TotalSeconds).ToString() 
	write-verbose "All ESXi hosts stopped after $timeElapsed seconds!" 

}
