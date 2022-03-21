# How to setup rsyncd on Mac OS X

[![Rsync](http://upload.wikimedia.org/wikipedia/en/thumb/1/11/Newrsynclogo.png/75px-Newrsynclogo.png "Rsync")](http://en.wikipedia.org/wiki/File:Newrsynclogo.png)

Image via Wikipedia

One of the most versatile utilities developed is rsync, however; learning to effectively use the application can be a daunting task. Rsync is useful for conducting backups to remote file servers or even mirroring a local drive to a removable one. It supports transferring files over ssh as well as it’s own protocol. Unfortunately, to use the built in rsync protocol you need to set up an [rsync server](http://en.wikipedia.org/wiki/Rsync "Rsync"), which on a [Mac](http://en.wikipedia.org/wiki/Macintosh "Macintosh") can be quite tricky.

On the one hand, you can simply type rsync —[daemon](http://en.wikipedia.org/wiki/Daemon_%28computer_software%29 "Daemon (computer software)") and it will start a rsync daemon running on [TCP port](http://en.wikipedia.org/wiki/Port_number "Port number") 873. But without the appropriate rsyncd.conf things can get a little messy. In addition, if you reboot the ‘server’ the process will not restart automatically. The worst thing is to have a system that has been operational for several months suddenly stop because someone rebooted the hardware and no one remembered that the process needed to be relaunched. Personally, I think it is much better to have the system offer some more resiliency by automating this process.

On the Mac, unfortunately inetd is no longer a viable option, thus you need to use launchd and launchdctl to load your [XML](http://en.wikipedia.org/wiki/XML "XML") described process file. So, I created the following [plist](http://en.wikipedia.org/wiki/Property_list "Property list") ([property list](http://en.wikipedia.org/wiki/Property_list "Property list")) file that I installed as root into /Library/LaunchDaemon.

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>Disabled</key>
        <false/>
        <key>Label</key>
        <string>org.samba.rsync</string>
        <key>Program</key>
        <string>/opt/local/bin/rsync</string>
        <key>ProgramArguments</key>
        <array>
                <string>/opt/local/bin/rsync</string>
                <string>--daemon</string>
                <string>--config=/usr/local/etc/rsyncd/rsyncd.conf</string>
        </array>
        <key>inetdCompatibility</key>
        <dict>
                <key>Wait</key>
                <false/>
        </dict>
                <key>Sockets</key>
                <dict>
                        <key>Listeners</key>
                        <dict>
                                <key>SockServiceName</key>
                                <string>rsync</string>
                                <key>SockType</key>
                                <string>stream</string>
                        </dict>
                </dict>
</dict>
</plist>
```

[![FreeBSD's mascot is the generic BSD daemon, al...](http://upload.wikimedia.org/wikipedia/en/thumb/5/55/Bsd_daemon.jpg/75px-Bsd_daemon.jpg "FreeBSD's mascot is the generic BSD daemon, al...")](http://en.wikipedia.org/wiki/File:Bsd_daemon.jpg)

Image via Wikipedia

[![FreeBSD logo introduced in 2005](http://upload.wikimedia.org/wikipedia/en/thumb/d/df/Freebsd_logo.svg/75px-Freebsd_logo.svg.png "FreeBSD logo introduced in 2005")](http://en.wikipedia.org/wiki/File:Freebsd_logo.svg)

Image via Wikipedia

You should also note that although I could have used the default 2.6.9 version of rsync that ships with most Macs, I have actually upgraded mine to 3.0.8 using the [MacPorts.org](http://MacPorts.org "Mac Ports") system. In addition, I have created this plist to look for the rsyncd.conf in /usr/local/etc/rsyncd, because it is a more unified best practice way of doing things. Besides, like [Mac OS](http://en.wikipedia.org/wiki/Mac_OS "Mac OS") X I am a fan of [FreeBSD](http://www.freebsd.org/ "FreeBSD") and it’s just the way I roll. The following is an example of a rsyncd.conf file that I have used in the past:

```
# rsyncd.conf - Example file, see rsyncd.conf(5)
#
#

# Set this if you want to stop rsync daemon with rc.d scripts
pid file = /var/run/rsyncd.pid

# Remember that rsync will supposedly reread this file before each new client connection
# so you should not need to HUP the daemon ever.

motd=/usr/local/etc/rsyncd/rsyncd.motd
uid = nobody
gid = nobody
use chroot = no
max connections = 4
syslog facility = local5

[mk]
        path = /Volumes/Data/home/mikel/stuff
        comment = Mikel King Repository
                uid = www
                gid = www
        list = yes
                read only = no
        auth users = mking
        secrets file = /usr/local/etc/rsyncd/mking.secrets
```

Once I have completed the basic setup it’s time to launch the daemon. To do this we need to use launchdctl to load the plist into the lauchd registry. I find it is easiest to use pushed to temporarily move to /Library/LaunchDaemons and run the command locally as follows;

```
sudo launchctl load org.samba.rsync.plist
```

At this point we have told the Mac (in my case a Snow Leopard Server) to make this service available. If you were to perform a _ps ax | grep rsync_ you would likely not see anything. Once you make a connection attempt on the appropriate TCP port 873 launchd will setup the daemon. On my laptop at the command prompt I enter the appropriate command that will make the connection to the rsync service.

```
rsync --stats mking@olivent.com::mk
```

This above command will connect to the rsync daemon, which is a geeky way of saying service causing launchd on the remote server to instantiate a copy of rsyncd to launch and run answering the request. It does this on the fly in order to save system resources. Honestly there isn’t much reason to keep rsyncd around running just in case someone makes the call and supplies the correct credentials. You don’t keep your car running just in case you might decide to hop in and run up to 7 Eleven for a burrito and cup of Brazilian Bold do you? No, because that would be a gross waste of resources! On the server side when we make the call it answers with the following;

```
isis:~ $ ps ax |grep rsync
85366   ??  Ss     0:00.00 /usr/libexec/launchproxy /opt/local/bin/rsync --daemon --config=/usr/local/etc/rsyncd/rsyncd.conf
```

As soon as the connection to rsync has completed it’s transaction the daemon will end it’s run allowing those cycles and ram to return to the pool of resources that the server needs to use for doing other things like serving Minecraft or WordPress web sites. The following is an example of what it looks like from the client perspective,which in geek speak is basically a way of saying what happened on my laptop;

```
djehuty: mking$ rsync  --stats  mking@olivent.com::mk
Password:
drwxrwxrwt         374 2011/11/19 11:39:11 .
-rw-r--r--      382258 2011/11/10 22:16:56 ThumbtackMap.png
-rwxr-xr-x          71 2011/07/30 00:48:29 addRoute
-rw-r--r--      255809 2011/10/24 09:03:27 mk-mib.jpg
-rw-r--r--       78922 2011/11/03 14:47:54 rei-press-mug.png
-rw-r--r--        1362 2011/07/29 23:56:50 rsyncd.conf
-rw-r--r--      681399 2011/11/18 15:03:15 stargate.png
-rw-r--r--       66468 2011/11/01 15:04:52 terminal.app.png
-rw-r--r--         715 2011/11/18 18:19:07 tftp.plist
-rw-r--r--       10274 2011/11/18 17:42:13 admin-ssh-bundle.tbz

Number of files: 10
Number of files transferred: 0
Total file size: 1477278 bytes
Total transferred file size: 0 bytes
Literal data: 0 bytes
Matched data: 0 bytes
File list size: 225
File list generation time: 0.007 seconds
File list transfer time: 0.000 seconds
Total bytes sent: 61
Total bytes received: 300

sent 61 bytes  received 300 bytes  144.40 bytes/sec
total size is 1477278  speedup is 4092.18
```

As you can see I am running rsync on my laptop with the –stats option which yields this handy output of what transpired during the session. After issuing the rsync command it prompts me for my password on the rsync server for that resource, which rsync calls a module. Assuming that I am listed in the module definition in rsyncd.conf as an auth user and enter the correct password noted in the appropriate “secrets” file then rsyncd will send the appropriate data to rsync on my laptop.

I understand all of this client server protocol negotiation may sound like “Blah blah blah blah” or one of the adults from a Peanuts comic because it’s definitely geek speak. Just keep the basics in mind; If you run rsync on your side of the connection to call rsyncd on the other end. This means that you are the client and the destination is the server. Of course this gets very muddy when you start talking about the X Windowing System but we shall save that for another day.

In summary rsync is an extremely useful service to have in your utility belt. I have used rsync to copy huge amounts of data to sites all over the world. When I was working on a project that required deliverables in Malaysia, China and Turkey from the US I used rsync to transport the data. The main reason I chose rsync is it’s ability to be automated and of course if you are using the rsync protocol you can not forget the ability resume a transfer if something breaks.

I hope this article helps you understand the power of rsync and sheds some insight into it’s uses. Please leave a comment on how you use rsync.

###### Related articles

-   [Advanced Mac OS X Shell Scripting](https://www.jafdip.net/index.php/2011/08/09/advanced-mac-os-x-shell-scripting/) (jafdip.com)
-   [How To rsync Server Setup for Centos](http://vijaynayani.wordpress.com/2010/10/09/how-to-rsync-server-setup-for-centos/) (vijaynayani.wordpress.com)
-   [Performing MacPorts Magick](https://www.jafdip.net/index.php/2011/08/01/performing-macports-magick/) (jafdip.com)