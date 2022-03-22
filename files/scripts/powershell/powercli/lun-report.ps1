## When you are running multi-node vSphere clusters, you probably already had the experience that one or more of 
## your LUNs were not visible on all nodes. Now you can try to find out which LUN is missing on which node the 
## hard way through the vSphere client. 
## 
## Or you can use the force of PowerCLI and run this script that will report all this in a handy spreadsheet.
##
## To make the script as flexible as possible it should be able to handle any n-node cluster. 
## And as you some of you might know, the Export-CSV cmdlet has some problems with variable length rows. 
## Luckily there is a handy solution I already used in my yadr – A vDisk reporter post.

param($clusName,$csvName=("C:\data\dettonville\datacenter\" + $clusName + "-LUN.csv"))

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

$rndNum = Get-Random -Maximum 99999

$LunInfoDef = @"
	public string ClusterName;
	public string CanonicalName;
	public string UsedBy;
	public string SizeMB;
"@
$LunInfoDef = "public struct LunInfo" + $rndNum + "{`n" + $LunInfoDef

$esxServers = Get-Cluster $clusName | Get-VMHost | Sort-Object -Property Name
$esxServers | %{
	$LunInfoDef += ("`n`tpublic string " + ($_.Name.Split(".")[0]) + ";")
}
$LunInfoDef += "`n}"

Add-Type -Language CsharpVersion3 -TypeDefinition $LunInfoDef

$scsiTab = @{}
$esxServers | %{
	$esxImpl = $_

	$msg += func_log "Get SCSI LUNs"
	$esxImpl | Get-ScsiLun | where {$_.LunType -eq "Disk"} | %{

		$key = $esxImpl.Name.Split(".")[0] + "-" + $_.CanonicalName.Split(".")[1]
		if(!$scsiTab.ContainsKey($key)){

			$scsiTab[$key] = $_.CanonicalName,"",$_.CapacityMB
		}
	}

	$msg += func_log "Get the VMFS datastores"
	$esxImpl | Get-Datastore | where {$_.Type -eq "VMFS"} | Get-View | %{
		$dsName = $_.Name
		$_.Info.Vmfs.Extent | %{
			$key = $esxImpl.Name.Split(".")[0] + "-" + $_.DiskName.Split(".")[1]
			$scsiTab[$key] = $scsiTab[$key][0], $dsName, $scsiTab[$key][2]
		}
	}
}

$msg += func_log "Get the RDM disks"
Get-Cluster $clusName | Get-VM | Get-View | %{
	$vm = $_
	$vm.Config.Hardware.Device | where {$_.gettype().Name -eq "VirtualDisk"} | %{
		if("physicalMode","virtualmode" -contains $_.Backing.CompatibilityMode){
			$disk = $_.Backing.LunUuid.Substring(10,32)
			$key = (Get-View $vm.Runtime.Host).Name.Split(".")[0] + "-" + $disk
			$scsiTab[$key][1] = $vm.Name + "/" + $_.DeviceInfo.Label
		}
	}
}

$msg += func_log "Getting additional lun info and exporting to csv"
$scsiTab.GetEnumerator() | Group-Object -Property {$_.Key.Split("-")[1]} | %{
	$lun = New-Object ("LunInfo" + $rndNum)
	$lun.ClusterName = $clusName
	$_.Group | %{
		$esxName = $_.Key.Split("-")[0]
		$lun.$esxName = "ok"
		if(!$lun.CanonicalName){$lun.CanonicalName = $_.Value[0]}
		if(!$lun.UsedBy){$lun.UsedBy = $_.Value[1]}
		if(!$lun.SizeMB){$lun.SizeMB = $_.Value[2]}

	}
	$lun
} | Export-Csv $csvName -NoTypeInformation -UseCulture
Invoke-Item $csvName
