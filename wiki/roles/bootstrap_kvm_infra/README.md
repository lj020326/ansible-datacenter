```markdown
---
title: Ansible Role for Virtual Infrastructure
original_path: roles/bootstrap_kvm_infra/README.md
category: Ansible Roles
tags: [KVM, Virtualization, Ansible]
---

# Ansible Role: Virtual Infrastructure

This role is designed to define and manage networks and guests on a KVM host.
Ansible's `--limit` option allows you to manage them individually or as a group.

It is primarily intended for development work where the KVM host is your local machine,
you have sudo privileges, and communicate with libvirtd at `qemu:///system`. In theory,
it supports remote KVM hosts as well.

The role supports setting guest states to `running`, `shutdown`, `destroyed`, or `undefined`
(to delete and clean up). You can specify memory, CPU, disks, and network cards for your guests
either via hostgroups or individually. It supports a variety of disk types including `scsi`,
`sata`, `virtio`, and even `nvme`.

You can create private NAT libvirt networks on the KVM host and place VMs on any number of them.
Guests can use these libvirt networks or existing bridge devices (e.g., br0) and Open vSwitch (OVS)
bridges on the KVM host. You can specify the MAC address for each interface if required.

This role supports various distributions using their qcow2 [cloud images](#guest-cloud-images).
I have tested CentOS, Fedora, Debian, Ubuntu, and openSUSE.

The qcow2 cloud base images to use for guests are specified as variables in the inventory
and should exist under the libvirt images directory (default is `/var/lib/libvirt/images/`).
This role does not automatically download these images.

Guest qcow2 boot images are created from these base images, and cloud-init is used to configure
guests on boot. Cloud-init ISOs are created automatically and attached to the guest.
The timezone will be set to match the KVM host by default.

By default, your shell username will also be used for the guest, along with your public SSH keys
on the KVM host (you can override this). Host entries are added to `/etc/hosts` on the KVM host,
so you can SSH straight in (but it doesn't modify your SSH config yet). You can set a root password
if needed.

With all that, you could define and manage OpenStack/Swift/Ceph clusters of different sizes with
multiple networks, disks, and even distributions!

## Requirements

All that's really needed is a Linux host capable of running KVM, some guest images, and a basic inventory.
Ansible will handle the rest on supported distributions.

**NOTE:** The role will install KVM, libvirtd, and other required packages on supported distributions
and ensure that libvirtd is running.

- A working x86_64 KVM host where the user running Ansible can communicate with libvirtd via sudo.
- Hardware support for KVM in the CPU to create accelerated guests and pass through the CPU (supports nested virtualization).
- Ansible and Jinja >= 2.8, as this role uses features like `equalto` comparisons.

I have tested this on CentOS 8, Fedora 3x, Debian 10, Ubuntu Bionic/Eoan, and openSUSE 15 hosts,
but other Linux machines likely work.

- At least one SSH key pair on your KVM host (the role will generate one if missing).
- Several user-space tools are also required on the KVM host (the role will install these on supported hosts):
  - `qemu-img`
  - `osinfo-query`
  - `virsh`
  - `virt-customize`
  - `virt-sysprep`

Download the guest images you want to use ([this is what I downloaded](#guest-cloud-images)) and
place them in the libvirt images path (usually `/var/lib/libvirt/images/`). The role will check that
the specified images exist and error if they are not found.

### KVM Host Configuration

Here are some instructions for configuring your KVM host, which may be useful.

#### Fedora

```bash
# Create SSH key if you don't have one
ssh-keygen

# libvirtd
sudo dnf install -y @virtualization
sudo systemctl enable --now libvirtd

# Ansible
sudo dnf install -y ansible

# Other dependencies (installed by playbook)
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

#### CentOS 7

CentOS 7 won't work until the `libselinux-python3` package is available, which is expected in version 7.8...

- [Bugzilla #1719978](https://bugzilla.redhat.com/show_bug.cgi?id=1719978)
- [Bugzilla #1756015](https://bugzilla.redhat.com/show_bug.cgi?id=1756015)

But here are the (hopefully) remaining steps for when it is available.

```bash
# Create SSH key if you don't have one
ssh-keygen

# libvirtd
sudo yum groupinstall -y "Virtualization Host"
sudo systemctl enable --now libvirtd

# Ansible and other dependencies
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

#### CentOS 8

```bash
# Create SSH key if you don't have one
ssh-keygen

# libvirtd
sudo dnf groupinstall -y "Virtualization Host"
sudo systemctl enable --now libvirtd

# Ansible
sudo dnf install -y epel-release
sudo dnf install -y ansible

# Other dependencies (installed by playbook)
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

#### Debian

```bash
# Create SSH key if you don't have one
ssh-keygen

# libvirtd
sudo apt-get update
sudo apt-get install -y qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager
sudo systemctl enable --now libvirtd

# Ansible and other dependencies
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install -y ansible

sudo apt-get install -y \
  git \
  genisoimage \
  libguestfs-tools \
  libosinfo-bin \
  python3-libvirt \
  python3-lxml \
  qemu-img \
  virt-manager \
  virtinst
```

#### Ubuntu

```bash
# Create SSH key if you don't have one
ssh-keygen

# libvirtd
sudo apt-get update
sudo apt-get install -y qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager
sudo systemctl enable --now libvirtd

# Ansible and other dependencies
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install -y ansible

sudo apt-get install -y \
  git \
  genisoimage \
  libguestfs-tools \
  libosinfo-bin \
  python3-libvirt \
  python3-lxml \
  qemu-img \
  virt-manager \
  virtinst
```

#### openSUSE

```bash
# Create SSH key if you don't have one
ssh-keygen

# libvirtd
sudo zypper install -y patterns-openSUSE-kvm_server
sudo systemctl enable --now libvirtd

# Ansible and other dependencies
sudo zypper addrepo https://download.opensuse.org/repositories/systemsmanagement:/ansible/openSUSE_Leap_15.3/ ansible
sudo zypper refresh
sudo zypper install -y ansible

sudo zypper install -y \
  git \
  genisoimage \
  libguestfs-tools \
  libosinfo \
  python3-libvirt-python \
  python3-lxml \
  qemu-img \
  virt-install
```

### Guest Cloud Images

Download the guest images you want to use and place them in the libvirt images path (usually `/var/lib/libvirt/images/`).

## Role Variables

Refer to the [variables documentation](#role-variables) for a detailed list of available variables.

## Dependencies

This role has no external dependencies beyond what is listed under [requirements](#requirements).

## Example Inventory

```ini
[kvm_hosts]
localhost ansible_connection=local

[kvm_guests]
guest1
guest2
```

## Example Playbook

### Grab the Cloud Image

Download and place the cloud image in `/var/lib/libvirt/images/`.

### Run the Playbook

```bash
ansible-playbook -i inventory playbook.yml
```

### Cleanup

To clean up, you can set the guest state to `destroyed` or `undefined` in your inventory.

### Post Setup Configuration

After setup, ensure that all configurations are as expected and perform any additional configuration needed for your environment.

## License

This role is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author Information

- **Author:** Chris Smart
- **GitHub:** [csmart](https://github.com/csmart)
- **Email:** csmart@users.noreply.github.com

## Backlinks

- [Ansible Roles Repository](https://github.com/csmart/ansible-role-virt-infra)
- [Playbook Repository](https://github.com/csmart/virt-infra-ansible)
```

This improved Markdown document is structured clearly, uses proper headings and formatting, and includes a YAML frontmatter with relevant metadata. It also adds a "Backlinks" section for easy navigation to related repositories.