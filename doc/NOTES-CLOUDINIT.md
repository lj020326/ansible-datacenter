

Ubuntu setup details:

[Automated 20.04 Server Installation using PXE and live server image](https://askubuntu.com/questions/1235723/automated-20-04-server-installation-using-pxe-and-live-server-image) 
==================================================================================================================================================================================

How to do an fully automated Ubuntu 20.04 Server install using PXE and
the *live server* image?

### Reason

With the 20.04 release, it seems clear Ubuntu is further pushing the
*live server* installer (*subiquity*) option. The debian-installer (d-i)
image has been renamed legacy. So has the netboot installer I typically
prefer. The 20.04 release also introduces a new automated installation
option for the *live server* installer.


Fully Automated Ubuntu 20.04 server install using PXE
=====================================================

These are steps to do a fully automated Ubuntu 20.04 Server install
using PXE with the *live server* image. I found the process to be
lightly documented and filled with issues. In these steps I am
installing 20.04 on a *UEFI* based server.

There are many variations to these steps possible. They can be
customized and tailored to suit one's needs. The goal is to provide one
example of how to accomplish this and to help other users overcome the
issues encountered.

### links about the installer

-   [https://wiki.ubuntu.com/FocalFossa/ReleaseNotes\#Installer](https://wiki.ubuntu.com/FocalFossa/ReleaseNotes#Installer)
-   [https://wiki.ubuntu.com/FoundationsTeam/AutomatedServerInstalls](https://wiki.ubuntu.com/FoundationsTeam/AutomatedServerInstalls)
-   [https://discourse.ubuntu.com/t/server-installer-plans-for-20-04-lts/13631](https://discourse.ubuntu.com/t/server-installer-plans-for-20-04-lts/13631)
-   [https://discourse.ubuntu.com/t/netbooting-the-live-server-installer/14510](https://discourse.ubuntu.com/t/netbooting-the-live-server-installer/14510)

### config references

-   [https://wiki.ubuntu.com/FoundationsTeam/AutomatedServerInstalls/ConfigReference](https://wiki.ubuntu.com/FoundationsTeam/AutomatedServerInstalls/ConfigReference)
-   [https://curtin.readthedocs.io/en/latest/topics/config.html](https://curtin.readthedocs.io/en/latest/topics/config.html)

### source code

-   [https://github.com/CanonicalLtd/subiquity](https://github.com/CanonicalLtd/subiquity)
-   [https://github.com/canonical/curtin](https://github.com/canonical/curtin)

Build a tftp server
-------------------

All the following steps are run as root. These were tested on an Ubuntu
18.04 server.

Install the tftp server and a web server

    apt-get -y install tftpd-hpa apache2

Configure apache to serve files from the tftp directory

    cat > /etc/apache2/conf-available/tftp.conf <<EOF
    <Directory /var/lib/tftpboot>
            Options +FollowSymLinks +Indexes
            Require all granted
    </Directory>
    Alias /tftp /var/lib/tftpboot
    EOF
    a2enconf tftp
    systemctl restart apache2

Download the live server iso

    wget https://releases.ubuntu.com/20.04/ubuntu-20.04-live-server-amd64.iso -O /var/lib/tftpboot/ubuntu-20.04-live-server-amd64.iso

Extract the kernel and initramfs from the live server iso

    mount /var/lib/tftpboot/ubuntu-20.04-live-server-amd64.iso /mnt/
    cp /mnt/casper/vmlinuz /var/lib/tftpboot/
    cp /mnt/casper/initrd /var/lib/tftpboot/
    umount  /mnt

Download the grub image to load via PXE

    wget http://archive.ubuntu.com/ubuntu/dists/focal/main/uefi/grub2-amd64/current/grubnetx64.efi.signed -O /var/lib/tftpboot/pxelinux.0

Configure grub. This configuration will provide a fully automated boot
option as well as a manual boot option

    mkdir -p /var/lib/tftpboot/grub
    cat > /var/lib/tftpboot/grub/grub.cfg <<'EOF'
    default=autoinstall
    timeout=30
    timeout_style=menu
    menuentry "Focal Live Installer - automated" --id=autoinstall {
        echo "Loading Kernel..."
        # make sure to escape the ';'
        linux /vmlinuz ip=dhcp url=http://${pxe_default_server}/tftp/ubuntu-20.04-live-server-amd64.iso autoinstall ds=nocloud-net\;s=http://${pxe_default_server}/tftp/
        echo "Loading Ram Disk..."
        initrd /initrd
    }
    menuentry "Focal Live Installer" --id=install {
        echo "Loading Kernel..."
        linux /vmlinuz ip=dhcp url=http://${pxe_default_server}/tftp/ubuntu-20.04-live-server-amd64.iso
        echo "Loading Ram Disk..."
        initrd /initrd
    }
    EOF

Configure *cloud-init* with the autoinstall configuration. I first ran
the install manually to get the generated
`/var/log/installer/autoinstall-user-data` file to use as the basis. I
then made modifications based on my needs and errors encountered.

    cat > /var/lib/tftpboot/meta-data <<EOF
    instance-id: focal-autoinstall
    EOF

    cat > /var/lib/tftpboot/user-data <<'EOF'
    #cloud-config
    autoinstall:
      version: 1
      # use interactive-sections to avoid an automatic reboot
      #interactive-sections:
      #  - locale
      apt:
        # even set to no/false, geoip lookup still happens
        #geoip: no
        preserve_sources_list: false
        primary:
        - arches: [amd64, i386]
          uri: http://us.archive.ubuntu.com/ubuntu
        - arches: [default]
          uri: http://ports.ubuntu.com/ubuntu-ports
      # r00tme
      identity: {hostname: focal-autoinstall, password: $6$.c38i4RIqZeF4RtR$hRu2RFep/.6DziHLnRqGOEImb15JT2i.K/F9ojBkK/79zqY30Ll2/xx6QClQfdelLe.ZjpeVYfE8xBBcyLspa/,
        username: ubuntu}
      keyboard: {layout: us, variant: ''}
      locale: en_US.UTF-8
      # interface name will probably be different
      network:
        network:
          version: 2
          ethernets:
            ens192:
              critical: true
              dhcp-identifier: mac
              dhcp4: true
      ssh:
        allow-pw: true
        authorized-keys: []
        install-server: true
      # this creates an efi partition, /boot partition, and root(/) lvm volume
      storage:
        grub:
          reorder_uefi: False
        swap:
          size: 0
        config:
        - {ptable: gpt, path: /dev/sda, preserve: false, name: '', grub_device: false,
          type: disk, id: disk-sda}
        - {device: disk-sda, size: 268435456, wipe: superblock, flag: boot, number: 1,
          preserve: false, grub_device: true, type: partition, id: partition-sda1}
        - {fstype: fat32, volume: partition-sda1, preserve: false, type: format, id: format-2}
        - {device: disk-sda, size: 1073741824, wipe: superblock, flag: linux, number: 2,
          preserve: false, grub_device: false, type: partition, id: partition-sda2}
        - {fstype: ext4, volume: partition-sda2, preserve: false, type: format, id: format-0}
        - {device: disk-sda, size: 20130562048, flag: linux, number: 3, preserve: false,
          grub_device: false, type: partition, id: partition-sda3}
        - name: vg-0
          devices: [partition-sda3]
          preserve: false
          type: lvm_volgroup
          id: lvm-volgroup-vg-0
        - {name: lv-root, volgroup: lvm-volgroup-vg-0, size: 20128464896.0B, preserve: false,
          type: lvm_partition, id: lvm-partition-lv-root}
        - {fstype: ext4, volume: lvm-partition-lv-root, preserve: false, type: format,
          id: format-1}
        - {device: format-1, path: /, type: mount, id: mount-2}
        - {device: format-0, path: /boot, type: mount, id: mount-1}
        - {device: format-2, path: /boot/efi, type: mount, id: mount-3}
    write_files:
      # override the kernel package
      - path: /run/kernel-meta-package
        content: |
          linux-virtual
        owner: root:root
        permissions: "0644"
      # attempt to also use an answers file by providing a file at the default path.  It did not seem to have any effect
      #- path: /subiquity_config/answers.yaml
      #  content: |
      #    InstallProgress:
      #      reboot: no
      #  owner: root:root
      #  permissions: "0644"
    EOF

Configure DHCP
--------------

Set the DHCP Options 66,67 according to the documentation for your DHCP
server.

Boot your server
----------------

At this point, you should be able to boot your UEFI based server and
perform a completely automatic install.

Errors encountered
==================

-   The server being installed requires over 2 GB of RAM. I ended up
    creating a VM with 3 GB for testing
-   The generated `/var/log/installer/autoinstall-user-data` file was
    broken in the following ways
    -   There is no `version` property, which caused a validation
        failure. I added the property
    -   The `network` section required another level of nesting. This
        bug is mentioned in the config reference
    -   The `preserve` property on each item in `storage` `config`
        needed to be set to **false**. Otherwise *curtin* would not
        install on a blank disk
    -   The `keyboard` property `toggle` was set to null, which caused a
        validation failure. I simply removed the property
-   When *curtin* installs on a UEFI device, it reorders the boot order
    so the current boot option is first in the list. The result is that
    network boot becomes the first option the next reboot. So when the
    install is done and the reboot happens... you end up in the PXE
    environment again instead of booting from disk. I found an
    **undocumented** *curtin* option `reorder_uefi`. Luckily,
    *subiquity* happens to pass this configuration to *curtin*
-   The `apt` config option `geoip` doesn't seem to work. There were
    always logs for geoip requests

Other missing features
======================

I didn't dig into these as much. They are based on what my preseed files
would do. Most of them could probably be fixed with clever use of
`early-commands`, `late-commands`, and *cloud-init*. I may have also
missed something

-   A way to set the timezone
-   A way to set the root password
-   A way to configure an apt only proxy. I like to use `apt-cacher-ng`
    for apt, but it does not work as a general proxy. The installer
    assumes any proxy you configure is for everything
-   A way to pause at the end of the install instead of automatically
    rebooting. The workaround is to add a value to
    `interactive-sections`, but that results in 3 pauses
-   Allow direct *curtin* configuration. You have to create yaml for
    *cloud-init* to provide yaml to *subiquity*, which then generates
    yaml for *curtin*. It would provide more configuration flexibility
    to be able to provide the curtin yaml directly
-   Allow direct *cloud-init* configuration. You have to create yaml for
    *cloud-init* to provide yaml to *subiquity*, which then generates
    yaml for *cloud-init* on the installed machine. These files should
    be easy to modify with `late-commands`, but I did not try it
-   Ability to choose the kernel package. I found that the kernel image
    installed is based on what is written to `/run/kernel-meta-package`.
    This is hardcoded to `linux-generic` in the initramfs. I prefer to
    use the `linux-virtual` package for VMs. I was able to use the
    *cloud-init* configuration to overwrite the file


Set the timezone in the user-data file's 'user-data' section, and also
set the root password there; like this:

    #cloud-config
    autoinstall:
      version: 1
      ...
      user-data:
        timezone: Europe/London
        disable_root: false
        chpasswd:
          list: |
            root:HASHEDPASSWORD
      ...

[share](https://askubuntu.com/a/1239021 "short permalink to this answer")

