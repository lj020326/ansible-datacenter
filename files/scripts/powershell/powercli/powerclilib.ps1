

## restorenfs on efx machines - call upon reboot
function restorenfs(){
	Init-PowerCLI
	Restore-Esx2NfsDatastores
#	Restore-Esx1NfsDatastores
}

Function Init-PowerCLI {

	## Adds the base cmdlets
	Add-PSSnapin VMware.VimAutomation.Core

	## Add the following if you want to do things with Update Manager
	#Add-PSSnapin VMware.VumAutomation

	# This script adds some helper functions and sets the appearance. You can pick and choose parts of this file for a fully custom appearance.
	#. "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-VIToolkitEnvironment.ps1"
	. "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
	Import-Module PowerCLI/DatastoreMod 
}

Function Restore-Esx2NfsDatastores {
	<#
	.SYNOPSIS
	Restores inactive NFS datastores on for each ESX host on vcenter:

	.EXAMPLE
	PS C:\> Restore-NfsDatastores

	#>
	
	$vmhost = "esx2.johnson.local"
	Activate-InactiveHostNFSDatastores $vmhost
}


Function Restore-EsxNfsDatastores {
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline=$true)]
		$vmhost
	)
	Process {
		<#
		.SYNOPSIS
		Restores inactive NFS datastores on for each ESX host on vcenter:

		.EXAMPLE
		PS C:\> Restore-NfsDatastores

		#>
		
		Activate-InactiveHostNFSDatastores $vmhost
	}
}

Function Restore-NfsDatastores {
	<#
	.SYNOPSIS
	Restores inactive NFS datastores on for each ESX host on vcenter:

	.EXAMPLE
	PS C:\> Restore-NfsDatastores

	#>
	
	$vcenter = "vcenter50.johnson.local"
	Activate-InactiveNFSDatastores $vcenter
}
