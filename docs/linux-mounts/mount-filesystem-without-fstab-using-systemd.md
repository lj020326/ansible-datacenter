
How to mount filesystem without fstab using systemd
===
 
- [List currently mounted systemd units](#List_currently_mounted_systemd_units "List currently mounted systemd units")
- [Location of systemd mount points](#Location_of_systemd_mount_points "Location of systemd mount points")
- [Create filesystem](#Create_filesystem "Create filesystem")
- [Get UUID of the filesystem](#Get_UUID_of_the_filesystem "Get UUID of the filesystem")
- [Sample systemd unit file to mount filesystem without fstab](#Sample_systemd_unit_file_to_mount_filesystem_without_fstab "Sample systemd unit file to mount filesystem without fstab")
- [Start the service (Mount filesystem without fstab)](#Start_the_service_Mount_filesystem_without_fstab "Start the service (Mount filesystem without fstab)")
- [Mount filesystem (Start systemd service)](#Mount_filesystem_Start_systemd_service "Mount filesystem (Start systemd service)")

We mount filesystem using `/etc/fstab` to make the changes persistent across reboot. Now there is **another way** to mount filesystem without fstab using [systemd](./../systemd/systemd-tutorial.md "systemd tutorial"). In CentOS/RHEL 7 and 8 we can create systemd unit file to mount filesystem without fstab for respective partition and/or filesystem. These changes can be made for the current session or reboot persistent.

NOTE:

At the time of writing this article CentOS 8 was not available but I assume the same steps to mount filesystem without fstab and using systemd would work on CentOS 8 as [similar to RHEL 8](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_basic_system_settings/managing-system-services-with-systemctl_configuring-basic-system-settings).

# How to mount filesystem without fstab using systemd (CentOS/RHEL 7/8)

If you check `/etc/fstab` in RHEL/CentOS 7 and 8, you will observe that it contains very less entry as most partitions (especially `tmpfs`) partitions are now mounted using [systemd](./../systemd/systemd-tutorial.md "systemd tutorial") unit file instead of `/etc/fstab`.

Below is my `/etc/fstab` file. This is a very basic setup so I only have only 3 entries

```shell
[root@rhel-8 system]# cat /etc/fstab
/dev/mapper/rhel-root   /                       ext4    defaults        1 1
UUID=abf4aa90-0b58-499a-b601-bc5f208fd2cd /boot                   xfs     defaults        0 0
/dev/mapper/rhel-swap   swap                    swap    defaults        0 0
```

While I have many more partitions available which are mounted on my RHEL system and most of them are [tmpfs partitions](https://www.golinuxcloud.com/change-tmpfs-partition-size-redhat-linux/ "How to change tmpfs partition size in Linux ( RHEL / CentOS 7 )")

```shell
[root@rhel-8 system]# df -h
Filesystem             Size  Used Avail Use% Mounted on
devtmpfs               900M     0  900M   0% /dev
tmpfs                  915M     0  915M   0% /dev/shm
tmpfs                  915M  8.5M  907M   1% /run
tmpfs                  915M     0  915M   0% /sys/fs/cgroup
/dev/mapper/rhel-root   15G  2.1G   12G  16% /
/dev/sda1              483M  258M  225M  54% /boot
tmpfs                  183M     0  183M   0% /run/user/0
```

If you happen to configure your filesystem within the `/etc/fstab` file, the system will simply convert these entries into dynamic "`mount`" unit types for the life of the running environment. You can see these dynamically created system mount unit types under `/run/systemd/generator`.

```shell
[root@rhel-8 system]# ls -l /run/systemd/generator/
total 12
-rw-r--r--. 1 root root 254 Sep 16 12:37  boot.mount
-rw-r--r--. 1 root root 230 Sep 16 12:37 'dev-mapper-rhelx2dswap.swap'
drwxr-xr-x. 2 root root  80 Sep 16 12:37  local-fs.target.requires
drwxr-xr-x. 2 root root  60 Sep 16 12:37  local-fs.target.wants
-rw-r--r--. 1 root root 218 Sep 16 12:37  -.mount  <--- This is for / (root) filesystem
drwxr-xr-x. 2 root root  60 Sep 16 12:37  swap.target.requires
```

## List currently mounted systemd units

To view the currently loaded [systemd](./../systemd/systemd-tutorial.md "systemd tutorial") unit files which are mounting the filesystem you can use below command:

```shell
[root@rhel-8 system]# systemctl -t mount
UNIT                    LOAD   ACTIVE SUB     DESCRIPTION
-.mount                 loaded active mounted Root Mount
boot.mount              loaded active mounted /boot
dev-hugepages.mount     loaded active mounted Huge Pages File System
dev-mqueue.mount        loaded active mounted POSIX Message Queue File System
run-user-0.mount        loaded active mounted /run/user/0
sys-kernel-config.mount loaded active mounted Kernel Configuration File System
sys-kernel-debug.mount  loaded active mounted Kernel Debug File System

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.

7 loaded units listed. Pass --all to see loaded but inactive units, too.
To show all installed unit files use 'systemctl list-unit-files'.
```

As you see currently 7 units are loaded on my RHEL system.

## Location of systemd mount points

By default all the [systemd](./../systemd/systemd-tutorial.md "systemd tutorial") unit files for mounting filesystem is available inside `/usr/lib/systemd/system`

```shell
[root@rhel-8 ~]# cd /usr/lib/systemd/system
```

A unit configuration file whose name ends in "`.mount`" encodes information about a file system mount point controlled and supervised by systemd.

```shell
[root@rhel-8 system]# ls -l *.mount
-rw-r--r--. 1 root root 750 Jun 22  2018 dev-hugepages.mount
-rw-r--r--. 1 root root 665 Jun 22  2018 dev-mqueue.mount
-rw-r--r--. 1 root root 655 Jun 22  2018 proc-sys-fs-binfmt_misc.mount
-rw-r--r--. 1 root root 795 Jun 22  2018 sys-fs-fuse-connections.mount
-rw-r--r--. 1 root root 767 Jun 22  2018 sys-kernel-config.mount
-rw-r--r--. 1 root root 710 Jun 22  2018 sys-kernel-debug.mount
-rw-r--r--. 1 root root 704 Jun 22  2018 tmp.mount
```

## Create filesystem

Now for the sake of this article I will create `/dev/sdb1` to demonstrate mount filesystem without fstab. 

```shell
[root@rhel-8 ~]# mkfs.ext4 /dev/sdb1
mke2fs 1.44.3 (10-July-2018)
Creating filesystem with 262144 4k blocks and 65536 inodes
Filesystem UUID: cea0757d-6329-4bf8-abbf-03f9c313b07f
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```

## Get UUID of the filesystem

To mount filesystem without fstab we will use [systemd](./../systemd/systemd-tutorial.md "systemd tutorial") unit file but instead of using filesystem/partition name, we will use UUID of the partition. I have shown two ways to get the UUID of the filesystem

```shell
[root@rhel-8 system]# ls -l /dev/disk/by-uuid/
total 0
lrwxrwxrwx. 1 root root  9 Sep 16 11:23 2019-04-04-08-40-23-00 -> ../../sr0
lrwxrwxrwx. 1 root root 10 Sep 16 11:23 2796b6a6-1080-4f7c-a902-b4438f071e6c -> ../../dm-4
lrwxrwxrwx. 1 root root 10 Sep 16 11:23 abf4aa90-0b58-499a-b601-bc5f208fd2cd -> ../../sda1
lrwxrwxrwx. 1 root root 10 Sep 16 11:46 cea0757d-6329-4bf8-abbf-03f9c313b07f -> ../../sdb1
lrwxrwxrwx. 1 root root 10 Sep 16 11:23 e6024940-527e-4a08-ac77-0e503b219d27 -> ../../dm-3
```

OR using blkid

```shell
[root@rhel-8 system]# blkid /dev/sdb1
/dev/sdb1: UUID="cea0757d-6329-4bf8-abbf-03f9c313b07f" TYPE="ext4" PARTUUID="0b051d7e-01"
```

## Sample systemd unit file to mount filesystem without fstab

Below I have created a sample [systemd](https://www.golinuxcloud.com/beginners-guide-systemd-tutorial-linux/ "systemd tutorial") mount file to mount `/dev/sdb1` on `/tmp_dir` mount point.

IMPORTANT NOTE:

Mount units must be named after the mount point directories they control. Example: the mount point `/home/lennart` must be configured in a unit file `home-lennart.mount`.

Here I have created my [systemd](https://www.golinuxcloud.com/beginners-guide-systemd-tutorial-linux/ "systemd tutorial") unit file as `tmp_dir.mount` since my mount point is `/tmp_dir`

```shell
[root@rhel-8 system]# cat tmp_dir.mount
#  This file is part of systemd.

[Unit]
Description=Test Directory (/tmp_dir)
DefaultDependencies=no
Conflicts=umount.target
Before=local-fs.target umount.target
After=swap.target

[Mount]
What=/dev/disk/by-uuid/cea0757d-6329-4bf8-abbf-03f9c313b07f
Where=/tmp_dir
Type=ext4
Options=defaults

[Install]
WantedBy=multi-user.target
```

Here,

```
What=
Takes an absolute path of a device node, file or other resource to mount. See mount(8) for details. If this refers to a device node, a dependency on the respective device unit is automatically created. This option is mandatory. Note that the usual specifier expansion is applied to this setting, literal percent characters should hence be written as "%%".

Where=
Takes an absolute path of a directory for the mount point; in particular, the destination cannot be a symbolic link. If the mount point does not exist at the time of mounting , it is created. This string must be reflected in the unit filename. (See above.) This option is mandatory.

Type=
Takes a string for the file system type. See mount(8) for details. This setting is optional.

Options=
Mount options to use when mounting. This takes a comma-separated list of options. This setting is optional. Note that the usual specifier expansion is applied to this setting, literal percent characters should hence be written as "%%".
```

The following dependencies are added unless `DefaultDependencies=no` is set:

-   All mount units acquire automatic `Before=` and `Conflicts=` on `umount.target` in order to be stopped during shutdown.
-   Mount units referring to local file systems automatically gain an `After=` dependency on `local-fs-pre.target`.
-   Network mount units automatically acquire `After=` dependencies on `remote-fs-pre.target`, `network.target` and `network-online.target`. Towards the latter a `Wants=` unit is added as well.

## Start the service (Mount filesystem without fstab)

Reload the daemon to refresh the [systemd](https://www.golinuxcloud.com/beginners-guide-systemd-tutorial-linux/ "systemd tutorial") changes

```shell
[root@rhel-8 system]# systemctl daemon-reload
```

## Mount filesystem (Start systemd service)

We are all set here. Next verify the status of this new mount service

```shell
[root@rhel-8 system]# systemctl show -p ActiveState -p SubState --value tmp_dir.mount
inactive
dead
```

Since the service is in-active state which means our filesystem is not mounted currently. So we will start our systemd service.

```shell
[root@rhel-8 system]# systemctl start tmp_dir.mount
```

Next verify the filesystem, as expected we could mount filesystem without fstab under `/tmp_dir`

```shell
[root@rhel-8 system]# df -h /tmp_dir/
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdb1       976M  2.6M  907M   1% /tmp_dir
```

Also as you see now our service is active

```shell
[root@rhel-8 system]# systemctl show -p ActiveState -p SubState --value tmp_dir.mount
active
mounted

[root@rhel-8 ~]# systemctl status tmp_dir.mount
● tmp_dir.mount - Test Directory (/tmp_dir)
   Loaded: loaded (/usr/lib/systemd/system/tmp_dir.mount; enabled; vendor preset: disabled)
   Active: active (mounted) since Mon 2019-09-16 19:01:09 IST; 10s ago
    Where: /tmp_dir
     What: /dev/sdb1
    Tasks: 0 (limit: 11517)
   Memory: 56.0K
   CGroup: /system.slice/tmp_dir.mount

Sep 16 19:01:09 rhel-8.example systemd[1]: Mounting Test Directory (/tmp_dir)...
Sep 16 19:01:09 rhel-8.example systemd[1]: Mounted Test Directory (/tmp_dir).
```

But our service is in disabled state which means post reboot, `/tmp_dir` will not be mounted by default

```shell
[root@rhel-8 ~]# systemctl is-enabled tmp_dir.mount
disabled
```

To prove this theory I will reboot my node. Post reboot as you see `/tmp_dir` is not mounted

```shell
[root@rhel-8 ~]# df -h /tmp_dir/
Filesystem             Size  Used Avail Use% Mounted on
/dev/mapper/rhel-root   15G  2.1G   12G  16% /
[root@rhel-8 ~]# df -h
Filesystem             Size  Used Avail Use% Mounted on
devtmpfs               900M     0  900M   0% /dev
tmpfs                  915M     0  915M   0% /dev/shm
tmpfs                  915M  8.5M  907M   1% /run
tmpfs                  915M     0  915M   0% /sys/fs/cgroup
/dev/mapper/rhel-root   15G  2.1G   12G  16% /
/dev/sda1              483M  258M  225M  54% /boot
tmpfs                  183M     0  183M   0% /run/user/0
```

Also the `tmp_dir` mount service is inactive

```shell
[root@rhel-8 ~]# systemctl show -p ActiveState -p SubState --value tmp_dir.mount
inactive
dead
```

So first let us enable the `tmp_dir` service so this filesystem can be mounted post reboot (persistent)

```shell
[root@rhel-8 system]# systemctl enable tmp_dir.mount
Created symlink /etc/systemd/system/multi-user.target.wants/tmp_dir.mount → /usr/lib/systemd/system/tmp_dir.mount.
```

Verify the status

```shell
[root@rhel-8 system]# systemctl is-enabled tmp_dir.mount
enabled
```

Next I will reboot the node again, post reboot as you see now systemd shows `tmp_dir` in the list of mounted filesystem so we were able to mount filesystem without fstab

```shell
[root@rhel-8 ~]# systemctl -t mount
UNIT                    LOAD   ACTIVE SUB     DESCRIPTION
-.mount                 loaded active mounted Root Mount
boot.mount              loaded active mounted /boot
dev-hugepages.mount     loaded active mounted Huge Pages File System
dev-mqueue.mount        loaded active mounted POSIX Message Queue File System
run-user-0.mount        loaded active mounted /run/user/0
sys-kernel-config.mount loaded active mounted Kernel Configuration File System
sys-kernel-debug.mount  loaded active mounted Kernel Debug File System
tmp_dir.mount           loaded active mounted Test Directory (/tmp_dir)

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.

8 loaded units listed. Pass --all to see loaded but inactive units, too.
To show all installed unit files use 'systemctl list-unit-files'.
```

Verify the `df` output, as expected our `tmp_dir` is in use by `/dev/sdb1`

```shell
[root@rhel-8 system]# df -h /tmp_dir
Filesystem             Size  Used Avail Use% Mounted on
/dev/sdb1              976M  2.6M  907M   1% /tmp_dir
```

I will continue to this article with [steps to auto-mount or auto-un-mount filesystem using systemd](https://www.golinuxcloud.com/automount-file-system-systemd-rhel-centos-7-8/ "How to automount file system using systemd unit file in CentOS/RHEL 7 & 8") and [steps to mount file system in a certain order (sequentially if required) using systemd and /etc/fstab with examples](https://www.golinuxcloud.com/mount-filesystem-in-certain-order-systemd/ "How to mount filesystem in certain order one after the other in CentOS/RHEL 7 & 8").

Lastly I hope the steps from the article to [mount filesystem without fstab](https://www.golinuxcloud.com/linux-mount-command-iso-usb-network-drive/) and using systemd unit files on Linux was helpful. So, let me know your suggestions and feedback using the comment section.

** Reference **

* https://www.golinuxcloud.com/mount-filesystem-without-fstab-systemd-rhel-8/
* [steps required to create filesystem](https://www.golinuxcloud.com/configure-software-linear-raid-linux/#Partitioning_with_fdisk "Step-by-Step Tutorial: Configure software Linear RAID 0 in Linux")
* 