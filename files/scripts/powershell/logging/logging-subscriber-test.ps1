
Import-Module PowerShellLogging 

## By using your own script blocks as event handlers, you can define whatever behaviour you want.  
## For example, this code reproduces the behaviour of 
## Enable-LogFile, but with a different date / time format:

function Write-Log
{
    param (
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [ValidateNotNull()]
        [string] $Line = '',

        [string] $Prefix

    )

    $Line = $Line.Trim()
    $Prefix = $Prefix.Trim()

    if ($Prefix) { $Prefix = "$Prefix " }
        
    $Now = Get-Date -Format 'G'
    $Line = "$Now - $Prefix$Line"

    Add-Content -Path $Path -Value $Line
}

#$logPath = "$home\someLogFile.txt"
#$logPath = "C:\apps\powershell\logs\logging-subscriber-test.log"
#$scriptname = split-path $MyInvocation.MyCommand.Definition -Leaf
$scriptname = (split-path $MyInvocation.MyCommand.Definition -Leaf).TrimEnd(".ps1")

$logPath = "C:\apps\powershell\logs\$scriptname.log"

if (Test-Path -Path $logPath) { Remove-Item $logPath }

$logFile = Enable-OutputSubscriber -OnWriteDebug   { Write-Log -Path $logPath -Line $args[0] -Prefix '[D]' } `
                                   -OnWriteError   { Write-Log -Path $logPath -Line $args[0] -Prefix '[E]' } `
                                   -OnWriteVerbose { Write-Log -Path $logPath -Line $args[0] -Prefix '[V]' } `
                                   -OnWriteWarning { Write-Log -Path $logPath -Line $args[0] -Prefix '[W]' } `
                                   -OnWriteOutput  { Write-Log -Path $logPath -Line $args[0] }
                                   
Write-Host 'Hello, world'
Write-Output 'Hello, Output world'
Write-Verbose -Verbose 'Hello, Verbose world'
Write-Debug 'Hello, Debug world before enabling debug'
$DebugPreference = 'Continue'
Write-Debug 'Hello, Debug world'
Write-Error 'Hello, Error world'
Write-Warning 'Hello, Warning world'

$logFile | Disable-OutputSubscriber

Get-Content $logPath

