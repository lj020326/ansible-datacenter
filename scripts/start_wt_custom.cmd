@echo off
rem @echo on

rem
rem ref: https://superuser.com/questions/606245/how-to-create-send-to-folder-similar-to-send-to-desktop-shortcut
rem
:: For my testing purposes, change this to whatever you need
rem set targetfolder=d:\Temp
rem set targetfolder=%UserProfile%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch
rem set targetfolder='wt new-tab -p "Command Prompt" --title "Cmd" --suppressApplicationTitle ; new-tab -p "Windows PowerShell" --title "PowerShell" --suppressApplicationTitle'

set tab1_profile="ssh-media01"
set tab1_title="media01"

set tab2_profile="ssh-vcontrol01"
set tab2_title="vcontrol01"

rem set tab3_profile="ssh-nas02"
rem set tab3_title="nas02"

set tab4_profile="MINGW64 / MSYS2"
set tab4_title="pipeline"
set tab4_dir="%UserProfile%/repos/jenkins/pipeline-automation-lib"

set tab5_profile="MINGW64 / MSYS2"
set tab5_title="packer"
set tab5_dir="%UserProfile%/repos/jenkins/packer-boxes"

set tab6_profile="MINGW64 / MSYS2"
set tab6_title="ansible"
set tab6_dir="%UserProfile%/repos/ansible/ansible-datacenter"

rem set tab1_profile="Command Prompt"
rem set tab1_title="Command Prompt"

rem set tab2_profile="Windows PowerShell"
rem set tab2_title="PowerShell"

rem wt new-tab -p %tab1_profile% --title %tab1_title% --suppressApplicationTitle ; new-tab -p %tab2_profile% --title %tab2_title% --suppressApplicationTitle

wt new-tab -p %tab1_profile% --title %tab1_title% --suppressApplicationTitle ; ^
  new-tab -p %tab2_profile% --title %tab2_title% --suppressApplicationTitle ; ^
  new-tab -p %tab4_profile% --title %tab4_title% -d %tab4_dir% --suppressApplicationTitle ; ^
  new-tab -p %tab5_profile% --title %tab5_title% -d %tab5_dir% --suppressApplicationTitle ; ^
  new-tab -p %tab6_profile% --title %tab6_title% -d %tab6_dir% --suppressApplicationTitle ; ^
  focus-tab -t 0

