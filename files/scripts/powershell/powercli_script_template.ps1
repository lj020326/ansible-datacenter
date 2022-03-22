#requires -version 2
<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Dot Source required Function Libraries
. "C:\Scripts\Functions\Logging_Functions.ps1"

#Add VMware PowerCLI Snap-Ins
Add-PSSnapin VMware.VimAutomation.Core

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Log File Info
$sLogPath = "C:\Windows\Temp"
$sLogName = "<script_name>.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Connect-VMwareServer{
  Param([Parameter(Mandatory=$true)][string]$VMServer)
  
  Begin{
    Log-Write -LogPath $sLogFile -LineValue "Connecting to VMware environment [$VMServer]..."
  }
  
  Process{
    Try{
      $oCred = Get-Credential -Message "Enter credentials to connect to vSphere Server or Host"
      Connect-VIServer -Server $VMServer -Credential $oCred
    }
    
    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }
  
  End{
    If($?){
      Log-Write -LogPath $sLogFile -LineValue "Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
    }
  }
}

<#

Function <FunctionName>{
  Param()
  
  Begin{
    Log-Write -LogPath $sLogFile -LineValue "<description of what is going on>..."
  }
  
  Process{
    Try{
      <code goes here>
    }
    
    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }
  
  End{
    If($?){
      Log-Write -LogPath $sLogFile -LineValue "Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
    }
  }
}

#>

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
#$Server = Read-Host "Specify the vCenter Server or ESXi Host to connect to (IP or FQDN)?"
#Connect-VMwareServer -VMServer $Server
#Script Execution goes here
#Log-Finish -LogPath $sLogFile
