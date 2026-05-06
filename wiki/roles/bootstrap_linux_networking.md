---
title: Bootstrap Linux Networking Role Documentation
role: bootstrap_linux_networking
category: Network Configuration
type: Ansible Role
tags: networking, linux, ansible, configuration
---

## Summary

The `bootstrap_linux_networking` role is designed to configure network interfaces on Linux systems. It supports various types of network configurations including Ethernet, bridge, bond, and VLAN interfaces. The role also handles package installation, service management, and network restarts based on the operating system family.

## Variables

| Variable Name                          | Default Value                                      | Description                                                                                         |
|----------------------------------------|----------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| `bootstrap_linux_network_pkgs`         | `[]`                                               | List of packages to install for networking.                                                           |
| `bootstrap_linux_network_ether_interfaces` | `[]`                                             | List of Ethernet interfaces to configure.                                                             |
| `bootstrap_linux_network_bridge_interfaces` | `[]`                                            | List of bridge interfaces to configure.                                                               |
| `bootstrap_linux_network_bond_interfaces`  | `[]`                                             | List of bond interfaces to configure.                                                                 |
| `bootstrap_linux_network_vlan_interfaces`  | `[]`                                             | List of VLAN interfaces to configure.                                                                 |
| `bootstrap_linux_network_check_packages`   | `true`                                           | Boolean to check and install required packages.                                                       |
| `bootstrap_linux_network_allow_service_restart` | `true`                                         | Boolean to allow network service restarts.                                                            |
| `bootstrap_linux_network_modprobe_persist`  | `false`                                          | Boolean to persist kernel module settings (not currently used in the role).                             |
| `env`                                  | `{ RUNLEVEL: 1 }`                                  | Environment variables for package installation commands.                                              |

## Usage

To use this role, include it in your playbook and define the necessary variables as per your network configuration requirements.

### Example Playbook

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_networking
      vars:
        bootstrap_linux_network_pkgs:
          - net-tools
          - iproute2
        bootstrap_linux_network_ether_interfaces:
          - device: eth0
            bootproto: dhcp
        bootstrap_linux_network_bridge_interfaces:
          - device: br0
            interfaces:
              - eth1
```

## Dependencies

This role does not have any external dependencies other than the packages specified in `bootstrap_linux_network_pkgs`.

## Tags

- `network` - Applies to all network configuration tasks.
- `packages` - Applies to package installation tasks.
- `services` - Applies to service management tasks.

## Best Practices

1. **Backup Configuration Files**: The role creates backups of existing network configuration files before making changes.
2. **Conditional Service Restarts**: Network services are only restarted if the `bootstrap_linux_network_allow_service_restart` variable is set to `true`.
3. **Environment Variables**: Environment variables can be customized using the `env` dictionary.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding them for automated testing and validation of the role's functionality.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_networking/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_networking/tasks/main.yml)
- [tasks/restartscript.yml](../../roles/bootstrap_linux_networking/tasks/restartscript.yml)
- [tasks/setup-Debian.yml](../../roles/bootstrap_linux_networking/tasks/setup-Debian.yml)
- [tasks/setup-RedHat.yml](../../roles/bootstrap_linux_networking/tasks/setup-RedHat.yml)
- [handlers/main.yml](../../roles/bootstrap_linux_networking/handlers/main.yml)