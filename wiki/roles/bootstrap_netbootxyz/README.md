title: netboot.xyz Documentation
harvested_date: '2026-08-07T18:07:09.345134+00:00'
original_path: roles/bootstrap_netbootxyz/README.md
source_type: legacy_markdown
category: Documentation
tags: [netboot.xyz, iPXE, bootloader, documentation]
---

# netboot.xyz

[![Build Status](https://travis-ci.com/netbootxyz/netboot.xyz.svg?branch=master)](https://travis-ci.com/netbootxyz/netboot.xyz)
[![Discord](https://img.shields.io/discord/425186187368595466)](https://discord.gg/An6PA2a)
[![Release](https://img.shields.io/github/v/release/netbootxyz/netboot.xyz?color=hunter%20green)](https://github.com/netbootxyz/netboot.xyz/releases/latest)

![netboot.xyz menu](https://netboot.xyz/images/netboot.xyz.gif)

## Table of Contents
- [Bootloader Downloads](#bootloader-downloads)
  - [Legacy (PCBIOS) iPXE Bootloaders](#legacy-pcbios-ipxe-bootloaders)
  - [UEFI iPXE Bootloaders](#uefi-ipxe-bootloaders)
- [What is netboot.xyz?](#what-is-netbootxyz)
- [Documentation](#documentation)
- [Self Hosting netboot.xyz](#self-hosting-netbootxyz)
  - [Deploying using Ansible](#deploying-using-ansible)
  - [Deploying with Docker](#deploying-with-docker)
  - [Local Overrides](#local-overrides)
  - [Self Hosted Custom Options](#self-hosted-custom-options)
- [What Operating Systems are currently available on netboot.xyz?](#what-operating-systems-are-currently-available-on-netbootxyz)

## Bootloader Downloads

### Legacy (PCBIOS) iPXE Bootloaders

| Type | Bootloader | Description |
|------|------------|-------------|
| ISO | [netboot.xyz.iso](https://boot.netboot.xyz/ipxe/netboot.xyz.iso) | Used for CD/DVD, Virtual CDs, DRAC/iLO, VMware, Virtual Box |
| USB | [netboot.xyz.usb](https://boot.netboot.xyz/ipxe/netboot.xyz.usb) | Used for creation of USB Keys |
| Kernel | [netboot.xyz.lkrn](https://boot.netboot.xyz/ipxe/netboot.xyz.lkrn) | Used for booting from GRUB/EXTLINUX |
| Floppy | [netboot.xyz.dsk](https://boot.netboot.xyz/ipxe/netboot.xyz.dsk) | Virtual floppy disk for DRAC/iLO, VMware, Virtual Box, etc |
| DHCP | [netboot.xyz.kpxe](https://boot.netboot.xyz/ipxe/netboot.xyz.kpxe) | DHCP boot image file, uses built-in iPXE NIC drivers |
| DHCP-undionly | [netboot.xyz-undionly.kpxe](https://boot.netboot.xyz/ipxe/netboot.xyz-undionly.kpxe) | DHCP boot image file, use if you have NIC issues |

### UEFI iPXE Bootloaders

| Type | Bootloader | Description |
|------|------------|-------------|
| ISO | [netboot.xyz-efi.iso](https://boot.netboot.xyz/ipxe/netboot.xyz-efi.iso) | Used for CD/DVD, Virtual CDs, DRAC/iLO, VMware, Virtual Box |
| USB | [netboot.xyz-efi.usb](https://boot.netboot.xyz/ipxe/netboot.xyz-efi.usb) | Used for creation of USB Keys |
| DHCP | [netboot.xyz.efi](https://boot.netboot.xyz/ipxe/netboot.xyz.efi) | DHCP boot image file, uses built-in iPXE NIC drivers |
| DHCP-snp | [netboot.xyz-snp.efi](https://boot.netboot.xyz/ipxe/netboot.xyz-snp.efi) | EFI w/ Simple Network Protocol, attempts to boot all net devices |
| DHCP-snponly | [netboot.xyz-snponly.efi](https://boot.netboot.xyz/ipxe/netboot.xyz-snponly.efi) | EFI w/ Simple Network Protocol, only boots from device chained from |

SHA256 checksums are generated during each build of iPXE and are located [here](https://boot.netboot.xyz/ipxe/netboot.xyz-sha256-checksums.txt). You can also view the scripts that are embedded into the images [here](https://github.com/netbootxyz/netboot.xyz/tree/master/ipxe/disks).

## What is netboot.xyz?

[netboot.xyz](http://www.netboot.xyz) is a convenient place to boot into any type of operating system or utility disk without the need of having to go spend time retrieving the ISO just to run it. [iPXE](http://ipxe.org/) is used to provide a user-friendly menu from within the BIOS that lets you easily choose the operating system you want along with any specific types of versions or bootable flags.

If you already have iPXE up and running on the network, you can hit netboot.xyz at anytime by typing:

```bash
chain --autofree https://boot.netboot.xyz/ipxe/netboot.xyz.lkrn
```

or when in EFI mode:

```bash
chain --autofree https://boot.netboot.xyz/ipxe/netboot.xyz.efi
```

This will load the appropriate netboot.xyz kernel with all of the proper options enabled.

## Documentation

See [netboot.xyz](https://netboot.xyz) for all documentation. Some links to get started with are:

- [Downloads](https://netboot.xyz/downloads/)
- [Self Hosting](https://netboot.xyz/selfhosting/)
- [Booting Methods](https://netboot.xyz/booting/)
- [FAQ](https://netboot.xyz/faq/)
- [Blog](https://blog.netboot.xyz/)

If you'd like to contribute to the documentation, the netboot.xyz documentation is located at [netboot.xyz-docs](https://github.com/netbootxyz/netboot.xyz-docs).

## Self Hosting netboot.xyz

For those users who want to deploy their own netboot.xyz environment, you can leverage the same scripts that are used to deploy the hosted environment. The source scripts are all Ansible templates and can be generated and customized to your preference.

Please see the [self-hosting docs](https://netboot.xyz/selfhosting/) for more information but in short:

### Deploying using Ansible

To generate, run:

```bash
ansible-playbook -i inventory site.yml
```

The build output will be located in `/var/www/html` by default.

### Deploying with Docker

```bash
docker build -t localbuild -f Dockerfile-build .
docker run --rm -it -v $(pwd):/buildout localbuild
```

The build output will be in the generated folder `buildout`.

### Local Overrides

Ansible will handle source generation as well as iPXE disk generation with your settings. It will generate Legacy (PCBIOS) and UEFI iPXE disks that can be used to load into your netboot.xyz environment. If you want to override the defaults, you can put overrides in `user_overrides.yml`. See `user_overrides.yml` for examples.

Using the overrides file, you can override all of the settings from the `defaults/main.yml` so that you can easily change the boot mirror URLs when the menus are rendered. If you prefer to do this after the fact, you can also edit the `boot.cfg` to make changes, but keep in mind those changes will not be saved when you redeploy the menu.

### Self Hosted Custom Options

In addition to being able to host netboot.xyz locally, you can also create your own custom templates for custom menus within netboot.xyz. Please see [Custom User Menus](etc/netbootxyz/custom/README.md) for more information.

## What Operating Systems are currently available on netboot.xyz?

### Operating Systems

| Name | URL | Installer Kernel | Live OS |
|------|-----|------------------|---------|
| Alpine Linux | [https://alpinelinux.org](https://alpinelinux.org) | Yes | No |
| Anarchy Linux | [https://anarchy-linux.org](https://anarchy-linux.org) | Yes | Yes |
| Arch Linux | [https://archlinux.org](https://archlinux.org) | Yes | Yes |
| CentOS | [https://centos.org](https://centos.org) | Yes | No |
| Debian | [https://debian.org](https://debian.org) | Yes | Yes |
| Fedora | [https://fedora.org](https://fedora.org) | Yes | Yes |
| FreeBSD | [https://freebsd.org](https://freebsd.org) | Yes | Yes |
| Gentoo | [https://gentoo.org](https://gentoo.org) | Yes | Yes |
| Kali Linux | [https://kali.org](https://kali.org) | Yes | Yes |
| Linux Mint | [https://linuxmint.com](https://linuxmint.com) | Yes | Yes |
| Manjaro | [https://manjaro.org](https://manjaro.org) | Yes | Yes |
| OpenSUSE | [https://opensuse.org](https://opensuse.org) | Yes | Yes |
| Pop!_OS | [https://popos.io](https://popos.io) | Yes | Yes |
| Ubuntu | [https://ubuntu.com](https://ubuntu.com) | Yes | Yes |
| Zorin OS | [https://zorinos.com](https://zorinos.com) | Yes | Yes |

This list is not exhaustive and is subject to change. For the most up-to-date list, please visit the [netboot.xyz website](https://netboot.xyz).