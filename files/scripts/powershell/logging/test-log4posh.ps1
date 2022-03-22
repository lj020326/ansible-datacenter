<#
.SYNOPSIS
		This script demonstrates how to use the Log4Posh module.  
		Log4Posh logs messages using log4net framework and redirects all 
		existing write-* messages to the log4net logger.

.DESCRIPTION
		This script demonstrates using log4net framework and redirect all 
		existing write-* streams to the log4net logger.  

		It uses the PowerShellLogging module by David Wyatt in order to subscribe to 
		all write-* streams in order to log to the log4net logger.

		This is useful for retrofitting existing code with the log4net framework. 
		There is minimal impact to existing code-base, since no changes are required to 
		existing write-* streams.  The existing error/warning/verbose/output streams 
		will automatically be directed to the log4net handlers defined in write-log4net. 

		The log4net configuration is configured in the log4net config file

		The behavior can be customized or adjusted by modifying the config file accordingly
		E.g., change color config or existing colorconsoleappender, add/remove appender(s), etc

.OUTPUT
         log file

.PARAMETER 
		none
#>

Import-Module Log4Posh 

##
## begin script
##
write-output "starting log4net test"

write-output "suppress standard powershell verbose/warn/debug output streams"
write-output "will use the log4net output stream from coloredconsoleappender instead"
write-output "the only posh output stream left logging will be write-output"
$WarningPreference = 'SilentlyContinue' 
$VerbosePreference = 'SilentlyContinue' 
$DebugPreference = 'SilentlyContinue' 

if ((-not (Get-Variable -Name PSScriptRoot -ValueOnly -ErrorAction SilentlyContinue)) -and
    ($scriptBlockFile = $MyInvocation.MyCommand.ScriptBlock.File)) {
     $PSScriptRoot = $MyInvocation.MyCommand.ScriptBlock.File
}

### set the locations for the log4net dll and configuration file used in the Init
$logSettings = @{
			loggerName = "root";
			log4netDllPath = "$PSScriptRoot\log4net\log4net.dll"; 
			logConfigFilePath = "$PSScriptRoot\log4net\logConfig.xml"}

write-output "enable Log4Posh"
$global:logger = Enable-Log4Posh @logSettings

$logFileName = $global:logger.Logger.Appenders.File

## change log level to all at runtime
$global:logger.Logger.level = [log4net.Core.Level]::All
write-output "testing log4net writes with log level set to all"
Test-LogSomething

## set log level to error at runtime
$global:logger.Logger.level = [log4net.Core.Level]::Error
write-output "testing log4net writes with log level set to error"
Test-LogSomething

## change log level to warn at runtime
$global:logger.Logger.level = [log4net.Core.Level]::Warn
write-output "testing log4net writes with log level set to warn"
Test-LogSomething

## change log level to info at runtime
$global:logger.Logger.level = [log4net.Core.Level]::Info
write-output "testing log4net writes with log level set to info"
Test-LogSomething

## change log level to debug at runtime
$global:logger.Logger.level = [log4net.Core.Level]::Debug
write-output "testing log4net writes with log level set to debug"
Test-LogSomething

## change log level to debug at runtime
$global:logger.Logger.level = [log4net.Core.Level]::Trace
write-output "testing log4net writes with log level set to trace"
Test-LogSomething

Disable-Log4Posh 

Write-Output "content of dynamic Log4Posh logging in ($logFileName):"
Get-Content $logFileName
