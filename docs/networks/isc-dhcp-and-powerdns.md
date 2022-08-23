
# ISC DHCP and PowerDNS

## This blog post is \*ancient\*, and preserved only for historical record.

Lately, I’ve been playing around with a pair of domain controllers in the office, trying to figure out a good way to implement a domain. See, the problem is, this kind of thing is a “nice-to-have” rather than a core requirement. At least as far as the business directors are concerned. Their argument is something like “It worked fine with just a bunch of PCs connected to a switch”.

I do like things manageable, and planned, and certainly now as we’re approaching 50 desktops in the office, plus mobile devices, plus laptops, and FSM knows what else, that there’s a real need for a bit more structure and management.

I ditched the Draytek’s DHCP ability to allow me to test out Windows 2008R2’s DNS / DHCP server, which interoperate fabulously, but do have a few limitations when it comes to specifying static leases (outside of the dynamic range). Bit annoying.

It does however do the dynamic dns updates, whenever a client gets a new lease, the DNS gets updated automatically. This is cool indeed.

I’ve been thinking of a way to replace this DNS and DHCP functionality with a bit of open-source goodness, because it’s a nice thing to have, and even nicer to have for free.

I chose [PowerDNS](https://www.powerdns.com/index.html), because, well, I like it, and it’s pretty scalable. Apparently it’s the DNS of choice for the Wikimedia foundation, and i’ve used it before in a couple of other tasks. It’s got a pretty nice MySQL backend, and also one for Postgres. For the time being, i’ll be using the MySQL one, because that’s what we tend to use around here.

So.. DHCPd, I chose [ISC’s DHCPd](https://www.isc.org/dhcp/), because it’s easily installed in Ubuntu. Always a winner there.

After a considerable amount of googling around, I figured out how to use the dhcpd.conf file to trigger an event to happen on commit, release and expiry hooks. [https://lists.isc.org/mailman/htdig/dhcp-users/2011-February/012753.html](https://lists.isc.org/mailman/htdig/dhcp-users/2011-February/012753.html) and [http://invalidmagic.wordpress.com/2010/03/27/magic-dhcp-stuff-isc-dynamic-host-configuration-protocol/](http://invalidmagic.wordpress.com/2010/03/27/magic-dhcp-stuff-isc-dynamic-host-configuration-protocol/) were pretty useful.

Then all I had to do was write a bit of python that would interact with the database, and update the records table.

Two major things caught me out.

1.  Don’t forget to `COMMIT` the data to the database, PowerDNS uses InnoDB on MySQL, so you’ll need to commit the transaction, or bugger all happens.
    
2.  apparmor on Ubuntu prevents dhcpd from using the exec() syscall. This is easily resolved by setting apparmor from enforcing to complaining for dhcpd.
    

Here’s a couple of bits of code, one is the python updater, and the other shows how this all fits into the dhcpd.conf file.

[dhcp-event](code/dhcpevent.py)

[dhcpd.conf](code/dhcp.conf)

___