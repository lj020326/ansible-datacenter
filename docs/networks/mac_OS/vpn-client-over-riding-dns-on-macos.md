
# VPN client over-riding DNS on macOS

Spent a lot of time today with this. Such an irritating topic! Primarily coz there doesn’t seem to be much info on how to do this correctly.

I have blogged about this in the past, in an opposite that. That time once I connect via VPN my [macOS wasn’t picking up the DNS servers offered by VPN](https://rakhesh.com/infrastructure/macos-vpn-doesnt-use-the-vpn-dns/). That was a different VPN solution – the Azure Point to Site VPN client. Since then I have moved to using GlobalProtect and that works differently in that it over-rides the default resolvers and makes the VPN provided ones the primary.

Here was my DNS configuration before connecting to VPN:

```shell
$ scutil --dns
DNS configuration

resolver #1
  nameserver[0] : 2001:8f8:172d:3ca9::1
  nameserver[1] : 192.168.17.1
  if_index : 10 (en0)
  flags    : Request A records, Request AAAA records
  reach    : 0x00020002 (Reachable,Directly Reachable Address)

<snip>

DNS configuration (for scoped queries)

resolver #1
  nameserver[0] : 2001:8f8:172d:3ca9::1
  nameserver[1] : 192.168.17.1
  if_index : 10 (en0)
  flags    : Scoped, Request A records, Request AAAA records
  reach    : 0x00020002 (Reachable,Directly Reachable Address)
```
Once I connect via GlobalProtect these change:

```shell
$ scutil --dns
DNS configuration

resolver #1
  search domain[0] : workdomain.com
  nameserver[0] : 10.222.5.21
  nameserver[1] : 10.222.5.22
  flags    : Request A records, Request AAAA records
  reach    : 0x00000002 (Reachable)
  order    : 50000

<snip>

DNS configuration (for scoped queries)

resolver #1
  nameserver[0] : 2001:8f8:172d:3ca9::1
  nameserver[1] : 192.168.17.1
  if_index : 10 (en0)
  flags    : Scoped, Request A records, Request AAAA records
  reach    : 0x00020002 (Reachable,Directly Reachable Address)
```

And I have no idea how to change the order so that my home router stays at #1 and the VPN provided one is added as #2.

Initially I thought the “order” in the DNS configuration might play a role. So I tried something changing the order of my home router to be better than the VPN one. I tried both setting it to a larger and smaller number, neither worked.

This is how one can try to change the order:

```shell
$ sudo scutil
Password:
> list ".*DNS"
  subKey [0] = State:/Network/Global/DNS
  subKey [1] = State:/Network/MulticastDNS
  subKey [2] = State:/Network/PrivateDNS
  subKey [3] = State:/Network/Service/7EAA1BB9-9BA7-4229-BB0E-70D01326AB21/DNS
> get State:/Network/Service/7EAA1BB9-9BA7-4229-BB0E-70D01326AB21/DNS
> d.show
<dictionary> {
  ServerAddresses : <array> {
    0 : 192.168.17.1
    1 : 2001:8f8:172d:3ca9::1
  }
}
> d.add SearchOrder 100000
> set State:/Network/Service/7EAA1BB9-9BA7-4229-BB0E-70D01326AB21/DNS
> exit
```

Didn’t help.

As an aside, don’t use tools like ping or nslookup to find how your DNS resolution is working. From [this StackOverflow article](https://superuser.com/a/1177211) which I’d like to copy paste here:

> macOS has a sophisticated system for DNS request routing (“scoped queries”) in order to handle cases like VPN, where you might want requests for your work’s domain name to go down your VPN tunnel so that you get answers from your work’s internal DNS servers, which may have more/different information than your work’s external DNS servers.
> 
> To see all the DNS servers macOS is using, and how the query scoping is set up, use: `scutil --dns`
> 
> To query DNS the way macOS does, use: `dns-sd -G v4v6 example.com` or `dns-sd -q example.com`
> 
> DNS-troubleshooting tools such as `nslookup(1)`, `dig(1)`, and `host(1)` contain their own DNS resolver code and don’t make use of the system’s DNS query APIs, so they don’t get the system behavior. If you don’t specify which DNS server for them to use, they will probably just use one of the ones listed in `/etc/resolv.conf`, which is auto-generated and only contains the default DNS servers for unscoped queries.
> 
> Traditional Unix command-line tools that aren’t specific to DNS, such as `ping(8)`, probably call the traditional `gethostbyname(3)` APIs, which, on macOS, make use of the system’s DNS resolver behaviors.
> 
> To see what your DHCP server told your Mac to use, look at the `domain_name_server` line in the output of: `ipconfig getpacket en0`

So ping is probably fine but nslookup and dig are definitely a no-no.

Anyways, in my case I finally decided to do remove the DNS entries provided by VPN altogether and replace it with my home router DNS. I’d have to do this each time I reconnect to VPN, but that can’t be helped I guess. If I launch scutil from the command line and look at the list of services and their DNS settings I can identify the one used by GlobalProtect.

```shell
$ sudo scutil
Password:
> list ".*DNS"
  subKey [0] = State:/Network/Global/DNS
  subKey [1] = State:/Network/MulticastDNS
  subKey [2] = State:/Network/PrivateDNS
  subKey [3] = State:/Network/Service/7EAA1BB9-9BA7-4229-BB0E-70D01326AB21/DNS
  subKey [4] = State:/Network/Service/gpd.pan/DNS
> get State:/Network/Service/gpd.pan/DNS
> d.show
<dictionary> {
  SearchDomains : <array> {
    0 : workdomain.com
  }
  SearchOrder : 50000
  ServerAddresses : <array> {
    0 : 10.222.5.21
    1 : 10.222.5.22
  }
}
```

I just chose to over-ride both the `SearchDomain` and `ServerAddresses` with my local settings (thanks to [this post](https://apple.stackexchange.com/a/101827) and [this](http://hints.macworld.com/article.php?story=20050621051643993)):

```shell
> d.remove SearchDomains
> d.remove ServerAddress
> d.add ServerAddresses * 192.168.17.1 2001:8f8:172d:3ca9::1
> set State:/Network/Service/gpd.pan/DNS
> exit
```

For my own copy paste convenience for next time, here’s what I would have to do once I launch `scutil`:

```shell
get State:/Network/Service/gpd.pan/DNS
d.remove SearchDomains
d.remove ServerAddress
d.add ServerAddresses * 192.168.17.1 2001:8f8:172d:3ca9::1
set State:/Network/Service/gpd.pan/DNS
exit
```

Ok, so far so good. But what if I also want resolution to the VPN domains working via VPN DNS servers when I am connected? Here I go back to what I did in my [previous blog post](https://rakhesh.com/infrastructure/macos-vpn-doesnt-use-the-vpn-dns/). I create multiple files under `/etc/resolver` for scoped queries, each having different search\_order (queries to internal DNS have a lower `search_order` and a timeout; queries to external DNS have a higher `search_order`).

**Update**: Turns out GlobalProtect over-writes the DNS settings periodically. So I made a script as below in my home directory:

```shell
#!/bin/bash

sudo scutil << EOF
get State:/Network/Service/gpd.pan/DNS
d.remove SearchDomains
d.remove ServerAddress
d.add ServerAddresses * 192.168.17.1 2001:8f8:172d:3ca9::1
set State:/Network/Service/gpd.pan/DNS
exit
EOF
```

And put it in my crontab:

```shell
@hourly /fixDNS.sh
```


## Reference

* https://rakhesh.com/powershell/vpn-client-over-riding-dns-on-macos/
* 
