# How to configure OpenVPN in PFSense and export clients?

VPN is a private virtual network that allows you to create a secure connection network connect other networks over the internet or intranet using multi-layers encryption and certificates. This is a step by step guide to configure OpenVPN and export clients In PFSense.

OpenVPN is an Open Source VPN server and client that is supported on a variety of platforms, including pfSense software. It can be used for Site-to-Site or Remote Access VPN configurations. OpenVPN can work with shared keys or with a PKI setup for SSL/TLS. Remote Access VPNs may be authenticated locally or using an external authentication source such as RADIUS or LDAP.

In this step by step guide, I have divided into 7 parts of this configuration.

**1- Install Configure CA (Certificate Authority).**

**2- Create and Sign Server Certificate**

**3- Configuring OpenVPN on PFSense**

**4-  Creating OpenVPN Client on PFSense**

**5- Installing the OpenVPN Client Export Package (OpenVPN-client-export)**

**6- Adding the VPN User**

1- Install and configure CA (Certificate Authority).

The first step in the process, which is Install and Configure CA (Certificate Authority) is to navigate to the  **Cert. Manager** in the **System** section.

![](./img/cert-manager-1.png.webp)

Then you will be presented with a dashboard. Click on **+Add** to create a new one certificate authority in **CAs** tab.

![](./img/add-CA.png?resolution=1920,1)

Give CA a useful common name, later on, you can use it to identify it. In this example I used AV-VPN\_CA.  
select the CA method from method dropdown. If you have existing CA, you need to select **Import an existing Certificate Authority** and fill the required information in **certificate data** and **certificate private key** section and click on **save**.

![](./img/Exisiting-CA.png?resolution=1920,1)

If you don’t have the existing CA, then select **Create an internal Certificate Authority** and fill out the details of your organization in **Internal Certificate Authority** section, which information’s are PFSense will use to create the Certificate Authority.  Once done, click on **Save** and your Internal Certificate Authority will be created.

![](./img/ca-details.png?resolution=1920,1)

Your CA will look like below after created by PFSense.

![](./img/internal-CA.png?resolution=1920,1)

2- create and sign server certification

The second step is to create and sign The second step in the process, which is created and sign a server certificate for OpenVPN.

![](./img/server-certificates.jpg.webp?resolution=1920,1)

If you have already configured or purchased the server certificate. Select **Import an Existing Certificate** from the drop-down in the **Method** section.  
Give the useful common name for the certificate. later on, it will be useful to identify it.

Fill out the **Certificate data** and **Private key data** information in the **Import Certificate** section and click on **Save**.

![](./img/server-certificates-exisiting.jpg.webp?resolution=1920,1)

If you don’t have the existing certificate, then select the **Create an internal Certificate** in **Method** dropdown. Give a friendly descriptive name, in this demo I used **AV\_VPN\_SERVER\_CERT**. Select your CA as a certificate authority in the **Internal Certificate** section, I have selected **AP\_VPN\_CA**, which I have created in this demo. **Certificate Type** is must be selected **Server Certificate** in **Certificate Attributes** section. And click on **Save**.

![](./img/Slide1-1024x576.jpg.webp?resolution=1920,1)

3- Configuring OpenVPN on PFSense

The third step in the process, which is to install and configure OpenVPN using the configuration wizard.

To start go to **VPN** in the main menu and then click on **OpenVPN**.

![](./img/openvpn-1.jpg.webp?resolution=1920,1)

Go to the **wizard** tab. Select your authentication backend type. If you have configured **LDAP** or **RADIUS**, select the appropriate setting. In this demo, I am using **Local User Access**. And click on **Next**.

![](./img/Wizard-1024x351.jpg.webp?resolution=1920,1)

Next Select the Certificate Authority Which you have created. and click **Next**. If you have not created one, follow the steps above about create CA.

![](./img/5-of-11.jpg.webp?resolution=1920,1)

Next, you will need to complete the Server Setup form which consists of four sections: **General OpenVPN Server Information**, **Cryptographic Settings**, **Tunnel Settings,** and **Client Settings**. As each environment is different, you may need to adjust these to meet your specific requirements. The settings below are the default settings that ensure privacy and use PFSense as your DNS server etc.

First, let’s configure the **General OpenVPN Server Information**. In the **interface,** section selects your WAN or ISP connect interface, If you have multiple ISP or WAN select the appropriate WAN/ISP interface. In the **Protocol** section, you can select the TCP, UDP on IPv4, or IPv6 depending on your requirement of VPN connection. In this demo, I’m selecting **UDP on IPv4 only** option. In the **local port,** you can define your OpenVPN listening port. I will continue with the default port. And give some nice description for this section.

![](./img/9.1-of-11-General-settings-1024x483.jpg.webp?resolution=1920,1)

Under **Cryptographic Settings**, make sure **TLS Authentication** and **Generate TLS key** options are checked. **DH Parameters Length** should be at least 2048 bit. If you have the same values in **Encryption algorithm** and  **Auth Digest Algorithm** leave it to defaults. If not, change these values to the shown like picture below. My hardware doesn’t support the hardware crypto acceleration. If your hardware supports, then select it in the **Hardware Crypto** section.

![](./img/9.2-of-11-cryptographic-settings-1024x667.jpg.webp?resolution=1920,1)

Under **Tunnel Settings**, enter the IP address range in CIDR notation (in my case 192.168.2.0/24) for the Tunnel network (this will be the IP address range OpenVPN will use to assign IP’s to VPN clients). You also need to tick the checkbox labeled Redirect Gateway to ensure all clients only use the VPN for all their traffic. Next enter the local network IP address range in CIDR notation (this is usually LAN) and then set your maximum number of concurrent connections. If you want to allow the communication between a VPN connected client, check the **Inter-Client Communication**.

![](./img/9.3-of-11-Tunnel-settings-1024x608.jpg.webp?resolution=1920,1)

In my demo configuration, I have left all **Client Settings** in their default state. **Dynamic IP** will assign an automatic IP address to the client. Here you may want to specify a DNS server, NTP Server, etc. Once completed click on **Next**.

![](./img/9.4-of-11-clientsettings.jpg.webp?resolution=1920,1)

In the next wizard,  Select the **Firewall Rule** and the **OpenVPN** **Rule.** It will create both rules automatically. If you don’t, later on, you need to create manually. And click on **Next**.

![](./img/9.5-of-11-firewall-and-openvon-add-rules-1024x405.jpg.webp?resolution=1920,1)

Finally, the OpenVPN configuration is complete. Click on **Finish**.

![](./img/9.6-of-11-finish-1024x312.jpg.webp?resolution=1920,1)

Now go the **Firewall** section and select **Rules** to check the Firewall rule and OpenVPN rule.

![](./img/Check-open-vpn-firewall-rules.jpg.webp?resolution=1920,1)

Now you have configured the Firewall Rule for the OpenVPN connection through the WAN address.

![](./img/Check-open-vpn-firewall-rules2-1024x386.jpg.webp?resolution=1920,1)

And OpenVPN rules for the OpenVPN server and client.

![](./img/Check-open-vpn-firewall-rules3-1024x353.jpg.webp?resolution=1920,1)

4- Creating OpenVPN Client On PFSense

Now that the OpenVPN server is up and running, we need to configure VPN client access. Navigate to VPN – OpenVPN and click on the **Clients** tab and then click on **+Add**.

![](./img/Client-Setup-1-1024x286.jpg.webp?resolution=1920,1)

After clicking on **+Add** it will open the OpenVPN client edit form which has 6 sections, **General information**, **User Authentication Settings**, **Cryptographic Settings**, **Tunnel Settings**, **Ping Settings,** and **Advanced Configuration**. As with the server config, you will need to configure these settings to match your specific requirements. Below are the minimum changes you need to make.

I am leaving **Tunnel Settings** and **Ping settings** to its d default. I will use tunnel settings from the server configuration. If you have multiple WAN configured with multiple OpenVPN server, you should define tunnel settings in the client configuration.

Under General information fill-out and select the required values in respective fields. Make sure that corresponded values are not mixed up. for example:- Please select the  **Protocol** the same value which you define in server configuration and **Interface** should be the same. The server **host or address** should be the hostname or IP of WAN if you have multiple WAN interfaces.

![](./img/Client-Setup-2-1024x794.jpg.webp?resolution=1920,1)

Under **User Authentication Settings** provide a Username and Password.

![](./img/Client-Setup-3-1024x210.jpg?resolution=1920,1)

Under **Cryptographic Settings** select your CA (Certificate Authority) for **Peer Certificate Authority** and SHA256 for the **Auth digest algorithm.**

![](./img/Client-Setup-4.jpg?resolution=1920,1)

Under **Advanced Configuration** select **IPv4 Only**, **IPv6 Only,** or **Both** respectively and then click **Save** (I have IPv4 Only).

![](./img/Client-Setup-5-1024x757.jpg?resolution=1920,1)

Now you should have a fully configured client configuration of OpenVPN in PFSense.

![](./img/configured-client-1024x125.jpg?resolution=1920,1)

5- Installing the OpenVPN Client Export Package (openvpn-client-export)

We now need to go and install the OpenVPN Client Export package so we can export the client configuration which we will need to provide to clients so that they can connect to our OpenVPN server.

First, go to **System** – **Package Manager**

![](./img/package-manager.jpg?resolution=1920,1)

Click on Available Packages and then search for **OpenVPN-client-export**. In the search results which are returned click on **Install** to install the OpenVPN-client-export package.

![](./img/client-export-1-1024x379.jpg?resolution=1920,1)

Now you should have an **OpenVPN-client-export** utility installed.

![](./img/client-export-2-1024x379.jpg?resolution=1920,1)

6- Adding the VPN User

We now need to create the VPN user which has 2 section **User Properties** and **Create Certificate for User**. To do this go to **System** – **User Manager** and click on **Add** to create a new user.

![](./img/User-Manager-1.jpg?resolution=1920,1)  
![](./img/User-Manager-2-1024x251.jpg?resolution=1920,1)

Fill in the username and password which needs to match the config you created under Client Settings during the OpenVPN client configuration. Ensure you tick **click to** **create a user certificate.**

![](./img/User-Creation-1024x610.jpg?resolution=1920,1)

And then give the certificate a name and select your Certificate Authority (Which is created/configured in the first step ). Once all is done click on **Save**.

![](./img/User-Creation-finale-1024x517.jpg?resolution=1920,1)

OpenVPN setup is completed. Now you should have **Client Export** under the OpenVPN menu item.

![](./img/Client-export-1024x109.jpg?resolution=1920,1)

If all the configuration is correctly configured, you should now able to download different client versions to connect the OpenVPN server.

![](./img/Finale-1024x296.jpg?resolution=1920,1)

Install OpenVPN client on your system. Provide the username and password. now it should be connected to the OpenVPN server. you can verify it by using **what’s my IP ?**  in google.

![](./img/Connection-1.jpg?resolution=1920,1)  
![](./img/Baburam.jpg?resolution=1920,1)

## References

* https://boredadmin.com/configure-opnevpnn-in-pfsense-and-export-client/
* 