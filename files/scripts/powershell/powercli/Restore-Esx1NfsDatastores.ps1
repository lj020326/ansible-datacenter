
Import-Module PowerCLI/DatastoreMod 

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

$vmhost = "esx1.johnson.local"
Restore-EsxNfsDatastores $vmhost
