Add-PSSnapin VMware.VimAutomation.Core  

$vcenter="vcenter50.johnson.local"  

#Connect to vcenter server  
connect-viserver $vcenter

# get list of vm's running on esx1 excluding nas1
$vmlist = Get-VMHost esx1.johnson.local | get-vm | Where-Object {$_.powerstate -eq "PoweredOn" -and $_.name -ne "nas1"} 

$vmlist | 
foreach {
    $vmname = $_.name  
	
    #Generate a vm view to determine whether to shutdown gracefully or stop based on vmtools status   
    $vm = Get-View -ViewType VirtualMachine -Filter @{"Name" = $vmname}  
	if ($vm.config.Tools.ToolsVersion -ne 0) {
		Write-Host "VMware tools installed. Graceful OS shutdown ++++++++ $vmname ----"  
		Shutdown-VMGuest $vmname -Confirm:$false  

		#For generating email  
		$Report += $vmname + " --- VMware tools installed. Graceful OS shutdown `r`n"  
	}  
	else {  
		Write-Host "VMware tools not installed. Force VM shutdown ++++++++ $vmname ----"  
		Stop-VM $vmname -Confirm:$false  

		#For generating email  
		$Report += $vmname + " --- VMware tools not installed. Force VM shutdown `r`n"  
	}  # if $vm.config.Tools.ToolsVersion 

}  # foreach vm in vmlist

#write-host "Sleeping ..."  
#Sleep 300  

$shutdownComplete = 0
# now check to see that all vm's have been shutdown - sleep if not shutdown
do {
	$vmlist | 
	foreach {
	    $vmname = $_.name  
		
	    #Generate a vm view to determine whether to shutdown gracefully or stop based on vmtools status   
	    $vm = Get-View -ViewType VirtualMachine -Filter @{"Name" = $vmname}  
		if ($vm.config.Tools.ToolsVersion -ne 0) {
			Write-Host "VMware tools installed. Graceful OS shutdown ++++++++ $vmname ----"  
			Shutdown-VMGuest $vmname -Confirm:$false  

			#For generating email  
			$Report += $vmname + " --- VMware tools installed. Graceful OS shutdown `r`n"  
		}  
		else {  
			Write-Host "VMware tools not installed. Force VM shutdown ++++++++ $vmname ----"  
			Stop-VM $vmname -Confirm:$false  

			#For generating email  
			$Report += $vmname + " --- VMware tools not installed. Force VM shutdown `r`n"  
		}  # if $vm.config.Tools.ToolsVersion 

	}  # foreach vm in vmlist
}while($shutdownComplete -ne 1);

#Send out an email with the names  
$emailFrom = "admin@dettonville.org"  
$emailTo = "admin@dettonville.org"  
$subject = "List of servers shutdown for maintenance"  
$smtpServer = "mail1.johnson.local"  
$smtp = new-object Net.Mail.SmtpClient($smtpServer)  
$smtp.Send($emailFrom, $emailTo, $subject, $Report)  

Disconnect-VIServer $vcenter -Confirm:$false
