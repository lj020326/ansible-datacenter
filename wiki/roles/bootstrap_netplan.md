---
title: "Bootstrap Netplan Role Documentation"
role: bootstrap_netplan
category: Networking
type: Ansible Role
tags: netplan, networking, configuration, ansible
---

## Summary

The `bootstrap_netplan` role is designed to manage and configure network settings using Netplan on Linux systems. It handles the installation of necessary packages, removal of existing configurations, generation of a new Netplan configuration file from templates, and application of the configuration. This role ensures that the system's networking is set up according to specified parameters, making it suitable for both static and dynamic IP configurations.

## Variables

| Variable Name                             | Default Value                                                                                       | Description                                                                                                                                                                                                 |
|-------------------------------------------|-----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_netplan__config_file`          | `/etc/netplan/01-ens160.yaml`                                                                       | The path to the Netplan configuration file that will be generated and applied.                                                                                                                              |
| `bootstrap_netplan__enabled`              | `true`                                                                                              | A boolean flag to enable or disable the role's functionality.                                                                                                                                             |
| `bootstrap_netplan__remove_existing`      | `true`                                                                                              | A boolean flag to determine whether existing Netplan configurations should be removed before applying a new configuration.                                                                                  |
| `bootstrap_netplan__dhcp4`                | `true`                                                                                              | A boolean flag indicating whether DHCPv4 should be enabled for the network interface.                                                                                                                       |
| `bootstrap_netplan__dhcp6`                | `true`                                                                                              | A boolean flag indicating whether DHCPv6 should be enabled for the network interface.                                                                                                                       |
| `bootstrap_netplan__renderer`             | `networkd`                                                                                            | The renderer to use for Netplan, such as `networkd` or `NetworkManager`.                                                                                                                                    |
| `bootstrap_netplan__ethernet_interface_name`| `"ens160"`                                                                                          | The name of the Ethernet interface to configure.                                                                                                                                                            |
| `bootstrap_netplan__ethernet_primary_interface`| `{{ ansible_facts['default_ipv4']['interface'] }}`                                                   | The primary Ethernet interface determined from Ansible facts.                                                                                                                                               |
| `bootstrap_netplan__ethernet_primary_mac`   | `{{ ansible_facts['default_ipv4']['macaddress'] }}`                                                    | The MAC address of the primary Ethernet interface determined from Ansible facts.                                                                                                                              |
| `bootstrap_netplan__configuration`        | `{}`                                                                                                | A dictionary to hold custom Netplan configuration settings. If provided, it will be used instead of generating a configuration from templates.                                                                |
| `bootstrap_netplan__static_addresses`     | `[]`                                                                                                | A list of static IP addresses to configure for the network interface.                                                                                                                                       |
| `bootstrap_netplan__routes`               | `[]`                                                                                                | A list of routes to add to the Netplan configuration.                                                                                                                                                       |
| `bootstrap_netplan__nameservers`          | `[]`                                                                                                | A list of nameservers to configure in the Netplan settings.                                                                                                                                                 |
| `bootstrap_netplan__packages`             | `[nplan, netplan.io]`                                                                               | A list of packages required for Netplan functionality that will be installed by the role.                                                                                                                   |
| `bootstrap_netplan__pri_domain`           | `example.org`                                                                                       | The primary domain name to configure in the Netplan settings.                                                                                                                                               |
| `bootstrap_netplan__check_install`        | `true`                                                                                              | A boolean flag indicating whether to check and install required packages before proceeding with configuration.                                                                                                 |
| `bootstrap_netplan__apply`                | `true`                                                                                              | A boolean flag indicating whether to apply the Netplan configuration after generating it.                                                                                                                   |

## Usage

To use the `bootstrap_netplan` role, include it in your Ansible playbook and optionally override any of the default variables as needed.

### Example Playbook

```yaml
- name: Configure network using Netplan
  hosts: all
  become: yes
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

These packages will be installed by the role if they are not already present.

## Best Practices

1. **Configuration Management**: Use the `bootstrap_netplan__configuration` variable to provide a custom Netplan configuration dictionary when needed, ensuring precise control over network settings.
2. **Static vs DHCP**: Set `bootstrap_netplan__dhcp4` and `bootstrap_netplan__dhcp6` appropriately based on whether you want to use static IP addresses or DHCP for your network interfaces.
3. **Package Management**: Ensure that the required packages (`nplan`, `netplan.io`) are installed before applying Netplan configurations.

## Molecule Tests

This role does not include any Molecule tests at this time. Consider adding Molecule scenarios to test different configurations and ensure the role behaves as expected across various environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_netplan/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_netplan/tasks/main.yml)
- [tasks/netplan.yml](../../roles/bootstrap_netplan/tasks/netplan.yml)
- [tasks/remove-existing.yml](../../roles/bootstrap_netplan/tasks/remove-existing.yml)
- [handlers/main.yml](../../roles/bootstrap_netplan/handlers/main.yml)