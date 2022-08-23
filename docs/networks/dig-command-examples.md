
# Dig Command Examples To Query DNS In Linux

Dig (domain information groper) is a tool that is used for querying DNS servers for various DNS records, making it very useful for troubleshooting DNS problems.

By the end of this guide you will know how to use dig to perform different types of DNS lookups in Linux.

## Install Dig

In order to use the dig command we must first install it. In CentOS/RHEL/Fedora dig is part of the ‘bind-utils’ package.

CentOS/RHEL/Fedora

```
[root@centos7 ~]# yum install bind-utils -y

```

For Debian/Ubuntu based distributions it comes from the ‘dnsutils’ package.

Debian/Ubuntu

```
root@datacomtss:~# apt-get install dnsutils -y

```

## How To Use dig – Command Examples

-   ### 1\. Basic DNS Query
    
    In its most simplest form we can specify a domain name after the dig command and it will perform a DNS lookup, as shown below.
    
    ```
    [root@centos7 ~]# dig google.com
    
    ; <<>> DiG 9.9.4-RedHat-9.9.4-29.el7_2.3 <<>> google.com
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 32702
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
    
    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; MBZ: 0005 , udp: 4000
    ;; QUESTION SECTION:
    ;google.com.                    IN      A
    
    ;; ANSWER SECTION:
    google.com.             5       IN      A       216.58.220.110
    
    ;; Query time: 27 msec
    ;; SERVER: 192.168.220.2#53(192.168.220.2)
    ;; WHEN: Tue Sep 06 09:13:28 AEST 2016
    ;; MSG SIZE  rcvd: 55
    
    ```
    
    In this output we can see that google.com has an A record pointing to the IP address 216.58.220.110.
    
    By default with no name server specified the DNS resolver in the /etc/resolv.conf file will be used, dig will also look for an A record with no other options specified.
    
-   ### 2\. Query Specific Name Server
    
    In the above example we did not query any specific name server, so our query would have been sent to whatever is configured in our /etc/resolv.conf file which will contain the DNS resolvers that our Linux system is configured to use. We can specify a name server to send the query to with the @ symbol, followed by the hostname or IP address of the name server to communicate with.
    
    ```
    [root@centos7 ~]# dig @8.8.8.8 google.com
    
    ; <<>> DiG 9.9.4-RedHat-9.9.4-29.el7_2.3 <<>> @8.8.8.8 google.com
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 62632
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 15, AUTHORITY: 0, ADDITIONAL: 1
    
    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 512
    ;; QUESTION SECTION:
    ;google.com.                    IN      A
    
    ;; ANSWER SECTION:
    google.com.             299     IN      A       150.101.161.222
    google.com.             299     IN      A       150.101.161.251
    google.com.             299     IN      A       150.101.161.237
    google.com.             299     IN      A       150.101.161.221
    google.com.             299     IN      A       150.101.161.219
    google.com.             299     IN      A       150.101.161.230
    google.com.             299     IN      A       150.101.161.241
    google.com.             299     IN      A       150.101.161.226
    google.com.             299     IN      A       150.101.161.234
    google.com.             299     IN      A       150.101.161.207
    google.com.             299     IN      A       150.101.161.245
    google.com.             299     IN      A       150.101.161.236
    google.com.             299     IN      A       150.101.161.211
    google.com.             299     IN      A       150.101.161.249
    google.com.             299     IN      A       150.101.161.215
    
    ;; Query time: 166 msec
    ;; SERVER: 8.8.8.8#53(8.8.8.8)
    ;; WHEN: Tue Sep 06 09:15:17 AEST 2016
    ;; MSG SIZE  rcvd: 279
    
    ```
    
    Note that as we are now specifying some external name server to query, our network needs to permit outbound access to this destination on port 53, otherwise the query will fail.
    
-   ### 3\. Search For Record Type
    
    So far we have seen that by default dig will return the A record, however we can specify any other records that we wish to query by simply appending the record type to the end of the query. In this example, we lookup the MX records associated with google.com.
    
    ```
    [root@centos7 ~]# dig @8.8.8.8 google.com MX
    
    ; <<>> DiG 9.9.4-RedHat-9.9.4-29.el7_2.3 <<>> @8.8.8.8 google.com MX
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 39927
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 5, AUTHORITY: 0, ADDITIONAL: 1
    
    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 512
    ;; QUESTION SECTION:
    ;google.com.                    IN      MX
    
    ;; ANSWER SECTION:
    google.com.             599     IN      MX      30 alt2.aspmx.l.google.com.
    google.com.             599     IN      MX      40 alt3.aspmx.l.google.com.
    google.com.             599     IN      MX      10 aspmx.l.google.com.
    google.com.             599     IN      MX      50 alt4.aspmx.l.google.com.
    google.com.             599     IN      MX      20 alt1.aspmx.l.google.com.
    
    ;; Query time: 180 msec
    ;; SERVER: 8.8.8.8#53(8.8.8.8)
    ;; WHEN: Tue Sep 06 09:17:54 AEST 2016
    ;; MSG SIZE  rcvd: 147
    
    ```
    
    In this example we can see 5 different MX records returned, all with varying priority. Generally the record with the lowest priority will be used first, so in this case aspmx.l.google.com.
    
-   ### 4\. Reverse DNS Lookup
    
    We can use the dig command to perform a reverse DNS lookup, that is we can query an IP address and find the domain name that it points to by querying the PTR record. This is done by using the -x option followed by the IP address to query. In the below example we perform a reverse lookup on one of the IP addresses that google.com resolved to in the first example.
    
    ```
    [root@centos7 ~]# dig -x 216.58.220.110
    
    ; <<>> DiG 9.9.4-RedHat-9.9.4-29.el7_2.3 <<>> -x 216.58.220.110
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 19387
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1
    
    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; MBZ: 0005 , udp: 4000
    ;; QUESTION SECTION:
    ;110.220.58.216.in-addr.arpa.   IN      PTR
    
    ;; ANSWER SECTION:
    110.220.58.216.in-addr.arpa. 5  IN      PTR     syd10s01-in-f14.1e100.net.
    110.220.58.216.in-addr.arpa. 5  IN      PTR     syd10s01-in-f110.1e100.net.
    
    ;; Query time: 2 msec
    ;; SERVER: 192.168.220.2#53(192.168.220.2)
    ;; WHEN: Tue Sep 06 09:20:38 AEST 2016
    ;; MSG SIZE  rcvd: 126
    
    ```
    
    This IP address has two PTR records, pointing to syd10s01-in-f14.1e100.net and syd10s01-in-f110.1e100.net.
    
-   ### 5\. Trace DNS Path
    
    We can perform a trace on the DNS lookup path with the +trace option, as shown below while querying google.com we can see what actually happens. First the root name servers for '.' are looked up, followed by the name servers for the .com domain, and then finally the name servers for google.com are returned, followed by the DNS records for it.
    
    ```
    [root@centos7 ~]# dig google.com +trace
    
    ; <<>> DiG 9.9.4-RedHat-9.9.4-29.el7_2.3 <<>> google.com +trace
    ;; global options: +cmd
    .                       5       IN      NS      h.root-servers.net.
    .                       5       IN      NS      g.root-servers.net.
    .                       5       IN      NS      f.root-servers.net.
    .                       5       IN      NS      e.root-servers.net.
    .                       5       IN      NS      d.root-servers.net.
    .                       5       IN      NS      c.root-servers.net.
    .                       5       IN      NS      b.root-servers.net.
    .                       5       IN      NS      a.root-servers.net.
    ;; Received 493 bytes from 192.168.220.2#53(192.168.220.2) in 671 ms
    
    com.                    172800  IN      NS      a.gtld-servers.net.
    com.                    172800  IN      NS      b.gtld-servers.net.
    com.                    172800  IN      NS      c.gtld-servers.net.
    com.                    172800  IN      NS      d.gtld-servers.net.
    com.                    172800  IN      NS      e.gtld-servers.net.
    com.                    172800  IN      NS      f.gtld-servers.net.
    com.                    172800  IN      NS      g.gtld-servers.net.
    com.                    172800  IN      NS      h.gtld-servers.net.
    com.                    86400   IN      DS      30909 8 2 E2D3C916F6DEEAC73294E8268FB5885044A833FC5459588F4A9184CF C41A5766
    com.                    86400   IN      RRSIG   DS 8 1 86400 20160915170000 20160905160000 46551 . aRW+mmwKW6sWvAef35LCj5ZeQkFrOP8uWwMjQkPIqMfayBRuK1YuqF0h Pu0v4ZBaXPxj0KjmwLIry+Y8p6gIX7lFATfQmUNJcmFxaPYDdEuLYW4S 4idKDZkkEWA3LLUn9OQ0EdioR1PdVr/4xY/u48066DFDx5Vg6aEs1/0Q oXY=
    ;; Received 734 bytes from 192.203.230.10#53(e.root-servers.net) in 215 ms
    
    google.com.             172800  IN      NS      ns2.google.com.
    google.com.             172800  IN      NS      ns1.google.com.
    google.com.             172800  IN      NS      ns3.google.com.
    google.com.             172800  IN      NS      ns4.google.com.
    CK0POJMG874LJREF7EFN8430QVIT8BSM.com. 86400 IN NSEC3 1 1 0 - CK0Q1GIN43N1ARRC9OSM6QPQR81H5M9A NS SOA RRSIG DNSKEY NSEC3PARAM
    CK0POJMG874LJREF7EFN8430QVIT8BSM.com. 86400 IN RRSIG NSEC3 8 2 86400 20160911044243 20160904033243 27452 com. F8heeEXQl6/iOiPAJxfH/dIE7k6NkI0KDRH+evPdZJV6dUs4bYIfbvwI dIEmEDB1wn28MntLpjEixu+64VusOHrUaOXzg5I26D+UbUmksImr2a/P 39zxhHLIRJgYEUxrE1HrID+xY+PewGq3/aEVvPKofbO7/FyBJlmftQn6 12o=
    S84AE3BIT99DKIHQH27TRC0584HV5KOH.com. 86400 IN NSEC3 1 1 0 - S84J17P3PT4RKMEJOHNGD73C5Q5NV5S9 NS DS RRSIG
    S84AE3BIT99DKIHQH27TRC0584HV5KOH.com. 86400 IN RRSIG NSEC3 8 2 86400 20160909045208 20160902034208 27452 com. vxkCSPNnOpLiQNpsk1ZpsQzGMzNdbSpL6Up0Z0njXJrRUdD5eHC/tgnA cHc5mDX2IuuBqU65hZd40U2pSYCBeb5BfaRd9gaQIMyLBbBzd9nj2E+F 8LnTRqa+oXeYQVO1AlfysumdS/CgxwN0CidhCPxPQpPtfdnl6UaKxCzL 5d4=
    ;; Received 660 bytes from 192.31.80.30#53(d.gtld-servers.net) in 201 ms
    
    google.com.             300     IN      A       150.101.161.211
    google.com.             300     IN      A       150.101.161.207
    google.com.             300     IN      A       150.101.161.221
    google.com.             300     IN      A       150.101.161.222
    google.com.             300     IN      A       150.101.161.237
    google.com.             300     IN      A       150.101.161.245
    google.com.             300     IN      A       150.101.161.215
    google.com.             300     IN      A       150.101.161.234
    google.com.             300     IN      A       150.101.161.236
    google.com.             300     IN      A       150.101.161.230
    google.com.             300     IN      A       150.101.161.241
    google.com.             300     IN      A       150.101.161.251
    google.com.             300     IN      A       150.101.161.219
    google.com.             300     IN      A       150.101.161.249
    google.com.             300     IN      A       150.101.161.226
    ;; Received 268 bytes from 216.239.38.10#53(ns4.google.com) in 185 ms
    
    ```
    
-   ### 6\. Adjust Answer Size
    
    By default dig runs with full long output, which displays a lot of verbose information. While useful, there may be times where we simply want our result returned. This can be achieved with the +short option, as shown below when we query google.com we only see the IP address result without any further information.
    
    ```
    [root@centos7 ~]# dig google.com +short
    216.58.220.110
    
    ```
    
-   ### 7\. Lookup From File
    
    Specifying a single domain after the dig command is not the only way to perform a lookup, we can also supply dig a list of domains from a file (one domain per line) which can be useful if you need to script bulk DNS lookups. In the below example, we use the -f option to read the file query.txt which contains three domains. For brevity I have also made use of +short here so we only see the IP addresses returned rather than the full output which would be quite long.
    
    ```
    [root@centos7 ~]# cat query.txt
    google.com
    yahoo.com
    rootusers.com
    
    [root@centos7 ~]# dig -f query.txt +short
    216.58.220.110
    98.139.183.24
    206.190.36.45
    98.138.253.109
    104.24.11.91
    104.24.10.91
    
    ```
    
-   ### 8\. Specify Port Number
    
    By default the dig command queries port 53 which is the standard DNS port, however we can optionally specify an alternate port if required. This may be useful if an external name server is configured to use a non standard port for some reason. We specify the port to query with the -p option, followed by the port number. In the below example we perform a DNS query to port 5300.
    
    ```
    [root@centos7 ~]# dig @8.8.8.8 -p 5300 google.com
    
    ; <<>> DiG 9.9.4-RedHat-9.9.4-29.el7_2.3 <<>> @8.8.8.8 -p 5300 google.com
    ; (1 server found)
    ;; global options: +cmd
    ;; connection timed out; no servers could be reached
    
    ```
    
    Note that the external name server must actually be listening for traffic on this port specified, and its firewall will also need to allow the traffic through otherwise the lookup will fail. In this example the connection times out, as 8.8.8.8 is not configured to listen on the random port 5300 that I selected for this example.
    
-   ### 9\. Use IPv4 Or IPv6
    
    By default our dig queries are running over the IPv4 network, we can specify if we want to use the IPv4 transport with the -4 option, or alternatively we can specify to use the IPv6 transport with the -6 option.
    
    ```
    [root@centos7 ~]# dig -6 @2001:4860:4860::8888 google.com A
    
    ; <<>> DiG 9.3.6-P1-RedHat-9.3.6-25.P1.el5_11.8 <<>> @2001:4860:4860::8888 google.com A
    ; (1 server found)
    ;; global options:  printcmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 40588
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 6, AUTHORITY: 0, ADDITIONAL: 0
    
    ;; QUESTION SECTION:
    ;google.com.INA
    
    ;; ANSWER SECTION:
    google.com.294INA66.102.1.113
    google.com.294INA66.102.1.101
    google.com.294INA66.102.1.138
    google.com.294INA66.102.1.100
    google.com.294INA66.102.1.139
    google.com.294INA66.102.1.102
    
    ;; Query time: 6 msec
    ;; SERVER: 2001:4860:4860::8888#53(2001:4860:4860::8888)
    ;; WHEN: Tue Sep  6 13:21:10 2016
    ;; MSG SIZE  rcvd: 124
    
    ```
    
    Note that your Linux system will need to have an IPv6 network configured for this to work correctly.
    
-   ### 10\. Query All DNS Record Types
    
    We can use the 'ANY' option to query all DNS record types, this way we can quickly see all DNS records available for a domain. In the below example we can see the results for all types of different records, including A, AAAA, TXT, MX and NS.
    
    ```
    [root@centos7 ~]# dig google.com ANY
    
    ; <<>> DiG 9.9.4-RedHat-9.9.4-29.el7_2.3 <<>> google.com ANY
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 16952
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 12, AUTHORITY: 0, ADDITIONAL: 11
    
    ;; QUESTION SECTION:
    ;google.com.                    IN      ANY
    
    ;; ANSWER SECTION:
    google.com.             5       IN      A       216.58.220.110
    google.com.             5       IN      NS      ns4.google.com.
    google.com.             5       IN      NS      ns3.google.com.
    google.com.             5       IN      NS      ns1.google.com.
    google.com.             5       IN      NS      ns2.google.com.
    google.com.             5       IN      MX      50 alt4.aspmx.l.google.com.
    google.com.             5       IN      MX      20 alt1.aspmx.l.google.com.
    google.com.             5       IN      MX      30 alt2.aspmx.l.google.com.
    google.com.             5       IN      MX      10 aspmx.l.google.com.
    google.com.             5       IN      MX      40 alt3.aspmx.l.google.com.
    google.com.             5       IN      TXT     "v=spf1 include:_spf.google.com ~all"
    google.com.             5       IN      AAAA    2404:6800:4006:801::200e
    
    ;; ADDITIONAL SECTION:
    ns4.google.com.         5       IN      A       216.239.38.10
    ns3.google.com.         5       IN      A       216.239.36.10
    ns1.google.com.         5       IN      A       216.239.32.10
    ns2.google.com.         5       IN      A       216.239.34.10
    alt4.aspmx.l.google.com. 5      IN      A       173.194.219.27
    alt4.aspmx.l.google.com. 5      IN      AAAA    2607:f8b0:4002:c03::1a
    alt1.aspmx.l.google.com. 5      IN      A       74.125.198.27
    alt1.aspmx.l.google.com. 5      IN      AAAA    2607:f8b0:400e:c03::1b
    alt2.aspmx.l.google.com. 5      IN      A       64.233.182.27
    alt2.aspmx.l.google.com. 5      IN      AAAA    2607:f8b0:4003:c05::1a
    aspmx.l.google.com.     5       IN      A       64.233.188.27
    
    ;; Query time: 28 msec
    ;; SERVER: 192.168.220.2#53(192.168.220.2)
    ;; WHEN: Tue Sep 06 09:53:06 AEST 2016
    ;; MSG SIZE  rcvd: 512
    
    ```
    
    It should be noted that some name servers do not support this and will deny the request, for example many domains behind Cloudflare will simply return the below record only.
    
    ```
    cloudflare.com.         5       IN      HINFO   "Please stop asking for ANY" "See draft-ietf-dnsop-refuse-any"
    
    ```
    
-   ### 11\. Customize Dig Output
    
    There are many different options that we can specify to customize what the dig command will print out.
    
    **Hide All**  
    With the +noall option, we can hide almost all output.
    
    ```
    [root@centos7 ~]# dig google.com +noall
    
    ; <<>> DiG 9.9.4-RedHat-9.9.4-29.el7_2.3 <<>> google.com +noall
    ;; global options: +cmd
    
    ```
    
    Now from this clean base, we can choose what we want to display. We can also disable components from the default output in a similar manner.
    
    **Print Statistics**  
    By default some basic statistics appear at the bottom of the dig query, including query time, the server queried, when it happened and the message size. These can be removed with the +nostats option, or added with +stats.
    
    ```
    [root@centos7 ~]# dig google.com +noall +stats
    
    ; <<>> DiG 9.9.4-RedHat-9.9.4-29.el7_2.3 <<>> google.com +noall +stats
    ;; global options: +cmd
    ;; Query time: 2 msec
    ;; SERVER: 192.168.220.2#53(192.168.220.2)
    ;; WHEN: Tue Sep 06 10:06:20 AEST 2016
    ;; MSG SIZE  rcvd: 55
    
    ```
    
    **Print Answer**  
    We can output the answer to the DNS query with the +answer option, as shown below we now actually see the IP address from the DNS query.
    
    ```
    [root@centos7 ~]# dig google.com +noall +answer
    
    ; <<>> DiG 9.9.4-RedHat-9.9.4-29.el7_2.3 <<>> google.com +noall +answer
    ;; global options: +cmd
    google.com.             5       IN      A       216.58.220.110
    
    ```
    
    Hopefully this gives you a basic understanding of how we can hide and display particular components of the dig output, there are many more options available and I recommend checking the manual page for further information on which specific parts can be displayed or hidden.
    
-   ### 12\. Adjust Defaults With ~/.digrc File
    
    We can create a .digrc file in our home directory to include any custom options that we want dig to run with by default. This way we can specify various options in the ~/.digrc file that will always automatically run with the dig command.
    
    In the below example we add the +short option to the .digrc in our home directory and then perform a dig on google.com, we can see that the output confirms it was run with +short even though we did not specify it on the command line.
    
    ```
    [root@centos7 ~]# cat .digrc
    +short
    [root@centos7 ~]# dig google.com
    216.58.220.110
    
    ```
    

## Summary

We have seen how the dig command can be used in many ways to perform DNS queries in Linux, making it a useful tool for troubleshooting or performing DNS lookups.

