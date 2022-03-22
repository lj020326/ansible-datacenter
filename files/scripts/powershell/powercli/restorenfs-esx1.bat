C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe -psconsolefile "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\vim.psc1" -noexit -Noninteractive -command "C:\apps\powershell\powercli\restorenfs-esx1.ps1"; Exit $LASTEXITCODE" >> restorenfs-esx1.log 2>&1
EXIT %ERRORLEVEL%
