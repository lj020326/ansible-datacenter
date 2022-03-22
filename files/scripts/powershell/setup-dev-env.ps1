
## initial path on VDI
## $env:localappdata\Microsoft\WindowsApps;$env:localappdata\Programs\Microsoft VS Code\bin;$env:userprofile\apps\git\cmd;$env:userprofile\apps\git;$env:userprofile\apps\git\bin;$env:userprofile\apps\msys64\usr\bin

$userpath="$env:localappdata\Microsoft\WindowsApps"
$userpath+=";$env:localappdata\Programs\Microsoft VS Code\bin"
$userpath+=";$env:userprofile\apps\git\cmd"
$userpath+=";$env:userprofile\apps\git"
$userpath+=";$env:userprofile\apps\git\bin"
$userpath+=";$env:userprofile\apps\msys64\usr\bin"

#Add the paths in $p to the PSModulePath value.
[Environment]::SetEnvironmentVariable("Path",$userpath,"User")
