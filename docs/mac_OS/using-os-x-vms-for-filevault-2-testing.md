
# Using OS X VMs for FileVault 2 Testing

This post details how to create a FileVault 2-ready base OS X virtual machine using **Parallels Desktop 10** and then create either a virtual machine template or make use of the new ‘linked clones’ feature to quickly create new virtual machines to test FileVault 2 workflows.

Using a virtual machine for FileVault 2 testing has a number of benefits.

-   A virtual machine is much smaller than most Macs (without repartitioning) and it takes less time to fully encrypt.
-   Instead of having to decrypt a Mac to run a test again, or wipe it to reinstall OS X, you can clone virtual machines endlessly and delete the encrypted ones when you are finished with them.
-   You can also snapshot virtual machines and them revert to previous states.

## **Create a New Base OS X 10.9 VM**

You can easily create a new virtual machine by dragging the “Install OS X Mavericks.app” onto the Parallels icon in your dock.

![](./img/fv2_vm_02.png?w=104&h=150)

Choose the default options for CPU (2), RAM (2 GB) and Disk space (64 GB).

![](./img/fv2_vm_01.png?w=300&h=211)

Click Continue to create the virtual machine.

## **Repartition the VM to Conserve Disk Space**

When a virtual machine is FileVault 2 encrypted it will encrypt **all** of the disk space that it is assigned.  If left at the default of 64 GB the virtual disk file will expand to the full size and take up unneeded space on your Mac.

To prevent this, repartition the disk drive so the boot volume only takes up what is required to install OS X.

Once you are in the OS X Installer, go to the **Utilities** menu and open **Disk Utility**.

![](./img/fv2_vm_03.png?w=300&h=237)

Split the drive into two partitions with the first/boot partition being set to 16 GB.

![](./img/fv2_vm_04.png?w=300&h=237)

Click **Apply** to create the new partitions and then quit Disk Utility.

[![](./img/fv2_vm_05.png?w=300&h=189)](./img/fv2_vm_05.png)

Install OS X to the 16 GB boot partition.

![](./img/fv2_vm_06.png?w=300&h=237)

## **Reinstall OS X to Create a Recovery Partition**

Once the install of OS X has finished and you have created your account open Terminal and run ‘diskutil list’.  You will note there is no Recovery HD partition present.

Per Parallel’s KB article, copying the “Install OS X Mavericks.app” to the virtual machine and running it will correctly create the Recovery HD partition and allow FileVault 2 encryption.

[http://kb.parallels.com/en/122661](http://kb.parallels.com/en/122661)

Mount your host Mac in the virtual machine and copy the “Install OS X Mavericks.app” to your second partition.  Then run it and re-install OS X Mavericks.

![](./img/fv2_vm_07.png?w=300&h=237)

Upon completion of the second install, run ‘diskutil list’ again and you will find the Recovery HD is present.

![](./img/fv2_vm_08.png?w=300&h=187)

The final virtual machine takes up less than ~15 GB of disk space on your Mac.

**DO NOT FILEVAULT 2 ENCRYPT THIS!**

Close all open applications and shut down the virtual machine for the next steps.

## **Create a New VM for FileVault 2 Testing**

### **Option 1) Template the Base OS X 10.9 VM**

You can convert your base OS X virtual machine into a VM Template.  Select the virtual machine and then from the **File** menu select **“Clone to Template…”** to create a copy that will be the template, or select **“Convert to Template”** to convert the virtual machine and not create a copy.

![](./img/fv2_vm_09.png?w=300&h=125)

Once you have your template, double-click on it and you will receive a prompt to create a new virtual machine from it.  This will create a new virtual machine

![](./img/fv2_vm_10.png?w=300&h=133)

You can share a virtual machine template with other Parallels users or move it to other Macs.  Each virtual machine created from a template will have unique identifiers to avoid conflicts.

### **Option 2) Create a Linked Clone of the Base OS X 10.9 VM**

“Linked Clones” are a new feature of Parallels Desktop 10.  A linked clone is a virtual machine created from a snapshot of a “parent” virtual machine.  This method is faster than the above virtual machine templates for spinning up instances.

[http://kb.parallels.com/en/122669](http://kb.parallels.com/en/122669)

By selecting **“New Linked Clone…”** from the virtual machine’s context menu a snapshot will be  automatically created from the parent virtual machine and the cloned virtual machine window will immediately appear and be ready to launch.

![](./img/fv2_vm_11.png?w=300&h=170)

## **Enable FileVault 2 on the Cloned VM**

With your clone of the base virtual machine you can now enroll it to a JSS (or whatever) to test whatever FileVault 2 workflows are required.

In the below screenshots you can see this virtual machine was enrolled, a configuration profile was deployed requiring FileVault 2 and included key redirection to the JSS.  Once logged out, FileVault 2 was triggered.

![](./img/fv2_vm_12.png?w=300&h=237)

![](./img/fv2_vm_13.png?w=300&h=237)

![](./img/fv2_vm_14.png?w=300&h=237)

![](./img/fv2_vm_15.png?w=450&h=89)

## Reference

* https://bryson3gps.wordpress.com/2014/08/27/using-os-x-vms-for-filevault-2-testing/
* 