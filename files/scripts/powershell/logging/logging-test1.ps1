
function test-function { 

    $logFileName = "C:\apps\powershell\logs\test1.log"

    $logFile = Enable-LogFile -Path $logFileName

    Write-Verbose "Before output subscription"

    Enable-OutputSubscriber -OnWriteVerbose {$fn=Get-FunctionName; "$fn"}    

    Write-Verbose "After output subscription"

    $logFile | Disable-LogFile 

    Get-Content $logFileName

}

test-function 
