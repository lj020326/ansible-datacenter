<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

**Table of Contents** _generated with [DocToc](https://github.com/thlorenz/doctoc)_

- [ansible-netplan](#ansible-netplan)
  - [Requirements](#requirements)
  - [Role Variables](#role-variables)
  - [Dependencies](#dependencies)
  - [Example Playbook](#example-playbook)
    - [Static IP Configuration](#static-ip-configuration)
    - [DHCP Configuration](#dhcp-configuration)
  - [License](#license)
  - [Author Information](#author-information)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# ansible-netplan

An [Ansible](https://www.ansible.com) role to manage [Netplan](https://netplan.io)

## Requirements

You probably want to run the role with `become: true`

## Role Variables

[defaults/main.yml](defaults/main.yml)

## Dependencies

None

## Example Playbook

This role supports both static and DHCP network configurations. Below are examples for each.

### Static IP Configuration

The following example sets a static IP address for a single network interface:

```yaml
---
- hosts: ...your hosts...
  any_errors_fatal: true
  roles:
    - role: bootstrap_netplan
      become: true
      bootstrap_netplan__enabled: true
      bootstrap_netplan__config_file: /etc/netplan/my-awesome-netplan.yaml
      bootstrap_netplan__renderer: networkd
      bootstrap_netplan__static_addresses:
        - 10.0.0.20/16
      bootstrap_netplan__nameservers:
        - 8.8.8.8
        - 8.8.4.4
```

### DHCP Configuration

The following example configures a network interface to use DHCP. Ensure that `bootstrap_netplan__ethernet_interface_name` matches the desired interface name, and `bootstrap_netplan__ethernet_primary_mac` matches the interface's MAC address to avoid configuration errors. The `set-name` property is only applied if the interface name differs from the desired name, requiring a `match` property with the MAC address.

```yaml
---
- hosts: ...your hosts...
  any_errors_fatal: true
  roles:
    - role: bootstrap_netplan
      become: true
      bootstrap_netplan__enabled: true
      bootstrap_netplan__config_file: /etc/netplan/my-awesome-netplan.yaml
      bootstrap_netplan__ethernet_interface_name: enp4s0
      bootstrap_netplan__dhcp6: false
```

**Note**: If you want to rename the interface (e.g., to `ens160`), ensure `bootstrap_netplan__ethernet_interface_name` is set to the desired name, and the `match` property will use the MAC address to identify the interface. For example:

```yaml
bootstrap_netplan__ethernet_interface_name: ens160
bootstrap_netplan__ethernet_primary_mac: "58:47:ca:7b:ab:4f"
```

This will generate a configuration that matches the interface with MAC address `58:47:ca:7b:ab:4f`, renames it to `ens160`, and enables DHCP.

### Custom or Advanced Netplan Configuration

Suitable for specialized cases where there can be multiple network interfaces, bridge/bond setup, etc.

The following example sets a static IP address for a single network interface:

```yaml
---
- hosts: ...your hosts...
  any_errors_fatal: true
  roles:
    - role: bootstrap_netplan
      become: true
      bootstrap_netplan__enabled: true
      bootstrap_netplan__config_file: /etc/netplan/my-awesome-netplan.yaml
      bootstrap_netplan__renderer: networkd
      bootstrap_netplan__configuration:
        network:
          version: 2
          ethernets:
            enp4s0:
              addresses:
                - 10.0.0.20/16
              gateway4: 10.0.0.1
              nameservers:
                addresses:
                  - 8.8.8.8
                  - 8.8.4.4
```
