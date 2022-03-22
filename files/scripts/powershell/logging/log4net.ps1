
##
## Init-Log4net - Initialize log4net logger
##
## pass $configSettings hash for external file dependencies: 
## 1) log4netDllPath - path for log4net.dll 
## 2) logConfigFilePath - path for log4net config file 
##
function Configure-Log4net([hashtable] $configSettings) {
	Add-Type -Assembly System.Configuration
	[log4net.ILog] $logger = $null

	$log4netDllPath = $configSettings["log4netDllPath"]
	$logConfigFilePath = $configSettings["logConfigFilePath"]
	if ( -not (test-path $log4netDllPath) ) {
		throw "Log4net library cannot be found on the path $log4netDllPath"
	}
	
	[System.Reflection.Assembly]::LoadFrom($log4netDllPath) | Out-Null

	#Reset
	[log4net.LogManager]::ResetConfiguration()
	$LogManager = [log4net.LogManager]
	if ( (test-path $logConfigFilePath) -eq $false) {
		write-verbose "WARNING: logging config file not found: " +  $logConfigFilePath
	}
	else
	{
		$configFile = new-object System.IO.FileInfo( $logConfigFilePath )
		$xmlConfigurator = [log4net.Config.XmlConfigurator]::ConfigureAndWatch($configFile)
		$logger = $LogManager::GetLogger("PowerShell")
		Write-Verbose "Log4net Logger is configured"
	}
	
	return $logger
}
