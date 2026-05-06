---
title: Bootstrap Netplan Role Documentation
role: bootstrap_netplan
category: Network Configuration
type: Ansible Role
tags: netplan, networkd, configuration, automation

## Summary

The `bootstrap_netplan` role is designed to automate the setup and management of network configurations using Netplan on Linux systems. It allows for the installation of necessary packages, removal of existing configurations, and application of new configurations based on user-defined settings.

## Variables

| Variable Name                           | Default Value                                                                 | Description                                                                                                                                                                                                 |
|-----------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_netplan__config_file`        | `/etc/netplan/ansible-config.yaml`                                          | The path to the Netplan configuration file that will be generated and applied.                                                                                                                              |
| `bootstrap_netplan__enabled`            | `true`                                                                        | A boolean flag to enable or disable the role execution.                                                                                                                                                     |
| `bootstrap_netplan__renderer`           | `networkd`                                                                    | Specifies the renderer for Netplan (e.g., `networkd`, `NetworkManager`).                                                                                                                                  |
| `bootstrap_netplan__ethernet_interface_name` | `"enp1s0"`                                                                   | The name of the Ethernet interface to configure.                                                                                                                                                              |
| `bootstrap_netplan__ethernet_primary_interface` | `{{ ansible_facts['default_ipv4']['interface'] }}`                     | The primary Ethernet interface determined from Ansible facts.                                                                                                                                                |
| `bootstrap_netplan__ethernet_primary_mac` | `{{ ansible_facts['default_ipv4']['macaddress'] }}`                       | The MAC address of the primary Ethernet interface determined from Ansible facts.                                                                                                                              |
| `bootstrap_netplan__configuration`      | `{}`                                                                          | A dictionary containing custom Netplan configuration settings.                                                                                                                                              |
| `bootstrap_netplan__static_addresses`   | `[]`                                                                          | A list of static IP addresses to assign to the network interfaces.                                                                                                                                        |
| `bootstrap_netplan__routes`             | `[]`                                                                          | A list of routes to configure for the network interfaces.                                                                                                                                                   |
| `bootstrap_netplan__dhcp4`              | `true`                                                                        | Enable or disable DHCPv4 on the network interfaces.                                                                                                                                                         |
| `bootstrap_netplan__dhcp6`              | `true`                                                                        | Enable or disable DHCPv6 on the network interfaces.                                                                                                                                                         |
| `bootstrap_netplan__nameservers`        | `[]`                                                                          | A list of DNS nameservers to configure for the network interfaces.                                                                                                                                        |
| `bootstrap_netplan__remove_existing`    | `true`                                                                        | A boolean flag to determine whether existing Netplan configurations should be removed before applying new ones.                                                                                                 |
| `bootstrap_netplan__packages`           | `[nplan, netplan.io]`                                                         | A list of packages required for Netplan to function properly.                                                                                                                                               |
| `bootstrap_netplan__pri_domain`         | `example.org`                                                                 | The primary domain name to be used in the network configuration.                                                                                                                                            |
| `bootstrap_netplan__check_install`      | `true`                                                                        | A boolean flag to determine whether the required packages should be installed before applying configurations.                                                                                                 |
| `bootstrap_netplan__apply`              | `true`                                                                        | A boolean flag to determine whether the Netplan configuration should be applied after generation.                                                                                                             |

## Usage

To use the `bootstrap_netplan` role, include it in your playbook and define any necessary variables as needed. Here is an example of how you might configure a static IP address:

```yaml
- hosts: all
  roles:
    - role: bootstrap_netplan
      vars:
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

These packages are installed by the role if `bootstrap_netplan__check_install` is set to `true`.

## Tags

The following tags can be used with this role:

- `netplan`: Applies to all tasks related to Netplan configuration.

To run only the tasks tagged with `netplan`, you can use the following command:

```bash
ansible-playbook -i inventory playbook.yml --tags netplan
```

## Best Practices

1. **Backup Existing Configurations**: Always ensure that existing network configurations are backed up before running this role, especially if `bootstrap_netplan__remove_existing` is set to `true`.
2. **Test Configurations**: Test your Netplan configurations in a safe environment before deploying them to production systems.
3. **Use Custom Variables**: Customize the variables as needed to fit your specific network requirements.

## Molecule Tests

This role does not currently include any Molecule tests. Consider adding Molecule tests to ensure the role functions correctly across different environments and distributions.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_netplan/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_netplan/tasks/main.yml)
- [tasks/netplan.yml](../../roles/bootstrap_netplan/tasks/netplan.yml)
- [tasks/remove-existing.yml](../../roles/bootstrap_netplan/tasks/remove-existing.yml)
- [handlers/main.yml](../../roles/bootstrap_netplan/handlers/main.yml)