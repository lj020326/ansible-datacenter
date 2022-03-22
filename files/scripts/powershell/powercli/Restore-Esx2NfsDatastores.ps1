
Import-Module PowerCLI/DatastoreMod 

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

Restore-Esx2NfsDatastores
