
Import-Module PowerShellLogging 

function global:Write-Log {
    [CmdletBinding()]
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

function test-function { 

    Write-Verbose "Testing log"

}

#$scriptname = (split-path $MyInvocation.MyCommand.Definition -Leaf).TrimEnd(".ps1")
$scriptname = ($MyInvocation.MyCommand.Definition).TrimEnd(".ps1")

$logPath = "$scriptname.log"

if (Test-Path -Path $logPath) { Remove-Item $logPath}

Write-Verbose "Before output subscription"

$logFile = Enable-OutputSubscriber -OnWriteDebug   { Write-Log -Path $logPath -Line $args[0] -Prefix '[D]' } `
                                   -OnWriteError   { Write-Log -Path $logPath -Line $args[0] -Prefix '[E]' } `
                                   -OnWriteVerbose { Write-Log -Path $logPath -Line $args[0] -Prefix '[V]' } `
                                   -OnWriteWarning { Write-Log -Path $logPath -Line $args[0] -Prefix '[W]' } `
                                   -OnWriteOutput  { Write-Log -Path $logPath -Line $args[0] -Prefix '[O]' }

Write-Verbose "After output subscription"
Write-Verbose -Verbose 'Hello, Verbose world'

$VerbosePreference = 'Continue' 
Write-Verbose "After output subscription and enabling verbose"
Write-Host 'Hello, world'
Write-Output 'Hello, Output world'

test-function 

$logFile | Disable-OutputSubscriber 

Get-Content $logPath
