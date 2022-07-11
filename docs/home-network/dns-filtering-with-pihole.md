
# DNS Filtering with PiHole

In [part one](container-visibility-and-dashboards.md) of this series I laid out the various components that I used on my home network to create dashboard that gives me an overview of the platform health.

This part of the series will cover DNS and DNS Filtering using the [PiHole](https://www.pi-hole.net/) project, then we’ll move on to the setup for container management and finally we’ll look at the monitoring side of things.

## What is DNS, and why do we want to filter it?

When we connect a device to a network, it receives something called an “IP Address”. This is a series of numbers (for version 4!) or letters and numbers (version 6!) and it is unique to each device on the network.

These IP Addresses are grouped into groups of addresses called “subnets”, and then our router (remember them from the [networking guide](https://www.budgetsmarthome.co.uk/2021/02/09/the-network-part-2-routers-switches-and-access-points/) a few weeks back?) ensures that the data can flow between the subnets and across the internet.

IP Addresses for IPv4 (and that’s what we’ll focus on here as not many networks use IPv6) are made up of 4 sets of three digits between 0 and 255, separated by a full stop, with `0` and `255` being reserved values.

As an example, the following are all valid IP addresses:

```
10.10.10.10
127.0.0.1   # Often called "localhost" and will exist on a network-capable device even if it is not attached to another network
8.8.8.8     
169.254.169.254
```

If you only have one network, and a handful of devices, then it’s relatively easy to track what lives where and on which address. The webserver is on `192.168.1.10`, your [home hub](https://www.budgetsmarthome.co.uk/2021/02/02/choosing-a-hub/) is on `192.168.1.5` etc, but then we start to get multiple subnets and significant numbers of devices and we can’t remember it all off the top of our head - this is where DNS comes in.

If the IP Address is the equivalent of a street address, DNS is the equivalent of [WhatThreeWords](https://what3words.com/). DNS maps human-readable, easy to remember labels to IP Addresses, letting us visit `http://web/` in our browser and automatically translating that to `192.168.1.10` in the background.

So how does this help us block adverts or unwanted content?

Most websites that you visit on a day to day basis almost certainly have more than one server behind them. This means that if a website tries to tell Facebook or Google about your browsing behaviour, we can’t just block a single IP Address as the code will use DNS to access a different one.

If we block at the DNS level then it means any requests to the advertising or data collection networks can be blocked at the local network, meaning that the tracking data never leaves our network.

## So how does PiHole work then?

Once PiHole is installed (more on that in a bit!), we configure it to act as a DNS server on our local network. We then point all of our clients at the PiHole installation, and when we request a website that PiHole doesn’t want us to access, it returns an error instead of resolving it to the correct IP Address.

By default, PiHole blocks adverts, however you can add additional blocklists to filter out adult content and various other services.

## How do I install PiHole?

If we take another look at our network diagram, we can see that we’re going to install PiHole on a pair of Raspberry Pi computers.

It’s probably key to say here that PiHole does _not_ need to run on a pi in order to work, it can be installed on any Linux server and even runs in docker containers, but for now we’ll stick with running it directly on a pi because it removes some of the complications around sharing resources and network ports.

It’s also worth pointing out that you can run just one copy of PiHole on your network - I’m only running two because I get complaints if “the internet” disappears for more than 30 seconds in our house, so running an extra one gives me redundancy!

[![](https://www.budgetsmarthome.co.uk/img/HomeLabOverview.png)](https://www.budgetsmarthome.co.uk/img/HomeLabOverview.png)

The [installation instructions](https://github.com/pi-hole/pi-hole/#one-step-automated-install) are pretty straight forward (although I’d always recommend you [read the script you’re about to run](https://github.com/pi-hole/pi-hole/blob/master/automated%20install/basic-install.sh) before running it like this!) so we won’t focus too much on that, but here’s what you’ll want to do in order to get up and running (Note, you’ll need to do this on both Pi’s if you’re running the same setup as I am!):

1.  Make sure you have a [fresh installation](https://www.raspberrypi.org/software/operating-systems/) - make sure it’s **Raspberry Pi OS Lite**, and _before_ you put the SD Card into the pi, open it in file manager and add a completely empty file called `ssh` to the **boot** partition
2.  Assign the Raspberry Pi a static IP Address on your router.
3.  Boot the Pi and log in via SSH (If you’re on Windows, take a look at [Putty](https://www.putty.org/) for an SSH Client) - you’ll want to use `pi` as the username, and `raspberry` as the password
4.  Change the password to something more secure by running `passwd` and entering `raspberry` for the “Current Password” and something of your own creation as the “New Password”
5.  Update the Pi to the latest version of the operating system by running `sudo apt update && sudo apt upgrade -y`
6.  Reboot the pi
7.  Reconnect to the pi and [run the PiHole installer](https://github.com/pi-hole/pi-hole/#one-step-automated-install) - Accept the default DNS servers for now, we’ll add our own later.
8.  Open a web browser and go to the address displayed on the output of the installation command, then log in to check that everything is running.
9.  Update the DNS Servers on your local machine to point to the PiHole IP Address then browse the internet, you should see traffic starting to be graphed on the interface and ad sites such as google ads being blocked.

### Multiple Pi-Hole instances

If you’re running multiple Pi-Hole servers we’ll need to setup a sync of the database that contains the blocklist. Fortunately there’s a tool to deal with this for us called [Gravity Sync](https://github.com/vmstan/gravity-sync/) so let’s go ahead and set that up now.

Decide which of your PiHole servers will be your “primary”. This is where you’ll make all your changes, and they will be synchronised to the secondary server.

Follow the [gravity sync installation instructions](https://github.com/vmstan/gravity-sync/wiki/Installing), ensuring that you execute the commands on the appropriate server.

Once Gravity is installed and configured, make a change on the primary such as adding a site to the blocklist, and then log on to the secondary PiHole and run the gravity-sync.sh command. Now log in to the admin interface on the secondary server and make sure that the change to the blocklist has shown up.

**NOTE:** If you decide to automate the Gravity Sync, I’d recommend doing it once a day in the middle of the night. I’m not 100% sure yet, but it does look like Gravity Sync prevents DNS queries from succeeding whilst the sync is in place, resulting in brief outages of your internet access. I’ll be troubleshooting this very soon and amending this post if that does turn out to be the case!

## Configuring the network to use the new servers

Now that the PiHole boxes have been configured and are running, it’s time to switch all our network devices over to start using them, and we do this by updating the DHCP options on our router.

If you’re running Unifi, then you’re looking for the DHCP Nameserver section in the network configuration:

[![](https://www.budgetsmarthome.co.uk/img/UnifiNameServers.png)](https://www.budgetsmarthome.co.uk/img/UnifiNameServers.png)

If you’re using another router, then you’ll want to update the settings accordingly in the relevant section of your admin console - look for “DNS Servers” or similar, and if they’re currently set to something other than your PiHole boxes then change it.

Finally, log in to the admin consoles on your PiHole servers and take a look at the dashboards, you should start to see multiple clients and sites being accessed, with ad sites such as google tag manager and the like being blocked.

If you’ve read this far, well done - this is definitely one of the longest posts I’ve written so far on this blog _and_ one of the most technical.

Next time, we’ll look at installing the Container Orchestration and Service discovery parts of the platform in preparation for configuring our monitor and logging solution!