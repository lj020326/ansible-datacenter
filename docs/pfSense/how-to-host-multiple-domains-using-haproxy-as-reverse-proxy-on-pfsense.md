
# How to host multiple domains using HAProxy as reverse proxy on pfSense

In previous posts it was discussed [how to create a DMZ network and host a website from a isolated VLAN on your network](https://geekistheway.com/2022/10/16/how-to-create-a-dmz-network-using-vlans-on-pfsense/). That is a powerful resource, but with the limitation of not being possible to use a friendly FQDN such as _geekistheway.com_ or _mydomain.com_ as the frontend for the websites.

This post will extend that post and address its limitation, showing how to leverage HAProxy as a reverse proxy and enable multiple domains to be hosted by a web server behind a pfSense. We are going to use _mydomain.com_ and _mydomain.net_ as the domains that will be hosted by your web servers.

In order to use FQDN domains (e.g. mydomain.com and mydomain.net) being forwarded to your web servers, you will need a static IP for your pfSense’s WAN interface. You also need to own at least one public domain (say mydomain.com) through a registrar, such as [Namecheap](http://namespace.com/) or [GoDaddy](http://godaddy.com/). Each domain needs a “A record” on the DNS pointing to your pfSense WAN IP. Both requirements above can be workarounded by the use of Dynamic DNS, as described by previous [posts](https://geekistheway.com/2020/06/27/setting-up-cloudflare-ddns-on-your-pfsense/)

To allow HTTPS connections to your web server without annoying browser warnings due to untrusted self-signed certificates/missing SSL certificates, you will need to create (Let’s Encrypt) SSL certificates for each domain you host (e.g. https://mydomain.com, https://mydomain.net)

For achieving this, similar to the previous post, we are going to use a VLAN to create a DMZ network to host the services and leverage NAT Port Forwarding to redirect users from Internet to the web servers. However, new concepts and tools will be introduced. The first one is [HAProxy](http://haproxy.com/), that  provides a high availability load balancer and reverse proxy for TCP and HTTP-based applications. We are only going to use its reverse proxy capability, which can be seen as a (frontend) software that forwards clients requests (from Internet in this post) to web servers (aka backend servers). The second concept introduced here is the notion of [Virtual IP (VIP)](https://docs.netgate.com/pfsense/en/latest/firewall/virtual-ip-addresses.html) , which is basically made-up alias used to bind HAProxy service to. We could use the web server IP instead, but the VIP provides the decoupling of the backend servers and the HAProxy frontend.

## Creating a DMZ network using VLAN

This was already covered in this [post](https://geekistheway.com/2022/10/16/how-to-create-a-dmz-network-using-vlans-on-pfsense), so go ahead and refer to it and execute the first two sections (creating the VLAN and configuring VLAN on your switch), but skip the third and optional section (enabling the web server). Just like the post above, we are going to use VLAN ID 100, VLAN network 10.20.100.1/24 and web server IP as 10.20.100.3.

## Creating a Virtual IP

Although we could use the web server IP instead, a virtual IP will be created as an alias for it. The VIP (e.g. 10.20.100.2) will be bound to HAProxy reverse proxy. On your pfSense, visit **_Firewall >> Virtual IPs_** an click on **Add**:

-   **Edit Virtual IP**
    -   **Type:** IP Alias
    -   **Interface:** VLAN\_100
    -   **Address type:** Single address
    -   **Addresses:** 10.20.100.2/32
    -   **Expansion:** unchecked
    -   **Description:** VIP for web server on VLAN 100

Click on **Save** and **Apply changes** to finish the deal.

## Creating Let’s Encrypt certificates for your domains

If you use [Cloudflare DNS as your nameserver](https://www.cloudflare.com/), you can follow this post and to issue [Let’s Encrypt certificates](https://geekistheway.com/2020/06/25/issuing-lets-encrypt-certificates-on-your-pfsense-using-acme/) for each of your domains!

Interesting to highlight that although you can host multiple websites, each with their own SSL certificate, HAProxy will be able to associate the correct certificate with each domain. This is possible due to an extension to TLS specification called [Server Name Indication (SNI)](https://en.wikipedia.org/wiki/Server_Name_Indication). I won’t get into the details, but that is the guy that you should appreciate for such magic.

For each certificate created above, we will need one more tweak. Every time the certificates are renewed, we want to reload HAProxy with the new certificate. For such, go to **Services >> Acme certificates** and click on the **edit icon (pencil)** for each new certificate. Scroll down to **Actions list** and click on **Add:**

-   **Mode:** Enabled
-   **Command:** /usr/local/etc/rc.d/haproxy.sh restart
-   **Method:** Shell command

Click on **Save** to complete the update. Do not forget to repeat the steps above for all certificates used by HAProxy.

## Accessing ports from local Port Forwards

As mentioned above, we are going to use NAT Port forward to redirect clients from Internet (WAN) to a web server. However, [according to pfSense’s official documentation](https://docs.netgate.com/pfsense/en/latest/recipes/port-forwards-from-local-networks.html), _pfSense software does not redirect internally connected devices to forwarded ports and 1:1 NAT on WAN interfaces. For example, if a client on LAN attempts to reach a service forwarded from WAN port `80` or `443`, the connection will hit the firewall web interface and not the service they intended to access. The client will be presented with a certificate error if the GUI is running HTTPS, and a DNS rebinding error since the GUI rejects access for unrecognized hostnames._

In order to solve this, we can either use Split DNS or NAT Reflection. We are going to use split DNS, as it is the more elegant (preserve user’s IP information and prevent loops inside the firewall) and yet easy solution. Split DNS is a configuration where internal and external clients resolve hostnames differently, meaning that _mydomain.com_ would resolve to 10.20.100.3 on your LAN network, but for an external access, it would resolve to your public WAN IP.

Go to **Services >> DNS Resolver** and scroll down to **Host overrides** section before clicking **Add:**

-   **Host Override Options**
    -   **Host:** empty
    -   **Domain:** mydomain.com
    -   **IP address:** 10.20.100.2 (VIP address)
    -   **Description:** mydomain.com Split DNS override for VIP VLAN 100
-   **Additional names for this host**
    -   **Host:** www
    -   **Domain:** mydomain.com
    -   **Description:** www.mydomain.com Split DNS override for VIP VLAN 100

Click on **Save** and **Apply changes** to complete the first split DNS. Next, repeat the process for all additional domains you may have, such as _mydomain.net._

The overall process to configure HAProxy is easy and it will be installed in 4 small steps: installing HAProxy, creating one backend for each domain, creating one backend for HTTP and another for HTTPS and finally enabling HAProxy.

On our setup, we are going to redirect HTTP requests to HTTPS to enforce security, so if the user tries to access www.mydomain.com, they will be redirected to https://www.mydomain.com and start using Let’s Encrypt certificates from previous sections to encrypt all traffic between the internet user and pfSense. As we will see soon, the communication between pfSense and the web server will be done using HTTP only, which means we are offloading the overhead for encryption to the pfSense appliance instead of the web server.

### Installing HAProxy package

HAProxy is offered as a separate package on pfSense. In order to install it, go to **System >> Package Manager >> Available Packages**. Scroll down until you find “_haproxy”_ and click on _**Install**._ Wait until the installation is finished before you leave the page, otherwise installation will be aborted and all sorts of bad mojo will follow.

### Creating HAProxy backends

Each domain, _mydomain.com_ and _mydomain.net_ in this post, will have their own HAProxy backend. Go to **Services >> HAProxy >> Backend** and click on **Add**:

-   **Edit HAProxy Backend server pool**
    -   **Name:** mydomain.com
    -   **Server list:** (click on down arrow to add an entry to the table)
        -   **Mode:** Active
        -   **Name:** mydomain.com
        -   **Forward to:** Address+Port
        -   **Address:** 10.20.100.3 (or the webserver FQDN)
        -   _Leave all the SSL settings unchecked/empty/unchanged_
-   **Load balancing options (when multiple servers are defined)**: empty
-   **Access control lists and actions**: empty
-   **Timeout / retry settings**: empty
-   **Health checking**:
    -   **Health check method**: HTTP
        -   Change it to _None_ if you get an unexpected error
    -   _Leave all other options _unchecked/empty/unchanged__
-   **Agent checks**: empty
-   **Cookie persistence**: empty
-   **Stick-table persistence**: empty
-   **Email notifications**: empty
-   **Statistics**: empty
-   **Error files**: empty
-   **HSTS / Cookie protection:** empty
-   **Advanced settings:** empty

Click on **Save** and **Apply changes** to finish your first backend. Repeat this step for each domain.

### Creating HAProxy frontend

Although in the previous section we had created one _backend_ for each domain, in this section we are going to create two frontends, only: one for handling HTTP and another for HTTPS traffic. Each frontend will be able to handle all domains based on _individual_ Access Control List (ACL) rule for each of domain.

The first frontend will be used to redirect users from unencrypted HTTP to the secure HTTPS connection. Click on **Frontend** tab and then **Add:**

-   **Edit HAProxy Frontend**:
    -   **Name:** HTTP\_80
    -   **Description:** Redirect HTTP to HTTPS
    -   **Status:** Active
    -   **Shared frontend:** unchecked
    -   **External address:**
        -   **Listen address:** 10.100.20.2 (The VIP address)
        -   **Port:** 80
        -   **SSL Offloading:** unchecked
        -   **Advanced:** empty
    -   **Max connections:** empty
    -   **Type:** http/https(offloading)
-   **Default backend, access control lists and actions**
    -   **Access Control lists**: empty
    -   ****Actions****: _click down arrow to add an entry_
        -   **Action:** http-redirect request
        -   **Condition acl names**: empty
        -   **Rule:** scheme https
    -   **Default Backend**: None
-   **Stats options**: empty
-   **Logging options**: empty
-   **Error files**: empty
-   **Advanced settings**:
    -   **Use “forwardfor” option**: checked
    -   _Leave all other options _unchecked/empty/unchanged__

Click on **Save** and **Apply changes** to complete the first frontend. Now it is time for the second backend, which will provide a HTTPS connection for each domain.

The mechanism to allow multiple domains to be served by a single frontend is called _Access Control List_. It works by pattern-matching the domain name with the address the users have typed on their browser’s address bar. Each _ACL_ entry has an associate name, which is later reused by an _Action_ to trigger the use of a specific backend. The first _ACL_ rule will match the first _Action_ entry and so on. The last piece is adding _Additional certificates_ for each domain _ACL_, so that the HAProxy can send the appropriate certificate to the user when a _backend_ is triggered by _Action_ entry. To get started, click on **Add:**

-   **Edit HAProxy Frontend**:
    -   **Name:** HTTPS\_443
    -   **Description:** Redirect HTTP to HTTPS
    -   **Status:** Active
    -   **Shared frontend:** unchecked
    -   **External address:**
        -   **Listen address:** 10.100.20.2 (The VIP address)
        -   **Port:** 443
        -   **SSL Offloading:** checked
        -   **Advanced:** empty
    -   **Max connections:** empty
    -   **Type:** http/https(offloading)
-   **Default backend, access control lists and actions**
    -   **Access Control lists**: _click down arrow to add one entry_
        -   **Name:** mydomain.com
        -   **Expression:** Host matches
        -   **CS:** unchecked
        -   **Not:** unchecked
        -   **Value:** mydomain.com
        -   _repeat the steps above for each domain_
    -   ****Actions****: _click down arrow to add an entry_
        -   **Action:** Use backend
        -   **Condition acl names**: mydomain.com
        -   **Backend:** mydomain.com
        -   _repeat the steps above for each domain_
    -   **Default Backend**: None
-   **Stats options**: empty
-   **Logging options**: empty
-   **Error files**: empty
-   **Advanced settings**:
    -   **Use “forwardfor” option**: checked
    -   _Leave all other options _unchecked/empty/unchanged__
-   **SSL Offloading**:
    -   **SNI Filter**: empty
    -   **Certificate:**
        
        -   _Select the certificate of your pfSense webConfigurator_ (will be the default certificate)
        
        -   **Add ACL for certificate CommonName**: checked
        -   **Add ACL for certificate Subject Alternative Names**: checked
    -   **OSCP:** unchecked
    -   ****Additional certificates****:
        
        -   _Click down arrow to add an entry_
            -   _Select the ACME Certificate_
            -   _Repeat this step for each domain you will host_
        
        -   **Add ACL for certificate CommonName**: checked
        -   **Add ACL for certificate Subject Alternative Names**: checked
    -   **Advanced ssl options**: empty
    -   ****Advanced certificate specific ssl options****: empty
-   **SSL Offloading – client certificates**: _Leave all other options _unchecked/empty/unchanged__

Click on **Save** and **Apply changes** to complete the last frontend.

## Enabling HAProxy

The last step is to enable HAProxy to start the service itself. Click on **Settings** tab:

-   **General settings**:
    -   **Enable HAProxy:** checked
    -   **Maximum connections**: 100 (or an appropriate number as per the help table on that page)
    -   _Leave all other options _unchecked/empty/unchanged__
-   **Stats tab, ‘internal’ stats port**:
    -   **Internal stats port**: 2200
    -   _Leave all other options _unchecked/empty/unchanged__
-   **Logging:**
    -   _Leave all other options _unchecked/empty/unchanged__
-   **Global DNS resolvers for haproxy**
    -   _Leave all other options _unchecked/empty/unchanged__
-   **Global email notifications**
    -   _Leave all other options _unchecked/empty/unchanged__
-   **Tuning**
    -   **Max SSL Diffie-Hellman size**: 2048
-   **Global Advanced pass thru**
    -   _Leave all other options _unchecked/empty/unchanged__
-   **Configuration synchronization**
    -   _Leave all other options _unchecked/empty/unchanged__

Click on **Save** and **Apply changes** to complete the configuration

At this point, you should be able to visit _mydomain.com, www.mydomain.com, mydomain.net_ and _mydomain.net_ from your local network.

## (Optional) Enabling access from Internet

The DMZ is already working and responding to requests coming from local networks. If you want to allow external access, you will need to create NAT rules to port forward traffic from WAN to the VIP address that is being used by HAProxy. Go to _**Firewall >> NAT >> Port forward**_, click _**Add (arrow down)**_ and do as follows:

-   **Edit Redirect Entry**
    -   **Disabled:** unchecked
    -   **No RDR (NOT)**: unchecked
    -   **Interface:** WAN
    -   **Address family:** IPv4
    -   **Protocol:** TCP
    -   **Source:** (let unchanged to allow traffic from _Any_)
    -   **Destination:**
        -   **Invert match:** unchecked
        -   **Type:** WAN Address
        -   **Destination port range**:
            -   **From port:** HTTP
            -   **To port:** HTTP
    -   **Redirect target IP:**
        -   **Type:** Single Address
        -   **IP:** 10.20.100.3
    -   **Redirect target port**:
        -   **Port:** HTTP
    -   **Description:** Redirect WAN to HTTP traffic to server on VLAN 100
    -   **No XMLRPC Sync**: unchecked
    -   **NAT reflection**: System default
    -   ****Filter rule association****: Add associated filter rule

Click **Save** and **Apply changes**. This will redirect traffic coming from WAN on port 80 (HTTP) to the VIP address that HAProxy will use to redirect them to port 443 (HTTPS) on the final web server.

Lastly, let’s create a new NAT port forward by repeating the steps above, but selecting **_port HTTPS_** in **Destination >> Destination Port range** and **Redirect target port** sections above.

That is all there is to it. From now on, whoever tries to visit any of your domains (e.g. http://mydomain.com, http://mydomain.net), they will be sent to the web server on https://10.20.100.3 with well known SSL certificates.

## (Optional) Testing

On a Windows machine, you can open a browser, say Mozilla Firefox or Microsoft Edge, and type the domain name (not the IP). you will notice that “mydomain.com” will be redirected to “https://mydomain.com” and “www.mydomain.net” will be redirected to “https://www.mydomain.net”. You should also notice that no warning will be shown because the SSL certificate will match the domain name.

On a Linux machine, another test that you can do is using _openssl_ tool to check whether the certificate is properly served to a particular domain name: For such, type “_openssl s\_client -servername mydomain.com -host 10.20.100.2 -port 443 < /dev/null | grep subject=CN_  
The answer should be something like:

_depth=2 C = US, O = Internet Security Research Group, CN = ISRG Root X1  
verify return:1  
depth=1 C = US, O = Let’s Encrypt, CN = R3  
verify return:1  
depth=0 CN = mydomain.com  
verify return:1  
DONE  
subject=CN = mydomain.com_

Finally, on a machine without a GUI, you can use a command-line browser, such as w3m. An example would be _“w3m mydomain.com”_. If everything is working, at the bottom of the browse, you should see something like _“Viewing\[SSL\]”_, which means that the connection is secure.

That is it, have fun!

## Reference

- https://geekistheway.com/2022/10/17/how-to-host-multiple-domains-using-haproxy-as-reverse-proxy-on-pfsense/
- 