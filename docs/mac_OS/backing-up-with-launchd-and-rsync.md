
# BACKING UP WITH LAUNCHD AND RSYNC IN OS X

Recently I was entrusted with the task of creating a simple backup solution for a client’s X-Serve. All I needed to do was mirror one directory to a secondary drive each night, as well as once on the weekend to an alternate location. While there are many fine utilities out there for performing backups, such as [ChronoSync](http://www.macupdate.com/info.php/id/7230), and the continually diminishing [Retrospect](http://www.macupdate.com/info.php/id/7562), I opted to take advantage of OS X’s included services.

rsync seemed like the natural choice. I thought about using cp at first but rsync is much more efficient, especially when only a few sub-directories need to be updated, versus having cp rewrite the entire backup directory each time.

Now that cron is deprecated in 10.4, I turned to launchd to run rsync on a schedule. This was the first time that I had tried to use launchd. I was pleased to learn that it’s much easier to configure and use then cron. launchd uses human readable .plist configuration files, which can be loaded on demand with launchctl. To make things even easier there is a utility for editing the launchd plist files called [Lingon](http://www.macupdate.com/info.php/id/19879).

Putting rsync and launchd together proved to be a little more of a challenge then I first suspected. Initially I had tried running rsync directly from launchd but kept getting “launchd: com.firefallpro.daily\_backup: 8 more failures without living at least 60 seconds will cause job removal” and “launchd: com.firefallpro.daily\_backup: exited with exit code: 12”. A quick look in man rsync informed me that an exit code of 12 is a _“Error in rsync protocol data stream.”_ Not that I know what that means.

After a bunch of research and checking out some examples on the web, most which seem to be incomplete, or untested, I was left with no choice but to read man pages and tinker. The only way to get the rsync to run properly was to trigger it from shell script versus directly from launchd.

The following is my final implementation for your approval, dissection, and hopefully, feedback.

**launchd plist** placed in _“/Library/LaunchDaemons/com.firefallpro.daily\_backup”_:  
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/
DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>Label</key>
<string>com.salesgraphics.daily_backup</string>
<key>OnDemand</key>
<true/>
<key>LowPriorityIO</key>
<true/>
<key>Nice</key>
<integer>12</integer>
<key>ProgramArguments</key>
<array>
<string>/Users/admin/Documents/daily_backup.sh</string>
</array>
<key>StartCalendarInterval</key>
<dict>
<key>Hour</key>
<integer>3</integer>
<key>Minute</key>
<integer>0</integer>
</dict>
</dict>
</plist>
```


**Shell script** placed in _“/Users/admin/Documents/daily\_backup.sh”_:  
```shell
#!/bin/bash
/usr/bin/rsync -qaEu /Library/WebServer/www/ /Volumes/Backup\ HD/daily;
```

Note: I ran "chown root /Users/admin/Documents/daily\_backup.sh" on the shell script to make sure it would execute rsync as root, and "chmod u+x /Users/admin/Documents/daily\_backup.sh" to make it executable.

rsync is being run with “-qaEu”:

-   q: Run quietly, seeing we’re running through launchd.
-   a: Enables a whole bunch of options needed for grabbing a directory and everything inside.
-   E: Extended attributes (get Mac OS resource forks).
-   u: Update forces rsync to skip files for which the destination file already exists and has a date later than the source file.

Once the files were in place I ran "launchctl load /Library/LaunchDaemons/", to load the new configuration files without rebooting. The console still logs some minor errors from launchd and rsync but the shell script executes successfully.

I hope this helps someone, and if I revise my strategy I’ll make sure to update this post.

## References

* https://blog.firefall.com/2006/03/backing-up-with-launchd-and-rsync-in.html
* 