
# Running PowerDNS and PowerDNS Admin in Docker Containers

PowerDNS is a server software written in C++ to provide both recursive and authoritative DNS services. The **_Recursor DNS_** does not have any knowledge of domains and consults the authoritative servers to provide answers to questions directed to it while the **_Authoritative DNS_** server answers questions on domains it has knowledge about and ignores queries about domains it doesn’t know about. Both products are provided separately but in most cases combined to work seamlessly.

PowerDNS was developed in the late 90s and became an open-source tool in **2002**. PowerDNS has been deployed throughout the world to become the best DNS server. The rapid growth of PowerDNS is mainly due to the following features offered.

-   It offers very high domain resolution performance.
-   Offers Open Source workhorses: Authoritative Server, dnsdist and Recursor
-   It provides a lot of statistics during its operation which not only helps to determine the scalability of an installation but also spotting problems.
-   Supports innumerable backends ranging from simple zonefiles to relational databases and load balancing/failover algorithms.
-   Has improved security features.

To make management of the PowerDNS server easier, a tool known as **PowerDNS Admin** was introduced. This is a web admin interface that allows one to create and manage DNS zones on the PowerDNS server. It offers the following features:

-   Support Google / Github / Azure / OpenID OAuth
-   User activity logging
-   Multiple domain management
-   Domain templates
-   DynDNS 2 protocol support
-   Support Local DB / SAML / LDAP / Active Directory user authentication
-   Edit IPv6 PTRs using IPv6 addresses directly (no more editing of literal addresses)
-   Full IDN/Punycode support
-   Limited API for manipulating zones and records
-   Dashboard and pdns service statistics
-   Support Two-factor authentication (TOTP)
-   User access management based on domain

This guide provides the required steps to run PowerDNS and PowerDNS Admin in Docker Containers. There are other ways to run PowerDNS and PowerDNS Admin such as:

-   [Install PowerDNS on CentOS 8 with MariaDB & PowerDNS-Admin](https://computingforgeeks.com/install-powerdns-on-centos-with-powerdns-admin/)
-   [Install PowerDNS and PowerDNS-Admin on Ubuntu](https://computingforgeeks.com/install-powerdns-and-powerdns-admin-on-ubuntu/)

These methods contain quite a number of steps. Using Docker is the easiest of them all.

## Step 1 – Prepare your Server

Begin by preparing your server for the installation. There are packages required that can be installed as below:

```
## On RHEL/CentOS/RockyLinux 8
sudo yum update
sudo yum install curl vim

## On Debian/Ubuntu
sudo apt update && sudo apt upgrade
sudo apt install curl vim

## On Fedora
sudo dnf update
sudo dnf -y install curl vim
```

Disable system resolved service which runs on port 53 and provides network name resolution used to load applications. This port will be used by PowerDNS instead.

```
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
```

Remove the symbolic link.

```
$ ls -lh /etc/resolv.conf 
-rw-r--r-- 1 root root 49 Feb 23 04:53 /etc/resolv.conf
$ sudo unlink /etc/resolv.conf
```

Now update the resolve conf.

```
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

## Step 2 – Install Docker and Docker-Compose on Linux

I assume that you already have Docker Engine is installed on your system, otherwise install Docker using the dedicated guide below.

-   [How To Install Docker CE on Linux Systems](https://computingforgeeks.com/install-docker-ce-on-linux-systems/)

Before you proceed, ensure that your system user is added to the docker group.

```
sudo usermod -aG docker $USER
newgrp docker
```

Start and enable Docker.

```
sudo systemctl start docker && sudo systemctl enable docker
```

You may also need Docker-compose installed to be able to run the container using the _docker-compose_ YAML file. Install Docker Compose using the below commands:

First, download the script using cURL.

```
curl -s https://api.github.com/repos/docker/compose/releases/latest | grep browser_download_url  | grep docker-compose-linux-x86_64 | cut -d '"' -f 4 | wget -qi -
```

Make it executable and move it to your path using the commands:

```
chmod +x docker-compose-linux-x86_64
sudo mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose
```

Verify the installation.

```
$ docker-compose version
Docker Compose version v2.2.3
```

## Step 3 – Create a Persistent Volume for the PowerDNS Container.

Create a persistent volume for PowerDNS with the right permissions as below.

```
sudo mkdir /pda-mysql
sudo chmod 777 /pda-mysql
```

The above volume will be used to persist the database and configurations. On Rhel-based systems, you need to set SELinux in permissive mode for the Path to be accessible.

```
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
```

There are two options on how to proceed:

-   Directly from Docker Hub
-   Using Docker-Compose

### Option 1 – From Docker Hub

This is so simple since few configurations are required. The PowerDNS Docker image consists of 4 images namely:

-   **pdns-mysql** – the PowerDNS server configurable with MySQL backend.
-   **pdns-recursor**– contains completely configurable PowerDNS 4.x recursor
-   **pdns-admin-uwsgi** – web app, written in Flask, for managing PowerDNS servers
-   **pdns-admin-static** – fronted (nginx)

We will run each of these containers and link them to each other.

-   **The Database Container.**

We will use MariaDB as the database container with the PowerDNS database created as below.

```
docker run --detach --name mariadb \
      -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
      -e MYSQL_DATABASE=pdns \
      -e MYSQL_USER=pdns \
      -e MYSQL_PASSWORD=mypdns \
      -v /pda-mysql:/var/lib/mysql \
      mariadb:latest
```

-   **The PowerDNS master Container.**

We will use the PowerDNS server configurable with MySQL backend linked to the database as below.

```
docker run -d -p 53:53 -p 53:53/udp --name pdns-master \
  --hostname pdns\
  --domainname computingforgeeks.com \
 --link mariadb:mysql \
  -e PDNS_master=yes \
  -e PDNS_api=yes \
  -e PDNS_api_key=secret \
  -e PDNS_webserver=yes \
  -e PDNS_webserver-allow-from=127.0.0.1,10.0.0.0/8,172.0.0.0/8,192.0.0.0/24 \
  -e PDNS_webserver_address=0.0.0.0 \
  -e PDNS_webserver_password=secret2 \
  -e PDNS_version_string=anonymous \
  -e PDNS_default_ttl=1500 \
  -e PDNS_allow_notify_from=0.0.0.0 \
  -e PDNS_allow_axfr_ips=127.0.0.1 \
  pschiffe/pdns-mysql
```

Here we allow the API to be accessible from several IP addresses to avoid the error “**connection Refused by peer**” or **_error 400_** when creating domains.

-   **The PowerDNS Admin Container.**

```
docker run -d --name pdns-admin-uwsgi \
  -p 9494:9494 \
  --link mariadb:mysql --link pdns-master:pdns \
  pschiffe/pdns-admin-uwsgi
```

-   **The PowerDNS Admin service Container**

Now expose the service using the pdns-admin-static container to expose the service.

```
docker run -d -p 8080:80 --name pdns-admin-static \
  --link pdns-admin-uwsgi:pdns-admin-uwsgi \
  pschiffe/pdns-admin-static
```

Now you should have all four containers up and running:

```
$ docker ps
CONTAINER ID   IMAGE                        COMMAND                  CREATED          STATUS          PORTS                                                                  NAMES
b71e4e3dcdcb   pschiffe/pdns-admin-static   "/usr/sbin/nginx -g …"   7 seconds ago    Up 5 seconds    0.0.0.0:8080->80/tcp, :::8080->80/tcp                                  pdns-admin-static
99332d2b4322   pschiffe/pdns-admin-uwsgi    "/docker-entrypoint.…"   2 minutes ago    Up 2 minutes    0.0.0.0:9494->9494/tcp, :::9494->9494/tcp                              pdns-admin-uwsgi
0b2cfb575481   pschiffe/pdns-mysql          "/docker-entrypoint.…"   3 minutes ago    Up 3 minutes    0.0.0.0:53->53/tcp, 0.0.0.0:53->53/udp, :::53->53/tcp, :::53->53/udp   pdns-master
f622128deb1d   mariadb:latest               "docker-entrypoint.s…"   10 minutes ago   Up 10 minutes   3306/tcp                                                               mariadb
```

At this point, the PowerDNS Admin web UI should be accessible on port **8080**

### Option 2 – Using Docker-Compose

With this method, all the variables are defined in a docker-compose file. Create the docker-conpose.yml file.

```
vim docker-compose.yml
```

In the file, you need to add the below lines.

```
version: '2'

services:
  db:
    image: mariadb:latest
    environment:
      - MYSQL_ALLOW_EMPTY_PASSWORD=yes
      - MYSQL_DATABASE=powerdnsadmin
      - MYSQL_USER=pdns 
      - MYSQL_PASSWORD=mypdns
    ports:
      - 3306:3306 
    restart: always
    volumes:
      - /pda-mysql:/var/lib/mysql
  pdns:
    #build: pdns
    image: pschiffe/pdns-mysql
    hostname: pdns
    domainname: computingforgeeks.com
    restart: always
    depends_on:
      - db
    links:
      - "db:mysql"
    ports:
      - "53:53"
      - "53:53/udp"
      - "8081:8081"
    environment:
      - PDNS_gmysql_host=db
      - PDNS_gmysql_port=3306
      - PDNS_gmysql_user=pdns
      - PDNS_gmysql_dbname=powerdnsadmin
      - PDNS_gmysql_password=mypdns
      - PDNS_master=yes 
      - PDNS_api=yes
      - PDNS_api_key=secret 
      - PDNSCONF_API_KEY=secret 
      - PDNS_webserver=yes 
      - PDNS_webserver-allow-from=127.0.0.1,10.0.0.0/8,172.0.0.0/8,192.0.0.0/24 
      - PDNS_webserver_address=0.0.0.0 
      - PDNS_webserver_password=secret2 
      - PDNS_version_string=anonymous 
      - PDNS_default_ttl=1500 
      - PDNS_allow_notify_from=0.0.0.0 
      - PDNS_allow_axfr_ips=127.0.0.1 

  web_app:
    image: ngoduykhanh/powerdns-admin:latest
    container_name: powerdns_admin
    ports:
      - "8080:80"
    depends_on:
      - db
    restart: always
    links:
      - db:mysql
      - pdns:pdns
    logging:
      driver: json-file
      options:
        max-size: 50m
    environment:
      - SQLALCHEMY_DATABASE_URI=mysql://pdns:mypdns@db/powerdnsadmin
      - GUNICORN_TIMEOUT=60
      - GUNICORN_WORKERS=2
      - GUNICORN_LOGLEVEL=DEBUG
```

In the above file, we have the below sections:

-   **pdns** for the DNS server. Remeber to set a **PDNS\_api\_key** to be used to connect to the PDNS dashboard.
-   **db** database for powerDns. It will include tables for domains, zones, etc
-   **pdns-mysql** DNS server configurable with MySQL database
-   **web\_app** admin web UI for interaction with powerdns

Run the container using the command:

```
docker-compose up -d
```

Check if the containers are running:

```
$ docker ps
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS                            PORTS                                                                                                             NAMES
7c5761e3d2a2   ngoduykhanh/powerdns-admin:latest   "entrypoint.sh gunic…"   10 seconds ago   Up 7 seconds (health: starting)   0.0.0.0:8080->80/tcp, :::8080->80/tcp                                                                             powerdns_admin
ebf3ff118c72   pschiffe/pdns-mysql                 "/docker-entrypoint.…"   10 seconds ago   Up 8 seconds                      0.0.0.0:53->53/tcp, :::53->53/tcp, 0.0.0.0:8081->8081/tcp, 0.0.0.0:53->53/udp, :::8081->8081/tcp, :::53->53/udp   thor-pdns-1
9ede175d6ae0   mariadb:latest                      "docker-entrypoint.s…"   11 seconds ago   Up 9 seconds                      0.0.0.0:3306->3306/tcp, :::3306->3306/tcp                                                                         thor-db-1
```

Here the PowerDNS service is available on port **8080**

## Step 5 – Access the PowerDNS Admin Web UI

Now you should be able to access the Web UI using the port set i.e [http://IP\_address:8080](http://ip_address:9393/)

[![Running PowerDNS and PowerDNS Admin in Docker Containers](img//Running-PowerDNS-and-PowerDNS-Admin-in-Docker-Containers.png?ezimgfmt=rs:696x503/rscb23/ng:webp/ngcb23 "Running PowerDNS and PowerDNS Admin in Docker Containers 1")](data:image/svg+xml,%3Csvg%20xmlns=%22http://www.w3.org/2000/svg%22%20width=%22775%22%20height=%22560%22%3E%3C/svg%3E)

Create a user for PowerDNS.

[![Running PowerDNS and PowerDNS Admin in Docker Containers 1](img//Running-PowerDNS-and-PowerDNS-Admin-in-Docker-Containers-1.png?ezimgfmt=rs:633x644/rscb23/ng:webp/ngcb23 "Running PowerDNS and PowerDNS Admin in Docker Containers 2")](data:image/svg+xml,%3Csvg%20xmlns=%22http://www.w3.org/2000/svg%22%20width=%22633%22%20height=%22644%22%3E%3C/svg%3E)

Login using the created user.

[![Running PowerDNS and PowerDNS Admin in Docker Containers 3](img//Running-PowerDNS-and-PowerDNS-Admin-in-Docker-Containers-3-.png?ezimgfmt=rs:489x427/rscb23/ng:webp/ngcb23 "Running PowerDNS and PowerDNS Admin in Docker Containers 3")](data:image/svg+xml,%3Csvg%20xmlns=%22http://www.w3.org/2000/svg%22%20width=%22489%22%20height=%22427%22%3E%3C/svg%3E)

Now access the dashboard by providing the URL _**http://pdns:8081/**_ and API Key in the YAML **secret** and **update**

[![Running PowerDNS and PowerDNS Admin in Docker Containers 11](img//Running-PowerDNS-and-PowerDNS-Admin-in-Docker-Containers-11.png?ezimgfmt=rs:696x565/rscb23/ng:webp/ngcb23 "Running PowerDNS and PowerDNS Admin in Docker Containers 4")](data:image/svg+xml,%3Csvg%20xmlns=%22http://www.w3.org/2000/svg%22%20width=%22803%22%20height=%22652%22%3E%3C/svg%3E)

Now the error will disappear, proceed to the dashboard.

[![Running PowerDNS and PowerDNS Admin in Docker Containers 5](img//Running-PowerDNS-and-PowerDNS-Admin-in-Docker-Containers-5-1024x588.png?ezimgfmt=rs:696x400/rscb23/ng:webp/ngcb23 "Running PowerDNS and PowerDNS Admin in Docker Containers 5")](data:image/svg+xml,%3Csvg%20xmlns=%22http://www.w3.org/2000/svg%22%20width=%221024%22%20height=%22588%22%3E%3C/svg%3E)

There are no domains at the moment, we need to add new domains. Let’s create a sample by clicking on **+New Domain** tab.

[![Running PowerDNS and PowerDNS Admin in Docker Containers 6](img//Running-PowerDNS-and-PowerDNS-Admin-in-Docker-Containers-6.png?ezimgfmt=rs:587x703/rscb23/ng:webp/ngcb23 "Running PowerDNS and PowerDNS Admin in Docker Containers 6")](data:image/svg+xml,%3Csvg%20xmlns=%22http://www.w3.org/2000/svg%22%20width=%22587%22%20height=%22703%22%3E%3C/svg%3E)

Enter the domain name you want to add, you can as well select the template to use for configuration from the templates list, and **submit**. Navigate to the dashboard and you will have your domain added as below.

[![Running PowerDNS and PowerDNS Admin in Docker Containers 7](img//Running-PowerDNS-and-PowerDNS-Admin-in-Docker-Containers-7-1024x649.png?ezimgfmt=rs:696x441/rscb23/ng:webp/ngcb23 "Running PowerDNS and PowerDNS Admin in Docker Containers 7")](data:image/svg+xml,%3Csvg%20xmlns=%22http://www.w3.org/2000/svg%22%20width=%221024%22%20height=%22649%22%3E%3C/svg%3E)

Records can be added to the domain by clicking on it. Set the name of the record, save and apply changes.

[![Running PowerDNS and PowerDNS Admin in Docker Containers 8](img//Running-PowerDNS-and-PowerDNS-Admin-in-Docker-Containers-8-1024x428.png?ezimgfmt=rs:696x291/rscb23/ng:webp/ngcb23 "Running PowerDNS and PowerDNS Admin in Docker Containers 8")](data:image/svg+xml,%3Csvg%20xmlns=%22http://www.w3.org/2000/svg%22%20width=%221024%22%20height=%22428%22%3E%3C/svg%3E)

PowerDNS admin web UI makes it easy to manage the PowerDNS Admin. Here there are many other configurations you can make such as editing the domain templates, removing domains, managing user accounts e.t.c. View the history of activities performed on the server.

[![Running PowerDNS and PowerDNS Admin in Docker Containers 10](img//Running-PowerDNS-and-PowerDNS-Admin-in-Docker-Containers-10-1024x580.png?ezimgfmt=rs:696x394/rscb23/ng:webp/ngcb23 "Running PowerDNS and PowerDNS Admin in Docker Containers 9")](data:image/svg+xml,%3Csvg%20xmlns=%22http://www.w3.org/2000/svg%22%20width=%221024%22%20height=%22580%22%3E%3C/svg%3E)

## Step 6 – Secure PowerDNS Web with SSL

You can as well issue SSL certificates in order to access the web UI using **HTTPS** which is more secure. In this guide, we will issue self-signed Certificates using **OpenSSL**. Ensure `openssl` is installed before proceeding as below.

```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout pdnsadmin_ssl.key -out pdnsadmin_ssl.crt
```

Provide the required details to create the certificates. Once created, move them to the **/etc/ssl/certs** directory.

```
sudo cp pdnsadmin_ssl.crt /etc/ssl/certs/pdnsadmin_ssl.crt
sudo mkdir -p /etc/ssl/private/
sudo cp pdnsadmin_ssl.key /etc/ssl/private/pdnsadmin_ssl.key
```

Now install the Nginx web server.

```
##On RHEL/CentOS/Rocky Linux 8
sudo yum install nginx

##On Debian/Ubuntu
sudo apt install nginx
```

Create a PowerDNS admin Nginx conf file. On a Rhel-based system, the conf will be under **/etc/nginx/conf.d/** as below

```
sudo vim /etc/nginx/conf.d/pdnsadmin.conf
```

Now add the lines below replacing the server name.

```
      server {
        listen       443 ssl http2 default_server;
        listen       [::]:443 ssl http2 default_server;
        server_name  pdnsadmin.computingforgeeks.com;
        root         /usr/share/nginx/html;

        ssl_certificate /etc/ssl/certs/pdnsadmin_ssl.crt;
        ssl_certificate_key /etc/ssl/private/pdnsadmin_ssl.key;
ssl_protocols TLSv1.2 TLSv1.1 TLSv1;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
       proxy_pass http://localhost:8080/;
            index  index.html index.htm;
       }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
```

Save the file and set the appropriate permissions.

```
# CentOS / RHEL / Fedora
sudo chown nginx:nginx /etc/nginx/conf.d/pdnsadmin.conf
sudo chmod 755 /etc/nginx/conf.d/pdnsadmin.conf

# Debian / Ubuntu
sudo chown www-data:www-data /etc/nginx/conf.d/pdnsadmin.conf
sudo chmod 755 /etc/nginx/conf.d/pdnsadmin.conf
```

Start and enable Nginx.

```
sudo systemctl start nginx
sudo systemctl enable nginx
```

You may need to allow HTTPS through the firewall.

```
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --reload
```

Now access PowerDNS admin web via HTTPS with the URL [https://IP\_Address](https://ip_address/) or [https://domain\_name](https://domain_name/)

[![Running PowerDNS and PowerDNS Admin in Docker Containers 12](img//Running-PowerDNS-and-PowerDNS-Admin-in-Docker-Containers-12.png?ezimgfmt=rs:696x649/rscb23/ng:webp/ngcb23 "Running PowerDNS and PowerDNS Admin in Docker Containers 10")](data:image/svg+xml,%3Csvg%20xmlns=%22http://www.w3.org/2000/svg%22%20width=%22805%22%20height=%22751%22%3E%3C/svg%3E)

## Conclusion.

That marks the end of this guide on how to run PowerDNS and PowerDNS Admin in Docker Containers. I hope this was significant.

## References

- https://computingforgeeks.com/running-powerdns-and-powerdns-admin-in-docker-containers/
- [Deploy Pinpoint APM (Application Performance Management) in Docker Containers](https://computingforgeeks.com/deploy-pinpoint-apm-in-docker-containers/)
- [How To Run QuestDB SQL database in Docker Container](https://computingforgeeks.com/how-to-run-questdb-sql-database-in-docker-container/)
- [Run Microsoft SQL Server in Podman|Docker Container](https://computingforgeeks.com/how-to-run-microsoft-sql-server-in-podman-docker-container/)
- [How To Run Netbox IPAM in Docker Containers](https://computingforgeeks.com/how-to-run-netbox-ipam-tool-in-docker-containers/)