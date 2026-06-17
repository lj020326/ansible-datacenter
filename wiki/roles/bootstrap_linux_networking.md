---
title: Bootstrap Linux Networking Role Documentation
role: bootstrap_linux_networking
category: Network Configuration
type: Ansible Role
tags: networking, linux, ansible, automation

## Summary

The `bootstrap_linux_networking` role is designed to automate the setup and configuration of network interfaces on Linux systems. It supports various types of network configurations including Ethernet, bridge, bond, and VLAN interfaces. The role dynamically includes OS-specific tasks and variables to ensure compatibility across different distributions such as Debian and RedHat derivatives.

## Variables

| Variable Name                         | Default Value                      | Description                                                                 |
|---------------------------------------|------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_linux_network_pkgs`        | `[]`                               | List of network-related packages to install.                              |
| `bootstrap_linux_network_ether_interfaces` | `[]`                             | List of Ethernet interfaces to configure.                                 |
| `bootstrap_linux_network_bridge_interfaces` | `[]`                            | List of bridge interfaces to configure.                                   |
| `bootstrap_linux_network_bond_interfaces`   | `[]`                            | List of bond interfaces to configure.                                     |
| `bootstrap_linux_network_vlan_interfaces`   | `[]`                            | List of VLAN interfaces to configure.                                     |
| `bootstrap_linux_network_check_packages`  | `true`                           | Boolean flag to determine if required packages should be checked and installed. |
| `bootstrap_linux_network_allow_service_restart` | `true`                       | Boolean flag to allow restarting network services after configuration changes.|
| `bootstrap_linux_network_modprobe_persist` | `false`                          | Boolean flag to persist kernel module loading at boot time (not used in this role). |
| `env`                                 | `{ RUNLEVEL: 1 }`                  | Environment variables for package installation tasks.                       |

## Usage

To use the `bootstrap_linux_networking` role, include it in your playbook and define the necessary variables to specify the network interfaces and packages you want to install.

### Example Playbook

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_networking
      vars:
        bootstrap_linux_network_pkgs:
          - net-tools
          - ifupdown
        bootstrap_linux_network_ether_interfaces:
          - device: eth0
            ip: 192.168.1.100
            netmask: 255.255.255.0
            gateway: 192.168.1.1
        bootstrap_linux_network_vlan_interfaces:
          - device: eth0.10
            ip: 192.168.10.100
            netmask: 255.255.255.0
```

## Dependencies

This role does not have any external dependencies other than the Ansible core modules and the specified network-related packages.

## Best Practices

- Ensure that the `bootstrap_linux_network_pkgs` list includes all necessary packages for your specific network configuration.
- Define all required interfaces in their respective lists (`bootstrap_linux_network_ether_interfaces`, `bootstrap_linux_network_bridge_interfaces`, etc.) with appropriate configurations.
- Set `bootstrap_linux_network_allow_service_restart` to `false` if you do not want the role to restart network services automatically.

## Molecule Tests

This role does not include any Molecule tests at this time. Consider adding Molecule scenarios to ensure the role behaves as expected across different environments and distributions.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_networking/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_networking/tasks/main.yml)
- [tasks/restartscript.yml](../../roles/bootstrap_linux_networking/tasks/restartscript.yml)
- [tasks/setup-Debian.yml](../../roles/bootstrap_linux_networking/tasks/setup-Debian.yml)
- [tasks/setup-RedHat.yml](../../roles/bootstrap_linux_networking/tasks/setup-RedHat.yml)
- [handlers/main.yml](../../roles/bootstrap_linux_networking/handlers/main.yml)