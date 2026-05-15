```markdown
---
title: bootstrap_linux_networking Role Documentation
original_path: roles/bootstrap_linux_networking/README.md
category: Ansible Roles
tags: networking, ansible, linux
---

# bootstrap_linux_networking Role

**WARNING:** This role can be dangerous to use. If you lose network connectivity to your target host by incorrectly configuring your networking, you may be unable to recover without physical access to the machine.

This role enables users to configure various network components on target machines. The role can be used to configure:

- Ethernet interfaces
- Bridge interfaces
- Bonded interfaces
- VLAN tagged interfaces
- Network routes

## Requirements

- Ansible 1.4 or higher
- Platform requirements are listed in the metadata file.

## Role Variables

The variables that can be passed to this role and a brief description about them are as follows:

| Variable                           | Required | Default | Comments                                                                 |
|------------------------------------|----------|---------|--------------------------------------------------------------------------|
| `bootstrap_linux_network_interfaces` | No       | `[]`    | The list of network interfaces (ethernet, bridge, bonded, vlan) to be added to the system. |

**Note:** The values for the list are listed in the examples below.

## Examples

### IPv4 Configuration with CIDR Notation
```yaml
cidr: 192.168.10.18/24
# OPTIONAL: specify a gateway for that network, or auto for network+1
gateway: auto
```

### Classic IPv4 Configuration
```yaml
address: 192.168.10.18
netmask: 255.255.255.0
network: 192.168.10.0
broadcast: 192.168.10.255
gateway: 192.168.10.1
```

### Custom MAC Address
```yaml
hwaddr: aa:bb:cc:dd:ee:ff
```

### Interface Options
```yaml
options:
    - "up /execute/my/command"
    - "down /execute/my/other/command"

ipv6_options:
    - "up /execute/my/command"
    - "down /execute/my/other/command"
```

#### Example 1: Configure Static and DHCP IP Addresses with Routes
```yaml
- hosts: myhost
  roles:
    - role: network
      bootstrap_linux_network_interfaces:
        - device: eth1
          bootproto: static
          cidr: 192.168.10.18/24
          gateway: auto
          route:
            - network: 192.168.200.0
              netmask: 255.255.255.0
              gateway: 192.168.10.1
            - network: 192.168.100.0
              netmask: 255.255.255.0
              gateway: 192.168.10.1
        - device: eth2
          bootproto: dhcp
```

#### Example 2: Configure a Bridge Interface with Multiple NICs
```yaml
- hosts: myhost
  roles:
    - role: network
      bootstrap_linux_network_interfaces:
        - device: br1
          type: bridge
          cidr: 192.168.10.10/24

          # Optional values
          bridge_ageing: 300
          bridge_bridgeprio: 32768
          bridge_fd: 15
          bridge_gcint: 4
          bridge_hello: 2
          bridge_maxage: 20
          bridge_maxwait: 0
          bridge_pathcost: "eth1 100"
          bridge_portprio: "eth1 128"
          bridge_stp: "on"
          bridge_waitport: "5 eth1 eth2"

        - device: eth0
          bridge: cloudbr0
          bootproto: none
          onboot: yes
          nm_controlled: True
          defroute: yes
          mtu: 1550

        - device: eth1
          bridge: cloudbr0
          bootproto: none
          onboot: yes
          nm_controlled: True
          defroute: yes
          mtu: 1550
```

#### Example 3: Configure a Bond Interface with Active-Backup Mode
```yaml
- hosts: myhost
  roles:
    - role: network
      bootstrap_linux_network_interfaces:
        - device: bond0
          bondmaster: bond0
          address: 192.168.10.128
          netmask: 255.255.255.0
          bond_mode: active-backup

          # Optional values
          bond_miimon: 100
          bond_lacp_rate: slow
          bond_xmit_hash_policy: layer3+4

        - device: eth0
          bondmaster: bond0
        - device: eth1
          bondmaster: bond0
```

#### Example 4: Configure a Bond Interface with 802.3ad Mode and DHCP
```yaml
- hosts: myhost
  roles:
    - role: network
      bootstrap_linux_network_interfaces:
        - device: bond0
          bootproto: dhcp
          bond_mode: 802.3ad
          bond_miimon: 100
          bond_slaves: [eth1, eth2]
          bond_ad_select: 2
```

#### Example 5: Configure a VLAN Interface
```yaml
- hosts: myhost
  roles:
    - role: network
      bootstrap_linux_network_interfaces:
        - device: eth1
          bootproto: static
          cidr: 192.168.10.18/24
          gateway: auto

        - device: eth1.2
          type: vlan
          vlan: 2
          bootproto: static
          cidr: 192.168.20.18/24
```

#### Example 6: Define Network Configurations for Multiple Hosts
**Inventory File (`/etc/ansible/hosts`):**
```ini
[dc1]
host1
host2
```

**Host Variables (`host_vars/host1`):**
```yaml
bootstrap_linux_network_interfaces:
  - device: eth1
    bootproto: static
    address: 192.168.10.18
    netmask: 255.255.255.0
    gateway: 192.168.10.1
    route:
      - network: 192.168.200.0
        netmask: 255.255.255.0
        gateway: 192.168.10.1

  - device: bond0
    bootproto: dhcp
    bond_mode: 802.3ad
    bond_miimon: 100

  - device: eth0
    bondmaster: bond0

  - device: eth1
    bondmaster: bond0
```

**Host Variables (`host_vars/host2`):**
```yaml
bootstrap_linux_network_interfaces:
  - device: eth0
    bootproto: static
    address: 192.168.10.18
    netmask: 255.255.255.0
    gateway: 192.168.10.1
```

#### Example 7: DNS Configuration with `resolvconf`
```yaml
dns_nameserver:
  - "8.8.8.8"
  - "8.8.4.4"

dns-search: "search.mydomain.tdl"
dns-domain: "mydomain.tdl"
```

#### Example 8: IPv6 Static IP Configuration
```yaml
ipv6_address: "aaaa:bbbb:cccc:dddd:dead:beef::1/64"
ipv6_gateway: "aaaa:bbbb:cccc:dddd::1"
```

### Playbook to Apply Role to All Hosts
```yaml
- hosts: all
  roles:
    - role: network
```

## Dependencies

- `python-netaddr`

## Firewalld Zone Configuration

This role can optionally add network interfaces to firewalld zones. The core firewalld module (http://docs.ansible.com/ansible/latest/firewalld_module.html) can perform the same function, so if you make use of both modules then your playbooks may not be idempotent.

**Example:**
```yaml
- device: eth0
  bootproto: static
  address: 192.168.10.18
  netmask: 255.255.255.0
  gateway: 192.168.10.1
  firewalld_zone: public
```

**Note:** Ansible needs network connectivity throughout the playbook process, you may need to have a control interface that you do *not* modify using this method while changing IP Addresses so that Ansible has a stable connection to configure the target systems. All network changes are done within a single generated script and network connectivity is only lost for few seconds.

## License

BSD

## Author Information

This project was originally created by [Benno Joy](https://github.com/bennojoy/network_interface).

Debian upgrades by:

- Martin Verges (croit, GmbH)
- Eric Anderson (Avi Networks, Inc.)

RedHat upgrades by:

- Eric Anderson (Avi Networks, Inc.)
- Luke Short (Red Hat, Inc.)
- Wei Tie (Cisco Systems, Inc.)

The full list of contributors can be found [here](https://github.com/MartinVerges/ansible.network_interface/graphs/contributors).

## Backlinks

- [Ansible Roles Documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)
```

This improved documentation is structured clearly, uses proper Markdown formatting, and includes a "Backlinks" section for reference.