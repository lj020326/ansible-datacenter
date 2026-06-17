---
title: "bootstrap_netplan Role Documentation"
role: bootstrap_netplan
category: Ansible Roles
type: Configuration Management
tags: netplan, networking, ansible-role
---

## Summary

The `bootstrap_netplan` role is designed to manage and configure network settings on Linux systems using Netplan. It handles the installation of necessary packages, manages configuration files, backs up existing configurations, and applies new configurations as specified by the user. This role ensures that the system's network interfaces are configured according to the provided specifications or defaults.

## Variables

| Variable Name                      | Default Value                                                                 | Description                                                                                                                                                                                                 |
|------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_netplan__config_dir`    | `/etc/netplan`                                                                | The directory where Netplan configuration files are stored.                                                                                                                                                 |
| `bootstrap_netplan__config_file`   | `"{{ bootstrap_netplan__config_dir }}/01-ens160.yaml"`                        | The specific Netplan configuration file to be managed.                                                                                                                                                    |
| `bootstrap_netplan__enabled`       | `true`                                                                        | Whether the role should manage Netplan configurations.                                                                                                                                                    |
| `bootstrap_netplan__remove_existing` | `true`                                                                       | Whether existing Netplan configurations in the specified directory should be backed up and removed before applying new configurations.                                                                         |
| `bootstrap_netplan__dhcp4`         | `true`                                                                        | Enable or disable DHCPv4 for the primary network interface.                                                                                                                                                 |
| `bootstrap_netplan__dhcp6`         | `true`                                                                        | Enable or disable DHCPv6 for the primary network interface.                                                                                                                                                 |
| `bootstrap_netplan__renderer`      | `networkd`                                                                    | The renderer to use for Netplan configurations (`networkd`, `NetworkManager`).                                                                                                                              |
| `bootstrap_netplan__ethernet_interface_name` | `"ens160"`                                                             | The name of the Ethernet interface to configure.                                                                                                                                                            |
| `bootstrap_netplan__ethernet_primary_interface` | `"{{ ansible_facts['default_ipv4']['interface'] }}"`             | The primary network interface determined from Ansible facts.                                                                                                                                                |
| `bootstrap_netplan__ethernet_primary_mac`     | `"{{ ansible_facts['default_ipv4']['macaddress'] }}"`              | The MAC address of the primary network interface determined from Ansible facts.                                                                                                                             |
| `__bootstrap_netplan__netplan_interfaces`    | `"{{ bootstrap_netplan__netplan_interfaces \| d([], true) }}"`     | **Internal variable** - List of interfaces to be configured by Netplan.                                                                                                                                   |
| `bootstrap_netplan__configuration`           | `{}`                                                                      | Custom Netplan configuration dictionary that can be provided by the user. If not specified, a default template will be used.                                                                               |
| `bootstrap_netplan__static_addresses`        | `[]`                                                                      | List of static IP addresses to configure for the network interface.                                                                                                                                         |
| `bootstrap_netplan__routes`                  | `[]`                                                                      | List of routes to add to the network configuration.                                                                                                                                                         |
| `bootstrap_netplan__nameservers`             | `[]`                                                                      | List of DNS nameservers to use in the network configuration.                                                                                                                                              |
| `bootstrap_netplan__packages`                | `- nplan<br>- netplan.io`                                               | List of packages required for Netplan management.                                                                                                                                                           |
| `bootstrap_netplan__pri_domain`              | `example.org`                                                           | The primary domain name for the system.                                                                                                                                                                     |
| `bootstrap_netplan__check_install`           | `true`                                                                    | Whether to check and install required Netplan packages before applying configurations.                                                                                                                        |
| `bootstrap_netplan__apply`                   | `true`                                                                    | Whether to apply the Netplan configuration after generating it.                                                                                                                                             |

## Usage

To use the `bootstrap_netplan` role, include it in your playbook and optionally override any of the default variables as needed. Here is an example playbook that demonstrates how to use this role:

```yaml
---
- name: Configure network using Netplan
  hosts: all
  become: true
  roles:
    - role: bootstrap_netplan
      vars:
        bootstrap_netplan__dhcp4: false
        bootstrap_netplan__static_addresses:
          - address: 192.168.1.100/24
            gateway4: 192.168.1.1
        bootstrap_netplan__nameservers:
          addresses:
            - 8.8.8.8
            - 8.8.4.4
```

## Dependencies

The `bootstrap_netplan` role depends on the following packages:

- `nplan`
- `netplan.io`

These packages are installed automatically by the role if `bootstrap_netplan__check_install` is set to `true`.

## Best Practices

1. **Backup Existing Configurations**: Ensure that existing Netplan configurations are backed up before applying new ones, especially in production environments.
2. **Custom Configuration**: Use the `bootstrap_netplan__configuration` variable to provide a custom Netplan configuration if needed. This allows for more granular control over network settings.
3. **Testing**: Test changes in a staging environment before applying them to production systems to avoid potential network outages.

## Molecule Tests

This role does not include Molecule tests at this time. However, it is recommended to create and run Molecule tests to ensure the role behaves as expected across different operating systems and configurations.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_netplan/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_netplan/tasks/main.yml)
- [tasks/netplan.yml](../../roles/bootstrap_netplan/tasks/netplan.yml)
- [tasks/remove-existing.yml](../../roles/bootstrap_netplan/tasks/remove-existing.yml)
- [handlers/main.yml](../../roles/bootstrap_netplan/handlers/main.yml)