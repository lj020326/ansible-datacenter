---
title: "Bootstrap Netplan Role"
role: roles/bootstrap_netplan
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_netplan]
---

# Bootstrap Netplan Role

The `bootstrap_netplan` role is designed to configure and manage network settings on Ubuntu-based systems using Netplan. It provides a flexible way to set up network interfaces, including DHCP, static IP addresses, routes, and DNS settings. This role is particularly useful for setting up network configurations during system provisioning or as part of a larger infrastructure automation process.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_netplan__config_dir` | `/etc/netplan` | Directory where Netplan configuration files are stored. |
| `bootstrap_netplan__config_file` | `{{ bootstrap_netplan__config_dir }}/01-ens160.yaml` | Path to the main Netplan configuration file. |
| `bootstrap_netplan__enabled` | `true` | Whether to enable the Netplan configuration. |
| `bootstrap_netplan__remove_existing` | `true` | Whether to remove existing Netplan configurations. |
| `bootstrap_netplan__dhcp4` | `true` | Whether to enable DHCP for IPv4. |
| `bootstrap_netplan__dhcp6` | `true` | Whether to enable DHCP for IPv6. |
| `bootstrap_netplan__renderer` | `networkd` | Netplan renderer to use (networkd or systemd-resolved). |
| `bootstrap_netplan__ethernet_interface_name` | `ens160` | Name of the primary Ethernet interface. |
| `bootstrap_netplan__ethernet_primary_interface` | `{{ ansible_facts['default_ipv4']['interface'] }}` | Primary network interface based on Ansible facts. |
| `bootstrap_netplan__ethernet_primary_mac` | `{{ ansible_facts['default_ipv4']['macaddress'] }}` | MAC address of the primary network interface. |
| `bootstrap_netplan__configuration` | `{}` | Custom Netplan configuration. |
| `bootstrap_netplan__static_addresses` | `[]` | List of static IP addresses to configure. |
| `bootstrap_netplan__routes` | `[]` | List of static routes to configure. |
| `bootstrap_netplan__nameservers` | `[]` | List of DNS nameservers to configure. |
| `bootstrap_netplan__packages` | `['nplan', 'netplan.io']` | List of Netplan-related packages to install. |
| `bootstrap_netplan__pri_domain` | `example.org` | Primary domain name for the system. |
| `bootstrap_netplan__check_install` | `true` | Whether to check for and install Netplan packages. |
| `bootstrap_netplan__apply` | `true` | Whether to apply the Netplan configuration after generating it. |

## Usage

To use the `bootstrap_netplan` role, include it in your playbook and set the desired variables. Here is an example playbook with default values:

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_netplan
```

For custom configurations, you can override the default variables:

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_netplan
      vars:
        bootstrap_netplan__dhcp4: false
        bootstrap_netplan__static_addresses:
          - address: 192.168.1.100/24
            gateway: 192.168.1.1
        bootstrap_netplan__nameservers:
          - 8.8.8.8
          - 8.8.4.4
```

## Dependencies

This role requires the `community.general` collection for the `archive` module. Ensure it is installed in your Ansible environment:

```bash
ansible-galaxy collection install community.general:>=2.0.0
```

## Best Practices

- Always test the role in a development environment before applying it to production systems.
- Use the `bootstrap_netplan__configuration` variable to provide custom Netplan configurations when needed. For example:
  ```yaml
  bootstrap_netplan__configuration:
    network:
      version: 2
      ethernets:
        ens160:
          dhcp4: no
          addresses:
            - 192.168.1.100/24
          gateway4: 192.168.1.1
          nameservers:
            addresses:
              - 8.8.8.8
              - 8.8.4.4
  ```
- Ensure that the `bootstrap_netplan__packages` variable includes all necessary Netplan-related packages for your distribution.
- Regularly review and update the role to accommodate changes in Netplan or your network infrastructure.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_netplan/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_netplan/tasks/main.yml)
- [tasks/netplan.yml](../../roles/bootstrap_netplan/tasks/netplan.yml)
- [tasks/remove-existing.yml](../../roles/bootstrap_netplan/tasks/remove-existing.yml)
- [handlers/main.yml](../../roles/bootstrap_netplan/handlers/main.yml)