
# Mac OS X - DNS resolving

I am using a MacBook with Mac OS X 10.8.2 and connect to my company's network via VPN. Everything works great when establishing the VPN connection via LAN or WLAN. However, when I use a dial-up connection (Huawei HSDPA USB Stick) host names are not correctly resolved in applications (e.g. Web-Browser). Command line tools like `host name` will correctly resolve the IP address, `ping name` will not resolve.

Using `scutil --dns` I dumped the DNS configuration when connecting via WLAN vs. dial-up. There is a notable difference in the lookup order:

```
connecting using WLAN:

resolver #1
  nameserver[0] : 192.168.80.10
  nameserver[1] : 192.168.80.24
  if_index : 6 (ppp0)
  reach    : Reachable,Transient Connection
  order    : 100000

resolver #2
  nameserver[0] : 192.168.80.10
  nameserver[1] : 192.168.80.24
  if_index : 6 (ppp0)
  reach    : Reachable,Transient Connection
  order    : 200000

resolver #3
  domain   : local
  options  : mdns
  timeout  : 5
  order    : 300000

resolver #4
  domain   : 254.169.in-addr.arpa
  options  : mdns
  timeout  : 5
  order    : 300200

resolver #5
  domain   : 8.e.f.ip6.arpa
  options  : mdns
  timeout  : 5
  order    : 300400

resolver #6
  domain   : 9.e.f.ip6.arpa
  options  : mdns
  timeout  : 5
  order    : 300600

resolver #7
  domain   : a.e.f.ip6.arpa
  options  : mdns
  timeout  : 5
  order    : 300800

resolver #8
  domain   : b.e.f.ip6.arpa
  options  : mdns
  timeout  : 5
  order    : 301000

DNS configuration (for scoped queries)

resolver #1
  nameserver[0] : 192.168.1.1
  if_index : 4 (en0)
  flags    : Scoped
  reach    : Reachable,Directly Reachable Address

resolver #2
  nameserver[0] : 192.168.80.10
  nameserver[1] : 192.168.80.24
  if_index : 6 (ppp0)
  flags    : Scoped
  reach    : Reachable,Transient Connection
```

The ppp0 connection is the VPN connection. As you can see, two servers are connected and they answer correctly on the command line and in applications.

```
Connecting via UMTS:

resolver #1
  nameserver[0] : 139.7.30.126
  nameserver[1] : 139.7.30.125
  if_index : 6 (ppp0)
  reach    : Reachable,Transient Connection
  order    : 100000

resolver #2
  nameserver[0] : 192.168.80.10
  nameserver[1] : 192.168.80.24
  if_index : 7 (ppp1)
  reach    : Reachable,Transient Connection
  order    : 100000

resolver #3
  nameserver[0] : 192.168.80.10
  nameserver[1] : 192.168.80.24
  if_index : 7 (ppp1)
  reach    : Reachable,Transient Connection
  order    : 200000

resolver #4
  domain   : local
  options  : mdns
  timeout  : 5
  order    : 300000

resolver #5
  domain   : 254.169.in-addr.arpa
  options  : mdns
  timeout  : 5
  order    : 300200

resolver #6
  domain   : 8.e.f.ip6.arpa
  options  : mdns
  timeout  : 5
  order    : 300400

resolver #7
  domain   : 9.e.f.ip6.arpa
  options  : mdns
  timeout  : 5
  order    : 300600

resolver #8
  domain   : a.e.f.ip6.arpa
  options  : mdns
  timeout  : 5
  order    : 300800

resolver #9
  domain   : b.e.f.ip6.arpa
  options  : mdns
  timeout  : 5
  order    : 301000

DNS configuration (for scoped queries)

resolver #1
  nameserver[0] : 192.168.80.10
  nameserver[1] : 192.168.80.24
  if_index : 7 (ppp1)
  flags    : Scoped
  reach    : Reachable,Transient Connection

resolver #2
  nameserver[0] : 139.7.30.126
  nameserver[1] : 139.7.30.125
  if_index : 6 (ppp0)
  flags    : Scoped
  reach    : Reachable,Transient Connection
```

This time, ppp1 is the VPN connection and ppp0 is the UMTS connection. From the response times of the commands (using the non-existing hostname `foo.bar.local`) I infer that `ping` uses the first resolver chain, where as `host` uses the scoped query configuration. `ping` takes 5 seconds to return "Unkown host", `host`gets back immediately. I assume ping runs into the 5 second timeout of the mdns resolver.

In order to fix my problem with the broken DNS lookups when dialing in via VPN over modem I need to change the order of the resolvers. So far I have not found a way of doing this.

## Solution

I had the same problem on my Mac, and after fixing it I have figured out that it was caused by [FortiClient](http://www.forticlient.com) (VPN client). Even when FortiClient was disconnected - it's DNS still appeared in the scutil.

The solution for me was:

```
scutil
> list ".*DNS"
```

This will show you a list of all DNS configs, that will look something like:

```
subKey [0] = State:/Network/Global/DNS <br>
subKey [1] = State:/Network/MulticastDNS<br>
subKey [2] = State:/Network/OpenVPN/DNS<br>
subKey [3] = State:/Network/OpenVPN/OldDNS<br>
subKey [4] = State:/Network/PrivateDNS<br>
subKey [5] = State:/Network/Service/forticlientsslvpn/DNS <br>
```

To check each of them run: (until you find the problematic one)

```
> get key_name
> d.show
```

…and to fix it run:

```
> get key_name
> d.remove ServerAddresses
> set key_name
```

This is how it looked on my machine:

```
> get State:/Network/Service/forticlientsslvpn/DNS 
> d.show
<dictionary> {
  ServerAddresses : <array> {
    0 : 192.168.30.6
    1 : 192.168.30.15
  }
  SupplementalMatchDomains : <array> {
    0 :
  }
  SupplementalMatchOrders : <array> {
    0 : 100000
  }
}
> d.remove ServerAddresses
> d.show
<dictionary> {
  SupplementalMatchDomains : <array> {
    0 :
  }
  SupplementalMatchOrders : <array> {
    0 : 100000
  }
}
> set State:/Network/Service/forticlientsslvpn/DNS
> exit
```


## References

* https://apple.stackexchange.com/questions/73076/mac-os-x-mountain-lion-dns-resolving-uses-wrong-order-on-vpn-via-dial-up-conne
