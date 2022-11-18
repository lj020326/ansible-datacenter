
# Interesting case of WAN dropping daily/DHCP being blocked by firewall

My pfsense box is dropping the WAN connection daily at random times. When it happens nothing being changed in pfsense with a following DHCP release/renew will fix it. I have to turn off my modem and then turn it back on AND reboot pfsense to regain connectivity.

    
    ISP (Spectrum) -> Netgear C6300 (bridged) -> pfsense box -> LAN

    
I have tried a multitude of things so far but nothing has solved the problem as every 12-24 hours pfsense will fail to get internet connectivity. I've verified it's the pfsense box because I can plug a laptop directly into Port 1 of the bridged modem and ping/surf the internet just fine after pfsense goes down.
    
I've tried:  
- Non-standard gateway latency probe intervals/etc
- Changing firewall mode from 'normal' to 'high latency'
- Disabling the gateway monitoring (did this today, still monitoring if this will fix it but I would rather have this enabled)
- Adding a firewall WAN rule allowing a 'blocked' DHCP IP from the log below to 'pass' to the 'firewall (self)' destination
    
Notes:  

According to my ISP (spectrum) there is no special MAC/static IP/hostname to be entered, it's all through their DHCP
    
Here is the gateway log sample from the last outage:
    
```output
Feb 16 14:19:07dpingerWAN_DHCP 97.XXX.XXX.X: sendto error: 65
Feb 16 14:19:10dpingerWAN_DHCP 97.XXX.XXX.X: sendto error: 65
Feb 16 14:19:13dpingerWAN_DHCP 97.XXX.XXX.X: sendto error: 65
Feb 16 14:19:16dpingerWAN_DHCP 97.XXX.XXX.X: sendto error: 65
*added note - this repeats 100x times*
Feb 16 14:21:44dpingersend_interval 3000ms loss_interval 6000ms time_period 60000ms report_interval 0ms data_len 0 alert_interval 8000ms latency_alarm 500ms loss_alarm 20% dest_addr 97.XXX.XXX.X bind_addr 97.XXX.XXX.XXX2 identifier "WAN_DHCP "
Feb 16 14:22:00dpingerWAN_DHCP 97.XXX.XXX.X: Alarm latency 0us stddev 0us loss 100%
Feb 16 14:25:33dpingersend_interval 500ms loss_interval 2000ms time_period 60000ms report_interval 0ms data_len 0 alert_interval 1000ms latency_alarm 500ms loss_alarm 20% dest_addr 97.XXX.XXX.X bind_addr 97.XXX.XXX.XXX2 identifier "WAN_DHCP "
Feb 16 14:25:35dpingersend_interval 500ms loss_interval 2000ms time_period 60000ms report_interval 0ms data_len 0 alert_interval 1000ms latency_alarm 500ms loss_alarm 20% dest_addr 97.XXX.XXX.X bind_addr 97.XXX.XXX.XXX2 identifier "WAN_DHCP "
Feb 16 14:25:39dpingerWAN_DHCP 97.XXX.XXX.X: Alarm latency 0us stddev 0us loss 100%
    
```
    
Routing log:
    
```output
Feb 16 14:52:07radvd34097sendmsg: Operation not permitted
Feb 16 14:52:15radvd34097sendmsg: Operation not permitted
Feb 16 14:52:23radvd34097sendmsg: Operation not permitted
Feb 16 14:52:32radvd34097sendmsg: Operation not permitted
Feb 16 14:52:42radvd34097sendmsg: Operation not permitted
Feb 16 14:52:47radvd34097sendmsg: Operation not permitted
Feb 16 14:52:55radvd34097sendmsg: Operation not permitted
```
    
Also in my firewall logs I'm getting some blocking of port 67/68 traffic (DHCP)
    
```
Feb 16 23:01:29WAN  10.209.64.1:67  255.255.255.255:68
```
    
    
Purchased a surfboard 6141 to replace the netgear bridged C6300 and it looks like the problem is fixed so far, it's been 12 hours without a drop.
    
I have the same problem but it seems to occur every few days for me. Using SG-1000.
    
- Rebooting modem does not work.
- The only remedy is rebooting pfsense.
- Interestingly, the Gateway Status still shows "Online".
- The latency alarm does not seem to do anything.
    
From the logs it looks like:
    
- The ISP is trying to assign a new IP address
- For some reason that cannot happen
- Connection "dies" probably because ISP stops routing
    
    Gateway Logs:
    
```output

... LOTS of previous instances of sendto error: 65 and before that 2 days earlier sendto error: 55...

Apr 16 13:31:53 Heimdall dpinger: WAN_PPPOE {ISP Primary Gateway}: sendto error: 65
Apr 16 13:31:54 Heimdall dpinger: WAN_PPPOE {ISP Primary Gateway}: sendto error: 65
Apr 16 13:31:54 Heimdall dpinger: WAN_PPPOE {ISP Primary Gateway}: sendto error: 65
Apr 16 13:31:55 Heimdall dpinger: WAN_PPPOE {ISP Primary Gateway}: sendto error: 65
Apr 16 13:31:55 Heimdall dpinger: WAN_PPPOE {ISP Primary Gateway}: sendto error: 65
Apr 16 13:31:56 Heimdall dpinger: WAN_PPPOE {ISP Primary Gateway}: sendto error: 65
Apr 16 13:31:56 Heimdall dpinger: WAN_PPPOE {ISP Primary Gateway}: sendto error: 65
Apr 16 13:31:57 Heimdall dpinger: WAN_PPPOE {ISP Primary Gateway}: sendto error: 65
Apr 16 13:31:57 Heimdall dpinger: WAN_PPPOE {ISP Primary Gateway}: sendto error: 65
Apr 16 13:31:58 Heimdall dpinger: send_interval 500ms  loss_interval 2000ms  time_period 60000ms  report_interval 0ms  data_len 0  alert_interval 1000ms  latency_alarm 500ms  loss_alarm 20%  dest_addr {ISP Secondary Gateway}  bind_addr {Valid WAN IP - 1}  identifier "WAN_PPPOE "
Apr 16 13:36:06 Heimdall dpinger: send_interval 500ms  loss_interval 2000ms  time_period 60000ms  report_interval 0ms  data_len 0  alert_interval 1000ms  latency_alarm 500ms  loss_alarm 20%  dest_addr {ISP Primary Gateway}  bind_addr {Valid WAN IP - 2}  identifier "WAN_PPPOE "
Apr 16 13:42:02 Heimdall dpinger: send_interval 500ms  loss_interval 2000ms  time_period 60000ms  report_interval 0ms  data_len 0  alert_interval 1000ms  latency_alarm 500ms  loss_alarm 20%  dest_addr {ISP Secondary Gateway}  bind_addr {Valid WAN IP - 3}  identifier "WAN_PPPOE "
Apr 16 13:42:08 Heimdall dpinger: send_interval 500ms  loss_interval 2000ms  time_period 60000ms  report_interval 0ms  data_len 0  alert_interval 1000ms  latency_alarm 500ms  loss_alarm 20%  dest_addr {ISP Secondary Gateway}  bind_addr {Valid WAN IP - 3}  identifier "WAN_PPPOE "

```
    
Routing Logs:
    
```output

Apr 16 13:10:05 Heimdall miniupnpd[47123]: remove port mapping 58698 TCP because it has expired
Apr 16 13:10:05 Heimdall miniupnpd[47123]: remove port mapping 58698 UDP because it has expired
Apr 16 13:11:20 Heimdall miniupnpd[47123]: upnp_event_process_notify: connect(172.16.10.15:2869): Operation timed out
Apr 16 13:11:20 Heimdall miniupnpd[47123]: upnp_event_process_notify: connect(172.16.10.99:2869): Operation timed out
Apr 16 13:15:39 Heimdall miniupnpd[47123]: ioctl(s, SIOCGIFADDR, ...): Can't assign requested address
Apr 16 13:15:39 Heimdall miniupnpd[47123]: Failed to get IP for interface pppoe0
Apr 16 13:15:39 Heimdall miniupnpd[47123]: SendNATPMPPublicAddressChangeNotification: cannot get public IP address, stopping
Apr 16 13:16:17 Heimdall miniupnpd[47123]: ioctl(s, SIOCGIFADDR, ...): Can't assign requested address
Apr 16 13:16:17 Heimdall miniupnpd[47123]: Failed to get IP for interface pppoe0
Apr 16 13:16:17 Heimdall miniupnpd[47123]: SendNATPMPPublicAddressChangeNotification: cannot get public IP address, stopping
Apr 16 13:18:05 Heimdall miniupnpd[47123]: SendNATPMPPublicAddressChangeNotification: sendto(s_udp=10): No route to host
Apr 16 13:18:05 Heimdall miniupnpd[47123]: SendNATPMPPublicAddressChangeNotification: sendto(s_udp=10): No route to host
Apr 16 13:29:22 Heimdall miniupnpd[47123]: ioctl(s, SIOCGIFADDR, ...): Can't assign requested address
Apr 16 13:29:22 Heimdall miniupnpd[47123]: Failed to get IP for interface pppoe0
Apr 16 13:29:22 Heimdall miniupnpd[47123]: SendNATPMPPublicAddressChangeNotification: cannot get public IP address, stopping
Apr 16 13:30:02 Heimdall miniupnpd[47123]: ioctl(s, SIOCGIFADDR, ...): Can't assign requested address
Apr 16 13:30:02 Heimdall miniupnpd[47123]: Failed to get IP for interface pppoe0
Apr 16 13:30:02 Heimdall miniupnpd[47123]: SendNATPMPPublicAddressChangeNotification: cannot get public IP address, stopping
Apr 16 13:31:52 Heimdall miniupnpd[47123]: SendNATPMPPublicAddressChangeNotification: sendto(s_udp=10): No route to host
Apr 16 13:31:52 Heimdall miniupnpd[47123]: SendNATPMPPublicAddressChangeNotification: sendto(s_udp=10): No route to host
Apr 16 13:36:22 Heimdall miniupnpd[47279]: HTTP listening on port 2189
Apr 16 13:36:22 Heimdall miniupnpd[47279]: no HTTP IPv6 address, disabling IPv6
Apr 16 13:36:22 Heimdall miniupnpd[47279]: Listening for NAT-PMP/PCP traffic on port 5351
Apr 16 13:36:23 Heimdall miniupnpd[47279]: upnp_event_recv: recv(): Connection reset by peer

```
    
## Solution

The solution to these troubles is to do with the link speed negotiation:

This exact behaviour happened on a connection I'm working with, after I explicitly set the WAN link's ethernet speed negotiation to 100BaseT Full Duplex.

The link then began going up and down like a yo-yo. If you refresh your browser every few seconds on interfaces>WAN this becomes clear. You do see the ISP's assigned IP come up as it should, but of course, then it drops out. On the cable modem you can also see the interface's link light turn off each time the link is dropped.

The Logs>Gateway shows 2 dpinger entries every second:  

```output
WAN\_DHCP XXX.XXX.XXX.XXX: sendto error: 65  
WAN\_DHCP XXX.XXX.XXX.XXX: sendto error: 65  
WAN\_DHCP XXX.XXX.XXX.XXX: sendto error: 65
```

Until you set the link speed neg:  
In Logs>Gateway you might see something like  

```output
Oct 10 14:22:16 dpinger WAN\_DHCP XXX.XXX.XXX.XXX: Alarm latency 9596us stddev 2791us loss 30%
```

Then, no more errors.

FYI: If you read the notice on the interface>link setting, "WARNING: MUST be set to autoselect (automatically negotiate speed) unless the port this interface connects to has its speed and duplex forced", you may get the hint when trying to resolve the problem.

I tried many settings, finding that neither autoselect or 'autoselect flowcontrol' work.  It only worked with: 'AutoSelect 1000BaseT full-duplex,master', or the default option.

As the current default option works, most people should not see this (bug?). Certainly, no autoselect option works!

Above true for:  
pfS 2.3.4-RELEASE-p1 (amd64),  
Intel bge on-board interface,  
Netgear 'Telstra Gateway MAX' C6300BD on a DOCSIS 3.0 network

I originally set the link speed in order to save power on two interfaces that don't need to negotiate a 1Gb speed. So much for that great idea ;-)
    
## Alternate Solution

I’ve literally tried everything, downgrading to an older version (2.4.5), going back to 2.5.1, back to 2.5.2 even went and upgraded to the 2.6.x DEV version (which I’m still running today.) Try as a may, my internet connection disconnected every 30 minutes on the clock.

[**Click here to jump to my solution**](#solution-using-cron-to-force-restart-dhclient)

Debugging the issue was kind of hard, all I had to go was this pattern:

```output
Oct 15 13:27:18 router dpinger[50793]: WANIPTV_DHCP 10.10.56.1: sendto error: 65
Oct 15 13:27:20 router dpinger[50793]: WANIPTV_DHCP 10.10.56.1: Alarm latency 0us stddev 0us loss 100%
Oct 15 13:27:21 router dpinger[67943]: send_interval 500ms loss_interval 2000ms time_period 60000ms report_interval 0ms data_len 1 alert_interval 1000ms latency_alarm 500ms loss_alarm 20% dest_addr 45.146.56.1 identifier "WAN_DHCP "
Oct 15 13:27:21 router dpinger[68139]: send_interval 500ms loss_interval 2000ms time_period 60000ms report_interval 0ms data_len 1 alert_interval 1000ms latency_alarm 500ms loss_alarm 20% dest_addr 10.10.56.1 identifier "WANIPTV_DHCP "
Oct 15 13:27:21 router dpinger[68139]: WANIPTV_DHCP 10.10.56.1: sendto error: 65
Oct 15 13:27:22 router dpinger[71301]: send_interval 500ms loss_interval 2000ms time_period 60000ms report_interval 0ms data_len 1 alert_interval 1000ms latency_alarm 500ms loss_alarm 20% dest_addr 45.146.56.1 identifier "WAN_DHCP "
Oct 15 13:27:22 router dpinger[71688]: send_interval 500ms loss_interval 2000ms time_period 60000ms report_interval 0ms data_len 1 alert_interval 1000ms latency_alarm 500ms loss_alarm 20% dest_addr 10.10.56.1 identifier "WANIPTV_DHCP "
Oct 15 13:27:22 router dpinger[71688]: WANIPTV_DHCP 10.10.56.1: sendto error: 65
Oct 15 13:27:24 router dpinger[71688]: WANIPTV_DHCP 10.10.56.1: Alarm latency 0us stddev 0us loss 100%
Oct 15 13:57:37 router dpinger[71301]: WAN_DHCP 45.146.56.1: Alarm latency 505us stddev 27us loss 22%
```

What is clear about this pattern is that we lose connection to the default gateway (45.146.56.1) every 30 minutes on the clock, I’ve removed a lot of excess lines, but the log continues on like this. Moreover, in the dashboard of pfSense you can see that the gateway is highlighted in red, claiming it is offline, but that didn’t make any sense since my connection on my old consumer router kept on working without a problem.

### Attempted fixes, which didn’t work

I’ve tried debugging the problem by fixing things one by one, starting with putting the gateway in always online mode, which ofcourse didn’t work… thus I tried changing the IP address dpinger attempts to ping to 1.1.1.1 as this server always replies extremely fast (since Cloudflare is located within 1ms of most internet connections.)

After a while it was clear to me that the timings were incorrect in the new default settings of pfSense, at least for my provider, thus I went ahead and changed those trying to get it right. In the end I opted for the FreeBSD default timing. You can do this at **Interfaces** > **WAN** > **DHCP Client Configuration**.  There you enable **Advanced Configuration** and then click on **Presets** > **FreeBSD default** (which is better than the pfSense defaults for my provider.)

Still not having solved the problem I decided to manually install an older binary version of **dpinger**, which I pulled from the pfSense GitHub repo, this also didn’t solve the WAN connection being dropped by dpinger. Moving on I knew for sure that I was facing a DHCP issue, so I tried replacing the **dhclient-script** and even went to the trouble of using an older binary version of **dhclient** which also did not fix any of my problems.

Eventually I even thought that it was a hardware problem, so I went out and bought a new card (Intel DA520-X2) again, but to my surprise, the problem persisted and my connection kept getting dropped. Eventually I decided to attempt manually refreshing my lease and this finally worked! 

Thus, I stumbled upon the solution which I am now sharing with the world as I hope others can benefit from this too.

### Solution Using cron to force restart dhclient

I’ve solved my internet connectivity problems by adding a cronjob in the shell which does a DHCP query on my WAN interfaces every 5 minutes, of every hour, every day, every month, every day of the week as follows:

`*/5 * * * * killall dhclient; dhclient ix0.34; dhclient ix0.4`  

It was easy to implement via the shell, I’m assuming you know how to do this, but if not, try to follow these steps after you’ve entered the BSD terminal as the admin user.

1.  **crontab -e**
2.  <press key: **i**\>
3.  <copy/paste rule above, don’t forget to change to your adapters, e.g. re1>
4.  <press key: **esc**\>
5.  **: x**
6.  <press key: **enter**\>

You should have no more problems with your internet connection, if you had the exact same problem as me. Of course, I’ve tested this solution manually first by running the command in the terminal first before I put I made a cronjob.

Eventually I found that the true issue was caused by a missing directory (**/var/run/dhclient**) creating this directory as the admin user ( **`mkdir /var/run/dhclient`** ) with the default rights also seemed to do the trick for me, I commented out the inital crontab, but ofcourse you can decide which of these two routes you want to go.

Hope this helps some of you out there.

## Final words

Since I am a network automation engineer, I needed to get to the bottom of this problem, I just had to know why this happened.

I’ve done my research and found out that the provider BNG router (Google: BNG/BRAS if you don’t know what this is) leases out address at 1800 second intervals, this was obvious when I used Wireshark and sniffed out their traffic, basically what happened in my case was that my pfSense box didn’t check back in (in time) with my provider, thus the BNG decided to forget and close the session between my ISP and me as the lease time had expired after 30 minutes, meaning that no traffic was able to flow back until pfSense requested an IP address again.

My box is directly connected to the ISP by means of a single mode simplex fiber connected to a BiDi SFP optic housed in a NIC in the form a PCIe x8 Intel X520-DA2 card.


## Reference

- https://forum.netgate.com/topic/111733/interesting-case-of-wan-dropping-daily-dhcp-being-blocked-by-firewall
- https://www.meteen.info/pfsense-disconnecting-wan/

