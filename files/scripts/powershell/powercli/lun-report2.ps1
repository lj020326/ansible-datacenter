## 
## List Hostname, Lun Name, Lun Policy, and Path State using PowerCLI
##

param($clusName,$csvName=("C:\data\dettonville\datacenter\" + $clusName + "-LUN2.csv"))

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

$msg = func_log "Starting LUN Report"

$vcenter = "vcenter50.johnson.local"
$msg += func_logon $vcenter

$lunpathinfo = @()
foreach ($vmhost in get-cluster $clusName | get-vmhost) {
$hostview= get-view $vmhost.id
$hostview.config.storagedevice.multipathinfo.lun | % { `
    $lunname=$_.id
    $lunpolicy=$_.policy.policy
    $_.path | % {
        $pathstate=$_.pathstate
        $lunpathinfo += "" | select @{name="Hostname"; expression={$vmhost.name}},
                                    @{name="LunName"; expression={$lunname}}, 
                                    @{name="LunPolicy"; expression={$lunpolicy}}, 
                                    @{name="PathState"; expression={$pathstate}}
    }
}
}
$lunpathinfo | export-csv $csvName  
