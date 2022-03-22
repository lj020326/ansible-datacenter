<#
.SYNOPSIS
	This module implements the log4net framework and logs all existing write-* messages to log file.
	This script uses PowerShellLogging module by David Wyatt. 

	This can be used to retrofit existing code with the log4net framework. 
	There is minimal impact to existing code-base, since no changes are required to 
	existing write-* output streams.  The existing error/warning/verbose/output streams 
	will automatically be directed to the log4net handlers defined in write-log4net. 

	The log4net configuration is enabled in the log4net config file

	The behavior can be customized or adjusted by modifying the config file accordingly
	E.g., change color config or existing colorconsoleappender, add/remove appender(s), etc

.OUTPUTS 
	log file

#>

Import-Module PowerShellLogging 

function Write-Log4net {
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
## todo: use dll extensions in posh to extend log4net to implement trace/verbose
#		"Trace" {$global:logger.Trace($Line);}  
#		"Verbose" {$global:logger.Verbose($Line);}  
        default {throw "Unknown loglevel: $LogLevel for message $Line"}
    }	
}

function Enable-Log4Posh 
{
	<#
	.SYNOPSIS
	      This function creates a log4net logger instance already configured
	.OUTPUTS
	      The log4net logger instance ready to be used
	#>
	[CmdletBinding()]
	Param
	(
		[string]
		# Name of the log4net logger matching the logger name in the configuration file
		$loggerName='root',
		[string]
		# Path of the configuration file of log4net
		$logConfigFilePath,
		[Alias("Dll")]
		[string]
		# Path of Log4net dll 
		$log4netDllPath,
        [Parameter(ValueFromRemainingArguments = $true)]
        $remainingArgs
	)
	Add-Type -Assembly System.Configuration

	$log4netDllPath = Resolve-Path $log4netDllPath -ErrorAction SilentlyContinue -ErrorVariable Err
	if ($Err)
	{
		throw "Log4net library cannot be found on the path $log4netDllPath"
	}

	Write-Verbose "[New-Logger] Log4net dll path is : '$log4netDllPath'"
	[Reflection.Assembly]::LoadFrom($log4netDllPath) | Out-Null

	#Reset
	[log4net.LogManager]::ResetConfiguration()
	$LogManager = [log4net.LogManager]

	$logConfigFilePath = Resolve-Path $logConfigFilePath -ErrorAction SilentlyContinue -ErrorVariable Err
	if ($Err)
	{
		throw "Log4net config file not found: " +  $logConfigFilePath
	}

	$configFile = new-object System.IO.FileInfo( $logConfigFilePath )
	$xmlConfigurator = [log4net.Config.XmlConfigurator]::ConfigureAndWatch($configFile)
	$logger = $LogManager::GetLogger($loggerName)
	Write-Verbose "Log4net Logger is enabled"

	$global:logSubscriber = Enable-OutputSubscriber `
									-OnWriteError   { Write-Log4net -LogLevel "Error" -Line $args[0] -Prefix '[E]' } `
									-OnWriteWarning { Write-Log4net -LogLevel "Warning" -Line $args[0] -Prefix '[W]' } `
									-OnWriteOutput  { Write-Log4net -LogLevel "Info" -Line $args[0] -Prefix '[O]' } `
									-OnWriteDebug   { Write-Log4net -LogLevel "Debug" -Line $args[0] -Prefix '[D]' } `
									-OnWriteVerbose { Write-Log4net -LogLevel "Debug" -Line $args[0] -Prefix '[V]' } 
	
	return $logger
}

function Disable-Log4Posh {
	<#
	.SYNOPSIS
	      Disable logging before the script exits 
	#>
	$global:logSubscriber | Disable-OutputSubscriber 
}

function Test-LogSomething {
	<#
	.SYNOPSIS
	      Logs diagnostic test messages at multiple levels below specified test level 
		  in order to test that Logger Logging Level is working correctly.
	#>
	[CmdletBinding()]
	Param(
		[log4net.Core.Level] 
		# The level at or below which the test messages should be logged
		## 
		## Order of log4net log levels
		##
		## $global:logger.Logger.Repository.LevelMap.AllLevels | sort -property value | select value, name | ft -auto
		##      Value Name
		##      ----- ----
		##-2147483648 ALL
		##      10000 VERBOSE
		##      10000 FINEST
		##      20000 TRACE
		##      20000 FINER
		##      30000 DEBUG
		##      30000 FINE
		##      40000 INFO
		##      50000 NOTICE
		##      60000 WARN
		##      70000 ERROR
		##      80000 SEVERE
		##      90000 CRITICAL
		##     100000 ALERT
		##     110000 FATAL
		##     120000 EMERGENCY
		## 2147483647 OFF
		##
		$logTestLevel = [log4net.Core.Level]::WARN 
	)
	
	$functionName = $MyInvocation.MyCommand	

	$logTestLevelVal = $global:logger.Logger.Repository.LevelMap[$logTestLevel].value

	if ($global:logger.Logger.Repository.LevelMap["ERROR"].value -le $logTestLevelVal) { $global:logger.error("in $functionName - log.error: Error ") }
	if ($global:logger.Logger.Repository.LevelMap["WARN"].value -le $logTestLevelVal) { $global:logger.warn("in $functionName - log.warn: Warning") }
	if ($global:logger.Logger.Repository.LevelMap["INFO"].value -le $logTestLevelVal) { $global:logger.info("in $functionName - log.info: Info") }
	if ($global:logger.Logger.Repository.LevelMap["DEBUG"].value -le $logTestLevelVal) { $global:logger.debug("in $functionName - log.debug: Debug")}
	if ($global:logger.Logger.Repository.LevelMap["TRACE"].value -le $logTestLevelVal) { $global:logger.trace("in $functionName - log.trace: Trace")}
#	Write-Error "in $functionName - Write-Error" 
#	Write-Warning "in $functionName - Write-Warning"
#	Write-Output "in $functionName - Write-Output"
#	Write-Debug "in $functionName - Write-Debug"
#	Write-Verbose "in $functionName - Write-Verbose"
}


function Test-Log4Posh { 

	write-output "suppress standard powershell verbose/warn/debug output streams"
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
	$logSettings = @{log4netDllPath = "$PSScriptRoot\log4net\ILogExtensions.dll"; 
				logConfigFilePath = "$PSScriptRoot\log4net\logConfig.xml"}

	write-output "load and configure log4net"
	$logger = Enable-Log4Posh @logSettings
	$logFileName = $global:logger.Logger.Appenders.File

	## set log level at runtime
	$global:logger.Logger.level = [log4net.Core.Level]::Error
	write-output "testing log4net writes with log level set to error"
	Test-LogSomething

	## change log level at runtime
	$global:logger.Logger.level = [log4net.Core.Level]::Warn
	write-output "testing log4net writes with log level set to warn"
	Test-LogSomething

	## change log level at runtime
	$global:logger.Logger.level = [log4net.Core.Level]::Info
	write-output "testing log4net writes with log level set to info"
	Test-LogSomething

	## change log level at runtime
	$global:logger.Logger.level = [log4net.Core.Level]::Debug
	write-output "testing log4net writes with log level set to debug"
	Test-LogSomething

	## change log level at runtime
	$global:logger.Logger.level = [log4net.Core.Level]::All
	write-output "testing log4net writes with log level set to all"
	Test-LogSomething

	Disable-Log4Posh 

	Write-Output "content of dynamic log4net logging:"
	Get-Content $logFileName 

}

