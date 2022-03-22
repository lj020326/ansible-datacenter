C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe -psconsolefile "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\vim.psc1" -noexit -Noninteractive -command "C:\apps\powershell\powercli\restartvms.ps1"; Exit $LASTEXITCODE" >> restartvms.log 2>&1
EXIT %ERRORLEVEL%
