
# docker swarm notes

## how to find out why service can't start

```shell
docker service ps --no-trunc {serviceName}
```

which will show errors with downloading images, mounting nfs volumes amongst others.

\---------------------- UPDATE

Not all errors can be found in the way described above. Another usefull tool is looking at the docker deamon logs which can be done the follwing way as explained on [stackoverflow](https://stackoverflow.com/a/30970134/7683711):

```shell
journalctl -u docker.service | tail -n 50 
```

The actual location of the log file depends on your OS. 
Here are a few of the OS-specific locations, with commands for few Operating Systems:

-   Ubuntu (old using upstart ) - `/var/log/upstart/docker.log`
-   Ubuntu (new using systemd ) - `journalctl -u docker.service`
-   Boot2Docker - `/var/log/docker.log`
-   Debian GNU/Linux - `/var/log/daemon.log`
-   CentOS - `/var/log/daemon.log | grep docker`
-   CoreOS - `journalctl -u docker.service`
-   Fedora - `journalctl -u docker.service`
-   Red Hat Enterprise Linux Server - `/var/log/messages | grep docker`
-   OpenSuSE - `journalctl -u docker.service`
-   OSX - `~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/log/docker.log`
-   Windows - `Get-EventLog -LogName Application -Source Docker -After (Get-Date).AddMinutes(-5) | Sort-Object Time`, as mentioned [here](https://learn.microsoft.com/en-us/virtualization/windowscontainers/troubleshooting#finding-logs).

Reference: https://stackoverflow.com/questions/45372848/docker-swarm-how-to-find-out-why-service-cant-start
