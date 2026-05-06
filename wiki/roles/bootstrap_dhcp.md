---
title: Bootstrap DHCP Role Documentation
role: bootstrap_dhcp
category: Networking
type: Ansible Role
tags: dhcp, apparmor, configuration
---

## Summary

The `bootstrap_dhcp` role is designed to automate the installation and configuration of a DHCP server on Debian-based systems. It handles package installation, AppArmor policy adjustments, default settings configuration, custom include files management, and the main DHCP configuration file setup. The role ensures that the DHCP service runs correctly with proper permissions and configurations.

## Variables

| Variable Name                      | Default Value                  | Description                                                                 |
|------------------------------------|--------------------------------|-----------------------------------------------------------------------------|
| `dhcp_apparmor_fix`                | `true`                         | Boolean to determine if AppArmor policy adjustments should be applied.      |
| `dhcp_global_includes_missing`     | `false`                        | Boolean to ignore errors when copying global include files if they are missing. |
| `dhcp_packages_state`              | `present`                      | State of the DHCP packages (e.g., present, absent).                         |
| `dhcp_subnets`                     | `[]`                           | List of subnets to be configured in the DHCP server.                        |

## Usage

To use the `bootstrap_dhcp` role, include it in your playbook and define any necessary variables as needed. Here is an example:

```yaml
- name: Configure DHCP Server
  hosts: dhcp_servers
  roles:
    - role: bootstrap_dhcp
      vars:
        dhcp_apparmor_fix: true
        dhcp_global_includes_missing: false
        dhcp_packages_state: present
        dhcp_subnets:
          - subnet: 192.168.1.0
            netmask: 255.255.255.0
            range_start: 192.168.1.10
            range_end: 192.168.1.100
            routers:
              - 192.168.1.1
            domain_name_servers:
              - 8.8.8.8
              - 8.8.4.4
```

## Dependencies

- The role does not have any external dependencies, but it assumes that the target hosts are Debian-based systems.

## Tags

The following tags can be used to control which parts of the role are executed:

- `dhcp`: Applies to all tasks in this role.
- `apparmor`: Specifically targets tasks related to AppArmor policy adjustments.
- `restart_dhcp`: Restarts the DHCP service when changes are made.

## Best Practices

- Ensure that the target hosts have the necessary permissions and network configurations to run a DHCP server.
- Review and test the configuration files before deploying them in production environments.
- Use the `dhcp_global_includes_missing` variable with caution, as ignoring errors might lead to incomplete configurations.

## Molecule Tests

This role does not include Molecule tests at this time. Future updates may include automated testing.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_dhcp/defaults/main.yml)
- [tasks/apparmor-fix.yml](../../roles/bootstrap_dhcp/tasks/apparmor-fix.yml)
- [tasks/default-fix.yml](../../roles/bootstrap_dhcp/tasks/default-fix.yml)
- [tasks/main.yml](../../roles/bootstrap_dhcp/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_dhcp/handlers/main.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_dhcp` role, including its purpose, configuration variables, usage instructions, and best practices.