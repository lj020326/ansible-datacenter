
# Unable to run systemd services on Docker Desktop 4.3.0

unable-to-run-systemd-services-on-docker-desktop-4.3.0

- I have tried with the latest version of Docker Desktop
- I have tried disabling enabled experimental features
- I have uploaded Diagnostics
- Diagnostics ID:

### Expected behavior

Systemd based services in containers should start, as they have always been doing in x86 computers

### Actual behavior

Systemd based services in containers do not start on M1 / Silicon computers.

### Information

Hi

I've recently been given a new M1 MBP laptop where I'm trying to run a docker image with systemd that we use as part of our CI build, but I'm not able to start it successfully. We have been building and running these containers in x86 MBP for years with success, so this seems to a platform specific issue with the new M1.

-   macOS Version: Monterey 12.0.1
-   Intel chip or Apple chip: Apple chip
-   Docker Desktop Version: 4.3.0 (71786)

### Steps to reproduce the behavior

Following the instructions at [https://hub.docker.com/\_/centos](https://hub.docker.com/_/centos) I've created a Centos Systemd ready container with the following Dockerfile:

```
FROM centos:7
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
```

However, when running it I get the following error:

```
$ docker run --rm  -ti --privileged -v /sys/fs/cgroup:/sys/fs/cgroup local/c7-systemd
Failed to insert module 'autofs4'
Failed to mount cgroup at /sys/fs/cgroup/systemd: Operation not permitted
systemd 219 running in system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 -SECCOMP +BLKID +ELFUTILS +KMOD +IDN)
Detected virtualization docker.
Detected architecture arm64.

Welcome to CentOS Linux 7 (AltArch)!

Set hostname to <6870484659ce>.
Initializing machine ID from random generator.
Cannot determine cgroup we are running in: No such file or directory
Failed to allocate manager object: No such file or directory
[!!!!!!] Failed to allocate manager object, freezing.
```

I've tried to use the `DOCKER_DEFAULT_PLATFORM=linux/amd64` environment variable as well, but the output and behavior is mostly the same.

```
$ docker run --rm  -ti --privileged -v /sys/fs/cgroup:/sys/fs/cgroup local/c7-systemd
Failed to insert module 'autofs4'
Failed to mount cgroup at /sys/fs/cgroup/systemd: Operation not permitted
systemd 219 running in system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 -SECCOMP +BLKID +ELFUTILS +KMOD +IDN)
Detected virtualization docker.
Detected architecture x86-64.

Welcome to CentOS Linux 7 (Core)!

Set hostname to <a2561af401fb>.
Initializing machine ID from random generator.

Failed to configure loopback device: Connection timed out
Cannot determine cgroup we are running in: No such file or directory
Failed to allocate manager object: No such file or directory
[!!!!!!] Failed to allocate manager object, freezing.
```

Some unsuccessful attempts I've done:

-   different combinations of the `privileged` setting and `/sys/fs/cgroup`mounts
-   adding tmpfs settings, as suggested at [https://stackoverflow.com/questions/36617368/docker-centos-7-with-systemctl-failed-to-mount-tmpfs-cgroup](https://stackoverflow.com/questions/36617368/docker-centos-7-with-systemctl-failed-to-mount-tmpfs-cgroup)
-   tweak the cgroups settings `"exec-opts": ["native.cgroupdriver=systemd"], "cgroup-parent": "docker.slice"`, as suggested at [https://serverfault.com/questions/1053187/systemd-fails-to-run-in-a-docker-container-when-using-cgroupv2-cgroupns-priva](https://serverfault.com/questions/1053187/systemd-fails-to-run-in-a-docker-container-when-using-cgroupv2-cgroupns-priva)

Is there anything that can be done to overcome this issue?

## Solution works on my workstation

Figured I'd share since I took the time to write this. Here's a **fix for MacOS** you can paste into your terminal:

```shell
# Stop running Docker
test -z "$(docker ps -q 2>/dev/null)" && osascript -e 'quit app "Docker"'
# Install jq and moreutils so we can merge into the existing json file
brew install jq moreutils
# Add the needed cgroup config to docker settings.json
echo '{"deprecatedCgroupv1": true}' | \
  jq -s '.[0] * .[1]' ~/Library/Group\ Containers/group.com.docker/settings.json - | \
  sponge ~/Library/Group\ Containers/group.com.docker/settings.json
# Restart docker desktop
open --background -a Docker
```

## Reference

* https://github.com/docker/for-mac/issues/6073
