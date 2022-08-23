
# rsync server daemon on Mac OS X with launchctl

(**Update**: Added the \--no-detach option to the rsync command. Newer MacOS versions wouldn't start the daemon without it. With the added argument, it now works again in Sierra.)

There are many web pages describing how to enable the rsync daemon on Mac OS X using launchd/launchctl mechanism. But I had to use a different (and simpler) plist file in LaunchDaemons to make it work across reboots on Lion (10.7.4).

I started by following [this guide](http://blog.bravi.org/?p=732) , and [this very similar one](http://jafdip.com/how-to-setup-rsyncd-on-mac-os-x/). And I also read [this](http://maxpowerindustries.com/2009/09/21/how-to-install-the-rsync-daemon-on-mac-os-x/) and [this](http://www.springsurprise.com/2009/06/16/setting-up-rsync-as-a-daemon/). In the end, what helped me getting the plist file right was [this thread](https://discussions.apple.com/thread/2446125). Particularly [this post](http://discussions.apple.com/thread/2446125#11595958): "For one you have both a Program and a ProgramArguments key, when you should have only one or the other (you use Program if there is just one element to the command, or ProgramArguments if there are multiple." And [this one](http://discussions.apple.com/thread/2446125#12106046).

This is the .plist file I used in /Library/LaunchDaemons/org.samba.rsync.plist :

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Disabled</key>
    <false/>
    <key>Label</key>
    <string>org.samba.rsync</string>
    <key>ProgramArguments</key>
    <array>
     <string>/usr/bin/rsync</string>
     <string>--daemon</string>
     <string>--no-detach</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
</dict>
</plist>

```

This is an example /etc/rsyncd.conf file:

```
secrets file = /etc/rsyncd.secrets
hosts allow = 192.168.1.0/24 10.0.0.1 *.cust.isp.tld

uid = nobody
gid = nobody
list = yes
read only = yes

[shared]
path = /Users/Shared
comment = Users-Shared
uid = someuser
gid = admin
auth users = user_in_secrets

```

The file /etc/rsyncd.secrets looks like:

```
some_rsync_user:password
other_user:other_password

```

To install it:

```
sudo -s
chown root:wheel /etc/rsyncd.*
chmod 644 /etc/rsyncd.conf
chmod 600 /etc/rsyncd.secrets
launchctl load /Library/LaunchDaemons/org.samba.rsync.plist
launchctl start org.samba.rsync ## (this last command is probably unneeded)

```

To check if it is installed and running:  

```
launchctl list | grep rsync
808 - 0x7fddb4806c10.anonymous.rsync
- 0 org.samba.rsync

ps ax | grep [r]sync
 808 ?? Ss 0:00.00 /usr/bin/rsync --daemon

rsync --stats someuser@localhost::
```

To check the config state:

```shell
launchctl dumpstate
```


To remove it:

```
sudo launchctl unload /Library/LaunchDaemons/org.samba.rsync.plist
sudo killall rsync
```

For logging transfers, add

```
log file = /var/log/rsyncd.log
transfer logging = yes
```

to /etc/rsyncd.conf. And to have the log rotated, create a file like /etc/newsyslog.d/rsyncd.conf and add

```
# logfilename          [owner:group]    mode count size when  flags [/pid_file] [sig_num]
/var/log/rsyncd.log   644  5    5000 *     J
```

## Reference

* http://bahut.alma.ch/2013/01/rsync-server-daemon-on-mac-os-x.html
* https://stackoverflow.com/questions/33492709/rsync-with-launchd-on-os-x-always-gives-me-error-code-255
* 