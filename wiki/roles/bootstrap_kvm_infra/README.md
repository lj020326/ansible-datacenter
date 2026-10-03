---
harvested_date: '2026-08-07T18:07:09.277369+00:00'
original_path: roles/bootstrap_kvm_infra/README.md
source_type: legacy_markdown
title: Ansible Role - Virtual Infrastructure
category: Ansible
tags: [KVM, Virtualization, Infrastructure, Ansible]
---

# Ansible Role - Virtual Infrastructure

This role is designed to define and manage networks and guests on a KVM host. Ansible's `--limit` option allows you to manage them individually or as a group.

It is primarily designed for development work where the KVM host is your local machine, you have sudo privileges, and you communicate with libvirtd at `qemu:///system` (though it theoretically supports a remote KVM host).

You can set guest states to `running`, `shutdown`, `destroyed`, or `undefined` (to delete and clean up). You can configure memory, CPU, disks, and network cards for your guests, either via host groups or individually. A mixture of multiple disks is supported, including `scsi`, `sata`, `virtio`, and even `nvme`.

You can create private NAT libvirt networks on the KVM host and place VMs on any number of them. Guests can use those libvirt networks or existing bridge devices (e.g., `br0`) and Open vSwitch (OVS) bridges on the KVM host (this won't create bridges on the host, but it will check that the bridge interface exists). You can specify the MAC for each interface if required.

This role supports various distributions and uses their qcow2 [cloud images](#guest-cloud-images) for convenience (though you can use your own images). I've tested CentOS, Fedora, Debian, Ubuntu, and openSUSE.

The qcow2 cloud base images to use for guests are specified as variables in the inventory and should exist under the libvirt images directory (default is `/var/lib/libvirt/images/`). This role will not automatically download the images for you.

Guest qcow2 boot images are created from those base images, and cloud-init is used to configure guests on boot up. The cloud-init ISOs are created automatically and attached to the guest. The timezone will be set to match the KVM host by default.

By default, your shell username will also be used for the guest, along with your public SSH keys on the KVM host (you can override this). Host entries are added to `/etc/hosts` on the KVM host so you can SSH straight in (though it doesn't modify your SSH config yet). You can set a root password if you really want to.

With all that, you could define and manage OpenStack/Swift/Ceph clusters of different sizes with multiple networks, disks, and even different distributions!

## Table of Contents
- [Requirements](#requirements)
- [KVM Host Configuration](#kvm-host-configuration)
- [Role Variables](#role-variables)
- [Dependencies](#dependencies)
- [Example Inventory](#example-inventory)
- [Example Playbook](#example-playbook)
- [Guest Cloud Images](#guest-cloud-images)
- [License](#license)
- [Author Information](#author-information)

## Requirements

All that's really needed is a Linux host capable of running KVM, some guest images, and a basic inventory. Ansible will do the rest (on supported distributions).

**NOTE:** Ansible will install KVM, libvirtd, and other required packages on supported distributions and ensure that libvirtd is running.

A working x86_64 KVM host where the user running Ansible can communicate with libvirtd via sudo.

It expects hardware support for KVM in the CPU so that we can create accelerated guests and pass the CPU through (supports nested virtualization).

You may need Ansible and Jinja >= 2.8 because this does things like 'equalto' comparisons.

I have tested this on CentOS 8, Fedora 3x, Debian 10, Ubuntu Bionic/Eoan, and openSUSE 15 hosts, but other Linux machines probably work.

At least one SSH key pair on your KVM host (the Ansible will generate one if missing).

Several user space tools are also required on the KVM host (the Ansible will install these on supported hosts):

- qemu-img
- osinfo-query
- virsh
- virt-customize
- virt-sysprep

Download the guest images you want to use ([this is what I downloaded](#guest-cloud-images)) and put them in the libvirt images path (usually `/var/lib/libvirt/images/`). This will check that the images you specified exist and error if they are not found.

## KVM Host Configuration

Here are some instructions for configuring your KVM host, in case they are useful.

### Fedora

```bash
# Create SSH key if you don't have one
ssh-keygen

# libvirtd
sudo dnf install -y @virtualization
sudo systemctl enable --now libvirtd

# Ansible
sudo dnf install -y ansible

# Other deps (installed by playbook)
sudo dnf install -y \
git \
genisoimage \
libguestfs-tools-c \
libosinfo \
python3-libvirt \
python3-lxml \
qemu-img \
virt-install
```

### CentOS 7

CentOS 7 won't work until we have the `libselinux-python3` package, which is coming in 7.8...

- [Bugzilla 1719978](https://bugzilla.redhat.com/show_bug.cgi?id=1719978)
- [Bugzilla 1756015](https://bugzilla.redhat.com/show_bug.cgi?id=1756015)

But here are (hopefully) the rest of the steps for when it is available.

```bash
# Create SSH key if you don't have one
ssh-keygen

# libvirtd
sudo yum groupinstall -y "Virtualization Host"
sudo systemctl enable --now libvirtd

# Ansible and other deps
sudo yum install -y epel-release
sudo yum install -y python36
pip3 install --user ansible

sudo yum install -y \
git \
genisoimage \
libguestfs-tools-c \
libosinfo \
python36-libvirt \
python36-lxml \
libselinux-python3 \
qemu-img \
virt-install
```

### CentOS 8

```bash
# Create SSH key if you don't have one
ssh-keygen

# libvirtd
sudo dnf groupinstall -y "Virtualization Host"
sudo systemctl enable --now libvirtd

# Ansible
sudo dnf install -y epel-release
sudo dnf install -y ansible
```

## Role Variables

Refer to the [defaults/main.yml](defaults/main.yml) file for all available variables and their default values.

## Dependencies

None.

## Example Inventory

```ini
[kvm_hosts]
localhost ansible_connection=local

[guests]
guest1
guest2
```

## Example Playbook

### Grab the Cloud Image

Download the guest images you want to use and place them in the libvirt images path (usually `/var/lib/libvirt/images/`).

### Run the Playbook

```bash
ansible-playbook -i inventory playbook.yml
```

### Cleanup

To clean up the virtual machines, you can set the state to `undefined` in your playbook.

### Post Setup Configuration

After setting up the virtual machines, you may need to configure additional settings or services on the guests.

## Guest Cloud Images

List of cloud images that can be used:

- CentOS
- Fedora
- Debian
- Ubuntu
- openSUSE

## License

This project is licensed under the MIT License.

## Author Information

Original author: [Your Name](https://github.com/yourusername)

## Backlinks

- [Related Documentation 1](link-to-related-doc-1)
- [Related Documentation 2](link-to-related-doc-2)