

# Could not download the identity profile from the encrypted profile service on MAC

I am getting attached error while logging onto company portal on MAC.

I have verified that MDM push certificate is up to date. I am trying to do it on a machine that's installed on VM ware. 

===
  
you might want to check if your device has a serial number. Sometimes after repair (replace of motherboard) the serial number is not written to the firmware again. You can verify with the "About This Mac" if you have a serial number. It must be displayed there. You then have two options. Call apple support to fix the missing serial number or you can follow some guides in the internet to write back the serial number to the firmware. But be aware utilizing internet tools for this is not supported and totally your personal risk! The process can also not be undone! It is not recommended to do! If you still like to do it, have a look for "blank board serializer" and there look for a version which boots with devices 2012 and later. After you have your serial number again, the enrollment should work again.  
  
===

SO it's installed on vmware

I found this article... maybe it's describing your problem  
\-----  
Intune/Apple doesn't like working on a VM-based Mac unless certain modifications are made to the .VMX file to make it look like a real Mac. I made these modifications originally but then upon rolling back one of my VM snapshots, the modification got lost. Since I was working off the base snapshot, what used to work no longer worked on any of the other VMs I built from the base snapshot.

So....

To modify the .vmx file you need to right-click on the VM bundle (I'm using VMWare here) and Show Package Contents. You will find the .vmx file in there that you need to modify with a text editor.

Add the following 3 lines to the end... IMPORTANT, no quotes on the last 2 items.... AND come up with your own valid serial number/hw.model match.

SMBIOS.use12CharSerialNumber = “TRUE”  
serialNumber = FVFZX1A1JYW0  
hw.model = Macmini8,1

To find a serial number and matching hardware model, go find another Mac, click on the Apple on the top left then About This Mac and then System Report. There you will see the Model Identifier of the Mac as well as the Serial Number (system) of the Mac. You probably shouldn't reuse a serial number (not sure what will happen though) but instead change a few of the characters in the serial number to make it different from any of the ones that you have. 

The serial number schema is:
```output
Char 1-3 (Factory code)  
Char 4 (Year and whether first half or second half)  
Char 5 (Manufacturing week)  
Char 6-8 (ID number of device - this is the part you can change with least impact)  
Char 9-12 (Model - this is the part that's most tied to the hw.model value above)

```

## References

* https://techcommunity.microsoft.com/t5/microsoft-intune/could-not-download-the-identity-profile-from-the-encrypted/m-p/2162603
* 