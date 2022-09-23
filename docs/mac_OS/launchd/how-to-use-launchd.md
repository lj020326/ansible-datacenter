
# How to set up a scheduled rsync job

Create plist file 

/Library/LaunchDaemons/org.example.rsync.plist:
```xml
?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>Label</key>
        <string>org.example.rsync</string>
        <key>OnDemand</key>
        <true/>
        <key>LowPriorityIO</key>
        <true/>
        <key>Nice</key>
        <integer>12</integer>
        <key>ProgramArguments</key>
        <array>
                <string>/Users/ljohnson/bin/sync-sshfs-example.sh</string>
        </array>
        <key>UserName</key>
        <string>ljohnson</string>
        <key>GroupName</key>
        <string>daemon</string>
        <key>RunAtLoad</key>
        <false/>

        <key>StandardErrorPath</key>
        <string>/tmp/rsync.example.stderr.log</string>
        <key>StandardOutPath</key>
        <string>/tmp/rsync.example.stdout.log</string>
        <key>StartCalendarInterval</key>
        <dict>
        <key>Minute</key>
        <integer>20</integer>
        </dict>
        </dict>
</plist>


```


Load job definition to launchd:

```shell
launchctl load -w /Library/LaunchDaemons/org.example.rsync.plist

```

Unload job definition to launchd:

```shell
launchctl unload -w /Library/LaunchDaemons/org.example.rsync.plist

```

```shell
la /var/log/com.apple.xpc.launchd/
launchctl bootout /Library/LaunchDaemons/org.example.rsync.plist
launchctl bootout /Library/LaunchAgents/org.example.rsync.plist
launchctl bootstrap /Library/LaunchAgents/org.example.rsync.plist
launchctl dumpstate org.example.rsync
launchctl enable gui/501/org.example.rsync
launchctl enable org.example.rsync
launchctl list | grep rsync
launchctl load /Library/LaunchAgents/org.example.rsync.plist
launchctl load /Library/LaunchDaemons/org.example.rsync.plist
launchctl start /Library/LaunchAgents/org.example.rsync.plist
launchctl start org.example.rsync
launchctl stop org.example.rsync
launchctl stop /Library/LaunchDaemons/org.example.rsync.plist 
launchctl unload /Library/LaunchAgents/org.example.rsync.plist
launchctl unload /Library/LaunchDaemons/org.example.rsync.plist
tail -30 /var/log/com.apple.xpc.launchd/launchd.log

```


## References

* https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html
* https://blog.codeleak.pl/2020/05/macos-sync-files-between-two-volumes.html
* 