
# Steps to Install Intel Graphic Drivers on Ubuntu 20.04LTS

Hello folks, in this article, We will be discussing how to install Intel graphic drivers on Ubuntu 20.04LTS.

Intel’s graphic drivers come preinstalled in the kernel. But if they are not installed on your system, and you want to install them or check for currently used drivers or graphic cards. Follow this article till the end.

-   [How to check graphic drivers on Ubuntu?](https://www.linuxfordevices.com/tutorials/ubuntu/install-intel-graphic-drivers#How-to-check-graphic-drivers-on-Ubuntu "How to check graphic drivers on Ubuntu?")
-   [How to install Intel graphic drivers on Ubuntu?](https://www.linuxfordevices.com/tutorials/ubuntu/install-intel-graphic-drivers#How-to-install-Intel-graphic-drivers-on-Ubuntu "How to install Intel graphic drivers on Ubuntu?")
-   [Conclusion](https://www.linuxfordevices.com/tutorials/ubuntu/install-intel-graphic-drivers#Conclusion "Conclusion")

Open a terminal window by pressing **Ctrl+Alt+T**. Execute the following command to see the currently used graphic drivers:

![install-graphic-driver-1](https://cdn.linuxfordevices.com/wp-content/uploads/2021/12/Screenshot-from-2021-12-19-11-12-18.png)

or

`sudo` `lspci -nn |` `grep` `-e VGA`

![install-graphic-driver-2](https://cdn.linuxfordevices.com/wp-content/uploads/2021/12/Screenshot-from-2021-12-19-11-20-01.png)

Another way of checking the currently used graphic drivers is using the mesa utility. First, install the mesa utility by executing the following command:

`sudo` `apt` `install` `mesa-utils`

![install-graphic-driver-3](https://cdn.linuxfordevices.com/wp-content/uploads/2021/12/Screenshot-from-2021-12-19-11-21-16.png)

Now, enter the following command to get the driver details. It will also give you other GPU details along with driver details.

![install-graphic-driver-4](https://cdn.linuxfordevices.com/wp-content/uploads/2021/12/Screenshot-from-2021-12-19-11-23-44.png)

## How to install Intel graphic drivers on Ubuntu?

Open a terminal window by pressing **Ctrl+Alt+T**. Now, to install the latest drivers, add the graphics package repository by executing the following commands, it will install gpg-agent and get and will install the public key required to verify the integrity of the package.

`sudo` `apt` `install` `-y gpg-agent wget`

`wget -qO - https:``//repositories``.intel.com``/graphics/intel-graphics``.key |`

  `sudo` `apt-key add -`

`sudo` `apt-add-repository \`

  `'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main'`

Now, Add the graphics software packages by executing the following command:

`sudo` `apt update`

`sudo` `apt` `install` `\`

  `intel-opencl-icd \`

  `intel-level-zero-gpu level-zero \`

  `intel-media-va-driver-non-``free` `libmfx1`

Thats it! Intel graphic drivers are installed successfully.

If you also want to install development packages, execute the following command:

`sudo` `apt` `install` `\`

  `libigc-dev \`

  `intel-igc-cm \`

  `libigdfcl-dev \`

  `libigfxcmrt-dev \`

  `level-zero-dev`

## Conclusion

So, We discussed how to check for currently used drivers and install Intel graphic drivers on Ubuntu 20.04LTS. I hope it works for you. Thank you for reading!

## Reference

* https://www.linuxfordevices.com/tutorials/ubuntu/install-intel-graphic-drivers
* https://packages.ubuntu.com/source/focal/intel-gmmlib
* 

