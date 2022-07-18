
# How to Install Plex Media Server on Ubuntu 22.04 LTS

**[Plex Media Server](https://www.plex.tv/)** is software to store all your digital media content and access it via a client application such as your TV, NVIDIA Shield, Roku, Mobile App, and many more platforms. Plex Media Server organizes your files and content into categories. It’s extremely popular with people storing TV Shows and Movie Libraries, and if your connection is good enough, share it with your friends and family. Over time Plex Media Server has grown much and now supports many platforms.

_In the following tutorial, you will learn how to install Plex Media Server on Ubuntu 22.04 LTS Jammy Jellyfish by securely importing the GPG key and official Plex repository and some tips on basic sets and creating a reverse proxy with Nginx._

Table of Contents

-   [Update Ubuntu](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#Update_Ubuntu "Update Ubuntu")
-   [Install Required Packages](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#Install_Required_Packages "Install Required Packages")
-   [Install Plex Media Server](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#Install_Plex_Media_Server "Install Plex Media Server")
-   [Configure UFW Firewall](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#Configure_UFW_Firewall "Configure UFW Firewall")
-   [Configure Ubuntu Server SSH](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#Configure_Ubuntu_Server_SSH "Configure Ubuntu Server SSH")
-   [Configure Plex Media Server in WebUI](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#Configure_Plex_Media_Server_in_WebUI "Configure Plex Media Server in WebUI")
    -   [Step 1. How Plex Works](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#Step_1_How_Plex_Works "Step 1. How Plex Works")
    -   [Step 2. Optional Plex Pass](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#Step_2_Optional_Plex_Pass "Step 2. Optional Plex Pass")
    -   [Step 3. Server Setup](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#Step_3_Server_Setup "Step 3. Server Setup")
    -   [Step 4. Media Library](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#Step_4_Media_Library "Step 4. Media Library")
    -   [Step 5. Finishing up](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#Step_5_Finishing_up "Step 5. Finishing up")
-   [Configure/Setup Media Files & Folders Permissions](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#ConfigureSetup_Media_Files_Folders_Permissions "Configure/Setup Media Files & Folders Permissions")
-   [Configure/Setup Nginx as a Reverse Proxy](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#ConfigureSetup_Nginx_as_a_Reverse_Proxy "Configure/Setup Nginx as a Reverse Proxy")
-   [Secure Nginx with Let’s Encrypt SSL Free Certificate](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#Secure_Nginx_with_Lets_Encrypt_SSL_Free_Certificate "Secure Nginx with Let’s Encrypt SSL Free Certificate")
-   [How to Update/Upgrade Plex Media Server](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#How_to_UpdateUpgrade_Plex_Media_Server "How to Update/Upgrade Plex Media Server")
-   [How to Remove (Uninstall) Plex Media Server](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#How_to_Remove_Uninstall_Plex_Media_Server "How to Remove (Uninstall) Plex Media Server")
-   [Comments and Conclusion](https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/#Comments_and_Conclusion "Comments and Conclusion")

## Update Ubuntu

First, before you begin, make sure you update your system to make sure all existing packages are up to date to avoid any conflicts during the installation.

```
sudo apt update && sudo apt upgrade -y
```

## Install Required Packages

To complete the tutorial and must of all install and use Plex, you must install the following packages:

```
sudo apt install apt-transport-https curl wget -y
```

To install Plex, you must create a repository file that pulls directly from the Plex repository. This ensures you install and update straight from the official source using the apt package manager.

First, open your terminal **(CTRL+ALT+T),** then import the GPG key using the following terminal command:

```
sudo wget -O- https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor | sudo tee /usr/share/keyrings/plex.gpg
```

Next, import the repository:

```
echo deb [signed-by=/usr/share/keyrings/plex.gpg] https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
```

Before installing Plex, run the **apt update** command to reflect the new repository imported.

```
sudo apt update
```

Now install the Plex Media Server on Ubuntu using the following **apt install command**.

```
sudo apt install plexmediaserver -y
```

During the installation, you will see the following prompt advising you about your Plex source list.

_Example:_

[![How to Install Plex Media Server on Ubuntu 22.04 LTS
](https://www.linuxcapable.com/wp-content/uploads/2022/04/source-list-plex-media-player-message-ubuntu-22.04-lts.png)](https://www.linuxcapable.com/wp-content/uploads/2022/04/source-list-plex-media-player-message-ubuntu-22.04-lts.png)

**Type “N”** to proceed with the installation.

By default, the Plex Media service should be automatically started. To verify this, use the following **systemctl status command**.

```
systemctl status plexmediaserver
```

_Example output:_

[![How to Install Plex Media Server on Ubuntu 22.04 LTS
](https://www.linuxcapable.com/wp-content/uploads/2022/04/plex-media-server-status-ubuntu-22.04-lts.png)](https://www.linuxcapable.com/wp-content/uploads/2022/04/plex-media-server-status-ubuntu-22.04-lts.png)

If the service is not active, use the following command to start Plex Media Server:

```
sudo systemctl start plexmediaserver
```

Next, enable on system boot:

```
sudo systemctl enable plexmediaserver
```

To restart the service, use the following:

```
sudo systemctl restart plexmediaserver
```

## Configure UFW Firewall

Before proceeding any further, you should configure your UFW firewall, for most users, this should be enabled by default or alternative enable it using the following command.

```
sudo ufw enable
```

Add the Plex Media Server port which is **32400**, you can further lock this down to your IP by learning more about UFW Firewall in our **[Ubuntu 22.04 firewall tutorial.](https://www.linuxcapable.com/install-enable-configure-ufw-firewall-on-ubuntu-22-04/)**

```
sudo ufw allow 32400
```

## Configure Ubuntu Server SSH

For users with Plex Media Server installed on a remote Ubuntu 22.04 server, you will first need to set up an SSH tunnel on your local computer for **initial setup to allow outside connections.**

**Replace {server-ip-address} with your own for example 192.168.50.1 etc.**

_Example:_

```
ssh {server-ip-address} -L 8888:localhost:32400
```

For users new to SSH, you may need to install it.

```
sudo apt install openssh-server -y
```

Next, start the service.

```
sudo systemctl enable ssh -y
```

Now you can access the Plex Media Server by accessing the localhost in your web browser.

```
http://localhost:8888/web
```

Or the alternative if the above address does not work.

```
localhost:32400/web/index.html#!/setup
```

THROUGH AN SSH TUNNEL, the HTTP request will be redirected to http://localhost:32400/web, the remote server. 

Once the initial setup is done, you will access your Plex Media Server with your remote server IP address.

```
https://{server-ip-address}:32400
```

Now that Plex is installed on your system, you need to configure and finish the setup through the WebUI. To access this, open your preferred Internet Browser and navigate to **http://127.0.0.1:32400/web** or **http://localhost:32400/web**.

_Example:_

[![How to Install Plex Media Server on Ubuntu 22.04 LTS
](https://www.linuxcapable.com/wp-content/uploads/2022/04/plex-landing-page-after-install-ubuntu-22.04.png "How to Install Plex Media Server on Debian 11 Bullseye 5")](https://www.linuxcapable.com/wp-content/uploads/2022/04/plex-landing-page-after-install-ubuntu-22.04.png)

Now, you can log in using an existing social media account listed above or with your e-mail to register a new account if you are new to Plex. Once logged in, you will begin the initial configuration setup.

### Step 1. How Plex Works

The first configuration page describes what Plex is and how it works in a concise example.

Navigate to **GOT IT**! and leave a click to proceed to the next page.

_Example:_

[![How to Install Plex Media Server on Ubuntu 22.04 LTS
](https://www.linuxcapable.com/wp-content/uploads/2022/04/how-plex-works-ubuntu-22.04.png "How to Install Plex Media Server on Debian 11 Bullseye 6")](https://www.linuxcapable.com/wp-content/uploads/2022/04/how-plex-works-ubuntu-22.04.png)

Note, depending on the Internet Browser you use, Firefox users will notice a message prompting to **enable DRM**; this choice is needed; without it, Plex WebUI may not work correctly.

### Step 2. Optional Plex Pass

Next, you will be prompted to upgrade to Plex Pass possibly. This is optional; however, Plex Pass benefits HDR options and access to Beta builds. If you want to skip-click the **“X”** on the top right-hand corner, you can always set this up later.

_Example:_

[![How to Install Plex Media Server on Ubuntu 22.04 LTS
](https://www.linuxcapable.com/wp-content/uploads/2022/04/plex-pass-message-and-offer-ubuntu-22.04.png "How to Install Plex Media Server on Debian 11 Bullseye 7")](https://www.linuxcapable.com/wp-content/uploads/2022/04/plex-pass-message-and-offer-ubuntu-22.04.png)

### Step 3. Server Setup

Configure your server name, and you can name this anything you desire, along with having the option to disable **“Allow me to access my media outside my home.”** By default, allowing access to media outside is enabled; if you are not going to do this, untick the feature.

Once configured, click the **NEXT** button.

_Example:_

[![How to Install Plex Media Server on Ubuntu 22.04 LTS
](https://www.linuxcapable.com/wp-content/uploads/2022/04/server-set-up-plex-allow-access-external-ubuntu-22.04.png "How to Install Plex Media Server on Debian 11 Bullseye 8")](https://www.linuxcapable.com/wp-content/uploads/2022/04/server-set-up-plex-allow-access-external-ubuntu-22.04.png)

### Step 4. Media Library

The Media Library page gives you the option to pre-add your media directories. If you have a media drive or folder ready, click the **ADD LIBRARY** button.

_Example:_

[![How to Install Plex Media Server on Ubuntu 22.04 LTS
](https://www.linuxcapable.com/wp-content/uploads/2022/04/add-library-for-plex-ubuntu-22.04.png "How to Install Plex Media Server on Debian 11 Bullseye 9")](https://www.linuxcapable.com/wp-content/uploads/2022/04/add-library-for-plex-ubuntu-22.04.png)

Now select the type of media you want your folders to be organized into tv shows, movies, music, etc. Click the **NEXT** button to proceed to add folders.

_Example:_

[![How to Install Plex Media Server on Ubuntu 22.04 LTS
](https://www.linuxcapable.com/wp-content/uploads/2022/04/example-of-adding-movie-library-ubuntu-22.04.png "How to Install Plex Media Server on Debian 11 Bullseye 10")](https://www.linuxcapable.com/wp-content/uploads/2022/04/example-of-adding-movie-library-ubuntu-22.04.png)

Click the **BROWSE FOR MEDIA FOLDER** button and select the media directory.

_Example:_

[![How to Install Plex Media Server on Ubuntu 22.04 LTS
](https://www.linuxcapable.com/wp-content/uploads/2022/04/browse-for-media-folders-plex-media-server-ubuntu-22.04.png "How to Install Plex Media Server on Debian 11 Bullseye 11")](https://www.linuxcapable.com/wp-content/uploads/2022/04/browse-for-media-folders-plex-media-server-ubuntu-22.04.png)

The last option is that the Advanced options will appear once the folder is added. Here, you can further customize Plex to your liking.

Once done, click **ADD LIBRARY** to continue back to the initial configuration setup installation.

_Example:_

[![How to Install Plex Media Server on Ubuntu 22.04 LTS
](https://www.linuxcapable.com/wp-content/uploads/2022/04/advanced-settings-example-of-library-add-plex-media-server-ubuntu-22.04.png "How to Install Plex Media Server on Debian 11 Bullseye 12")](https://www.linuxcapable.com/wp-content/uploads/2022/04/advanced-settings-example-of-library-add-plex-media-server-ubuntu-22.04.png)

### Step 5. Finishing up

Next**,** hit the **NEXT** button to finish the initial setup with or without adding a Media Library.

_Example:_

[![How to Install Plex Media Server on Ubuntu 22.04 LTS
](https://www.linuxcapable.com/wp-content/uploads/2022/04/example-of-organizing-media-plex-media-server-ubuntu-22.04.png "How to Install Plex Media Server on Debian 11 Bullseye 13")](https://www.linuxcapable.com/wp-content/uploads/2022/04/example-of-organizing-media-plex-media-server-ubuntu-22.04.png)

The next screen informs you that you are all set. Click the **DONE** button to proceed to Plex Dashboard.

_Example:_

[![How to Install Plex Media Server on Ubuntu 22.04 LTS
](https://www.linuxcapable.com/wp-content/uploads/2022/04/finishing-plex-server-set-up-ubuntu-22.04.png "How to Install Plex Media Server on Debian 11 Bullseye 14")](https://www.linuxcapable.com/wp-content/uploads/2022/04/finishing-plex-server-set-up-ubuntu-22.04.png)

Now you will arrive at your Plex Dashboard.

_Example:_

[![How to Install Plex Media Server on Ubuntu 22.04 LTS
](https://www.linuxcapable.com/wp-content/uploads/2022/04/example-plex-main-dashboard-ubuntu-22.04-1024x569.png "How to Install Plex Media Server on Debian 11 Bullseye 15")](https://www.linuxcapable.com/wp-content/uploads/2022/04/example-plex-main-dashboard-ubuntu-22.04.png)

During the initial setup, you may have noticed that your media did not appear or have problems adding content that won’t be picked up. Plex refused to find the content on your existing hard drive’s internal and external secondaries. This is partly due to Plex creating a dedicated user account named **plexuser**, which needs to read and execute permission on your media directories. 

Ubuntu permissions can be set using chown or setfalc; both are good. Some examples of how to apply are below.

_setfalc way example:_

```
sudo setfacl -R -m u:plex:rx /media/yourfolder/
```

```
sudo setfacl -R -m u:plex:rx /media/yourfolder/tv
sudo setfacl -R -m u:plex:rx /media/yourfolder/movies
```

These commands require the ACL package to be installed; if this is missing, use the following command to install.

```
sudo apt install acl -y
```

_**chown way example:**_

```
sudo chown -R plex:plex /media/yourfolder/
```

Or individual files in the hard drive if other folders are present that you do not want Plex to touch/access.

```
sudo chown -R plex:plex /media/yourfolder/tv
sudo chown -R plex:plex /media/yourfolder/movies
```

## Configure/Setup Nginx as a Reverse Proxy

You can set up a reverse proxy to access Plex Media Server from a remote computer or network. In this example, the tutorial will set up an Nginx proxy server.

First, install Nginx:

```
sudo apt install nginx -y
```

Nginx should be enabled by default if it is not activated using the following command.

```
sudo systemctl enable nginx --now
```

Now check to make sure Nginx is activated and has no errors:

```
systemctl status nginx
```

_Example output:_

[![How to Install Plex Media Server on Ubuntu 22.04 LTS
](https://www.linuxcapable.com/wp-content/uploads/2022/04/systemctl-status-nginx-for-plex-ubuntu-22.04-lts.png)](https://www.linuxcapable.com/wp-content/uploads/2022/04/systemctl-status-nginx-for-plex-ubuntu-22.04-lts.png)

Now, create a new server block as follows:

```
sudo nano /etc/nginx/conf.d/plex.conf
```

You will need an active domain name which can be purchased for as little as 1 to 2 dollars if you do not have one. [**NameCheap**](https://www.namecheap.com/) has the best cheap domains going around and if you prefer a **.com**, use [**Cloudflare**](https://www.cloudflare.com/).

After you have created your sub-domain, add the following to the server block file:

```
server {
      listen 80;
      server_name plex.example.com;

      location / {
          proxy_pass http://127.0.0.1:32400;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

          #upgrade to WebSocket protocol when requested
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "Upgrade";
      }
}
```

Save the file **(CTRL+O),** then exit **(CTRL+X)**.

Now do a dry run to make sure no errors in the Nginx configuration or your server block:

```
sudo nginx -t
```

_If everything is working correctly, the example output should be:_

```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Reload Nginx for the change to take effect:

```
sudo systemctl reload nginx
```

If you have set up your domain and DNS records to point to your server IP, you can now access your Plex Media Server at **plex.example.com**.

## Secure Nginx with Let’s Encrypt SSL Free Certificate

Ideally, you would want to run your Nginx on HTTPS using an SSL certificate. The best way to do this is to use Let’s Encrypt, a free, automated, and open certificate authority run by the nonprofit Internet Security Research Group (ISRG).

First, install the certbot package as follows.

```
sudo apt install python3-certbot-nginx -y
```

Once installed, run the following command to start the creation of your certificate:

```
sudo certbot --nginx --agree-tos --redirect --hsts --staple-ocsp --email you@example.com -d www.example.com
```

During the certificate installation, you will get a notice to receive emails from **EFF(Electronic Frontier Foundation)**. Choose either **Y** or **N** then your TLS certificate will be automatically installed and configured for you.

This ideal setup includes force HTTPS 301 redirects, a Strict-Transport-Security header, and OCSP Stapling. Just make sure to adjust the e-mail and domain name to your requirements.

Now your URL will be **HTTPS://www.example.com** instead of **HTTP://www.example.com**.

If you use the old **HTTP URL**, it will automatically redirect to **HTTPS**.

Optionally, you can set a cron job to renew the certificates automatically. Certbot offers a script that does this automatically, and you can first test to make sure everything is working by performing a dry run.

```
sudo certbot renew --dry-run
```

If everything is working, open your crontab window using the following terminal command.

```
sudo crontab -e
```

Next, please specify the time when it should auto-renew. This should be checked daily at a minimum, and if the certificate needs to be renewed, the script will not update the certificate. If you need help finding a good time to set, use the [**crontab.guru**](https://crontab.guru/) free tool.

```
00 00 */1 * * /usr/sbin/certbot-auto renew
```

A great idea will be to test using a free SSL test such as [**DigiCert**](https://www.digicert.com/help/) or **[SSL Labs](https://www.ssllabs.com/).**

Plex can be updated as per the standard **apt update command** that you would use most of your time upgrading packages on your system.

To check for updates:

```
sudo apt update
```

If one is available, use the upgrade command:

```
sudo apt upgrade plexmediaserver -y
```

If you no longer wish to use Plex and want to remove it from your Ubuntu system, execute the following command:

```
sudo apt autoremove plexmediaserver --purge -y
```

Note, if you installed the Nginx reverse proxy, do not forget to disable it and, if needed, delete the configuration file of your domain.

Lastly, remove the repository located in **/etc/apt/sources.list.d/** if you do not need to re-install Plex again on your Ubuntu system.

```
sudo rm /etc/apt/sources.list.d/plexmediaserver.list
```

Lastly, for good maintenance and security, remove the **GPG key** located in the **usr/share/keyrings/**.

```
sudo rm usr/share/keyrings/plex.gpg
```

Plex is an excellent media server software with great features and a very active community. I have tried many others, such as Emby, and always found myself coming back to Plex. Another great benefit is that Plex has some awesome 3rd party developers doing some community projects that are open source that you don’t see in other communities of this nature.

## Reference

* https://www.linuxcapable.com/how-to-install-plex-media-server-on-ubuntu-22-04-lts/
* 
