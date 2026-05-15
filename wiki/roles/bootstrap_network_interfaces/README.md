```markdown
---
title: ansible-config-interfaces Role Documentation
original_path: roles/bootstrap_network_interfaces/README.md
category: Ansible Roles
tags: [ansible, network, interfaces, configuration]
---

# ansible-config-interfaces

An [Ansible](https://www.ansible.com) role to configure network interfaces.

- Define DHCP, static, and manual settings.
- Create VLANs, bonds, bridges, and interfaces.
- Create Open vSwitch bridges, bonds, and interfaces.

## Table of Contents

- [Requirements](#requirements)
- [Role Variables](#role-variables)
- [Dependencies](#dependencies)
- [Example Playbook](#example-playbook)
- [Examples](#examples)
  - [Example (standard) `/etc/network/interfaces`](#example-standard-etcnetworkinterfaces)
  - [Example (Open vSwitch) `/etc/network/interfaces`](#example-open-vswitch-etcnetworkinterfaces)
- [License](#license)
- [Author Information](#author-information)

## Requirements

See [Example Playbook](#example-playbook) for examples of how to define specific network configurations.

> **NOTE:** If creating Open vSwitch configurations, you will need to use the [ansible-openvswitch](https://github.com/mrlesmithjr/ansible-openvswitch) Ansible role.

## Role Variables

Refer to [defaults/main.yml](defaults/main.yml).

## Dependencies

If the interface is wireless, you will need to define it as such and provide the SSID and key.

## Example Playbook

See [Example Playbook](playbook.yml).

## Examples

### Example (standard) `/etc/network/interfaces`

```bash
# Ansible managed
# Any changes made here will be lost

auto lo
iface lo inet loopback

########## Network Interfaces
auto enp0s3
iface enp0s3 inet dhcp
  pre-up sleep 2

auto enp0s8
iface enp0s8 inet static
  address 192.168.250.10
  netmask 255.255.255.0

# bond0 member
auto enp0s9
iface enp0s9 inet manual
  bond_master bond0

# bond0 member
auto enp0s10
iface enp0s10 inet manual
  bond_master bond0

# br0 member
auto enp0s16
iface enp0s16 inet manual

########## End of Network Interfaces

########## Network Bonds
# Bond Group 0
auto bond0
iface bond0 inet static
  address 192.168.1.10
  netmask 255.255.255.0
  bond_slaves enp0s9 enp0s10
  bond_primary enp0s9
  bond_mode active-backup
  bond_miimon 100

########## End of Network Bonds

########## Network Bridges
# Bridge 0
auto br0
iface br0 inet static
  address 192.168.1.11
  netmask 255.255.255.0
  bridge_stp off
  bridge_fd 0
  bridge_ports enp0s16

########## End of Network Bridges

dns-nameservers 8.8.8.8 8.8.4.4
dns-search test.vagrant.local
```

### Example (Open vSwitch) `/etc/network/interfaces`

```bash
# Ansible managed
# Any changes made here will be lost

auto lo
iface lo inet loopback

########## Network Interfaces
auto enp0s3
iface enp0s3 inet dhcp
  pre-up sleep 2

auto enp0s8
iface enp0s8 inet static
  address 192.168.250.10
  netmask 255.255.255.0

########## End of Network Interfaces

########## OVS Bonds
# OVS Bond
allow-vmbr0 bond0
iface bond0 inet manual
  ovs_bridge vmbr0
  ovs_type OVSBond
  ovs_bonds enp0s9 enp0s10
  ovs_options bond_mode=active-backup lacp=off

########## End of OVS Bonds

########## OVS Bridges
# OVS Bridge
auto vmbr0
allow-ovs vmbr0
iface vmbr0 inet manual
  ovs_type OVSBridge
  ovs_ports bond0 vlan1

########## End of OVS Bridges

########## OVS Interfaces
# VLAN1
allow-vmbr0 vlan1
iface vlan1 inet static
  address 192.168.250.100
  netmask 255.255.255.0
  ovs_bridge vmbr0
  ovs_type OVSIntPort

########## End of OVS Interfaces

dns-nameservers 8.8.8.8 8.8.4.4
dns-search test.vagrant.local
```

## License

MIT

## Author Information

Larry Smith Jr.

- [@mrlesmithjr](https://www.twitter.com/mrlesmithjr)
- [EverythingShouldBeVirtual](http://everythingshouldbevirtual.com)
- [mrlesmithjr@gmail.com](mailto:mrlesmithjr@gmail.com)

## Backlinks

- [Ansible Roles Documentation](/ansible-roles-documentation)
```

This improved Markdown document adheres to clean and professional standards, ensuring it renders well on GitHub. The structure is clear, headings are properly formatted, and the content remains intact with added YAML frontmatter for metadata.