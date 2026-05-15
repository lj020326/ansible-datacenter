---
title: Bootstrap OS Network Role Documentation
role: bootstrap_os_network
category: Networking
type: Ansible Role
tags: network, configuration, backup, systemd
---

## Summary

The `bootstrap_os_network` role is designed to manage and configure the network interfaces on a target system. It includes tasks for backing up existing network configurations, installing new configurations, disabling NetworkManager, and restarting the network service. This ensures that the system's networking setup aligns with specified requirements.

## Variables

| Variable Name         | Default Value               | Description                                                                 |
|-----------------------|-----------------------------|-----------------------------------------------------------------------------|
| `ifcfg_dir`           | `/etc/sysconfig/network-scripts` | The directory where network configuration files are stored.             |
| `osa_networks`        | `[]`                        | A list of dictionaries containing network configurations to be applied.     |

## Usage

To use the `bootstrap_os_network` role, include it in your playbook and provide the necessary variables. Here is an example:

```yaml
- hosts: all
  roles:
    - role: bootstrap_os_network
      vars:
        ifcfg_dir: /etc/sysconfig/network-scripts
        osa_networks:
          - name: br-mgmt
            device: eth0
            native: true
            vlan_id: 10
          - name: br-storage
            device: eth1
```

## Dependencies

This role does not have any external dependencies. However, it assumes that the target system uses `systemd` for managing services and has a directory structure compatible with Red Hat-based systems (e.g., `/etc/sysconfig/network-scripts`).

## Best Practices

- Ensure that the `osa_networks` variable is correctly defined to match your network configuration requirements.
- Always back up existing network configurations before applying new ones, as this role will overwrite them.
- Verify that the target system uses `systemd` and has a compatible directory structure for network scripts.

## Molecule Tests

This role does not include any Molecule tests at this time. Consider adding tests to ensure the role functions correctly in various environments.

## Backlinks

- [tasks/main.yml](../../roles/bootstrap_os_network/tasks/main.yml)
- [defaults/main.yml](../../roles/bootstrap_os_network/defaults/main.yml) (if it exists)

---

This documentation provides a comprehensive overview of the `bootstrap_os_network` Ansible role, including its purpose, variables, usage, and best practices.