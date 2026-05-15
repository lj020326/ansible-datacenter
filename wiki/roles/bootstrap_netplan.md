---
title: "Bootstrap Netplan Role Documentation"
role: bootstrap_netplan
category: Networking
type: Ansible Role
tags: netplan, networking, configuration, automation
---

## Summary

The `bootstrap_netplan` role is designed to automate the setup and management of network configurations using Netplan on Linux systems. It handles package installation, existing configuration removal, custom or default Netplan configuration generation, and applies the configuration. This ensures consistent network settings across multiple hosts.

## Variables

| Variable Name                         | Default Value                                                                 | Description                                                                                                                                                                                                 |
|---------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_netplan__config_file`      | `/etc/netplan/01-ens160.yaml`                                               | The path to the Netplan configuration file.                                                                                                                                                                   |
| `bootstrap_netplan__enabled`          | `true`                                                                        | Whether the role should be enabled and executed.                                                                                                                                                              |
| `bootstrap_netplan__remove_existing`  | `true`                                                                        | If set to true, existing Netplan configurations will be removed before applying new ones.                                                                                                                     |
| `bootstrap_netplan__dhcp4`            | `true`                                                                        | Enable or disable DHCP for IPv4.                                                                                                                                                                            |
| `bootstrap_netplan__dhcp6`            | `true`                                                                        | Enable or disable DHCP for IPv6.                                                                                                                                                                            |
| `bootstrap_netplan__renderer`         | `networkd`                                                                    | The renderer to use for Netplan (e.g., networkd, NetworkManager).                                                                                                                                             |
| `bootstrap_netplan__ethernet_interface_name` | `"ens160"`                                                               | The name of the Ethernet interface.                                                                                                                                                                           |
| `bootstrap_netplan__ethernet_primary_interface` | `"{{ ansible_facts['default_ipv4']['interface'] }}"`                | The primary Ethernet interface determined from Ansible facts.                                                                                                                                             |
| `bootstrap_netplan__ethernet_primary_mac` | `"{{ ansible_facts['default_ipv4']['macaddress'] }}"`                    | The MAC address of the primary Ethernet interface determined from Ansible facts.                                                                                                                            |
| `bootstrap_netplan__netplan_interfaces` | `[]`                                                                        | A list of interfaces to be configured (internal variable, not user-configurable).                                                                                                                             |
| `bootstrap_netplan__configuration`    | `{}`                                                                          | Custom Netplan configuration dictionary. If provided, it will override the default template-based configuration.                                                                                            |
| `bootstrap_netplan__static_addresses` | `[]`                                                                        | A list of static IP addresses to be configured for the interface.                                                                                                                                             |
| `bootstrap_netplan__routes`           | `[]`                                                                        | A list of routes to be added in the Netplan configuration.                                                                                                                                                  |
| `bootstrap_netplan__nameservers`      | `[]`                                                                        | A list of nameservers to be configured.                                                                                                                                                                       |
| `bootstrap_netplan__packages`         | `[nplan, netplan.io]`                                                         | List of packages required for Netplan.                                                                                                                                                                        |
| `bootstrap_netplan__pri_domain`       | `example.org`                                                                 | The primary domain name to be used in the configuration.                                                                                                                                                    |
| `bootstrap_netplan__check_install`    | `true`                                                                        | Whether to check and install required packages before applying configurations.                                                                                                                                |
| `bootstrap_netplan__apply`            | `true`                                                                        | Whether to apply the Netplan configuration after generation.                                                                                                                                                |

## Usage

To use this role, include it in your playbook and optionally override any of the default variables as needed:

```yaml
- hosts: all
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

- `nplan`
- `netplan.io`

These packages are installed by the role if not already present.

## Best Practices

1. **Backup Configurations**: Always ensure you have backups of existing Netplan configurations before running this role.
2. **Test Changes**: Test changes in a staging environment before applying them to production systems.
3. **Custom Configuration**: Use `bootstrap_netplan__configuration` for complex or custom configurations that cannot be easily managed with the default variables.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding Molecule scenarios to ensure the role behaves as expected in different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_netplan/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_netplan/tasks/main.yml)
- [tasks/netplan.yml](../../roles/bootstrap_netplan/tasks/netplan.yml)
- [tasks/remove-existing.yml](../../roles/bootstrap_netplan/tasks/remove-existing.yml)
- [handlers/main.yml](../../roles/bootstrap_netplan/handlers/main.yml)