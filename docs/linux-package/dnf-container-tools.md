
# Handle issues with dnf install of container-tools

```shell
$ dnf module list container-tools
Red Hat Enterprise Linux 8 for x86_64 - AppStream (RPMs)
Name            Stream    Profiles   Summary                                                                                                                                                                                                                                   
container-tools rhel8 [d] common [d] Most recent (rolling) versions of podman, buildah, skopeo, runc, conmon, runc, conmon, CRIU, Udica, etc as well as dependencies such as container-selinux built and tested together, and updated as frequently as every 12 weeks.         
container-tools 1.0       common [d] Stable versions of podman 1.0, buildah 1.5, skopeo 0.1, runc, conmon, CRIU, Udica, etc as well as dependencies such as container-selinux built and tested together, and supported for 24 months.                                          
container-tools 2.0       common [d] Stable versions of podman 1.6, buildah 1.11, skopeo 0.1, runc, conmon, etc as well as dependencies such as container-selinux built and tested together, and supported as documented on the Application Stream lifecycle page.             
container-tools 3.0       common [d] Stable versions of podman 3.0, buildah 1.19, skopeo 1.2, runc, conmon, CRIU, Udica, etc as well as dependencies such as container-selinux built and tested together, and supported as documented on the Application Stream lifecycle page.
container-tools 4.0       common [d] Stable versions of podman 4.0, buildah 1.24, skopeo 1.6, runc, conmon, CRIU, Udica, etc as well as dependencies such as container-selinux built and tested together, and supported as documented on the Application Stream lifecycle page.

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
$ 
$ dnf module enable container-tools 
## OR specify the specific package stream to enable
$ dnf module enable container-tools:rhel8

```

