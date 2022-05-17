
How to mount filesystem in specified order using systemd
===

- [Systemd Unit File Locations](#Systemd_Unit_File_Locations "Systemd Unit File Locations")
- [Mount filesystem in certain order using systemd](#Mount_filesystem_in_certain_order_using_systemd "Mount filesystem in certain order using systemd")
    -   [Get UUID of the filesystem](#Get_UUID_of_the_filesystem "Get UUID of the filesystem")
    -   [Sample systemd unit file](#Sample_systemd_unit_file "Sample systemd unit file")
    -   [Verification of the steps with examples](#Verification_of_the_steps_with_examples "Verification of the steps with examples")
- [Mount filesystem in certain order using /etc/fstab](#Mount_filesystem_in_certain_order_using_etcfstab "Mount filesystem in certain order using /etc/fstab")
    -   [Sample /etc/fstab content](#Sample_etcfstab_content "Sample /etc/fstab content")
    -   [Verify the changes](#Verify_the_changes "Verify the changes")
- [Analyze System Manager](#Analyze_System_Manager "Analyze System Manager")

Now since we learned to [mount](https://www.golinuxcloud.com/mount-filesystem-without-fstab-systemd-rhel-8/ "How to mount filesystem without fstab using systemd (CentOS/RHEL 7/8)") and [automount](https://www.golinuxcloud.com/automount-file-system-systemd-rhel-centos-7-8/ "How to automount file system using systemd unit file in CentOS/RHEL 7 & 8") file system using systemd unit file (without using `/etc/fstab`), let us continue our knowledge gathering on similar topic. Here in this article I will explain the steps to mount filesystem in certain order using systemd unit file as well as with fstab file.

With the introduction of [systemd](./../systemd/systemd-tutorial.md "systemd tutorial") in RHEL 7 the boot process has become a lot faster because many services and processes are now started in parallel.

One of those consequences is the lack of consistent order in which filesystems are mounted. Their order for mounting is no longer guaranteed based on the entries in `/etc/fstab`. Filesystems are now just another systemd unit. Because [systemd](./../systemd/systemd-tutorial.md "systemd tutorial") defaults to parallel units execution process startup, specific target units startup order is not consistent.

# How to mount filesystem in certain order one after the other in CentOS/RHEL

In RHEL 7 and 8, [systemd](./../systemd/systemd-tutorial.md "systemd tutorial") handles the mount order, and not the order of mount entries in `/etc/fstab`. Hence, the order of entries in `/etc/fstab` need not be the same in which they are mounted in RHEL 7.

## Systemd Unit File Locations

[systemd](./../systemd/systemd-tutorial.md "systemd tutorial") introduces the concept of systemd units. These units are represented by unit configuration files located in one of the directories listed in the following table.

## Mount filesystem in certain order using systemd

Now to demonstrate this article to mount filesystem in certain order I will create two filesystems

```
/dev/sdb2 -> Mounted on /first_part -> Mapped with first_part.mount unit file
/dev/sdc1 -> Mounted on /second_part -> Mapped with second_part.mount unit file
```

We will make sure that if `first_part.mount` is called before second\_part.mount while the system boots so we know that we can mount filesystem in certain order.

### Get UUID of the filesystem

Before we start we need the UUID of both the filesystem to configure our systemd unit file to mount filesystem in certain order.

```
[root@rhel-8 system]# ls -l /dev/disk/by-uuid/*
lrwxrwxrwx. 1 root root  9 Sep 16 15:09 /dev/disk/by-uuid/2019-04-04-08-40-23-00 -> ../../sr0
lrwxrwxrwx. 1 root root 10 Sep 16 15:09 /dev/disk/by-uuid/2796b6a6-1080-4f7c-a902-b4438f071e6c -> ../../dm-4
lrwxrwxrwx. 1 root root 10 Sep 16 15:09 /dev/disk/by-uuid/3f46ad95-0d39-4f56-975d-2e61fc26230b -> ../../sdc1
lrwxrwxrwx. 1 root root 10 Sep 16 18:25 /dev/disk/by-uuid/716664b6-1475-4c11-9297-5920bb4f0677 -> ../../sdb2
lrwxrwxrwx. 1 root root 10 Sep 16 15:09 /dev/disk/by-uuid/abf4aa90-0b58-499a-b601-bc5f208fd2cd -> ../../sda1
lrwxrwxrwx. 1 root root 10 Sep 16 17:09 /dev/disk/by-uuid/cea0757d-6329-4bf8-abbf-03f9c313b07f -> ../../sdb1
lrwxrwxrwx. 1 root root 10 Sep 16 15:09 /dev/disk/by-uuid/e6024940-527e-4a08-ac77-0e503b219d27 -> ../../dm-3
```

OR you can use `blkid` command

```
[root@rhel-8 system]# blkid /dev/sdb2
/dev/sdb2: UUID="716664b6-1475-4c11-9297-5920bb4f0677" TYPE="ext4" PARTUUID="0b051d7e-02"

[root@rhel-8 system]# blkid /dev/sdc1
/dev/sdc1: UUID="3f46ad95-0d39-4f56-975d-2e61fc26230b" TYPE="ext4" PARTUUID="65a7b241-01"
```

### Sample systemd unit file

Below is my systemd unit file for first partition

```
[root@rhel-8 system]# pwd
/usr/lib/systemd/system
```

```
[root@rhel-8 system]# cat first_part.mount
[Unit]
Description=Test Directory (/first_part)
DefaultDependencies=no
Conflicts=umount.target
Before=local-fs.target umount.target
After=swap.target

[Mount]
What=/dev/disk/by-uuid/716664b6-1475-4c11-9297-5920bb4f0677
Where=/first_part
Type=ext4
Options=defaults

[Install]
WantedBy=multi-user.target
```

Below is my systemd unit file for second partition.

```
[root@rhel-8 system]# pwd
/usr/lib/systemd/system
```

```
[root@rhel-8 system]# cat second_part.mount
#  This file is part of systemd.

[Unit]
Description=Test Directory (/second_part)
DefaultDependencies=no
Conflicts=umount.target
Before=local-fs.target umount.target
RequiresMountsFor=/first_part

[Mount]
What=/dev/disk/by-uuid/3f46ad95-0d39-4f56-975d-2e61fc26230b
Where=/second_part
Type=ext4
Options=defaults,x-systemd.requires-mounts-for=/first_part

[Install]
WantedBy=multi-user.target
```

Here,

```
RequiresMountsFor=
    Takes a space-separated list of absolute paths. Automatically adds dependencies of type Requires= and After= for all mount units required to access the specified path.

x-systemd.requires-mounts-for=
    Configures a RequiresMountsFor= dependency between the created mount unit and other mount units. The argument must be an absolute path. This option may be specified more than once.
```

All other parameters are explained under this article.

NOTE:

If a mount point is beneath another mount point in the file system hierarchy, a dependency between both units is created automatically so you don't need to create a `Requires` and `After` entry for `/test/test1` to mount only after `/test` exists and is mounted.

It is important that you reload the systemd daemon after creating these systemd unit file or after every modification you do in these files

```
[root@rhel-8 system]# systemctl daemon-reload
```

### Verification of the steps with examples

Now we are all done with our configuration to mount filesystem in certain order one after the other using systemd unit file. At this moment as you see none of our filesystems from this article are in mounted state.

```
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

Let us start our first filesystem mount service

```
[root@rhel-8 system]# systemctl start first_part.mount
```

As expected `/first_part` is now mounted but `/second_part` is not yet mounted

```
[root@rhel-8 system]# df -h | grep part
/dev/sdb2              976M  2.6M  907M   1% /first_part
```

Similarly if we stop the first\_mount service then `/first_part` will be un-mounted as expected

```
[root@rhel-8 system]# systemctl stop first_part.mount
```

We get a blank output for this command which is expected

```
[root@rhel-8 system]# df -h | grep part
```

here at this stage `first_part.mount` is in-active/dead

```
[root@rhel-8 system]# systemctl show -p ActiveState -p SubState --value first_part.mount
inactive
dead
```

Now let us start the `second_part.mount` service

```
[root@rhel-8 system]# systemctl start second_part.mount
```

Here as you see we were able to mount filesystem in certain order. Once we trigerred start of `second_part.mount`, it first mounted `/first_part` followed by mounting `/second_part` as we had planned.

Output from `/var/log/messages`

```
Sep 17 02:57:53 rhel-8.example systemd[1]: Mounting Test Directory (/first_part)...
Sep 17 02:57:53 rhel-8.example kernel: EXT4-fs (sdb2): mounted filesystem with ordered data mode. Opts: (null)
Sep 17 02:57:53 rhel-8.example systemd[1]: Mounted Test Directory (/first_part).
Sep 17 02:57:53 rhel-8.example systemd[1]: Mounting Test Directory (second_partition)...
Sep 17 02:57:53 rhel-8.example kernel: EXT4-fs (sdc1): mounted filesystem with ordered data mode. Opts: (null)
Sep 17 02:57:53 rhel-8.example systemd[1]: Mounted Test Directory (second_partition).
```

Verify the same using `df` command

```
[root@rhel-8 system]# df -h | grep part
/dev/sdb2              976M  2.6M  907M   1% /first_part
/dev/sdc1              976M  2.6M  907M   1% /second_part
```

Enable both the [systemd](./../systemd/systemd-tutorial.md "systemd tutorial") unit service to make the changes persistent across reboots

```
[root@rhel-8 system]# systemctl enable first_part.mount
[root@rhel-8 system]# systemctl enable second_part.mount
```

## Mount filesystem in certain order using /etc/fstab

You can also mount filesystem in certain order using traditional `/etc/fstab` file.

### Sample /etc/fstab content

Add the filesystem and mount information depending upon your environment in `/etc/fstab` as added for my usecase where I have two filesystems

```
[root@rhel-8 ~]# cat /etc/fstab
/dev/mapper/rhel-root   /                       ext4    defaults        1 1
UUID=abf4aa90-0b58-499a-b601-bc5f208fd2cd /boot                   xfs     defaults        0 0
/dev/mapper/rhel-swap   swap                    swap    defaults        0 0
UUID=716664b6-1475-4c11-9297-5920bb4f0677       /first_part     ext4    defaults        0 0
UUID=3f46ad95-0d39-4f56-975d-2e61fc26230b       /second_part    ext4    defaults,x-systemd.requires-mounts-for=/first_part      0 0
```

Now save and exit the file.

Since we already had created our systemd service to mount filesystem in certain order, we will disable those services so that we can verify the changes from `/etc/fstab`

```
[root@rhel-8 system]# systemctl disable --now second_part.mount
[root@rhel-8 system]# systemctl disable --now first_part.mount
```

This will stop the service and disable it for upcoming reboots.

### Verify the changes

Next reboot the node and verify the changes

```
[root@rhel-8 system]# reboot
login as: root
root@127.0.0.1's password:
Last login: Tue Sep 17 03:12:05 2019 from 10.0.2.2
```

We will check if our filesystem is mounted

```
[root@rhel-8 ~]# df -h | grep part
/dev/sdb2              976M  2.6M  907M   1% /first_part
/dev/sdc1              976M  2.6M  907M   1% /second_part
```

So our `/etc/fstab` changes are working as expected.

Since we are using `fstab` to perform these changes, systemd will create a service unit file for individual `fstab` entries inside `/run/systemd/generator/`

To list the systemd mount files loaded as per their order we can run below command

```
[root@rhel-8 ~]# ls -lt /run/systemd/generator/
total 20
-rw-r--r--. 1 root root 254 Sep 17 03:16  boot.mount
-rw-r--r--. 1 root root 230 Sep 17 03:16 'dev-mapper-rhelx2dswap.swap'
-rw-r--r--. 1 root root 261 Sep 17 03:16  first_part.mount
drwxr-xr-x. 2 root root 120 Sep 17 03:16  local-fs.target.requires
drwxr-xr-x. 2 root root  60 Sep 17 03:16  local-fs.target.wants
-rw-r--r--. 1 root root 218 Sep 17 03:16  -.mount
-rw-r--r--. 1 root root 351 Sep 17 03:16  second_part.mount
drwxr-xr-x. 2 root root  60 Sep 17 03:16  swap.target.requires
```

The systemd generated mount unit file will look similar to what we had created earlier in this article

```
[root@rhel-8 generator]# cat second_part.mount
# Automatically generated by systemd-fstab-generator

[Unit]
SourcePath=/etc/fstab
Documentation=man:fstab(5) man:systemd-fstab-generator(8)
Before=local-fs.target
RequiresMountsFor=/first_part

[Mount]
Where=/second_part
What=/dev/disk/by-uuid/3f46ad95-0d39-4f56-975d-2e61fc26230b
Type=ext4
Options=defaults,x-systemd.requires-mounts-for=/first_part
```

To [list all the mount points](https://www.golinuxcloud.com/show-nfs-shares-list-nfs-client-mount-points/ "SHOW NFS SHARES | LIST NFS MOUNT POINTS | LIST NFS CLIENTS LINUX") which are currently loaded and active

```
[root@rhel-8 ~]# systemctl -t mount
UNIT                    LOAD   ACTIVE SUB     DESCRIPTION
-.mount                 loaded active mounted Root Mount
boot.mount              loaded active mounted /boot
dev-hugepages.mount     loaded active mounted Huge Pages File System
dev-mqueue.mount        loaded active mounted POSIX Message Queue File System
first_part.mount        loaded active mounted /first_part
run-user-0.mount        loaded active mounted /run/user/0
second_part.mount       loaded active mounted /second_part
sys-kernel-config.mount loaded active mounted Kernel Configuration File System
sys-kernel-debug.mount  loaded active mounted Kernel Debug File System

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.

9 loaded units listed. Pass --all to see loaded but inactive units, too.
To show all installed unit files use 'systemctl list-unit-files'.
```

## Analyze System Manager

We can also get more information on the chain used by such mount related systemd unit file. As you see, my `second_part.mount` shows the chain it will follow while bringing up the service.

HINT:

A reboot is required after configuring the systemd service to get the chain details

```
[root@rhel-8 ~]# systemd-analyze critical-chain second_part.mount
The time after the unit is active or started is printed after the "@" character.
The time the unit takes to start is printed after the "+" character.

second_part.mount +22ms
└─first_part.mount @939ms +42ms
  └─swap.target @938ms
    └─dev-mapper-rhelx2dswap.swap @819ms +95ms
      └─dev-mapper-rhelx2dswap.device
```

For more information you can follow the [man page of systemd.mount](https://www.freedesktop.org/software/systemd/man/systemd.mount.html)

```
[root@rhel-8 ~]# man systemd.mount
```

Lastly I hope the steps from the article to [mount filesystem](https://www.golinuxcloud.com/linux-mount-command-iso-usb-network-drive/) in certain order one after the other on CentOS/RHEL 7 and 8 Linux was helpful. So, let me know your suggestions and feedback using the comment section.