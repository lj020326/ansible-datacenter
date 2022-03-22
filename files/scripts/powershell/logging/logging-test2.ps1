
<<<<<<< HEAD
function test-function { 

    Write-Verbose "Testing log"

    $logFile | Disable-LogFile 

    Get-Content $logFileName

}

$logFileName = "C:\apps\powershell\logs\test1.log"

$logFile = Enable-LogFile -Path $logFileName

Enable-OutputSubscriber -OnWriteVerbose {$fn=Get-FunctionName; "$fn"}    

Write-Verbose "Before output subscription"

test-function 
=======
Import-Module PowerShellLogging 

function Write-Log {
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

$logPath = "C:\apps\powershell\logs\test2.log"

Write-Verbose "Before output subscription"

$logFile = Enable-OutputSubscriber -OnWriteDebug   { Write-Log -Path $logPath -Line $args[0] -Prefix '[D]' } `
                                   -OnWriteError   { Write-Log -Path $logPath -Line $args[0] -Prefix '[E]' } `
                                   -OnWriteVerbose { Write-Log -Path $logPath -Line $args[0] -Prefix '[V]' } `
                                   -OnWriteWarning { Write-Log -Path $logPath -Line $args[0] -Prefix '[W]' } `
                                   -OnWriteOutput  { Write-Log -Path $logPath -Line $args[0] }


test-function 

$logFile | Disable-OutputSubscriber 

Get-Content $logPath
>>>>>>> 000a7e67081903b2b20b9e9256cf23270cd965c8
