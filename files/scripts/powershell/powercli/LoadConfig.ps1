
##
## Script for Creating and Using a Configuration File for Your PowerShell Scripts
##
## sourced from and see more info at:
## https://rkeithhill.wordpress.com/2006/06/01/creating-and-using-a-configuration-file-for-your-powershell-scripts/
##
## at the top of your scripts you can execute:
## .\LoadConfig scriptname.config
## 
## and then access settings like so:
## 
## $appSettings["MaxScanDetailRows"]
## 500
## 

param($path = $(throw "You must specify a config file"))
$global:appSettings = @{}
$config = [xml](get-content $path)
foreach ($addNode in $config.configuration.appsettings.add) {
	if ($addNode.Value.Contains(‘,’)) {
		# Array case
		$value = $addNode.Value.Split(‘,’)

		for ($i = 0; $i -lt $value.length; $i++) {
			$value[$i] = $value[$i].Trim()
		}
	}
	else {
		# Scalar case
		$value = $addNode.Value
	}
	$global:appSettings[$addNode.Key] = $value
}
