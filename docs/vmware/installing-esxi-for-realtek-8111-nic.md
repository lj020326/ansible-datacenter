
# Installing ESXi for Realtek 8111 NIC

I decided to setup another ESXi host on a [Mini-ITX build that I completed a while ago](https://avojak.com/blog/2020/09/11/elementary-os-desktop-build/). After downloading the latest ESXi ISO (version 7.0), I created the bootable USB drive, fired it up, and… failure. I don’t have a picture of the error, but it boiled down to a missing driver for the network card. No matter, I’ll just Google away and see what I can find.

Long story short, I struggled non-stop for at least 10 hours trying to get this working before stumbling across the EXACT blog post that I needed to find: [https://www.sysadminstories.com/2018/08/adding-realtek-8111-driver-to-vsphere.html?m=1](https://www.sysadminstories.com/2018/08/adding-realtek-8111-driver-to-vsphere.html?m=1). Turns out that the motherboard I’m using (ASUS Prime H310T R2.0/CSM) has a Realtek 8111 network card, just like the person who wrote the blog. Also very importantly, the author points out that this will not work for ESXi 7.

## The Steps

My first course of action was to setup a Windows VM on my MacBook Pro because I don’t have a Windows box to use, and the tools that I’d be using are for Powershell.

### Retrieving the ESXi 6.7 Offline Bundle

I had independently come across this blog with instructions about the [ESXi Customizer](https://www.v-front.de/p/esxi-customizer-ps.html), however I was trying to use ESXi 7 to no avail. The Powershell tool is available here: [https://github.com/VFrontDe/ESXi-Customizer-PS](https://github.com/VFrontDe/ESXi-Customizer-PS). The tool also requires that you have VMware PowerCLI, available here: [https://code.vmware.com/web/tool/12.1.0/vmware-powercli](https://code.vmware.com/web/tool/12.1.0/vmware-powercli).

Using ESXi-Customizer-PS I was able to fetch the elusive offline bundle for ESXi 6.7:

```shell
PS C:\Users\Andrew\Downloads> .\ESXi-Customizer-PS.ps1 -v67 -ozip
```

The `-v67` flag gets us version 6.7, while the `-ozip` flag gets us an offline bundle rather than the ISO.

There should now be a .zip file in the directory named something like: `ESXi-6.7.0-20201104001-standard.zip`.

### Retrieving the Realtek Driver

Next, I fetched the net55-r8168 Realtek driver from here: https://vibsdepot.v-front.de/wiki/index.php/Net55-r8168 (the offline bundle download). Despite the name, this driver supports Realtek 8168/8111/8411/8118 NICs.

### Building the New ISO

For better detail, see the original blog post I mentione (https://www.sysadminstories.com/2018/08/adding-realtek-8111-driver-to-vsphere.html?m=1).

With both of the offline bundles (ESXi and the Realtek driver) in the same directory, we can now run some more commands:

1.  Create the software depot:
    
    ```shell
     PS C:\Users\Andrew\Downloads> Add-EsxSoftwareDepot ".\net55-r8168-8.045a-napi-offline_bundle.zip", `
        "ESXi-6.7.0-20201104001-standard.zip" 
    ```
    
2.  Create an image profile by cloning an existing one:
    
    ```shell
     PS C:\Users\Andrew\Downloads> Get-EsxImageProfile
     PS C:\Users\Andrew\Downloads> New-EsxImageProfile -CloneProfile ESXi-6.7.0-20201104001-standard `
        -name ESXi-6.7.0-20201104001-standard-RTL8111 -Vendor Razz
     PS C:\Users\Andrew\Downloads> Set-EsxImageProfile ESXi-6.7.0-20201104001-standard-RTL8111 `
        -AcceptanceLevel CommunitySupported
    ```
    
3.  Add the driver to the new image profile:
    
    ```shell
     PS C:\Users\Andrew\Downloads> Get-EsxSoftwarePackage
     PS C:\Users\Andrew\Downloads> Add-EsxSoftwarePackage -ImageProfile ESXi-6.7.0-20201104001-standard-RTL8111 `
        -SoftwarePackage net55-r8168
    ```
    
4.  Create the ISO:
    
    ```shell
     PS C:\Users\Andrew\Downloads> Export-EsxImageProfile -ImageProfile ESXi-6.7.0-20201104001-standard-RTL8111 `
        -ExportToIso -filepath .\VMware-ESXi-6.7.0-20201104001-RTL8111.iso
    ```
    

### Create the Bootable USB Drive

I used [Rufus](https://rufus.akeo.ie/) as well to create the bootable USB drive from the ISO, but you can use any tool that will get the job done.

### Install ESXi

After plugging in the USB drive and navigating through the installer, everything went well until the end when I received a warning about hardware virtualization not being enabled. Once the installer completed I rebooted and went into the BIOS to enable Intel Hardware Virtualization support. I then deployed a test VM and everything worked perfectly!

_Note: You may need to disable secure boot from the BIOS prior to booting the installer_

## Limitations

It appears that this really only works for ESXi <7, which is not a problem for me since this is just a home setup.

## References

* https://williamlam.com/2020/03/homelab-considerations-for-vsphere-7.html
* https://avojak.com/blog/2020/12/19/installing-esxi-for-realtek-8111-nic/
* https://www.geekdecoder.com/how-to-customize-esxi-install-with-realtek-drivers/
* https://www.virten.net/2020/09/realtek-nic-and-esxi-7-0-use-passthrough-to-make-use-of-the-adapter/


