
# Rsync error cannot stat destination- Quick fix!

_Have you ever got stuck with Rsync error cannot stat destination?_

Errors are common while migrating files between different servers. But, rsync errors are a bit tricky.

Usually, it occurs due to improper file system settings.

Today, let’s discuss this Rsync error in detail and see how to fix it.

## What causes rsync error cannot stat destination?

The _rsync_ command synchronizes files from a source server to a destination. It can copy data locally, and to/from another host over any remote shell.

In general, it is widely used for backups and as an improved copy command for everyday use. Let’s discuss the major reasons that cause this error.

### 1\. Missing user privileges

When the user that initiates Rsync does not have enough privileges, it can result in Rsync errors.

By default, rsync creates its temporary files in the same folder as the target directory. But even if it can’t create those temporary files it still starts the transfer and fails afterward. The rsync command will not be checking right at the beginning if it has all required write permissions.

And, such a lack of privileges often results in errors like:

```
stderr: rsync: ERROR: cannot stat destination "/var/www/vhosts/examle.com/httpdocs/": Permission denied (13)
rsync error: errors selecting input/output files, dirs (code 3) at main.c(635) [Receiver=3.1.2]
```

### 2\. Incorrect temp directory

Similarly, in some cases, the rsync temp directory also creates problems with file copying. This happens due to the use of a temp-dir on a different filesystem than the destination file.

Here, rsync tries to rename the finished file, copy the file and set proper permissions, ownership, etc. If for some reason the  
file vanishes during this updating, rsync will complain about it and show up errors.

Ideally, the temp directory should be on the same file system as that of the destination file. But, keeping the temp directory on a different file system or the different drives will result in errors.

## How we fix the error?

We just saw the top reasons for the Rsync error cannot stat destination. Let’s check on how our [Dedicated Engineers](https://bobcares.com/server-management-services/) resolve it for our customers.

Recently, one of our customers contacted us with a rsync cannot stat destination error.

He got the following error,

```
rsync --whole-file --temp-dir /tmp myweb.html destination.machine:/path/to/file/myweb.html
error:
rsync: stat "/path/to/file/myweb.html" failed: No such file or directory (2)
rsync error: some files could not be transferred (code 23) at main.c(702)
```

Initially, I checked and verified that the user performing Rsync has enough privileges to write and modify files at the destination.

I dug deeper and found the error with the file system. Here, the _temp_ directory was on a different file system than the destination. This caused the error.

We fixed this quickly by changing the temp directory to the same file system as the destination. This resolved the error.

Another common option is to use a relative _partial-dir_ option.  For instance:

```
rsync --temp-dir=/tmp --partial-dir=../tmp file.txt dest:/path/
```

Here, Rsync will first copy the files from the temp-dir into partial-dir and then rename it into the correct destination.

**\[Need more assistance to solve the rsync error? [We are available 24×7 to help you](https://bobcares.com/server-management-services/).\]**

## Conclusion

In short, rsync error cannot stat destination occurs due to conflicts in the file system and insufficient permission of rsync user. 

## References

* https://bobcares.com/blog/rsync-error-cannot-stat-destination/
* 