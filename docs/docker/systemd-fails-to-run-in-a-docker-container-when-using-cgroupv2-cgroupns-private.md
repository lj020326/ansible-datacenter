
# Systemd fails to run in a docker container when using cgroupv2 (--cgroupns=private)

I will attach the minimized test case below. However, it is a simple Dockerfile that has these lines:

```Dockerfile
VOLUME ["/sys/fs/cgroup"]
CMD ["/lib/systemd/systemd"]
```

It is Debian:buster-slim based image, and runs systemd inside the container. Effectively, I used to run the container like this:

```shell
$ docker run  --name any --tmpfs /run \
    --tmpfs /run/lock --tmpfs /tmp \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro -it image_name
```

It used to work fine before I upgraded a bunch of host Linux packages. The host kernel/systemd now seems to default cgroup v2. Before, it was cgroup. It stopped working. However, if I give the kernel option so that the host uses cgroup, then it works again.

Without giving the kernel option, the fix was to add `--cgroupns=host` to `docker run` besides mounting `/sys/fs/cgroup` as read-write (`:rw` in place of `:ro`).

I'd like to avoid forcing the users to give the kernel option. Although I am far from an expert, forcing the host namespace for a docker container does not sound right to me.

I am trying to understand why this is happening, and figure out what should be done. My goal is to run systemd inside a docker, where the host follows cgroup v2.

Here's the error I am seeing:

```shell
$ docker run --name any --tmpfs /run --tmpfs /run/lock --tmpfs /tmp \
    -v /sys/fs/cgroup:/sys/fs/cgroup:rw -it image_name
systemd 241 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN2 +IDN -PCRE2 default-hierarchy=hybrid)
Detected virtualization docker.
Detected architecture x86-64.

Welcome to Debian GNU/Linux 10 (buster)!

Set hostname to <5e089ab33b12>.
Failed to create /init.scope control group: Read-only file system
Failed to allocate manager object: Read-only file system
[!!!!!!] Failed to allocate manager object.
Exiting PID 1...
```

It does not look right but especially this line seems suspicous:

```shell
Failed to create /init.scope control group: Read-only file system
```

It seems like there should have been something before `/init.scope`. That was why I reviewed the `docker run` options, and tried the `--cgroupsns` option. If I add the `--cgroupns=host`, it works. If I mount `/sys/fs/cgroup` as read-only, then it fails with a different error, and the corresponding line looks like this:

```shell
Failed to create /system.slice/docker-0be34b8ec5806b0760093e39dea35f4305262d276ecc5047a5f0ff43871ed6d0.scope/init.scope control group: Read-only file system
```

To me, it is like the docker daemon/engine fails to configure XXX.slice or something like that for the container. I assume that docker may be to some extend responsible for giving the namespace but something is not going well. However, I can't be so sure at all. What would be the issue/fix?

The Dockerfile I used for this experiment is as follows:

```Dockerfile
FROM debian:buster-slim

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

USER root
WORKDIR /root

RUN set -x

RUN apt-get update -y \
    && apt-get install --no-install-recommends -y systemd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -f /var/run/nologin

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
    /lib/systemd/system/systemd-update-utmp*

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/lib/systemd/systemd"]
```

I am using Debian. The docker version is 20.10.3 or so. Google search told me that docker supports cgroup v2 as of 20.10 but I don't actually understand what that "support" means.

## Solution 1

### tl;dr

It seems to me that this _use case is not explicitly supported yet_. You can almost get it working but not quite.

### The root cause

When systemd sees a _unified cgroupfs_ at `/sys/fs/cgroup` it assumes _it should be able to write to it_ which normally should be possible but is not the case here.

### The basics

First of all, you need to create a [**systemd slice**](https://www.freedesktop.org/software/systemd/man/systemd.slice.html) for docker containers and tell docker to use it - my current `docker/daemon.json`:

```json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "features": { "buildkit": true },
  "experimental": true,
  "cgroup-parent": "docker.slice"
}
```

> **Note:** Not all of these options are necessary. The most important one is `cgroup-parent`. The `cgroupdriver` should already be switched to "systemd' by default.

Each slice gets its own nested cgroup. There is one caveat though: Each group might only be a "leaf" or "intermediary". Once a process takes ownershop of a cgroup no other can manage it. This means that the actual container process needs and will get its own _private_ group attached below the configured one in the form of a [**systemd scope**](https://www.freedesktop.org/software/systemd/man/systemd.scope.html).

> **Reference:** Please find more about [systemd resource control](https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#), handling of [cgroup namespaces](https://man7.org/linux/man-pages/man7/cgroup_namespaces.7.html) and [delegation](https://systemd.io/CGROUP_DELEGATION/).

> **Note:** A this point docker daemon should use `--cgroupns private` by default, but you can force it anyway.

Now a newly started container **will get its own group** which should be available in a path that (depending on your setup) resembles:

```
/sys/fs/cgroup/your_docker_parent.slice/your_container.scope
```

And here is the important part: **You must not mount a volume into container's `/sys/fs/cgroup`**. The path to its private group mentioned above should get mounted there automatically.

### The goal

Now, in theory, the container should be able to manage this delegated, private group by itself almost fully. This would allow its own init process to create child groups.

### The problem

The problem is that the `/sys/fs/cgroup` path in the container gets mounted **read-only**. I've checked apparmor rules and switched seccomp to unconfined to no avail.

### The hypothesis

I am not completely certain yet - my current hypothesis is that this is a security feature of docker/moby/containerd. Without private groups it makes perfect sense to mount this path `ro`.

### Potential solutions

What I've also discovered is that enabling [user namespace remapping](https://docs.docker.com/engine/security/userns-remap/) causes the private `/sys/fs/cgroup` to be mounted with `rw` as expected!

This is far from perfect though - the **cgroup (among others) mount has wrong ownership**: it's owned by the real system root (UID0) while the container has been remapped to a completely different user. Once I've manually adjusted the owner - the container was able to start a systemd init sucessfully.

I _suspect_ this is a deficiency of docker's userns remapping feature and might be fixed sooner or later. _Keep in mind that I might be wrong about this - I did not confirm._

### Discussion

Userns remapping has got a lot of drawbacks and the best possible scenario for me would be to get the cgroupfs mounted `rw` without it. I still don't know if this is done on purpose or if it's some kind of limitation of the cgroup/userns implementation.

### Notes

It's not enough that your kernel has cgroupv2 enabled. Depending on the linux distribution bundled systemd might prefer to use v1 by default.

You can tell systemd to use cgroupv2 via kernel cmdline parameter:  
`systemd.unified_cgroup_hierarchy=1`

It might also be needed to explictly disable _hybrid_ cgroupv1 support to avoid problems using: `systemd.legacy_systemd_cgroup_controller=0`

Or completely disable cgroupv1 in the kernel with: `cgroup_no_v1=all`

## Solution 2

Here is a Dockerfile and command line, it works fine. I hope this helps:

```Dockerfile
FROM debian:bullseye
# Using systemd in docker: https://systemd.io/CONTAINER_INTERFACE/
# Make sure cgroupv2 is enabled. To check this: cat /sys/fs/cgroup/cgroup.controllers
ENV container docker
STOPSIGNAL SIGRTMIN+3
VOLUME [ "/tmp", "/run", "/run/lock" ]
WORKDIR /
# Remove unnecessary units
RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
  /etc/systemd/system/*.wants/* \
  /lib/systemd/system/local-fs.target.wants/* \
  /lib/systemd/system/sockets.target.wants/*udev* \
  /lib/systemd/system/sockets.target.wants/*initctl* \
  /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
  /lib/systemd/system/systemd-update-utmp*
CMD [ "/lib/systemd/systemd", "log-level=info", "unit=sysinit.target" ]
```

```shell
$ docker build -t systemd_test .
$ docker run -t --rm --name systemd_test \
  --privileged --cap-add SYS_ADMIN --security-opt seccomp=unconfined \
  --cgroup-parent=docker.slice --cgroupns private \
  --tmpfs /tmp --tmpfs /run --tmpfs /run/lock \
  systemd_test
```

Note: you MUST use Docker 20.10 or above, and your system enabled cgroupv2 (check if /sys/fs/cgroup/cgroup.controllers) exists.

### Solution 3 (Tested on MacOS)

It's interesting to notice that with docker desktop for Mac 4.13.1 this Dockerfile works:

```Dockerfile
FROM debian:bullseye

VOLUME [ "/tmp", "/run", "/run/lock" ]

RUN apt-get update && apt-get install -y systemd bash && apt-get clean && mkdir -p /lib/systemd && ln -s /lib/systemd/system /usr/lib/systemd/system;

WORKDIR /

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
  /etc/systemd/system/*.wants/* \
  /lib/systemd/system/local-fs.target.wants/* \
  /lib/systemd/system/sockets.target.wants/*udev* \
  /lib/systemd/system/sockets.target.wants/*initctl* \
  /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
  /lib/systemd/system/systemd-update-utmp*

CMD [ "/lib/systemd/systemd" ]
```

With just:

```shell
$ docker build . -t debiansys
$ docker run --rm -it --privileged debiansys
```

## Reference

* https://serverfault.com/questions/1053187/systemd-fails-to-run-in-a-docker-container-when-using-cgroupv2-cgroupns-priva
* https://access.redhat.com/discussions/6029491
* https://serverfault.com/questions/936985/cannot-use-systemctl-user-due-to-failed-to-get-d-bus-connection-permission
* https://askubuntu.com/questions/1007055/systemctl-edit-problem-failed-to-connect-to-bus
* https://stackoverflow.com/questions/49285658/how-to-solve-docker-issue-failed-to-connect-to-bus-no-such-file-or-directory
* https://abdennoor.medium.com/finally-systemd-is-running-in-redhat-centos-containers-3d9598d26976
* https://github.com/moby/moby/issues/30723
* https://developers.redhat.com/blog/2014/05/05/running-systemd-within-docker-container
* https://stackoverflow.com/questions/64753019/rootless-podman-with-systemd-in-ubi8-container-on-rhel8-not-working
* https://www.ansible.com/blog/developing-and-testing-ansible-roles-with-molecule-and-podman-part-1
* https://www.jeffgeerling.com/blog/2018/testing-your-ansible-roles-molecule
* https://molecule.readthedocs.io/en/latest/getting-started.html
* 
