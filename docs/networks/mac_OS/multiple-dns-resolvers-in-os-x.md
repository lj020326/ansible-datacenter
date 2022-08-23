
# Multiple DNS resolvers in OS X

Lately I’ve been trying out [consul](https://consul.io/) and I love some of its core concepts. One of them is service discovery, which is provided through either an HTTP API or a DNS interface.

The DNS interface works well, but it’s hard to try out on your own laptop. Sure, you can `dig @<consul_server_ip> -p 8600` but anything else turns out to be difficult.

My first try was to use `curl`’s `--dns-servers` option. The documentation reads:

```
--dns-servers <ip-address,ip-address>
       Set  the  list  of  DNS  servers to be used instead of the system
       default.  The list of IP addresses should be separated with commas. Port
       numbers may also optionally be given as :<port-number> after each IP
       address.

       This option requires that libcurl was built with a resolver backend that
       supports this operation. The c-ares backend is the only such one.
       (Added in 7.33.0)
```

Simple enough, right? (#1)

Unfortunately, at the time of writing OS X’s `curl` isn’t compiled with `c-ares` resolver. So let’s compile our own `curl` to bake in the support needed:

`$ brew install curl --with-c-ares`

Simple enough, right? (#2)

Unfortunately, curl times out using `--dns-servers <consul_server_ip>:8600`. A quick `tcpdump` shows requests going out to DNS standard port 53, so something’s up.

I had a quick look at `curl`’s source code, following into `c-ares` source code and found [this gem](https://github.com/bagder/c-ares/blob/e3b04e5a4796215d2483aba3cb75c72ba337ac14/ares_set_servers_csv.3#L37):

```
The port option is currently ignored by c-ares internals
and the standard port is always used.
```

[Aw, blërg](https://www.youtube.com/watch?v=4DuKPHXRLjA)!

As usual with The Internets, someone else already had [a solution for me](https://github.com/bagder/c-ares/pull/19), so I just had to `brew edit curl`, add the following patch and `brew reinstall curl --with-c-ares`:

```
diff --git a/Library/Formula/c-ares.rb b/Library/Formula/c-ares.rb
index 960521c..366fa16 100644
--- a/Library/Formula/c-ares.rb
+++ b/Library/Formula/c-ares.rb
@@ -6,11 +6,9 @@ class CAres < Formula
   url 'http://c-ares.haxx.se/download/c-ares-1.10.0.tar.gz'
   sha1 'e44e6575d5af99cb3a38461486e1ee8b49810eb5'

-  bottle do
-    cellar :any
-    sha1 "aa711a345bac4780f2e7737c212c1fb5f7862de8" => :yosemite
-    sha1 "c6851c662552524fa92e341869a23ea72dbc4375" => :mavericks
-    sha1 "27494a19ac612daedeb55356e911328771f94b19" => :mountain_lion
+  patch do
+    url "https://github.com/bagder/c-ares/pull/19.patch"
+    sha256 "99ef83d196fa550f2c46335abd63d825ba8650d686d7713e774579385d7c8998"
   end

   def install
```

Note: remember to rollback that change after compiling, so that you don’t get merge conflicts next time this formula is updated!

(sidenote: how cool is GitHub?? Just adding a `.diff` or `.patch` gives you exactly what you want!)

So, after all this work, `curl` should work with `consul`’s DNS interface. But in practice, you just enabled `curl` to use alternate DNS servers, not your whole system. Wouldn’t it be great to use your browser to access a web server that `consul` knows about?

This is usually where `/etc/resolv.conf` comes into play. Being OS X though, things aren’t as simple; as far as I could tell, half of the standard \*nix CLI tools have this notice on their man pages:

```
Mac OS X NOTICE
       The host command does not use the host name and address resolution or
       the DNS query routing mechanisms used by other processes running on Mac
       OS X.  The results of name or address queries printed by host may differ
       from those found by other processes that use the Mac OS X native name
       and address resolution mechanisms.  The results of DNS queries may also
       differ from queries that use the Mac OS X DNS routing library.
```

Well, that sucks. But it got me curious as to what exactly is this “Mac OS X native name and address resolution mechanisms”.

`man 5 resolver` is quite interesting in that regard. It suggests the possibility of different DNS configurations for specific domains, so I tried it by creating this file:

```
$ cat /etc/resolver/dc1.consul
domain dc1.consul
port 8600
nameserver <consul_server_1>.8600
nameserver <consul_server_2>.8600
nameserver <consul_server_3>.8600
```

Some of these configs are redundant, namely defining explicitly a domain when the file name should be enough and defining the port in every nameserver when the default port was changed before. This was made to make clear what should be happening here.

Anyway, I also found out a nice little command that lets you check your current DNS configurations (which resolvers you have defined, in which order are they configured, which domains do they resolve): `scutil --dns`

Assuming everything went ok, you should see your custom resolver there.

Another way you can test this now is to run:

```
$ dscacheutil -q host -a name webserver.service.dc1.consul
name: webserver.service.dc1.consul
ip_address: <webserver_ip_address>
```

In other news, you can now use Consul domains directly in your browsers! Sadly, none of the major browsers support [RFC 2782](https://tools.ietf.org/html/rfc2782) SRV lookups, so you’ll still have to add the port if your webserver is running on a non-standard port.

## References

* https://verynomagic.com/2015/07/multiple-dns-resolvers-in-os-x.html
* 
