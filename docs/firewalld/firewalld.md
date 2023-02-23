
# Firewalld notes

## When getting the error "internal:0:0-0: Error: No such file or directory"
refs:
	https://netfilter.org/projects/nftables/
	https://www.theurbanpenguin.com/using-nftables-in-centos-8/
	https://wiki.nftables.org/wiki-nftables/index.php/Configuring_chains
	https://www.liquidweb.com/kb/how-to-install-nftables-in-ubuntu/
	https://github.com/firewalld/firewalld/issues/673

When getting the following error:

```shell
internal:0:0-0: Error: No such file or directory
'python-nftables' failed: internal:0:0-0: Error: No such file or directory
```
	
	
It is usually due to missing table or chain:

ref: https://askubuntu.com/questions/1320012/firewalld-no-such-file-or-directory

```shell
## if nftables not installed already
## apt-get install -y nftables
nft list tables
nft add table inet firewalld
...
```

If still having issues, then reset the firewalld state the following way:

You may simply delete the files containing the customized zone rules from `/etc/firewalld/zones`. 
After that, reload `firewalld` with `firewall-cmd --complete-reload`, and it should start using the default settings. 
When you make changes to the zone rules, files will appear again in that directory.

As for `iptables`, you may reset all rules with `iptables -F`. 
Rebooting works as well, unless you implemented some sort of persistency. 
Beware that `firewalld` may be configured to use `iptables` as its backend, which means it will add or remove `iptables` rules itself, according to what you specified in its zone rules.

If using iptables and you truly want to delete everything:

```shell
rm -rf /etc/firewalld/zones
## or 
rm -fr /usr/etc/firewalld/zones ## depending on your distro

## AND
iptables -X
iptables -F
iptables -Z
```

After clearing out the settings then restart the service

```shell
systemctl restart firewalld
```

and then you have a new set of rules and zones ;)

## Setting up rich/direct rules

Very helpful for more advanced setups including setting up rich/direct rules:

	https://www.liquidweb.com/kb/an-introduction-to-firewalld/

## Using ansible to enable segmented firewalld network zones

Using ansible to enable segmented network zones:

	https://www.clockworknet.com/blog/2020/03/10/managing-firewalld-with-ansible/

## How to debug rejected ports

How to debug rejected ports:

	https://www.cyberciti.biz/faq/enable-firewalld-logging-for-denied-packets-on-linux/

```shell
firewall-cmd --set-log-denied=all
firewall-cmd --get-log-denied

tail -10f /var/log/{syslog|messages}
Oct  2 12:47:23 nas02 kernel: [132359.381122] FINAL_REJECT: IN=ens192 OUT= MAC=... SRC=192.168.0.135 DST=... LEN=49 TOS=0x00 PREC=0x00 TTL=64.. PROTO=UDP SPT=46608 DPT=32414 LEN=29

firewall-cmd --permanent --add-port=445/tcp --add-port=139/tcp --add-port=32412/udp --add-port=32414/udp --add-port=33979/tcp --add-port=40783/tcp
firewall-cmd --reload

tail -10f /var/log/{syslog|messages}

## extract SPT and DPT and aggregate
## ref: https://stackoverflow.com/questions/52663431/extract-fields-from-logs-with-awk-and-aggregate-them-for-a-new-command
## https://www.cloudsavvyit.com/640/how-to-extract-and-sort-columns-out-of-log-files-on-linux/
##
grep FINAL_REJECT /var/log/syslog | grep -v -e FLOWLBL -e "DF PROTO" | awk -F[' '] '{print $12, $19, $20, $21}' | sort | uniq
SRC=0.0.0.0 PROTO=UDP SPT=68 DPT=67
SRC=192.168.0.1 PROTO=UDP SPT=53 DPT=35077
SRC=192.168.0.1 PROTO=UDP SPT=53 DPT=36960
...
SRC=192.168.0.1 PROTO=UDP SPT=53 DPT=37569
SRC=192.168.0.1 PROTO=UDP SPT=53 DPT=57238
SRC=192.168.0.1 PROTO=UDP SPT=67 DPT=68
SRC=192.168.0.254 PROTO=UDP SPT=68 DPT=67
SRC=192.168.2.1 PROTO=UDP SPT=68 DPT=67
SRC=213.230.77.51 PROTO=UDP SPT=35995 DPT=51413


## to get details:
$ grep FINAL_REJECT /var/log/syslog | awk -F[' '] '{$1=$2=$3=$5=$11=""; print $0}' | sort | uniq
10:31:46  kernel: [1085359.242128] FINAL_REJECT: IN=eno1 OUT=  SRC=192.168.0.1 DST=192.168.0.135 LEN=83 TOS=0x00 PREC=0x00 TTL=64 ID=8949 PROTO=UDP SPT=53 DPT=53967 LEN=63
10:33:47  kernel: [1085480.655723] FINAL_REJECT: IN=eno1 OUT=  SRC=192.168.0.1 DST=192.168.0.135 LEN=71 TOS=0x00 PREC=0x00 TTL=64 ID=23182 PROTO=UDP SPT=53 DPT=52995 LEN=51
10:33:48  kernel: [1085481.346356] FINAL_REJECT: IN=eno1 OUT=  SRC=192.168.0.1 DST=192.168.0.135 LEN=74 TOS=0x00 PREC=0x00 TTL=64 ID=25707 PROTO=UDP SPT=53 DPT=51773 LEN=54
10:33:48  kernel: [1085481.346379] FINAL_REJECT: IN=eno1 OUT=  SRC=192.168.0.1 DST=192.168.0.135 LEN=74 TOS=0x00 PREC=0x00 TTL=64 ID=44036 PROTO=UDP SPT=53 DPT=45022 LEN=54
10:34:05  kernel: [1085498.636060] FINAL_REJECT: IN=eno1 OUT=  SRC=192.168.0.1 DST=192.168.0.135 LEN=74 TOS=0x00 PREC=0x00 TTL=64 ID=31274 PROTO=UDP SPT=53 DPT=36450 LEN=54
10:34:43  kernel: [1085536.515718] FINAL_REJECT: IN=eno1 OUT=  SRC=192.168.0.1 DST=192.168.0.135 LEN=75 TOS=0x00 PREC=0x00 TTL=64 ID=12913 PROTO=UDP SPT=53 DPT=33670 LEN=55


## verify nothing is rejected - if so, we can now disable the rejected logging from the firewall
$ firewall-cmd --set-log-denied=off
```
	
Note the DPT and PROTO - this lets you know the destination port and protocol that was attempted and rejected

FYI - needed to open 40073 on ubuntu for vmware esxi to mount:

nfs_firewalld_exposed_ports:
  ## ref: https://unix.stackexchange.com/questions/243756/nfs-servers-and-firewalld
  ## 2020-08-03: this was needed this port open for vmware esxi to mount ubuntu nfs server share
  ## found this out by debugging the firewalld REJECT messages to find the port
  ## ref: https://www.cyberciti.biz/faq/enable-firewalld-logging-for-denied-packets-on-linux/
  - "40073/tcp"
  - "40073/udp"


```shell
$ root@nas02:[administrator]$ firewall-cmd --set-log-denied=all
$ root@nas02:[administrator]$ firewall-cmd --get-log-denied
$ root@nas02:[administrator]$ firewall-cmd --set-log-denied=off
$ 
$ root@nas02:[administrator]$ firewall-cmd --zone=internal --list-all
internal (active)
$ root@nas02:[administrator]$ firewall-cmd --zone=internal --permanent --add-port=445/tcp --add-port=139/tcp --add-port=33979/tcp --add-port=40073/udp --zone=internal
success
$ root@nas02:[administrator]$
$ root@nas02:[administrator]$ firewall-cmd --zone=internal --permanent --remove-port=665-1023/udp
success
$ root@nas02:[administrator]$ firewall-cmd --reload
success
$ root@nas02:[administrator]$ firewall-cmd --zone=internal --list-all
internal (active)
...

$ root@nas02:[administrator]$ tail -10f syslog
Oct  2 12:47:23 nas02 kernel: [132359.381122] FINAL_REJECT: IN=ens192 OUT= MAC=ff:ff:ff:ff:ff:ff:1c:69:7a:0a:6d:b5:08:00 SRC=192.168.0.135 DST=192.168.255.255 LEN=49 TOS=0x00 PREC=0x00 TTL=64 ID=17119 DF PROTO=UDP SPT=46608 DPT=32414 LEN=29
Oct  2 12:47:23 nas02 kernel: [132359.381173] FINAL_REJECT: IN=ens192 OUT= MAC=ff:ff:ff:ff:ff:ff:1c:69:7a:0a:6d:b5:08:00 SRC=192.168.0.135 DST=192.168.255.255 LEN=49 TOS=0x00 PREC=0x00 TTL=64 ID=17120 DF PROTO=UDP SPT=34149 DPT=32412 LEN=29
Oct  2 12:47:28 nas02 kernel: [132364.382181] FINAL_REJECT: IN=ens192 OUT= MAC=ff:ff:ff:ff:ff:ff:1c:69:7a:0a:6d:b5:08:00 SRC=192.168.0.135 DST=192.168.255.255 LEN=49 TOS=0x00 PREC=0x00 TTL=64 ID=17901 DF PROTO=UDP SPT=34149 DPT=32412 LEN=29
Oct  2 12:51:56 nas02 kernel: [132632.463572] FINAL_REJECT: IN=ens192 OUT= MAC=00:50:56:8d:5a:db:00:50:56:89:1e:11:08:00 SRC=192.168.10.20 DST=192.168.10.10 LEN=52 TOS=0x02 PREC=0x00 TTL=128 ID=18232 DF PROTO=TCP SPT=51529 DPT=445 WINDOW=8192 RES=0x00 CWR ECE SYN URGP=0
Oct  2 12:51:57 nas02 kernel: [132633.557306] FINAL_REJECT: IN=ens192 OUT= MAC=00:50:56:8d:5a:db:00:50:56:89:1e:11:08:00 SRC=192.168.10.20 DST=192.168.10.10 LEN=52 TOS=0x02 PREC=0x00 TTL=128 ID=18235 DF PROTO=TCP SPT=51530 DPT=139 WINDOW=8192 RES=0x00 CWR ECE SYN URGP=0
Oct  2 12:51:59 nas02 kernel: [132635.460798] FINAL_REJECT: IN=ens192 OUT= MAC=00:50:56:8d:5a:db:00:50:56:89:1e:11:08:00 SRC=192.168.10.20 DST=192.168.10.10 LEN=52 TOS=0x02 PREC=0x00 TTL=128 ID=18236 DF PROTO=TCP SPT=51529 DPT=445 WINDOW=8192 RES=0x00 CWR ECE SYN URGP=0
Oct  2 12:52:00 nas02 kernel: [132636.570129] FINAL_REJECT: IN=ens192 OUT= MAC=00:50:56:8d:5a:db:00:50:56:89:1e:11:08:00 SRC=192.168.10.20 DST=192.168.10.10 LEN=52 TOS=0x02 PREC=0x00 TTL=128 ID=18237 DF PROTO=TCP SPT=51530 DPT=139 WINDOW=8192 RES=0x00 CWR ECE SYN URGP=0
Oct  2 12:52:05 nas02 kernel: [132641.476417] FINAL_REJECT: IN=ens192 OUT= MAC=00:50:56:8d:5a:db:00:50:56:89:1e:11:08:00 SRC=192.168.10.20 DST=192.168.10.10 LEN=48 TOS=0x00 PREC=0x00 TTL=128 ID=18238 DF PROTO=TCP SPT=51529 DPT=445 WINDOW=8192 RES=0x00 SYN URGP=0
Oct  2 12:52:06 nas02 kernel: [132642.585759] FINAL_REJECT: IN=ens192 OUT= MAC=00:50:56:8d:5a:db:00:50:56:89:1e:11:08:00 SRC=192.168.10.20 DST=192.168.10.10 LEN=48 TOS=0x00 PREC=0x00 TTL=128 ID=18239 DF PROTO=TCP SPT=51530 DPT=139 WINDOW=8192 RES=0x00 SYN URGP=0
Oct  2 12:52:18 nas02 kernel: [132654.586317] FINAL_REJECT: IN=ens192 OUT= MAC=00:50:56:8d:5a:db:00:50:56:89:1e:11:08:00 SRC=192.168.10.20 DST=192.168.10.10 LEN=52 TOS=0x02 PREC=0x00 TTL=128 ID=18244 DF PROTO=TCP SPT=905 DPT=33979 WINDOW=8192 RES=0x00 CWR ECE SYN URGP=0
Oct  2 12:52:21 nas02 kernel: [132657.585809] FINAL_REJECT: IN=ens192 OUT= MAC=00:50:56:8d:5a:db:00:50:56:89:1e:11:08:00 SRC=192.168.10.20 DST=192.168.10.10 LEN=52 TOS=0x02 PREC=0x00 TTL=128 ID=18252 DF PROTO=TCP SPT=905 DPT=33979 WINDOW=8192 RES=0x00 CWR ECE SYN URGP=0
^C
$ root@nas02:[log]$ firewall-cmd --zone=internal --permanent --add-port=445/tcp --add-port=139/tcp --add-port=33979/tcp --add-port=40783/tcp
success
$ root@nas02:[log]$ firewall-cmd --reload
success
$ root@nas02:[log]$

```

## How to manage zones

How to manage zones:

	https://www.techrepublic.com/article/how-to-manage-zones-on-centos-7-with-firewalld/
	https://www.linuxjournal.com/content/understanding-firewalld-multi-zone-configurations

## How to setup/configure firewalld

How to setup/configure firewalld:

	https://docs.ansible.com/ansible/latest/modules/firewalld_module.html

	https://computingforgeeks.com/install-and-use-firewalld-on-ubuntu-18-04-ubuntu-16-04/
	https://askubuntu.com/questions/864958/how-can-we-replace-iptables-with-firewalld-in-ubuntu-16-04
	https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-firewalld-on-centos-7
	https://github.com/plone/ansible-playbook/blob/master/firewalls/centos-firewalld.yml

	https://support.onegini.com/hc/en-us/articles/115000769311-Firewalld-error-with-Docker-No-route-to-host-

## Examples (TL;DR)

Examples (TL;DR)
	ref: https://www.mankier.com/1/firewall-cmd

View the available firewall zones:
`$ firewall-cmd --get-active-zones`

View the rules which are currently applied:
`$ firewall-cmd --list-all`

Permanently open the port for a service in the specified zone (like port 443 when in the public zone):
`$ firewall-cmd --permanent --zone=public --add-service=https`

Permanently close the port for a service in the specified zone (like port 80 when in the public zone):
`$ firewall-cmd --permanent --zone=public --remove-service=http`

Reload firewalld to force rule changes to take effect:
`$ firewall-cmd --reload`


## How to debug REJECTED connections

How to debug REJECTED connections:

	ref: https://www.cyberciti.biz/faq/enable-firewalld-logging-for-denied-packets-on-linux/

```shell
firewall-cmd --set-log-denied=all
firewall-cmd --get-log-denied
firewall-cmd --set-log-denied=off
```

```shell
$ root@admin2:[administrator]$ firewall-cmd --zone=internal --list-all
internal (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.0.0/16 172.0.0.0/8
  services: ssh mdns samba-client dhcpv6-client nfs ldap smtp nfs3 mountd rpc-bind
  ports: 10000/tcp 80/tcp 443/tcp 389/tcp 69/tcp 25151/tcp 2375/tcp 2376/tcp 8443/tcp 8080/tcp 25/tcp 636/tcp 111/tcp 2049/tcp 10443/tcp 10080/tcp 53/udp 53/tcp 953/udp 953/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

$ root@admin2:[administrator]$
$ root@admin2:[administrator]$
$ root@admin2:[administrator]$ firewall-cmd --permanent --add-port=2049/tcp --add-port=2049/udp --zone=internal
Warning: ALREADY_ENABLED: 2049:tcp
success
$ root@admin2:[administrator]$ firewall-cmd --zone=internal --list-all
internal (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.0.0/16 172.0.0.0/8
  services: ssh mdns samba-client dhcpv6-client nfs ldap smtp nfs3 mountd rpc-bind
  ports: 10000/tcp 80/tcp 443/tcp 389/tcp 69/tcp 25151/tcp 2375/tcp 2376/tcp 8443/tcp 8080/tcp 25/tcp 636/tcp 111/tcp 2049/tcp 10443/tcp 10080/tcp 53/udp 53/tcp 953/udp 953/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

$ root@admin2:[administrator]$
$ root@admin2:[administrator]$ firewall-cmd --reload
success
$ root@admin2:[administrator]$ firewall-cmd --zone=internal --list-all
internal (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.0.0/16 172.0.0.0/8
  services: ssh mdns samba-client dhcpv6-client nfs ldap smtp nfs3 mountd rpc-bind
  ports: 10000/tcp 80/tcp 443/tcp 389/tcp 69/tcp 25151/tcp 2375/tcp 2376/tcp 8443/tcp 8080/tcp 25/tcp 636/tcp 111/tcp 2049/tcp 10443/tcp 10080/tcp 53/udp 53/tcp 953/udp 953/tcp 2049/udp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

$ root@admin2:[administrator]$
$ root@admin2:[administrator]$ firewall-cmd --permanent --add-port=111/udp --zone=internal
success
$ root@admin2:[administrator]$ firewall-cmd --reload
success
$ root@admin2:[administrator]$ firewall-cmd --zone=internal --list-all
internal (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.0.0/16 172.0.0.0/8
  services: ssh mdns samba-client dhcpv6-client nfs ldap smtp nfs3 mountd rpc-bind
  ports: 10000/tcp 80/tcp 443/tcp 389/tcp 69/tcp 25151/tcp 2375/tcp 2376/tcp 8443/tcp 8080/tcp 25/tcp 636/tcp 111/tcp 2049/tcp 10443/tcp 10080/tcp 53/udp 53/tcp 953/udp 953/tcp 2049/udp 111/udp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

$ root@admin2:[administrator]$
$ root@admin2:[administrator]$
$ root@admin2:[administrator]$ firewall-cmd --permanent --add-port=4001/tcp --add-port=4001/udp --zone=internal
success
$ root@admin2:[administrator]$ firewall-cmd --reload
success
$ root@admin2:[administrator]$ firewall-cmd --zone=internal --list-all
internal (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.0.0/16 172.0.0.0/8
  services: ssh mdns samba-client dhcpv6-client nfs ldap smtp nfs3 mountd rpc-bind
  ports: 10000/tcp 80/tcp 443/tcp 389/tcp 69/tcp 25151/tcp 2375/tcp 2376/tcp 8443/tcp 8080/tcp 25/tcp 636/tcp 111/tcp 2049/tcp 10443/tcp 10080/tcp 53/udp 53/tcp 953/udp 953/tcp 2049/udp 111/udp 4001/tcp 4001/udp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

$ root@admin2:[administrator]$
$ root@admin2:[administrator]$ firewall-cmd --zone=internal --list-all
internal (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.0.0/16 172.0.0.0/8
  services: ssh mdns samba-client dhcpv6-client nfs ldap smtp nfs3 mountd rpc-bind
  ports: 10000/tcp 80/tcp 443/tcp 389/tcp 69/tcp 25151/tcp 2375/tcp 2376/tcp 8443/tcp 8080/tcp 25/tcp 636/tcp 111/tcp 2049/tcp 10443/tcp 10080/tcp 53/udp 53/tcp 953/udp 953/tcp 2049/udp 111/udp 4001/tcp 4001/udp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

$ root@admin2:[administrator]$
$ root@admin2:[administrator]$ firewall-cmd --permanent --add-port=892/tcp --add-port=892/udp --zone=internal
success
$ root@admin2:[administrator]$ firewall-cmd --reload
success
$ root@admin2:[administrator]$ firewall-cmd --zone=internal --list-all
internal (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.0.0/16 172.0.0.0/8
  services: ssh mdns samba-client dhcpv6-client nfs ldap smtp nfs3 mountd rpc-bind
  ports: 10000/tcp 80/tcp 443/tcp 389/tcp 69/tcp 25151/tcp 2375/tcp 2376/tcp 8443/tcp 8080/tcp 25/tcp 636/tcp 111/tcp 2049/tcp 10443/tcp 10080/tcp 53/udp 53/tcp 953/udp 953/tcp 2049/udp 111/udp 4001/tcp 4001/udp 892/tcp 892/udp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

$ root@admin2:[administrator]$ firewall-cmd --permanent --add-port=334/tcp --add-port=334/udp --zone=internal
success
$ root@admin2:[administrator]$ firewall-cmd --reload
success
$ root@admin2:[administrator]$ firewall-cmd --zone=internal --list-all
internal (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.0.0/16 172.0.0.0/8
  services: ssh mdns samba-client dhcpv6-client nfs ldap smtp nfs3 mountd rpc-bind
  ports: 10000/tcp 80/tcp 443/tcp 389/tcp 69/tcp 25151/tcp 2375/tcp 2376/tcp 8443/tcp 8080/tcp 25/tcp 636/tcp 111/tcp 2049/tcp 10443/tcp 10080/tcp 53/udp 53/tcp 953/udp 953/tcp 2049/udp 111/udp 4001/tcp 4001/udp 892/tcp 892/udp 334/tcp 334/udp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

$ root@admin2:[administrator]$ firewall-cmd --zone=internal --permanent --add-port=665-1023/tcp
success
$ root@admin2:[administrator]$ firewall-cmd --zone=internal --permanent --add-port=665-1023/udp
success
$ root@admin2:[administrator]$ firewall-cmd --reload
success
$ root@admin2:[administrator]$ firewall-cmd --zone=internal --list-all
internal (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.0.0/16 172.0.0.0/8
  services: ssh mdns samba-client dhcpv6-client nfs ldap smtp nfs3 mountd rpc-bind
  ports: 10000/tcp 80/tcp 443/tcp 389/tcp 69/tcp 25151/tcp 2375/tcp 2376/tcp 8443/tcp 8080/tcp 25/tcp 636/tcp 111/tcp 2049/tcp 10443/tcp 10080/tcp 53/udp 53/tcp 953/udp 953/tcp 2049/udp 111/udp 4001/tcp 4001/udp 892/tcp 892/udp 334/tcp 334/udp 665-1023/tcp 665-1023/udp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

$ root@admin2:[administrator]$
$ root@admin2:[administrator]$ cp -p /etc/firewalld/firewalld.conf /etc/firewalld/firewalld.conf.20200803~
$ root@admin2:[administrator]$ emacs /etc/firewalld/firewalld.conf

[1]+  Stopped                 emacs /etc/firewalld/firewalld.conf
$ root@admin2:[administrator]$
$ root@admin2:[administrator]$ systemctl restart firewalld
$ root@admin2:[administrator]$ client_loop: send disconnect: Connection reset by peer

Lee@LJLAPTOP:[~]$
Lee@LJLAPTOP:[~]$ sshadmin2
Welcome to Ubuntu 18.04.4 LTS (GNU/Linux 4.15.0-66-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

 * Are you ready for Kubernetes 1.19? It's nearly here! Try RC3 with
   sudo snap install microk8s --channel=1.19/candidate --classic

   https://www.microk8s.io/ has docs and details.

 * Canonical Livepatch is available for installation.
   - Reduce system reboots and improve kernel security. Activate at:
     https://ubuntu.com/livepatch

0 packages can be updated.
0 updates are security updates.

 setting prompt
 setting aliases
 setting openrc env
administrator@admin2:[~]$ sudo su
 setting prompt
 setting aliases
 setting openrc env
$ root@admin2:[administrator]$
$ root@admin2:[administrator]$ firewall-cmd --get-log-denied
all
$ root@admin2:[administrator]$ journalctl -f -l -u firewalld
-- Logs begin at Wed 2020-07-15 05:32:38 EDT. --
Aug 03 14:47:08 admin2 firewalld[23713]: WARNING: COMMAND_FAILED: '/sbin/iptables -w2 -t filter -C FORWARD -i br-f4cb3ea53e43 -o br-f4cb3ea53e43 -j ACCEPT' failed: iptables: Bad rule (does a matching rule exist in that chain?).
Aug 03 14:47:08 admin2 firewalld[23713]: WARNING: COMMAND_FAILED: '/sbin/iptables -w2 -t filter -C FORWARD -i br-f4cb3ea53e43 ! -o br-f4cb3ea53e43 -j ACCEPT' failed: iptables: Bad rule (does a matching rule exist in that chain?).
Aug 03 14:47:09 admin2 firewalld[23713]: WARNING: COMMAND_FAILED: '/sbin/iptables -w2 -t filter -C FORWARD -o br-f4cb3ea53e43 -j DOCKER' failed: iptables: No chain/target/match by that name.
Aug 03 14:47:09 admin2 firewalld[23713]: WARNING: COMMAND_FAILED: '/sbin/iptables -w2 -t filter -C FORWARD -o br-f4cb3ea53e43 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT' failed: iptables: Bad rule (does a matching rule exist in that chain?).
Aug 03 14:47:09 admin2 firewalld[23713]: WARNING: COMMAND_FAILED: '/sbin/iptables -w2 -t nat -C DOCKER -p tcp -d 0/0 --dport 443 -j DNAT --to-destination 172.24.0.3:443 ! -i br-f4cb3ea53e43' failed: iptables: No chain/target/match by that name.
Aug 03 14:47:09 admin2 firewalld[23713]: WARNING: COMMAND_FAILED: '/sbin/iptables -w2 -t filter -C DOCKER ! -i br-f4cb3ea53e43 -o br-f4cb3ea53e43 -p tcp -d 172.24.0.3 --dport 443 -j ACCEPT' failed: iptables: Bad rule (does a matching rule exist in that chain?).
Aug 03 14:47:09 admin2 firewalld[23713]: WARNING: COMMAND_FAILED: '/sbin/iptables -w2 -t nat -C POSTROUTING -p tcp -s 172.24.0.3 -d 172.24.0.3 --dport 443 -j MASQUERADE' failed: iptables: No chain/target/match by that name.
Aug 03 14:47:09 admin2 firewalld[23713]: WARNING: COMMAND_FAILED: '/sbin/iptables -w2 -t nat -C DOCKER -p tcp -d 0/0 --dport 80 -j DNAT --to-destination 172.24.0.3:80 ! -i br-f4cb3ea53e43' failed: iptables: No chain/target/match by that name.
Aug 03 14:47:10 admin2 firewalld[23713]: WARNING: COMMAND_FAILED: '/sbin/iptables -w2 -t filter -C DOCKER ! -i br-f4cb3ea53e43 -o br-f4cb3ea53e43 -p tcp -d 172.24.0.3 --dport 80 -j ACCEPT' failed: iptables: Bad rule (does a matching rule exist in that chain?).
Aug 03 14:47:10 admin2 firewalld[23713]: WARNING: COMMAND_FAILED: '/sbin/iptables -w2 -t nat -C POSTROUTING -p tcp -s 172.24.0.3 -d 172.24.0.3 --dport 80 -j MASQUERADE' failed: iptables: No chain/target/match by that name.

$ root@admin2:[administrator]$ grep 192.168.0.11 /var/log/kern.log
Aug  3 14:50:09 admin2 kernel: [10392.895767] FINAL_REJECT: IN=ens32 OUT= MAC=00:50:56:91:08:d0:00:1e:c9:56:14:3b:08:00 SRC=192.168.0.11 DST=192.168.0.42 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=51861 DF PROTO=TCP SPT=934 DPT=40073 WINDOW=65535 RES=0x00 SYN URGP=0
Aug  3 14:50:24 admin2 kernel: [10407.897198] FINAL_REJECT: IN=ens32 OUT= MAC=00:50:56:91:08:d0:00:1e:c9:56:14:3b:08:00 SRC=192.168.0.11 DST=192.168.0.42 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=52181 DF PROTO=TCP SPT=935 DPT=40073 WINDOW=65535 RES=0x00 SYN URGP=0
Aug  3 14:50:39 admin2 kernel: [10422.898830] FINAL_REJECT: IN=ens32 OUT= MAC=00:50:56:91:08:d0:00:1e:c9:56:14:3b:08:00 SRC=192.168.0.11 DST=192.168.0.42 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=52518 DF PROTO=TCP SPT=936 DPT=40073 WINDOW=65535 RES=0x00 SYN URGP=0
$ root@admin2:[administrator]$
$ root@admin2:[administrator]$
$ root@admin2:[administrator]$ firewall-cmd --permanent --add-port=40073/tcp --add-port=40073/udp --zone=internal
success
$ root@admin2:[administrator]$
$ root@admin2:[administrator]$ firewall-cmd --zone=internal --permanent --remove-port=665-1023/udp
success
$ root@admin2:[administrator]$ firewall-cmd --reload
success
$ root@admin2:[administrator]$ firewall-cmd --zone=internal --list-all
internal (active)

```

