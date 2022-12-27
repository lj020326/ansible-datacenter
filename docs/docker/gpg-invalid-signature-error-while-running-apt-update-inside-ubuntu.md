
# GPG invalid signature error while running apt update inside arm32v7/ubuntu:20.04 docker

## Question

I am trying to upgrade from ubuntu16 to ubuntu20 and for that I need to change image `arm32v7/ubuntu:16.04` to `arm32v7/ubuntu:20.04` in all our Dockerfiles \[update required libraries after that\], But while working on this task I found that there's some issue with arm32v7 base image of ubuntu:20.04 - when I run `apt-get update` it fails with following error messages-

```shell
Err:1 http://ports.ubuntu.com/ubuntu-ports focal InRelease
  At least one invalid signature was encountered.
Get:4 http://ports.ubuntu.com/ubuntu-ports focal-security InRelease [107 kB]
Err:2 http://ports.ubuntu.com/ubuntu-ports focal-updates InRelease
  At least one invalid signature was encountered.
Err:3 http://ports.ubuntu.com/ubuntu-ports focal-backports InRelease
  At least one invalid signature was encountered.
Err:4 http://ports.ubuntu.com/ubuntu-ports focal-security InRelease
  At least one invalid signature was encountered.
Reading package lists... Done
W: GPG error: http://ports.ubuntu.com/ubuntu-ports focal InRelease: At least one invalid signature was encountered.
E: The repository 'http://ports.ubuntu.com/ubuntu-ports focal InRelease' is not signed.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
N: See apt-secure(8) manpage for repository creation and user configuration details.
W: GPG error: http://ports.ubuntu.com/ubuntu-ports focal-updates InRelease: At least one invalid signature was encountered.
E: The repository 'http://ports.ubuntu.com/ubuntu-ports focal-updates InRelease' is not signed.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
```

I tried the solution mentioned [here](https://askubuntu.com/a/1264921/872700) but that too is not working as we are using the image in Dockerfile and its not allowed to pass `--security-opt` in `docker build` command.

As a workaround I ran `docker run` with `--security-opt` option and created another image with `docker commit` - then ran `apt-get update` inside new image but that too is not working.

FYI, The machine has the following docker version on it- `Docker version 19.03.13, build 4484c46`

### Comments

-   checkout duplicate on askubuntu [apt update throws signature error in ubuntu 20 04 container on arm](https://askubuntu.com/questions/1263284/apt-update-throws-signature-error-in-ubuntu-20-04-container-on-arm)
    
-   same issue occurred with php8 docker container

## Solution

I had this issue on Docker Desktop for Mac recently, running `apt-get update` in an Ubuntu 20.04 x86_64 container. It turned out the VM hosting the Docker images on macOS had run out of disk space. That somehow manifested itself as `apt` reporting invalid signatures on package index files. Pruning unused images to free space solved the issue for me:

> docker image prune -a

As mentioned in [comment](https://stackoverflow.com/questions/64439278/gpg-invalid-signature-error-while-running-apt-update-inside-arm32v7-ubuntu20-04/64553153#comment116083404_64553153) by [sema](https://stackoverflow.com/users/343314/sema), if the issue is caused by insufficient disk space, another workaround is to increase the size of the virtual disk used by the virtual machine that is running docker. In Docker Desktop for Mac this can be done via `Preferences > Resources > Disk image size`.

## Reference

- https://stackoverflow.com/questions/64439278/gpg-invalid-signature-error-while-running-apt-update-inside-arm32v7-ubuntu20-04
- 