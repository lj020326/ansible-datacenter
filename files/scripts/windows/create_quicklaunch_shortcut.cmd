rem
rem ref: https://superuser.com/questions/606245/how-to-create-send-to-folder-similar-to-send-to-desktop-shortcut
rem
@echo off
:: For my testing purposes, change this to whatever you need
rem set targetfolder=d:\Temp
set targetfolder=%UserProfile%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch
shortcut /f:"%targetfolder%\%~n1%~x1.lnk" /a:c /t:%1
rem alternative approach to using the shortcut above would be using a powershell script to do the same per the following
rem ref: https://sumtips.com/tips-n-tricks/create-shortcuts-from-command-line-in-windows/
rem Set-ShortCut "C:\Path\to\Save\Shortcut.lnk" "C:\Path\To\Program.exe"
rem Set-ShortCut %targetfolder%\%~n1%~x1.lnk %1
