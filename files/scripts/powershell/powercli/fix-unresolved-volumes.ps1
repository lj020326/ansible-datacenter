
## 
## script will force unmount, and remount of disabled datastores in the vcenter
## 1) it first retrieves disabled/unresolved volumes from vcenter 
## 2) then logs onto the esx host with disabled/unresolved datastore and
## 3) disconnects the datastore and reconnects
##
## see more details at 
## https://communities.vmware.com/message/1838111#1838111 
## 
## The first Connect-VIServer should be to your vCenter, otherwise the Get-VMHost will not return all the hosts in the cluster.
##
## And make sure that the VIServer mode is set to Multiple, that way you can have a connection to the server together with 
## a connection to the ESXi server you're scanning.
## 
## Use the Set-PowerCLIConfiguration cmdlet for setting the mode.
## 

Set-PowerCLIConfiguration -DefaultVIServerMode Multiple

$cluster = "prod-cluster"
$vcenter = "vcenter50.johnson.local"
Connect-VIServer $vcenter

Foreach($esxhost in (Get-VMHost -Location $cluster)){
    Connect-VIServer $esxhost -User $user -Password $password
    $hostView = get-vmhost -name $esxhost | get-view
    $dsView = get-view $hostView.ConfigManager.DatastoreSystem
    $unBound = $dsView.QueryUnresolvedVmfsVolumes()

    foreach ($ub in $UnBound) {
        $extPaths = @()
        $Extents = $ub.Extent;
        foreach ($ex in $Extents) {
        $extPaths = $extPaths + $ex.DevicePath
                                  }      
        $resolutionSpec = New-Object VMware.Vim.HostUnresolvedVmfsResolutionSpec[] (1)
        $resolutionSpec[0] = New-Object VMware.Vim.HostUnresolvedVmfsResolutionSpec
        $resolutionSpec[0].extentDevicePath = New-Object System.String[] (1)
        $resolutionSpec[0].extentDevicePath[0] = $extPaths
        $resolutionSpec[0].uuidResolution = "forceMount"

	    $dsView = Get-View -Id 'HostStorageSystem-storageSystem'
	    $dsView.ResolveMultipleUnresolvedVmfsVolumes($resolutionSpec)
    }
#	Disconnect-VIServer $esxhost -Confirm:$false
}

Set-PowerCLIConfiguration -DefaultVIServerMode Single

