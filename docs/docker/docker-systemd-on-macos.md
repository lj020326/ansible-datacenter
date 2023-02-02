
# Usage

## MacOS 

I don't think that this is an M1 issue. I see something similar on an Intel Macbook when trying to run the official Ubuntu:18.04 image on 4.3.0.

From my docker compose log:

```output
heimdall_api          | Failed to insert module 'autofs4': No such file or directory
heimdall_api          | systemd 237 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN2 +IDN -PCRE2 default-hierarchy=hybrid)
heimdall_api          | Detected virtualization docker.
heimdall_api          | Detected architecture x86-64.
heimdall_api          |
heimdall_api          | Welcome to Ubuntu 18.04.6 LTS!
heimdall_api          |
heimdall_api          | Set hostname to <28176e1eef6a>.
heimdall_api          | Failed to create /init.scope control group: Read-only file system
heimdall_api          | Failed to allocate manager object: Read-only file system
heimdall_api          | [!!!!!!] Failed to allocate manager object, freezing.
heimdall_api          | Freezing execution.
```

Dropping back to Docker Desktop 4.2.0 fixes the issue. I assume that it's related to the note in the 4.3.0 release notes:

```
Docker Desktop now uses cgroupv2. If you need to run systemd in a container then:
* Ensure your version of systemd supports cgroupv2. It must be at least systemd 247. Consider upgrading any centos:7 images to centos:8.
* Containers running systemd need the following options: --privileged --cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw.
```

Test Successfully on MacOS:
```shell
$ docker run \
       --name systemd-ubuntu \
       --privileged \
       --cgroupns=host \
       -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
       --tmpfs /run \
       --tmpfs /tmp \
       -d \
       jrei/systemd-ubuntu:22.04

$ docker exec -it systemd-ubuntu bash
root@05e98d7df57a:/# systemctl is-system-running
running
root@05e98d7df57a:/# 
```


If so, though, it's going to break a bunch of people on older images.

## Alternative

To run _systemd_ in an unprivileged container a few manual tweaks are currently necessary. Remember to replace `/tmp` in following commands to a non-world-readable directory.

First it depends on the _cgroups_ directory, at least it needs read-only access to `cgroup name=systemd` hierarchy (in `/sys/fs/cgroup/systemd`). Lets prepare **one for all** _ubuntu-systemd_ containers:

```bash
$ mkdir -p /tmp/cgroup/systemd && mount -t cgroup systemd /tmp/cgroup/systemd -o ro,noexec,nosuid,nodev,none,name=systemd

# or alternatively:
$ mkdir -p /tmp/cgroup/systemd && mount --bind /sys/fs/cgroup/systemd /tmp/cgroup/systemd
```

Next it needs _tmpfs_ mount points in `/run` and `/run/lock`. This needs to be prepared **separately for each** _ubuntu-systemd_ container:

```bash
$ mkdir /tmp/run && mount -t tmpfs tmpfs /tmp/run
$ mkdir /tmp/run/lock && mount -t tmpfs tmpfs /tmp/run/lock
```

You could also add all mount points permanently to your `/etc/fstab`:

```
systemd  /tmp/cgroup/systemd  cgroup  ro,noexec,nosuid,nodev,none,name=systemd  0  0
tmpfs  /tmp/run  tmpfs  nodev,nosuid,mode=755,size=65536k  0  0
tmpfs  /tmp/run/lock  tmpfs  nodev,nosuid,mode=755,size=65536k  0  0
```

Then you are **ready to use** your _Docker_ container:

```bash
$ docker run -d --name xxx -v /tmp/cgroup:/sys/fs/cgroup:ro -v /tmp/run:/run:rw tozd/ubuntu-systemd
$ docker exec -it xxx /bin/bash
```

Please note that **graceful stopping** and removal of the _Docker_ container looks a little different now:

```bash
$ docker kill --signal SIGPWR xxx && docker stop xxx

$ docker rm -f xxx
$ umount /tmp/run/lock /tmp/run && rmdir /tmp/run
$ umount /tmp/cgroup/systemd && rmdir /tmp/cgroup/systemd /tmp/cgroup
```

## Reference

* https://github.com/docker/for-mac/issues/6073
* https://developers.redhat.com/blog/2016/09/13/running-systemd-in-a-non-privileged-container#enter_oci_hooks
* https://serverfault.com/questions/1053187/systemd-fails-to-run-in-a-docker-container-when-using-cgroupv2-cgroupns-priva
* https://ilhicas.com/2018/08/20/Using-molecule-with-docker.html
* https://github.com/ansible-community/molecule-docker/pull/166
* https://github.com/ansible-community/molecule/pull/3665
* https://medium.com/@TomaszKlosinski/testing-ansible-role-of-a-systemd-based-service-using-molecule-and-docker-4b3608a10ef0
* https://github.com/docker/for-mac/issues/6073
* https://github.com/moby/moby/issues/30723
* https://hub.docker.com/r/tozd/ubuntu-systemd/#!
* 