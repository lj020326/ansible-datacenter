##
## this example is sourced from 
## https://gallery.technet.microsoft.com/scriptcenter/Enhanced-Script-Logging-27615f85/view/Discussions#content
##

Import-Module PowerShellLogging 

$logFileName = "C:\apps\powershell\logs\test.log"

$logFile = Enable-LogFile -Path $logFileName
 
# Note - it is necessary to save the result of Enable-LogFile to a variable in order to keep the object alive.  
# As soon as the $LogFile variable is reassigned or falls out of scope, the LogFile object becomes eligible for garbage collection. 
 
$VerbosePreference = 'Continue' 
$DebugPreference = 'Continue' 
 
Write-Host "Write-Host test." 
"Out-Default test." 
Write-Verbose "Write-Verbose test." 
Write-Debug "Write-Debug test." 
Write-Warning "Write-Warning test." 
Write-Error "Write-Error test." 
Write-Host ""   # To display a blank line in the file and on screen. 
Write-Host "Multi`r`nLine`r`n`r`nOutput"  # To display behavior when strings have embedded newlines. 
 
# Disable logging before the script exits (good practice, but the LogFile will be garbage collected 
# so long as this variable was not in the Global Scope, as a backup in case the script crashes 
# or you somehow forget to call Disable-LogFile). 
 
$LogFile | Disable-LogFile 
 
<# 
Sample contents of log file: 
Sun, 04 Aug 2013 14:04:15 GMT - Write-Host test. 
Sun, 04 Aug 2013 14:04:15 GMT - Out-Default test. 
Sun, 04 Aug 2013 14:04:15 GMT - [V] Write-Verbose test. 
Sun, 04 Aug 2013 14:04:15 GMT - [D] Write-Debug test. 
Sun, 04 Aug 2013 14:04:15 GMT - [W] Write-Warning test. 
Sun, 04 Aug 2013 14:04:15 GMT - [E] C:\Users\Dave\Source\Temp\Test.ps1 : Write-Error test. 
Sun, 04 Aug 2013 14:04:15 GMT - [E]     + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException 
Sun, 04 Aug 2013 14:04:15 GMT - [E]     + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Test.ps1 
  
 
Sun, 04 Aug 2013 14:04:15 GMT - Multi 
Sun, 04 Aug 2013 14:04:15 GMT - Line 
 
Sun, 04 Aug 2013 14:04:15 GMT - Output 
#>
