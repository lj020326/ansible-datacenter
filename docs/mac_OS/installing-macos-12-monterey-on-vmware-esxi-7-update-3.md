
# Installing macOS 12 Monterey on VMware ESXi 7 Update 3

I thought I'd write a simplistic guide to running macOS on vSphere 7. 

Below you'll find the step-by-step instructions on how I got this installed in my [home lab](https://vmscrub.com/home-lab/). 

**DISCLAIMER**

This should only be run in a lab environment and not in a production environment. Don't be that person! 

\- Please note: This guide is written for an Intel compute based machine running a [Type 1](https://en.wikipedia.org/wiki/Hypervisor) bare metal hypervisor and not a [Type 2](https://en.wikipedia.org/wiki/Hypervisor) like VMware Workstation or VMware Fusion. -

## Prerequisites

1.  [](https://apps.apple.com/us/app/macos-monterey/id1576738294?mt=12)[VMware ESXi 7 Update 3](https://customerconnect.vmware.com/en/downloads/info/slug/datacenter_cloud_infrastructure/vmware_vsphere/7_0)  
    
2.  [macOS 12 Monterey ISO](https://apps.apple.com/us/app/macos-monterey/id1576738294?mt=12)
3.  [macOS Unlocker](https://github.com/erickdimalanta/esxi-unlocker)

First we'll need the above 3 items in order to complete this whole process.  

## VMware ESXi 7 Update 3

### 1\. Download VMware ESXi 7 Update 3

So first things first! We will fetch the [latest ESXi version](https://customerconnect.vmware.com/en/downloads/info/slug/datacenter_cloud_infrastructure/vmware_vsphere/7_0) and install it prior to installing macOS 12. Go to the downloads page [here](https://customerconnect.vmware.com/en/downloads/info/slug/datacenter_cloud_infrastructure/vmware_vsphere/7_0) and select the version of ESXi you have and want to install/update. 

![](./img/vsphere7u3c.png "vsphere7u3c")

### 2\. Install/Upgrade VMware ESXi 7 Update 3

Once you've selected the correct install for your licensed version of vSphere, you'll simply need to install it. I've written a previous guide on how to [Upgrade from an offline bundle here](https://vmscrub.com/upgrade-esxi-65-version-using-the-offline-bundle/). This is the path I went with in order to update the current ESXi install in my lab. 

![](./img/vsphere7u3c_build.jpg "vsphere7u3c_build")

## macOS 12 Monterey ISO

Next we'll need to obtain the macOS 12 Monterey ISO. I'm sure it'll be easy to search the net and find the ISO, but ensure you get it from a valid trusted source. Otherwise make sure you validate the [SHA-1](https://en.wikipedia.org/wiki/SHA-1), [CRC](https://en.wikipedia.org/wiki/Cyclic_redundancy_check) and [MD5](https://en.wikipedia.org/wiki/MD5) values of the image to make sure it hasn't been tampered with before installing it. 

I'll take the safer route and create it myself using a macOS native machine. If you have access to a MacBook, iMac or Mac mini already on Monterey, you should be able to create an ISO from any one of those machines.  

#### **Can't you hook a brotha up and let me direct download the ISO from your site?** 

### 1\. Download macOS 12 Monterey Installer

-   Once you have a macOS native machine running Monterey in front of you, [navigate to the App Store here](https://apps.apple.com/us/app/macos-monterey/id1576738294?mt=12) to download the obtain the Monterey installer. Once you click the link, you should see a browser pop-up asking you to open **App Store.app**. 

![](./img/macos_appstore.jpg "macos_appstore")

-   From there, the App Store app should open up to the Monterey page. click on the **Get** button to download Monterey. 

![](./img/Monterey_Get.jpg "Monterey_Get")

Once you click on **Get** you'll be greeted with a download prompt. Click on **Download** then wait for the download to complete. Download times will vary based on your network speed. 

![](./img/macos_download.jpg "macos_download")

![](./img/macos_download_time.jpg "macos_download_time")

When the download is finished, you'll be prompted with the install window to Continue. However...

**DO NOT CLICK CONTINUE!**

![](./img/hellboy_stop.gif "hellboy_stop")

![](./img/monterey_dontcont.jpg "monterey_dontcont")

Instead, simply press **Command + Q** to at this install window. Once you do, simply click on **Quit** at the prompt to close the window.  

![](./img/monterey_dontcont_quit.jpg "monterey_dontcont_quit")

If you did everything correctly, you should now have the **Install macOS Monterey.app** listed in your **Application** Folder. This app is what we'll use to create our ISO in the next step. 

![](./img/install_monterey_app.jpg "install_monterey_app")

### 2\. Mount Installer then Convert to ISO

Now that we have the Monterey App, we'll run a few commands to first mount the installer then convert it to an ISO with the purpose of mounting it to a VM in ESXi. 

-   Launch the terminal and run the following command. 

Running this command will prompt for the administrator password. Once you type it in, you'll now be logged in as the root user which will be the account we'll use to execute the rest of the commands. 

![](./img/sudo.jpg "sudo")

-   From the **root#** prompt, enter in the following command:

hdiutil create -o /tmp/monterey -size 13800.1m -volname monterey -layout SPUD -fs HFS+J

hdiutil create -o /tmp/monterey -size 13800.1m -volname monterey -layout SPUD -fs HFS+J

```
 hdiutil create -o /tmp/monterey -size 13800.1m -volname monterey -layout SPUD -fs HFS+J
```

This will create the directory **/tmp/monterey.dmg**

![](./img/temp_mont.jpg "temp_mont")

\*\* This **13800.1m** size for this guide was based on the version **12.2** of macOS and may be different for any updates/patches on future **12.x** versions. \*\*

-   After this we'll need to mount the dmg using the following command:

hdiutil attach /tmp/monterey.dmg -noverify -mountpoint /Volumes/monterey

hdiutil attach /tmp/monterey.dmg -noverify -mountpoint /Volumes/monterey

```
hdiutil attach /tmp/monterey.dmg -noverify -mountpoint /Volumes/monterey
```

-   You should see the following output below:

![](./img/volume_monterey.jpg "volume_monterey")

You should now also be able to see the mounted disk under Disk Utility. 

![](./img/disk_utility.jpg "disk_utility")

-   Next we'll create the install media from our new mount with this command:

sudo /Applications/Install\\ macOS\\ Monterey.app/Contents/Resources/createinstallmedia --volume /Volumes/monterey --nointeraction

sudo /Applications/Install\\ macOS\\ Monterey.app/Contents/Resources/createinstallmedia --volume /Volumes/monterey --nointeraction

```
sudo /Applications/Install\ macOS\ Monterey.app/Contents/Resources/createinstallmedia --volume /Volumes/monterey --nointeraction
```

You should see the following result below while making the disk bootable. 

![](./img/mont_bootable.jpg "mont_bootable")

-   Afterwards, you can eject the attached install disk using the following command:

hdiutil eject -force /volumes/Install\\ macOS\\ Monterey

hdiutil eject -force /volumes/Install\\ macOS\\ Monterey

```
hdiutil eject -force /volumes/Install\ macOS\ Monterey
```

You should see that the install disk is ejected now. 

![](./img/eject_install_mont.jpg "eject_install_mont")

-   Next we'll need to convert the image to a .cdr with the following command:

hdiutil convert /tmp/monterey.dmg -format UDTO -o /Users/erickdimalanta/Desktop/monterey.cdr

hdiutil convert /tmp/monterey.dmg -format UDTO -o /Users/erickdimalanta/Desktop/monterey.cdr

```
hdiutil convert /tmp/monterey.dmg -format UDTO -o /Users/erickdimalanta/Desktop/monterey.cdr
```

Don't forget to change the path /Users/erickdimalanta/Desktop/monterey.cdr to your own specific path you are working out of. Once you run the command, you should now see a **monterey.cdr** file in your working directory that is about 14.47 GB. 

![](./img/monterey_cdr.jpg "monterey_cdr")

![](./img/monterey14gb.jpg "monterey14gb")

Now that we have our media, we simply need to rename the file extension to a .iso. You can do so with the command below by running an in-place mv(move) command. 

mv /Users/erickdimalanta/Desktop/monterey.cdr /Users/erickdimalanta/Desktop/monterey.iso

mv /Users/erickdimalanta/Desktop/monterey.cdr /Users/erickdimalanta/Desktop/monterey.iso

```
mv /Users/erickdimalanta/Desktop/monterey.cdr /Users/erickdimalanta/Desktop/monterey.iso
```

Again, make sure you set "**YOUR**" correct path if you are copying and pasting the command above. 

![](./img/mont_iso.jpg "mont_iso")

![](./img/mont_iso_final.jpg "mont_iso_final")

### 3\. Cleaning Up

Finally let's clean up after ourselves since leaving remnants of leftover data is not too nice.

We are going to clean up the initial directory where we created the **monterey.dmg** in the following path **/tmp/monterey.dmg**. Use the below command to cleanup. 

This above command will make sure to force delete everything in the specified directory without prompting for confirmation. So basically we are removing everything in the **/tmp** folder that starts with "**mont**." Make sure nothing else starts with "**mont**" otherwise you'll remove that also. 

  
The below screenshot shows how to simply validate and double check afterwards. 

![](./img/cleanup_mont.jpg "cleanup_mont")

### 4\. Upload Monterey ISO to Datastore

For the last step in this section, we'll need to transfer the newly created **Monterey.iso** to our VMware environment. You can upload it to a datastore or Content Library if you are also running a vCenter. To keep it simple, I'll showcase uploading it to a datastore. 

1.  Login to your **ESXi host**
2.  Navigate to **Storage** and select the **Datastore** you want to place the .iso in. 
3.  Click on **Datastore Browser**
4.  Select the **Datastore** 
5.  Select the folder you'll place the .iso in. I'll use the **ISO folder**. 
6.  Then click on **Upload**

![](./img/datastore_upload.jpg "datastore_upload")

Navigate to the directory where you created the monterey.iso. Select the **monterey.iso** and click on **Open**. 

![](./img/upload_mont_iso.jpg "upload_mont_iso")

Review the **Recent Tasks** pane, do a run around the block, then monitor to completion. 

![](./img/upload_monterey_iso.jpg "upload_monterey_iso")

![](./img/run_forrest.gif "run_forrest")

## macOS Unlocker Installation

Once the .iso is finally uploaded to the datastore, it's now time to prep our ESXi host with the ability to run macOS in a VM. The unlocker is written python that modifies the [vmware-vmx file](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vm_admin.doc/GUID-CEFF6D89-8C19-4143-8C26-4B6D6734D2CB.html) to allow macOS to boot. Without this [unlocker](https://github.com/erickdimalanta/esxi-unlocker), the machine simply doesn't work and is suck in a sad infinite boot loop. 

![](./img/bootloop01.jpg "bootloop01")

![](./img/bootloop02.jpg "bootloop02")

### 1\. Download the Unlocker

You'll first need to download the [unlocker zip file here](https://github.com/erickdimalanta/esxi-unlocker/releases/download/3.0.1/esxi-unlocker-master.zip). 

The above link should be a direct download to the [unlocker](https://github.com/erickdimalanta/esxi-unlocker) from [github](https://github.com/erickdimalanta). The file name is **esxi-unlocker-master.zip**. 

### 2\. Upload to Datastore

Once you've downloaded the **esxi-unlocker-master.zip**, you'll need to upload this to the same location we uploaded the monterey.iso in a [previous step](https://vmscrub.com/installing-macos-12-monterey-on-esxi-7-update-3/#t-1637615402621) above. 

![](./img/esxi-unlocker-upload.jpg "esxi-unlocker-upload")

### 3\. SSH into ESXi host to Install the Unlocker

Bring up your terminal if you've previously closed it and SSH into your host.

**\- Make sure you enable SSH on your host if disabled. -**

![](./img/ssh_enable.jpg "ssh_enable")

From there, login to your ESXi host then navigate to your unlocker location as shown by the screenshot below. 

![](./img/unlocker-ssh.jpg "unlocker-ssh")

-   Once in the parent location of the unlocker, we'll need to unzip the **esxi-unlocker-master.zip** file. You can do so with the command below:

unzip esxi-unlocker-master.zip

unzip esxi-unlocker-master.zip

```
unzip esxi-unlocker-master.zip
```

The below image should be your resulted output.

![](./img/unlocker_unzip.jpg "unlocker_unzip")

### 4\. Set permissions on the extracted folder

Before we navigate to the newly extracted folder and install the patch. We'll need to set the permissions on the folder and files within. Not doing so will result in a "Permission denied" error as shown below. 

![](./img/permission_denied.jpg "permission_denied")

So since I'm here to save you the headache so that this install guide works the first time.

-   Enter the following command below:

chmod 775 -R esxi-unlocker-301/

chmod 775 -R esxi-unlocker-301/

```
chmod 775 -R esxi-unlocker-301/
```

![](./img/chmod.jpg "chmod")

This command will grant permissions to the folder and all the files recursively within. 

### 5\. Install Unlocker Patch

Once you've set the permissions on the folder and files above, we can now install the patch. First navigate to the extracted folder that contains all the files necessary for the patch. 

-   Enter in the following command:

![](./img/unlocker-navigate.jpg "unlocker-navigate")

Once there, we can actually use a patch validation checker to make sure the patch is installed or not. I know we haven't installed the patch yet, but let's just run that first to see the resulted output.

-   Run the following command to validate:

![](./img/smc_false.jpg "smc_false")

After running the command, it will obviously show **false** since we've not yet installed the patch. Well let's do it now! 

-   Run the following command to install the patch:

![](./img/unlocker-install.jpg "unlocker-install")

Once you've run the install **./esxi-install.sh**, we'll need to now restart the server for the configuration changes to take effect.

\*\*Make sure you have no running VMs before typing **reboot**. ![😛](https://s.w.org/images/core/emoji/14.0.0/svg/1f61b.svg)\*\*

In the same terminal window, you can simply type **reboot** then press Enter. 

![](./img/reboot-after-install.jpg "reboot-after-install")

### 6\. Validate Successful Patch Install

When the ESXi host is back up from it's reboot, let's SSH into the host again and navigate to the same location where we ran the patch installer. 

Once there run the validation command again to now see a different result.  

This should now display **smcPresent = true** which means we are now ready to install macOS without running into any boot issues. 

![](./img/smcinstall-true.jpg "smcinstall-true")

## macOS 12 Monterey VM Install

If you've followed the above steps correctly, you should now be able to continue on and install Monterey!

### 1\. Create a New Virtual Machine

Go back to your ESXi host and navigate to the **Virtual Machine** menu item on the left. Then click on **Create / Register VM**. 

Another screen will pop up. From there select **Create a new virtual machine** and click on **Next**. 

![](./img/create_vm.jpg "create_vm")

Next, type out a name for your new VM. Select the following options from the drop down menu for the rest of the categories.

-   Name: **ANY NAME SHORTER THAN 80 CHARACTERS**
-   Compatibility: **ESXi 7.0 U2 virtual machine (U3 wasn't available despite being on U3)**
-   Guest OS Family: **Mac OS**
-   Guest OS version: **Apple macOS 12 (64-bit)**

 Finally, click **Next** when finished. 

![](./img/create_vm02.jpg "create_vm02")

From here, select which datastore you'll want to place your machine in. 

![](./img/create_vm02a.jpg "create_vm02a")

The next option will be to configure the hardware specs of the VM. 

You are going to want to set your **CPU**, **Memory**, **Storage** size, [type of provisioning](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vm_admin.doc/GUID-4C0F4D73-82F2-4B81-8AA7-1DD752A8A5AC.html), **Network**, and most importantly configure your **CD/DVD Drive 1** to boot from the **monterey.iso** we've created. This is located in the ISO folder on the datastore we uploaded it to in an [earlier step](https://vmscrub.com/installing-macos-12-monterey-on-esxi-7-update-3/#t-1637615402621). 

Click on **Next** once done. 

![](./img/create_vm04.jpg "create_vm04")

Finally, confirm all your settings are what you want, then click on **Finish** when complete. 

![](./img/create_vm05.jpg "create_vm05")

### 2\. Power On VM & Format VM Storage

Sweet! Now that you are done creating your VM, let's power this bad boy on to see if it bypasses the boot loop error since we [applied the Unlocker patch](https://vmscrub.com/installing-macos-12-monterey-on-esxi-7-update-3/#t-1637704318850). 

![](./img/poweron01.jpg "poweron01")

![](./img/poweron02.jpg "poweron02")

Select your language of choice and click on the bottom **right arrow**. Next we'll need to format the newly provisioned disk so that macOS can recognize the storage to install itself onto. 

-   Select **Disk Utility** and click on **Continue**.

![](./img/macos_install02.jpg "macos_install02")

-   Next, highlight the **VMware Virtual SATA Hard Drive Media** and click on the **Erase** option at the top.

![](./img/macos_install03.jpg "macos_install03")

Enter in a Name to label your disk and keep the defaults for Format - **APFS** and Scheme - **GUID Partition Map**.

-   Click the **Erase** button when ready

![](./img/macos_install04.jpg "macos_install04")

-   The formatting process will proceed. Once complete, click **Done**.

![](./img/macos_install05.jpg "macos_install05")

-   We can now quit Disk Utility by navigating to the top menu and clicking on **Disk Utility** > **Quit Disk Utility**. 

![](./img/macos_install06.jpg "macos_install06")

### 3\. Install macOS 12 Monterey

-   Now we can install the OS. From here select **Install macOS Monterey** then click on **Continue**.

![](./img/macos_install07.jpg "macos_install07")

-   On the next screen click **Continue**

![](./img/macos_install08.jpg "macos_install08")

Click **Agree** twice for the Software License Agreement

![](./img/macos_install09.jpg "macos_install09")

![](./img/macos_install10.jpg "macos_install10")

Click on the newly formatted HDD then click on **Continue**.

![](./img/macos_install11.jpg "macos_install11")

macOS Monterey will start to install now...

![](./img/macos_install12.jpg "macos_install12")

![](./img/macos_install13.jpg "macos_install13")

Don't believe the time remaining is even close to accurate. I would go bake a frozen pizza and watch a movie or something, then come back waaaayyyyy later. 

When the never ending string of installation reboots are completed, the install will be complete! Again, I won't go through this self-explanatory setup wizard. 

![](./img/monterey01.jpg "monterey01")

## Install VMware Tools (Optional but necessary)

Finally, the last thing to do after you've gone through the initial OS setup wizard, is to install VMware tools. You can also unmount the **monterey.iso** from the VM at this point since it's no longer needed.  

#### **VMware tools** 

### 1\. VMware Tools Error 21001

You'll likely receive the below error when attempting to mount the VMware Tools from the host.

_**Failed - The required VMware Tools ISO image does not exist or is inaccessible.**_ 

![](./img/Tools_Install_Error-01.jpg "Tools_Install_Error 01")

![](./img/Tools_Install_Error.jpg "Tools_Install_Error")

This occurs because the **darwin.iso** doesn't exist in the directory "**/usr/lib/vmware/isoimages.**" Which is fine as these are the iso images that shipped with this version of ESXi that I installed. According to the [KB 2129825](https://kb.vmware.com/s/article/2129825) we have a few options in resolving this. I'm going to simply go with the option to download the latest VMware tools for this specific OS.

### 2\. Download VMware Tools

-   Make sure you are logged into your [Customer Connect](https://customerconnect.vmware.com/login?bmctx=296D2E0AAD70CA31C97E695D763C13F7622392514A6552A849FE0184F298DF1D&contextType=external&username=string&OverrideRetryLimit=1&action=%2F&password=secure_string&challenge_url=https:%2F%2Fcustomerconnect.vmware.com%2Flogin&creds=username%20password&request_id=4356316440978171257&authn_try_count=0&locale=en_US&resource_url=%252Fuser%252Floginsso) account. Then click [Here](https://customerconnect.vmware.com/en/downloads/details?downloadGroup=VMTOOLS1135&productId=1073&rPId=74478) to Download the latest VMware Tools. I selected the .zip option.

![](./img/VMware_tools_dl.jpg "VMware_tools_dl")

Next, navigate to your download location and extract the .zip. On macOS you can simply double-click the file to extract. 

![](./img/vmtools_extract01.jpg "vmtools_extract01")

Sweet! Now you should have the **darwin.iso** image we need to install VMware Tools onto our macOS 12 Virtual Machine. 

### 3\. Mount VMware Tools ISO to VM

Now that we have the VMware Tools image for macOS, we'll need to upload the .iso to a datastore the same way we [Uploaded the monterey.iso](https://vmscrub.com/installing-macos-12-monterey-on-esxi-7-update-3/#t-1637615402621) in an earlier step. 

Once the iso is uploaded there, **Edit settings** on the VM and select the **darwin.iso** to mount just like we did when we were [creating the VM](https://vmscrub.com/installing-macos-12-monterey-on-esxi-7-update-3/#t-1637704318853). When done, click **Save**. 

![](./img/monterey_tools02.jpg "monterey_tools02")

#### **So...who in the heck is Darwin?** 

### 4\. Install VMware Tools in Monterey

Next we'll hop back over to our VM and we can now see that VMware Tools is mounted and ready for install. 

![](./img/monterey_tools03.jpg "monterey_tools03")

Double click on the **Install VMware Tools** icon. From there the Tools installer will launch. Click on **Continue** to proceed. 

![](./img/monterey_tools04a.jpg "monterey_tools04a")

Click **Install** on the next screen

![](./img/monterey_tools05a.jpg "monterey_tools05a")

You'll then be prompted to enter in the **password** you set when you went through the initial OS setup wizard. Once done, click on **Install Software**. Then click **OK** on the administer prompt. 

![](./img/monterey_tools06a.jpg "monterey_tools06a")

![](./img/monterey_tools07a.jpg "monterey_tools07a")

You'll then likely receive a **System Extension Blocked** prompt during this process. Click on **Open Security Preferences**. At this point the **Security & Privacy** window will open up. Once opened, click on the lock in the bottom left and enter in your OS password, then click **Unlock**. 

Once done and the lock icon is unlocked, click on the **Allow** button to allow VMware Tools to continue loading. 

![](./img/monterey_tools11a.jpg "monterey_tools11a")

You should now receive a prompt to Restart before using the system extensions. But before doing so, click on the open **Installer** in the dock below. 

![](./img/monterey_tools12a.jpg "monterey_tools12a")

![](./img/monterey_tools13b.jpg "monterey_tools13b")

The VMware Tools window should showcase that the installation was successful. Go back to the **Security & Privacy** window in the background and click on **Restart** from there.  

Once the machine has rebooted, you should now see that VMware Tools are installed for this VM. From there, you can either eject the mounted VMware Tools image from the OS or disconnect it from the **CD/DVD Drive 1** option in the VM under **Edit settings**. 

![](./img/monterey_tools14.jpg "monterey_tools14")

You should now have a macOS 12 environment that you can test and break all you want! Have fun! 

## Reference

* https://vmscrub.com/installing-macos-12-monterey-on-vmware-esxi-7-update-3/
* [shanyungyang](https://github.com/shanyungyang/esxi-unlocker)'s github and everyone else involved that helped me put this updated simple guide together.\*\*
