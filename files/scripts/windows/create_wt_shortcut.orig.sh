#!/bin/sh
## ref: https://superuser.com/questions/606245/how-to-create-send-to-folder-similar-to-send-to-desktop-shortcut
tab1_profile="Command Prompt"
tab1_title="Command Prompt"
tab2_profile="PowerShell"
tab2_title="PowerShell"
targetfolder="wt new-tab -p \"$tab1_profile\" --title \"$tab1_title\" --suppressApplicationTitle ; new-tab -p \"$tab2_profile\" --title \"$tab2_title\" --suppressApplicationTitle"
cmd //c shortcut //f:$USERPROFILE\Desktop\windows-term-custom.lnk //a:c //t:"$targetfolder"
