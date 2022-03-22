<#
.SYNOPSIS
		This script demonstrates how to ue PowerShellLogging module by David Wyatt 
		in order to log message using log4net framework and handle the filtered logging 
		of all existing write-* messages to log file.

		This is highly useful for retrofitting existing code with the log4net framework. 
		There is minimal impact to existing code-base, since no changes are required to 
		existing write-* streams.  The existing error/warning/verbose/output streams 
		will automatically be directed to the log4net handlers defined in write-log4net. 

		The log4net configuration is configured in the log4net config file

		The behavior can be customized or adjusted by modifying the config file accordingly
		E.g., change color config or existing colorconsoleappender, add/remove appender(s), etc

.OUTPUTS (with a S at the end....)
         log file

.PARAMETER 
		none
#>

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
        
    $Line = "$Prefix$Line"

	switch ($LogLevel) { 
		"Error" {$global:logger.Error($Line);}
		"Warning" {$global:logger.Warn($Line);}
		"Info" {$global:logger.Info($Line);}
		"Debug" {$global:logger.Debug($Line);}
        default {throw "Unknown loglevel: $LogLevel for message $Line"}
    }	
}

<#
.SYNOPSIS
        Configure-Log4net - Initialize log4net logger
.OUTPUTS 
        output is a log4net logger [log4net.ILog]
.PARAMETER 
		a single hash with the following two dependencies 
			log4netDllPath - path location for log4net.dll 
			logConfigFilePath - path location for log4net config file 
#>
function Configure-Log4net([hashtable] $configSettings) {
	Add-Type -Assembly System.Configuration

	$log4netDllPath = $configSettings["log4netDllPath"]
	$logConfigFilePath = $configSettings["logConfigFilePath"]
	if ( -not (test-path $log4netDllPath) ) {
		throw "Log4net library cannot be found on the path $log4netDllPath"
	}
	
	[System.Reflection.Assembly]::LoadFrom($log4netDllPath) | Out-Null
	[log4net.ILog] $logger = $null

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
		$logger = $LogManager::GetLogger("root")
		Write-Verbose "Log4net Logger is configured"
	}
	
	return $logger
}

function test-function { 

	write-output "test-function - log4net writes "
	$global:logger.error("log.error: test-function")
	$global:logger.warn("log.warn: test-function")
	$global:logger.info("log.info: test-function")
	$global:logger.debug("log.debug: test-function")
	Write-Warning "Warning test-function"
	Write-Verbose "Verbose test-function"
	Write-Output "Output test-function"
	Write-Debug "Debug test-function"

}

##
## begin script
##
write-output "starting log4net test"

write-output "first suppress standard powershell verbose/warn/debug output streams"
write-output "instead will use the log4net output stream from coloredconsoleappender"
write-output "the only posh output stream left logging will be write-output"
$WarningPreference = 'SilentlyContinue' 
$VerbosePreference = 'SilentlyContinue' 
$DebugPreference = 'SilentlyContinue' 

if ((-not (Get-Variable -Name PSScriptRoot -ValueOnly -ErrorAction SilentlyContinue)) -and
    ($scriptBlockFile = $MyInvocation.MyCommand.ScriptBlock.File)) {
     $PSScriptRoot = $MyInvocation.MyCommand.ScriptBlock.File
}

## set the locations for the log4net dll and configuration file used in the Init
$logSettings = @{"log4netDllPath" = "$PSScriptRoot\log4net\log4net.dll" 
				"logConfigFilePath" = "$PSScriptRoot\log4net\logConfig.xml"}

write-output "load and configure log4net"
$global:logger = Configure-Log4net $logSettings

$logFile = Enable-OutputSubscriber -OnWriteDebug   { Write-Log4net -LogLevel "Debug" -Line $args[0] -Prefix '[D]' } `
                                   -OnWriteError   { Write-Log4net -LogLevel "Error" -Line $args[0] -Prefix '[E]' } `
                                   -OnWriteVerbose { Write-Log4net -LogLevel "Debug" -Line $args[0] -Prefix '[V]' } `
                                   -OnWriteWarning { Write-Log4net -LogLevel "Warning" -Line $args[0] -Prefix '[W]' } `
                                   -OnWriteOutput  { Write-Log4net -LogLevel "Info" -Line $args[0] -Prefix '[O]' }


## set log level at runtime
$global:logger.Logger.level = [log4net.Core.Level]::Error

write-output "testing log4net writes with log level set to error"
$global:logger.error("log.error: Error After loglevel change to error")
$global:logger.warn("log.warn: Warn After loglevel change to error")
$global:logger.info("log.info: Info After loglevel change to error")
$global:logger.debug("log.debug: Debug After loglevel change to error")
Write-Warning "Warning After loglevel change to error"
Write-Verbose "Verbose After loglevel change to error"
Write-Output "Output After loglevel change to error"
Write-Debug "Debug After loglevel change to error"

## change log level at runtime
$global:logger.Logger.level = [log4net.Core.Level]::Warn

write-output "testing log4net writes with log level set to warn"
$global:logger.error("log.error: Error After loglevel change to warn")
$global:logger.warn("log.warn: Warn After loglevel change to warn")
$global:logger.info("log.info: Info After loglevel change to warn")
$global:logger.debug("log.debug: Debug After loglevel change to warn")
Write-Warning "Warning After loglevel change to warn"
Write-Verbose "Verbose After loglevel change to warn"
Write-Output "Output After loglevel change to warn"
Write-Debug "Debug After loglevel change to warn"

## change log level at runtime
$global:logger.Logger.level = [log4net.Core.Level]::Info

write-output "testing log4net writes with log level set to info"
$global:logger.error("log.error: Error After loglevel change to info")
$global:logger.warn("log.warn: Warn After loglevel change to info")
$global:logger.info("log.info: Info After loglevel change to info")
$global:logger.debug("log.debug: Debug After loglevel change to info")
Write-Warning "Warning After loglevel change to info"
Write-Verbose "Verbose After loglevel change to info"
Write-Output "Output After loglevel change to info"
Write-Debug "Debug After loglevel change to info"

## change log level at runtime
$global:logger.Logger.level = [log4net.Core.Level]::Debug

write-output "testing log4net writes with log level set to debug"
$global:logger.error("log.error: Error After loglevel change to debug")
$global:logger.warn("log.warn: Warn After loglevel change to debug")
$global:logger.info("log.info: Info After loglevel change to debug")
$global:logger.debug("log.debug: Debug After loglevel change to debug")
Write-Warning "Warning After loglevel change to debug"
Write-Verbose "Verbose After loglevel change to debug"
Write-Output "Output After loglevel change to debug"
Write-Debug "Debug After loglevel change to debug"

## change log level at runtime
$global:logger.Logger.level = [log4net.Core.Level]::All

write-output "testing log4net writes with log level set to all"
$global:logger.error("log.error: Error After loglevel change to all")
$global:logger.warn("log.warn: Warn After loglevel change to all")
$global:logger.info("log.info: Info After loglevel change to all")
$global:logger.debug("log.debug: Debug After loglevel change to all")
Write-Warning "Warning After loglevel change to all"
Write-Verbose "Verbose After loglevel change to all"
Write-Output "Output After loglevel change to all"
Write-Debug "Debug After loglevel change to all"

test-function 

$logFile | Disable-OutputSubscriber 

Write-Output "content of dynamic log4net logging:"
Get-Content $global:logger.Logger.Appenders.File
