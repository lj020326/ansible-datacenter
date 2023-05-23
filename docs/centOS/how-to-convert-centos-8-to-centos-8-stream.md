
# How to convert CentOS 8 to CentOS 8 Stream

If you’ve been paying attention, you know all about what’s been going down with CentOS. Because of that, you’re probably concerned about all those CentOS servers you have on your network. Since those servers probably power a number of services to your backend, that concern is legitimate.

However, if you’re not up to speed on the CentOS drama, let me give you the 15 second commercial version of the news:

-   Red Hat decided to stop supporting the standard release version of CentOS
    
-   In CentOS’s place will be the rolling release version CentOS Stream
    
-   The Linux community is up in arms
    

There, you’re caught up.

Although the rolling release candidate may not please everyone, CentOS Stream is still a viable option for admins looking to deploy open source operating systems for their servers.

For some admins who are concerned about their regular release CentOS installations falling out of support (EOL being December 31, 2021), CentOS Stream might be the most logical option, especially given it will be supported until 2024. If that’s you, are you going to be stuck reinstalling the platform and then getting everything transferred back to the server? No.

There is another option: Convert that standard release over to a Stream release. Believe it or not, this process is quite simple and reliable. In fact, I’ve migrated a number of CentOS machines to Stream and have only encountered one small problem (more on that in a bit).

Let me show you how to do the same.

**SEE:** [**Linux service control commands**](https://www.techrepublic.com/resource-library/downloads/linux-service-control-commands/) **(TechRepublic Premium)**

## What you’ll need

-   A running instance of CentOS 8
    
-   A user with sudo privileges
    

## How to convert to CentOS Stream

This entire process is handled with three commands. The first command installs the necessary repository files. That command is:

`sudo dnf install centos-release-stream -y`

The next command removes centos-release, centos-repos, and centos-release-stream and replaces them with centos-stream-release. That command is:

`sudo dnf swap centos-{linux,stream}-repos`

Finally, we sync everything up with the command:

`sudo dnf distro-sync`

The first two commands complete almost instantly. The last command, however, will take some time, depending on the state of the server you are upgrading.

When the final command completes, reboot the server and enjoy CentOS 8 Stream.

## No caveat, but a word of caution

I do recommend you first test this process on a non-production server. I’ve run it a number of times and the only issue I’ve encountered was a failure to run the final command on one server, because docker-ce was installed. I had to run _dnf remove docker-ce_, run the distro-sync command, and then (after a reboot), I discovered containerd had been automatically installed in the conversion. However, that’s a rather specific incident.

If you are running a Kubernetes cluster with your CentOS 8 server, and you haven’t already made the switch to containerd, you should do that–regardless if you’re migrating to stream or not. Since Docker is being deprecated from Kubernetes, you’ll need to ensure your cluster still functions.


### Reference

- https://www.techrepublic.com/article/how-to-convert-centos-8-to-centos-8-stream/
- [How to become a developer: A cheat sheet](https://www.techrepublic.com/article/how-to-become-a-developer-a-cheat-sheet/) (TechRepublic)
- [Kubernetes security guide (free PDF)](https://www.techrepublic.com/resource-library/downloads/kubernetes-security-guide-free-pdf/) (TechRepublic)
- [Could Microsoft be en route to dumping Windows in favor of Linux?](https://www.techrepublic.com/article/could-microsoft-be-en-route-to-dumping-windows-in-favor-of-linux/) (TechRepublic)
- [Linux file and directory management commands](https://www.techrepublic.com/resource-library/downloads/linux-file-and-directory-management-commands/) (TechRepublic Premium)
- [How open source-software transformed the business world](https://www.zdnet.com/article/how-open-source-software-transformed-the-business-world/) (ZDNet)
- [Linux, Android, and more open source tech coverage](https://flipboard.com/@techrepublic/linux-android-and-more-open-source-tech-lg1d5t1ky) (TechRepublic on Flipboard)

- [Open source](https://www.techrepublic.com/topic/open-source/)
- [Software](https://www.techrepublic.com/topic/software/)
- 