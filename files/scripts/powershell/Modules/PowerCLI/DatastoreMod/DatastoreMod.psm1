
Function Get-DatastoreMountInfo2 {
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline=$true)]
		$Datastore
	)
	Process {
		$AllInfo = @()
		if (-not $Datastore) {
			$Datastore = Get-Datastore
		}
		Foreach ($ds in $Datastore) {  
			$hostviewDSDiskName = $null
			if ($ds.ExtensionData.Info.vmfs.extent) {
				$hostviewDSDiskName = $ds.ExtensionData.Info.vmfs.extent[0].Diskname
			}
			if ($ds.ExtensionData.Host) {
				$attachedHosts = $ds.ExtensionData.Host
				Foreach ($VMHost in $attachedHosts) {
					Write-Verbose "VMHost = $VMHost"
					$hostview = Get-View $VMHost.Key
					$hostviewDSState = $VMHost.MountInfo.Mounted
					Write-Verbose "hostviewDSState = $hostviewDSState"
					$StorageSys = Get-View $HostView.ConfigManager.StorageSystem
					$devices = $StorageSys.StorageDeviceInfo.ScsiLun
					Foreach ($device in $devices) {
						Write-Verbose "device = $device"
						$Info = "" | Select Datastore, VMHost, Lun, CanonicalName, Mounted, State
						Write-Verbose "info = $info"
						Write-Verbose "device.canonicalName = $($device.canonicalName)"
						Write-Verbose "hostviewDSDiskName = $hostviewDSDiskName"
						$hostviewDSAttachState = ""
						if ($device.canonicalName -eq $hostviewDSDiskName) {
							if ($device.operationalState[0] -eq "ok") {
								$hostviewDSAttachState = "Attached"							
							} elseif ($device.operationalState[0] -eq "off") {
								$hostviewDSAttachState = "Detached"							
							} else {
								$hostviewDSAttachState = $device.operationalstate[0]
							}
						}
						Write-Verbose "hostviewDSAttachState = $hostviewDSAttachState "
						$Info.Datastore = $ds.Name
						$Info.Lun = $hostviewDSDiskName
						$Info.CanonicalName = $device.canonicalName
						$Info.VMHost = $hostview.Name
						$Info.Mounted = $HostViewDSState
						$Info.State = $hostviewDSAttachState
						Write-Verbose "Info = $Info"
						$AllInfo += $Info
					}
					
				}
			}
		}
		$AllInfo
	}
}

Function Get-DatastoreMountInfo {
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline=$true)]
		$Datastore
	)
	Process {
		$AllInfo = @()
		if (-not $Datastore) {
			$Datastore = Get-Datastore
		}
		Foreach ($ds in $Datastore) {  
			if ($ds.ExtensionData.info.Vmfs) {
				$hostviewDSDiskName = $ds.ExtensionData.Info.vmfs.extent[0].diskname
				if ($ds.ExtensionData.Host) {
					$attachedHosts = $ds.ExtensionData.Host
					Foreach ($VMHost in $attachedHosts) {
						$hostview = Get-View $VMHost.Key
						$hostviewDSState = $VMHost.MountInfo.Mounted
						$StorageSys = Get-View $HostView.ConfigManager.StorageSystem
						$devices = $StorageSys.StorageDeviceInfo.ScsiLun
						Foreach ($device in $devices) {
							$Info = "" | Select Datastore, VMHost, Lun, Mounted, State
							if ($device.canonicalName -eq $hostviewDSDiskName) {
								$hostviewDSAttachState = ""
								if ($device.operationalState[0] -eq "ok") {
									$hostviewDSAttachState = "Attached"							
								} elseif ($device.operationalState[0] -eq "off") {
									$hostviewDSAttachState = "Detached"							
								} else {
									$hostviewDSAttachState = $device.operationalstate[0]
								}
								$Info.Datastore = $ds.Name
								$Info.Lun = $hostviewDSDiskName
								$Info.VMHost = $hostview.Name
								$Info.Mounted = $HostViewDSState
								$Info.State = $hostviewDSAttachState
								$AllInfo += $Info
							}
						}
						
					}
				}
			}
		}
		$AllInfo
	}
}



Function Detach-Datastore {
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline=$true)]
		$Datastore
	)
	Process {
		if (-not $Datastore) {
			Write-Host "No Datastore defined as input"
			Exit
		}
		Foreach ($ds in $Datastore) {
			$hostviewDSDiskName = $ds.ExtensionData.Info.vmfs.extent[0].Diskname
			if ($ds.ExtensionData.Host) {
				$attachedHosts = $ds.ExtensionData.Host
				Foreach ($VMHost in $attachedHosts) {
					$hostview = Get-View $VMHost.Key
					$StorageSys = Get-View $HostView.ConfigManager.StorageSystem
					$devices = $StorageSys.StorageDeviceInfo.ScsiLun
					Foreach ($device in $devices) {
						if ($device.canonicalName -eq $hostviewDSDiskName) {
							$LunUUID = $Device.Uuid
							Write-Host "Detaching LUN $($Device.CanonicalName) from host $($hostview.Name)..."
							$StorageSys.DetachScsiLun($LunUUID);
						}
					}
				}
			}
		}
	}
}


Function Unmount-Datastore {
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline=$true)]
		$Datastore
	)
	Process {
		if (-not $Datastore) {
			Write-Host "No Datastore defined as input"
			Exit
		}
		Foreach ($ds in $Datastore) {
			$hostviewDSDiskName = $null
			if ($ds.ExtensionData.Info.vmfs.extent) {
				$hostviewDSDiskName = $ds.ExtensionData.Info.vmfs.extent[0].Diskname
			}
			if ($ds.ExtensionData.Host) {
				$attachedHosts = $ds.ExtensionData.Host
				Foreach ($VMHost in $attachedHosts) {
					$hostview = Get-View $VMHost.Key
					$StorageSys = Get-View $HostView.ConfigManager.StorageSystem
					Write-Host "Unmounting VMFS Datastore $($DS.Name) from host $($hostview.Name)..."
					$StorageSys.UnmountVmfsVolume($DS.ExtensionData.Info.vmfs.uuid);
				}
			}
		}
	}
}

Function Mount-Datastore {
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline=$true)]
		$Datastore
	)
	Process {
		if (-not $Datastore) {
			Write-Host "No Datastore defined as input"
			Exit
		}
		Foreach ($ds in $Datastore) {
			$hostviewDSDiskName = $ds.ExtensionData.Info.vmfs.extent[0].Diskname
			if ($ds.ExtensionData.Host) {
				$attachedHosts = $ds.ExtensionData.Host
				Foreach ($VMHost in $attachedHosts) {
					$hostview = Get-View $VMHost.Key
					$StorageSys = Get-View $HostView.ConfigManager.StorageSystem
					Write-Host "Mounting VMFS Datastore $($DS.Name) on host $($hostview.Name)..."
					$StorageSys.MountVmfsVolume($DS.ExtensionData.Info.vmfs.uuid);
				}
			}
		}
	}
}

Function Attach-Datastore {
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline=$true)]
		$Datastore
	)
	Process {
		if (-not $Datastore) {
			Write-Host "No Datastore defined as input"
			Exit
		}
		Foreach ($ds in $Datastore) {
			$hostviewDSDiskName = $ds.ExtensionData.Info.vmfs.extent[0].Diskname
			if ($ds.ExtensionData.Host) {
				$attachedHosts = $ds.ExtensionData.Host
				Foreach ($VMHost in $attachedHosts) {
					$hostview = Get-View $VMHost.Key
					$StorageSys = Get-View $HostView.ConfigManager.StorageSystem
					$devices = $StorageSys.StorageDeviceInfo.ScsiLun
					Foreach ($device in $devices) {
						if ($device.canonicalName -eq $hostviewDSDiskName) {
							$LunUUID = $Device.Uuid
							Write-Host "Attaching LUN $($Device.CanonicalName) to host $($hostview.Name)..."
							$StorageSys.AttachScsiLun($LunUUID);
						}
					}
				}
			}
		}
	}
}

#
function Activate-InactiveNFSDatastores {
	<#
	.SYNOPSIS
	      This function determines which nfs datastores are inactive on which host 
		  and then iterates through each host to remove each datastore
		  usually upon removing on the host, vcenter will automatically update 
		  the inactive datastore back to active.
		  if not, the function will add the nfs datastore back
	#>
	Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Confirm:$false | Out-Null

	$datastores = Get-Datastore | Where {$_.Type -eq "NFS"} 
	$inactiveDatastores = $datastores | Get-DatastoreMountInfo2 | Where-Object {$_.mounted -eq $false} | sort-object -property vmhost, datastore -unique 
	$hostList = $inactiveDatastores | sort-object -property vmhost -unique 
	Foreach ($item in $hostList) {
		$esxhost = $item.vmhost
		Write-Output "connecting to $esxhost"
		Connect-VIServer $esxhost
		$dsList = $inactiveDatastores | Where-Object {$_.vmhost -eq $esxhost} 
		Foreach ($inactive in $dsList) {
			## go directly to the host to forceably unmount
			$dsName = $inactive.Datastore

			$nfs = Get-Datastore $dsName 
			$nfs = $nfs | sort-object -property name -unique 
			
	        [string]$shareName = $nfs.Name
			Write-Output "found NFS share $sharename"

			Write-Output "$sharename is inactive"
	        [string]$remoteHost = $nfs.extensiondata.info.nas.remotehost
	        [string]$remotePath = $nfs.extensiondata.info.nas.remotepath
			$Info = "" | Select ShareName, RemoteHost, RemotePath
			Write-Output "[sharename = $sharename; remoteHost = ($remoteHost); remotePath = ($remotePath)]"

			$Info.ShareName = $shareName
			$Info.remoteHost = $remoteHost 
			$Info.remotePath = $remotePath 
			Write-Output "Nfs Share Info = $Info"
#			$AllInfo += $Info

			Write-Output "Removing inactive datastore $dsName on $esxhost"
			Remove-Datastore -Server $esxhost -Datastore $dsName -VMHost $esxhost -Confirm:$false 

			Write-Output "Checking for datastore $dsName on $esxhost"
			$dsList = Get-VMHost $esxhost | Get-Datastore $shareName | Where {$_.type -eq "NFS"} -ErrorAction SilentlyContinue
			$dsList
			write-output "$dsList.count=$($dsList.count)"
			If ($dsList -eq $null) {
		        Write-Host "NFS mount $shareName doesn't exist on $($esxhost)" -fore Red
				Write-Output "Adding new datastore $dsName on $esxhost [sharename = $sharename; remoteHost = ($remoteHost); remotePath = ($remotePath)]"
		        New-Datastore -Nfs -VMHost $esxhost -Name $sharename -Path $remotePath -NfsHost $remoteHost | Out-Null
		    } else {
		        Write-Host "NFS mount $shareName already exists on $($esxhost), skipping to next share" -fore Red
			}			
		}
		Write-Output "disconnecting from $esxhost"
		Disconnect-VIServer $esxhost -Confirm:$false
	}
	Write-Output "DONE"
	
}

#
function Activate-InactiveHostNFSDatastoresOld {
	<#
	.SYNOPSIS
	      This function determines which nfs datastores are inactive on which host 
		  and then iterates through each host to remove each datastore
		  usually upon removing on the host, vcenter will automatically update 
		  the inactive datastore back to active.
		  if not, the function will add the nfs datastore back
	#>

#	Connect-VIServer $esxhost
	$datastores = Get-Datastore | Where {$_.Type -eq "NFS"} 
	$inactiveDatastores = $datastores | Get-DatastoreMountInfo2 | Where-Object {$_.mounted -eq $false} | sort-object -property vmhost, datastore -unique 
	
	Foreach ($inactive in $inactiveDatastores ) {
		## go directly to the host to forceably unmount
		$dsName = $inactive.Datastore

		$nfs = Get-Datastore $dsName 
		$nfs = $nfs | sort-object -property name -unique 
		
        [string]$shareName = $nfs.Name
		Write-Output "found NFS share $sharename"

		Write-Output "$sharename is inactive"
        [string]$remoteHost = $nfs.extensiondata.info.nas.remotehost
        [string]$remotePath = $nfs.extensiondata.info.nas.remotepath
		$Info = "" | Select ShareName, RemoteHost, RemotePath
		Write-Output "[sharename = $sharename; remoteHost = ($remoteHost); remotePath = ($remotePath)]"

		$Info.ShareName = $shareName
		$Info.remoteHost = $remoteHost 
		$Info.remotePath = $remotePath 
		Write-Output "Nfs Share Info = $Info"
#			$AllInfo += $Info

		Write-Output "Removing inactive datastore $dsName on $esxhost"
		Remove-Datastore -Server $esxhost -Datastore $dsName -VMHost $esxhost -Confirm:$false 

		Write-Output "Checking for datastore $dsName on $esxhost"
		$dsList = Get-VMHost $esxhost | Get-Datastore $shareName | Where {$_.type -eq "NFS"} -ErrorAction SilentlyContinue
		$dsList
		write-output "$dsList.count=$($dsList.count)"
		If ($dsList -eq $null) {
	        Write-Host "NFS mount $shareName doesn't exist on $($esxhost)" -fore Red
			Write-Output "Adding new datastore $dsName on $esxhost [sharename = $sharename; remoteHost = ($remoteHost); remotePath = ($remotePath)]"
	        New-Datastore -Nfs -VMHost $esxhost -Name $sharename -Path $remotePath -NfsHost $remoteHost | Out-Null
	    } else {
	        Write-Host "NFS mount $shareName already exists on $($esxhost), skipping to next share" -fore Red
		}			
	}
	Write-Output "disconnecting from $esxhost"
#	Disconnect-VIServer $esxhost -Confirm:$false

	Write-Output "DONE"
	
}

#
function Activate-InactiveNFSDatastores {
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline=$true)]
		$vcenter
	)
	Process {
		<#
		.SYNOPSIS
		      This function determines which nfs datastores are inactive on which host 
			  and then iterates through each host to remove each datastore
			  usually upon removing on the host, vcenter will automatically update 
			  the inactive datastore back to active.
			  if not, the function will add the nfs datastore back
		#>

		Connect-VIServer $vcenter
		$hostList = Get-VMHost
		Foreach ($host in $hostList) {
			Activate-InactiveHostNFSDatastores $host
		}
		Write-Output "disconnecting from $vcenter"
		Disconnect-VIServer $vcenter -Confirm:$false
		Write-Output "DONE"	
	}
}

#
function Activate-InactiveHostNFSDatastores {
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline=$true)]
		$esxhost
	)
	Process {
		<#
		.SYNOPSIS
		      This function determines which nfs datastores are inactive on which host 
			  and then iterates through each host to remove each datastore
			  usually upon removing on the host, vcenter will automatically update 
			  the inactive datastore back to active.
			  if not, the function will add the nfs datastore back
		#>

		Connect-VIServer $esxhost
		$datastores = Get-Datastore | Where {$_.Type -eq "NFS"} 
		$inactiveDatastores = $datastores | Where {$_.extensiondata.host.mountinfo.mounted -eq $false} 
	#	$inactiveDatastores = $datastores | Where {$_.extensiondata.host.mountinfo.accessible -eq $false} 
		
		Foreach ($nfs in $inactiveDatastores ) {
			## go directly to the host to forceably unmount
	        [string]$shareName = $nfs.Name
			Write-Output "found NFS share $sharename"

			Write-Output "$sharename is inactive"
	        [string]$remoteHost = $nfs.extensiondata.info.nas.remotehost
	        [string]$remotePath = $nfs.extensiondata.info.nas.remotepath
			Write-Output "[sharename = $sharename; remoteHost = ($remoteHost); remotePath = ($remotePath)]"
			Write-Output "Removing inactive datastore $shareName on $esxhost"
			Remove-Datastore -Server $esxhost -Datastore $shareName -VMHost $esxhost -Confirm:$false 

			Write-Output "Checking for datastore $shareName on $esxhost"
			$dsList = Get-VMHost $esxhost | Get-Datastore $shareName | Where {$_.type -eq "NFS"} -ErrorAction SilentlyContinue 
			Write-Verbose "$dsList.count=$($dsList.count)"
			If ($dsList -eq $null) {
		        Write-Host "NFS mount $shareName doesn't exist on $($esxhost)" -fore Red
				Write-Output "Adding new datastore $shareName on $esxhost [sharename = $sharename; remoteHost = ($remoteHost); remotePath = ($remotePath)]"
		        New-Datastore -Nfs -VMHost $esxhost -Name $sharename -Path $remotePath -NfsHost $remoteHost | Out-Null
		    } else {
		        Write-Host "NFS mount $shareName already exists on $($esxhost), skipping to next share" -fore Red
			}
		}
		Write-Output "disconnecting from $esxhost"
		Disconnect-VIServer $esxhost -Confirm:$false
		Write-Output "DONE"	
	}
}

#$vcenter = "vcenter50.johnson.local"
#Activate-InactiveNFSDatastores $vcenter
#
#Connect-VIServer $vcenter
#Activate-InactiveNFSDatastores $vcenter
#Disconnect-VIServer $vcenter -Confirm:$false
#
#Get-DatastoreMountInfo2 
#Get-Datastore | Get-DatastoreMountInfo | Sort Datastore, VMHost | FT -AutoSize
#
#Get-Datastore IX2ISCSI01 | Unmount-Datastore
#
#Get-Datastore IX2ISCSI01 | Get-DatastoreMountInfo | Sort Datastore, VMHost | FT -AutoSize
#
#Get-Datastore IX2iSCSI01 | Mount-Datastore
#
#Get-Datastore IX2iSCSI01 | Get-DatastoreMountInfo | Sort Datastore, VMHost | FT -AutoSize
#
#Get-Datastore IX2iSCSI01 | Detach-Datastore
#
#Get-Datastore IX2iSCSI01 | Get-DatastoreMountInfo | Sort Datastore, VMHost | FT -AutoSize
#
#Get-Datastore IX2iSCSI01 | Attach-datastore
#
#Get-Datastore IX2iSCSI01 | Get-DatastoreMountInfo | Sort Datastore, VMHost | FT -AutoSize
#