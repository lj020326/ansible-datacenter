#
# Find all hosts with triggered alarms in "Red" state
#

param($csvName=("C:\data\dettonville\datacenter\get-triggered-alarms.csv"))

function func_log([string] $msg, [System.ConsoleColor] $foregroundColor) {
		$msg += "`r`n" 
		if ($foregroundColor) {
			Write-Host $msg -ForegroundColor $foregroundColor
		} else {
			Write-Host $msg 
		}
		return $msg 
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
	    $msg += func_log "Something is wrong, Aborting script" Red
		func_sendReport $msg
	    exit
	}
	Write-Host ""
	return $msg
}

$msg = func_log "Starting Report"

$vcenter = "vcenter50.johnson.local"
$msg += func_logon $vcenter

$esx_all = Get-VMHost | Get-View
$Report=@()
foreach ($esx in $esx_all){
    foreach($triggered in $esx.TriggeredAlarmState){
        If ($triggered.OverallStatus -like "red" ){
            $lineitem={} | Select Name, AlarmInfo
            $alarmDef = Get-View -Id $triggered.Alarm
            $lineitem.Name = $esx.Name
            $lineitem.AlarmInfo = $alarmDef.Info.Name
            $Report+=$lineitem
        } 
    }
}
$Report |Sort Name | export-csv $csvName -notypeinformation -useculture
Invoke-item $csvName
