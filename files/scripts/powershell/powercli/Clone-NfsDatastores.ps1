
Function Clone-NfsDatastores {
	<#
	.SYNOPSIS
	Clones an existing ESXi NFS Server layout to a new ESXi server:

	.EXAMPLE
	PS C:\> Clone-NfsDatastores

	.EXAMPLE
	PS C:\> Clone-NfsDatastores $original_esxhost_name $copy_esxhost_name
	#>
	Param ( 
		[string] 
		## name of existing server
		$REFHost, 
		## name of server to copy to 
		[string] $NEWHost) 

	#$VISRV = Connect-VIServer (Read-Host "Enter the name of your VI SERVER")
	#$REFHost = Get-VMHost -Name (Read-Host " Enter name of existing server")
	#$NEWHost = Get-VMHost -Name (Read-Host " Enter name of server copy to ")

	foreach($nfs in (Get-VMhost $REFHost | Get-Datastore | Where {$_.type -eq "NFS"})){
	    $share = ($nfs | get-view).summary.url
	    $share = $share.Replace("//","/")
	    $share = $share.TrimStart("netfs:/")
	    if($share -match "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"){
	        $ip = $matches[0]
	    }
	    $remotePath = $share.Trim("$ip")
	    $remoteHost = $ip
	    $shareName = $nfs
		Write-Output "Datastore $dsName [sharename = $sharename; remoteHost = ($remoteHost); remotePath = ($remotePath)]"

		exit
	    $NEWHost | Get-Datastore | Where{$_.Name -eq $shareName -and $_.type -eq "NFS"} -ErrorAction SilentlyContinue
	    If (($NEWHost | Get-Datastore | Where{$_.Name -eq $shareName -and $_.type -eq "NFS"} -ErrorAction SilentlyContinue )-eq $null){
	        Write-Host "Mounting NFS datastore $($Sharename)" -fore Yellow
	        New-Datastore -Nfs -VMHost $NEWHost -Name $Sharename -Path $remotePath -NfsHost $remoteHost | Out-Null
	    }
	}
}
