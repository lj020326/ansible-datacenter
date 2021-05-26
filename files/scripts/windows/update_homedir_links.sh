#!/usr/bin/env bash

echo "Run from msys shell"
echo "Starting"

cd ~/
rm Templates && ln -s ~/AppData/Roaming/Microsoft/Windows/Templates
rm Start\ Menu && ln -s ~/AppData/Roaming/Microsoft/Windows/Start\ Menu
rm SendTo && ln -s ~/AppData/Roaming/Microsoft/Windows/SendTo
rm Recent && ln -s ~/AppData/Roaming/Microsoft/Windows/Recent
rm Printer\ Shortcuts && ln -s ~/AppData/Roaming/Microsoft/Windows/Printer\ Shortcuts
rm NetHood && ln -s ~/AppData/Roaming/Microsoft/Windows/Network\ Shortcuts NetHood
rm My\ Documents && ln -s ~/Documents My\ Documents
rm Local\ Settings && ln -s ~/AppData/Local Local\ Settings
rm Cookies && ln -s ~/AppData/Local/Microsoft/Windows/INetCookies Cookies
rm Application\ Data && ln -s ~/AppData/Roaming/ Application\ Data

echo "Done"
