
Import-Module PowerCLI/DatastoreMod 

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

Restore-NfsDatastores
