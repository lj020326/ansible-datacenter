
# Plex Media Server with Intel NUC and Ubuntu 22.04 LTS

## HARDWARE

-   Intel NUC (BOXNUC7I5BNK, i5-7260U 2,20 GHz, [Link 534](https://www.intel.com/content/www/us/en/products/boards-kits/nuc/kits/nuc7i5bnk.html))
-   2 x 8GB DDR4 RAM (CT2K8G4SFD8213, [Link 117](https://www.amazon.com/dp/B015HQ9VEM))
-   250GB M.2 PCIe NVMe SSD (Samsung 960 EVO MZ-V6E250BW, [Link 92](https://www.amazon.com/dp/B01LYFKX41))

This hardware setup is meant to be an allrounder. Fast enough to transcode multiple movies at the same time, almost completely silent in order to run it in the living room and power efficient in order to run it 24/7. It is able to hardware transcode three H.264 1080p movies at the same time with ~30-35% CPU load. Transcoding a single H.265 4K HDR movie has ~35-40% CPU load.  
If you are looking for a single user setup this NUC might be overkill, the [NUC i3 210](https://www.intel.com/content/www/us/en/products/boards-kits/nuc/kits/nuc7i3dnke.html) with 2 x 4GB RAM should be fine then.

  

## Step 1: Install Ubuntu

-   Update BIOS with latest from Intel’s website
    
-   Install Ubuntu 22.04 LTS 64bit server version
    
-   Use the following partition scheme (ESP size was suggested by Ubuntu, swap size is much bigger than usual because of RAM transcoding):
    
    > #1: 536MB, ESP, bootable
    

> #2: 64GB, swap  
> #3: 185,5GB, ext4

-   Setup user named `plex`

  

## Step 2: Install Plex Media Server

-   Add plex repository as source
    -   `echo deb https://downloads.plex.tv/repo/deb/ public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list`
    -   `curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -`
-   Install Plex Media Server + dependencies
    -   `sudo apt-get update && sudo apt-get install avahi-daemon avahi-utils plexmediaserver`
    -   During installation you will be asked if you want to override the plex repository source with the one from the package. Select `yes`.
-   Re-enable plex repository source
    -   By default the plex repository source from the package is disabled (commented out), enable it in `/etc/apt/sources.list.d/plexmediaserver.list`

  

## Step 3: Setup NFS and Autofs

-   Install dependencies
    -   `sudo apt-get install autofs nfs-common`
-   Create mount directory and configure Autofs
    -   `sudo mkdir /data`
    -   `sudo nano /etc/auto.master`
    -   Append the following line at the end of the file:

```
/data      /etc/auto.data
```

-   Create Autofs configuration file for data directory
    -   `sudo cp /etc/auto.misc /etc/auto.data`
    -   Append all your mount points at the end of the file, for example:

```
movies    -fstype=nfs4    :/volume1/Movies
music     -fstype=nfs4    :/volume1/Music
```

-   Restart Autofs
    -   `sudo systemctl restart autofs`
-   All your mount points are now available at `/data/...`
-   Autofs will automatically unmount all mount points if there is no access within 5 minutes and remount if you try to access the mount point. You can keep ghost references to the mount points by adding `--ghost` in `auto.master` at the end of the appended line

  

## Step 4: Configure Plex Media Server

-   Open `http://<ip-of-your-server>:32400/web` in your browser and configure your server

  

## Step 5: Setup RAM transcoding

-   Create transcoding directory
    -   `sudo mkdir /tmp/transcoding`
-   Setup the system to mount the RAM disk on every boot
    -   `sudo nano /etc/fstab`
    -   Append the following line:

```
tmpfs    /tmp    tmpfs    defaults,noatime,nosuid,nodev,noexec,size=64G,mode=1777    0    0
```

-   Grant writing permissions for the transcoding directory
    -   `sudo chown -R plex:plex /tmp/transcoding`
-   Use `/tmp/transcoding` in Plex Media Server > Settings > Server > Transcoder > Temporary directory

  

## Additional notes / tips

-   In order to update plex media server it is enough to run the system update: `sudo apt-get update && sudo apt-get upgrade`
-   If you setup a DDNS service for your server consider to configure the Ubuntu firewall. In that case please check out the [Plex reference 8](https://support.plex.tv/hc/en-us/articles/201543147-What-network-ports-do-I-need-to-allow-through-my-firewall-) for which ports you need to allow

## Reference

* https://forums.plex.tv/t/guide-plex-media-server-with-intel-nuc-and-ubuntu-16-04-lts/217937
* 