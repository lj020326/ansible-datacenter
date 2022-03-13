#!/bin/sh
## ref: https://superuser.com/questions/606245/how-to-create-send-to-folder-similar-to-send-to-desktop-shortcut
targetfolder="C:\apps\bin\start_wt_custom.cmd"
cmd //c shortcut //f:"$USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\windows-term-custom.lnk" //a:c //t:"$targetfolder"
