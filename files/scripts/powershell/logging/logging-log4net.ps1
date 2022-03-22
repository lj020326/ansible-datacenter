##
## This script will write to 2 log files 
## the first log will append all "write-" log messages as specified in the write-log path argument
## the second log will be configured and written to as per the log4net config file
##
## This behavior can be modified to write to just one file by modifying the Write-Log method accordingly
##

Import-Module PowerShellLogging 

function global:Write-Log4net {
    [CmdletBinding()]
    param (
		[ValidateSet('Error', 'Warning', 'Info','Debug')]
		[string] $LogLevel='Info',
        [ValidateNotNull()]
        [string] $Line = '',
        [string] $Prefix
    )

    $Line = $Line.Trim()
    $Prefix = $Prefix.Trim()

    if ($Prefix) { $Prefix = "$Prefix " }
        
    $Now = Get-Date -Format 'G'
    $Line = "$Now - $Prefix$Line"

#    Add-Content -Path $Path -Value $Line

	switch ($LogLevel) { 
		"Error" {$global:logger.Error($Line);}
		"Warning" {$global:logger.Warn($Line);}
		"Info" {$global:logger.Info($Line);}
		"Debug" {$global:logger.Debug($Line);}
        default {"Unknown loglevel: $LogLevel"}
    }	

}

##
## Init-Log4net - Initialize log4net logger
##
## pass $configSettings hash for external file dependencies: 
## 1) log4netDllPath - path for log4net.dll 
## 2) logConfigFilePath - path for log4net config file 
##
function Configure-Log4net([hashtable] $configSettings) {
	Add-Type -Assembly System.Configuration
#	$logger = $null
#	[log4net.ILog] $logger = $null

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
#		$appender = new-object log4net.Appender.ConsoleAppender()
#		$appender = New-Object log4net.Appender.RollingFileAppender()
#		[log4net.Config.BasicConfigurator]::Configure($appender)

		$configFile = new-object System.IO.FileInfo( $logConfigFilePath )
		$xmlConfigurator = [log4net.Config.XmlConfigurator]::ConfigureAndWatch($configFile)
		$logger = $LogManager::GetLogger("PowerShell")
#		$logger = $LogManager::GetLogger($Host.GetType())
#		[log4net.ILog] $logger = $LogManager::GetLogger($Host.GetType()) 
#		$appender.Threshold = [log4net.Core.Level]::Info
		Write-Verbose "Log4net Logger is configured"
	}

#	$Appender = new-object log4net.Appender.ConsoleAppender(`
#    	new-object log4net.Layout.PatternLayout($logpattern))
#	[log4net.Config.BasicConfigurator]::Configure($Appender)

#	# determines the log statements that show up
#	$Appender.Threshold = [log4net.Core.Level]::Info
#	$Log = [log4net.LogManager]::GetLogger($Host.GetType())
	
	return $logger
}

function test-function { 

    Write-Verbose "Testing log"

}

##
## begin script
##
write-output "starting log4net test"

if ((-not (Get-Variable -Name PSScriptRoot -ValueOnly -ErrorAction SilentlyContinue)) -and
    ($scriptBlockFile = $MyInvocation.MyCommand.ScriptBlock.File)) {
     $PSScriptRoot = $MyInvocation.MyCommand.ScriptBlock.File
}

## set the locations for the log4net dll and configuration file used in the Init
$logSettings = @{"log4netDllPath" = "$PSScriptRoot\log4net\log4net.dll" 
				"logConfigFilePath" = "$PSScriptRoot\log4net\logConfig.xml"}

write-output "load and configure log4net"
$global:logger = Configure-Log4net $logSettings

Write-Verbose "Before output subscription"

$logFile = Enable-OutputSubscriber -OnWriteDebug   { Write-Log4net -LogLevel "Debug" -Line $args[0] -Prefix '[D]' } `
                                   -OnWriteError   { Write-Log4net -LogLevel "Error" -Line $args[0] -Prefix '[E]' } `
                                   -OnWriteVerbose { Write-Log4net -LogLevel "Debug" -Line $args[0] -Prefix '[V]' } `
                                   -OnWriteWarning { Write-Log4net -LogLevel "Warning" -Line $args[0] -Prefix '[W]' } `
                                   -OnWriteOutput  { Write-Log4net -LogLevel "Info" -Line $args[0] -Prefix '[O]' }

## set log level at runtime
$global:logger.Logger.level = [log4net.Core.Level]::Error

$global:logger.error("Error After loglevel change to error")
$global:logger.warn("Warn After loglevel change to error")
$global:logger.info("Info After loglevel change to error")
$global:logger.debug("Debug After loglevel change to error")
Write-Warning "Warning After loglevel change to error"
Write-Verbose "Verbose After loglevel change to error"
Write-Output "Output After loglevel change to error"
Write-Debug "Debug After loglevel change to error"

## change log level at runtime
$global:logger.Logger.level = [log4net.Core.Level]::Warn

$global:logger.error("Error After loglevel change to warn")
$global:logger.warn("Warn After loglevel change to warn")
$global:logger.info("Info After loglevel change to warn")
$global:logger.debug("Debug After loglevel change to warn")
Write-Warning "Warning After loglevel change to warn"
Write-Verbose "Verbose After loglevel change to warn"
Write-Output "Output After loglevel change to warn"
Write-Debug "Debug After loglevel change to warn"

## change log level at runtime
$global:logger.Logger.level = [log4net.Core.Level]::Info

$global:logger.error("Error After loglevel change to info")
$global:logger.warn("Warn After loglevel change to info")
$global:logger.info("Info After loglevel change to info")
$global:logger.debug("Debug After loglevel change to info")
Write-Warning "Warning After loglevel change to info"
Write-Verbose "Verbose After loglevel change to info"
Write-Output "Output After loglevel change to info"
Write-Debug "Debug After loglevel change to info"

## change log level at runtime
$global:logger.Logger.level = [log4net.Core.Level]::Debug

$global:logger.error("Error After loglevel change to debug")
$global:logger.warn("Warn After loglevel change to debug")
$global:logger.info("Info After loglevel change to debug")
$global:logger.debug("Debug After loglevel change to debug")
Write-Warning "Warning After loglevel change to debug"
Write-Verbose "Verbose After loglevel change to debug"
Write-Output "Output After loglevel change to debug"
Write-Debug "Debug After loglevel change to debug"

## change log level at runtime
$global:logger.Logger.level = [log4net.Core.Level]::All

$global:logger.error("Error After loglevel change to all")
$global:logger.warn("Warn After loglevel change to all")
$global:logger.info("Info After loglevel change to all")
$global:logger.debug("Debug After loglevel change to all")
Write-Warning "Warning After loglevel change to all"
Write-Verbose "Verbose After loglevel change to all"
Write-Output "Output After loglevel change to all"
Write-Debug "Debug After loglevel change to all"

test-function 

$logFile | Disable-OutputSubscriber 

Write-Output "content of dynamic log4net logging:"
Get-Content $global:logger.Logger.Appenders.File
