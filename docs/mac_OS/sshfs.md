# How To Use SSHFS on macOS

Using **sshfs** is a great way to mount a remote drive from AWS, Azure, or any remote machine to your local mac. Installing **sshfs** is a relatively straightforward process.

#### Prerequisites & Installation

Be sure that you can SSH to your target machine using SSH keys.

Download and Install the [OSXFuse](http://osxfuse.github.io/) and [SSHFS](http://osxfuse.github.io/) packages as admin.

Create a local folder to access your remote filesystem.

```shell
mkdir /tmp/sshfs
```

Use brew to install macfuse / sshfs

```shell
brew install macfuse
```

#### Mount Filesystem

Example usage of sshfs.

```shell
sshfs username@remote:/remote/directory /mount/point
```

#### Unmount Filesystem

If you cant eject the drive in finder can force the unmount.

```shell
diskutil umount /mount/point
## OR
diskutil umount force /mount/point
```

Or 

```shell
fusermount -u /mount/point
```

#### Debugging Connection Issues

Sometimes you may want a more verbose output when trying to mount a drive with sshfs. This can help you diagnose connection-related issues etc.

```shell
sshfs -odebug,sshfs\_debug,loglevel=debug username@remote:/remote/directory /mount/point
```

## Syncing files/dirs based on file changes

lsyncd seems to be the ideal solution. 
It combines inotify (kernel builtin function witch watches for file changes in a directory trees) and rsync (cross platform file-syncing-tool).

Example
```shell
lsyncd -rsyncssh /home remotehost.org backup-home/

```

# Uninstalling/Removing

* https://www.imymac.com/powermymac/unistall-mac-fuse.html
* https://nektony.com/how-to/remove-fuse-from-mac
* https://code.google.com/archive/p/macfuse/issues/36
* http://hints.macworld.com/article.php?story=20070121150939976

## Reference

* https://www.petergirnus.com/blog/how-to-use-sshfs-on-macos
* https://unix.stackexchange.com/questions/61567/how-to-specify-key-in-sshfs
* https://stackoverflow.com/questions/71522478/macfuse-giving-mount-macfuse-mount-point-is-itself-on-a-macfuse-volume-ap
* https://osxfuse.github.io/
* https://www.itsfullofstars.de/2022/03/mount-a-remote-directory-via-ssh-on-macos-sshfs/
* https://unix.stackexchange.com/questions/424541/how-to-automount-sshfs-shares-for-a-user-upon-login
* https://stackoverflow.com/questions/63569542/mount-filesystem-over-sshfs-at-system-startup-boot-mojave-10-14-6
* https://unix.stackexchange.com/questions/61567/how-to-specify-key-in-sshfs
* https://github.com/osxfuse/sshfs
* https://github.com/osxfuse/osxfuse/issues/901
* https://github.com/osxfuse/osxfuse/issues/384
* https://github.com/tormodwill/macSSHFS/discussions/4
* https://serverfault.com/questions/148665/is-it-possible-to-sync-two-linux-directories-in-real-time

