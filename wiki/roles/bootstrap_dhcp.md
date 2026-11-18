---
title: "Bootstrap DHCP Role"
role: roles/bootstrap_dhcp
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_dhcp]
---

# Bootstrap DHCP Role Documentation

## Purpose

The `bootstrap_dhcp` role is designed to configure and manage the DHCP server on a system. It handles package installation, configuration file management, AppArmor policy adjustments, and service control for the DHCP server. This role is particularly useful for setting up DHCP servers on Debian-based systems.

## Variables

| Variable Name              | Default Value           | Description                                                                 |
|----------------------------|-------------------------|-----------------------------------------------------------------------------|
| `dhcp_apparmor_fix`        | `true`                  | Whether to apply AppArmor policy fixes for DHCP.                            |
| `dhcp_global_includes_missing` | `false`             | Whether to ignore errors when global includes are missing.                  |
| `dhcp_packages_state`      | `present`               | The desired state of the DHCP packages (present or absent).                 |
| `dhcp_subnets`             | `[]`                    | List of subnets to be configured in the DHCP server.                        |

## Usage

To use this role, include it in your playbook and set any necessary variables. Here is an example playbook:

```yaml
---
- hosts: dhcp_servers
  roles:
    - role: bootstrap_dhcp
      vars:
        dhcp_apparmor_fix: true
        dhcp_global_includes_missing: false
        dhcp_packages_state: present
        dhcp_subnets:
          - subnet: 192.168.1.0 netmask 255.255.255.0
            range: 192.168.1.100 192.168.1.200
            option routers: 192.168.1.1
            option domain-name-servers: 8.8.8.8, 8.8.4.4
```

## Dependencies

This role does not have any external dependencies. It assumes that the necessary DHCP packages are available in the system's package repository.

## Best Practices

- Ensure that the DHCP server is properly configured and tested in a development environment before deploying it to production.
- Regularly update the DHCP server software to benefit from security patches and new features.
- Monitor the DHCP server logs to detect and resolve any issues promptly.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_dhcp/defaults/main.yml)
- [tasks/apparmor-fix.yml](../../roles/bootstrap_dhcp/tasks/apparmor-fix.yml)
- [tasks/default-fix.yml](../../roles/bootstrap_dhcp/tasks/default-fix.yml)
- [tasks/main.yml](../../roles/bootstrap_dhcp/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_dhcp/handlers/main.yml)