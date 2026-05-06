---
title: Bootstrap Linux Firewalld Role Documentation
role: bootstrap_linux_firewalld
category: Security
type: Ansible Role
tags: firewalld, security, linux, ansible
---

## Summary

The `bootstrap_linux_firewalld` role is designed to manage the installation, configuration, and uninstallation of the `firewalld` service on Linux systems. It provides flexibility in defining firewall rules, zones, services, and other configurations through Ansible variables.

## Variables

| Variable Name                      | Default Value                                                                 | Description                                                                                                                                                                                                 |
|------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `firewalld_supported_actions`      | `['install', 'configure', 'uninstall']`                                     | List of supported actions for the role.                                                                                                                                                                     |
| `firewalld_action`                 | `install`                                                                     | The action to perform: install, configure, or uninstall firewalld.                                                                                                                                          |
| `firewalld_default_zone`           | `internal`                                                                    | The default firewall zone to use.                                                                                                                                                                           |
| `firewalld_zones_force_reset`      | `false`                                                                       | Whether to force reset unmanaged zones in `/etc/firewalld/zones`.                                                                                                                                           |
| `firewalld_handler_reload`         | `true`                                                                        | Whether to reload firewalld after configuration changes.                                                                                                                                                    |
| `firewalld_enabled`                | `true`                                                                        | Whether the firewalld service should be enabled and started.                                                                                                                                              |
| `firewalld_firewallbackend`        | `iptables`                                                                    | The backend used by firewalld (e.g., iptables).                                                                                                                                                           |
| `firewalld_conf_file`              | `/etc/firewalld/firewalld.conf`                                               | Path to the firewalld configuration file.                                                                                                                                                                 |
| `firewalld_configs`                | `{}`                                                                          | Dictionary of custom configurations for the firewalld.conf file.                                                                                                                                            |
| `firewalld_ipsets`                 | `[]`                                                                          | List of ipset definitions.                                                                                                                                                                                  |
| `firewalld_services`               | `[]`                                                                          | List of custom services to define in firewalld.                                                                                                                                                             |
| `firewalld_zones`                  | `[{"name": "{{ firewalld_default_zone }}"}}]`                                  | List of firewall zones to configure.                                                                                                                                                                      |
| `firewalld_ports`                  | `[]`                                                                          | List of ports to open or close in the firewall.                                                                                                                                                           |
| `firewalld_rules`                  | `[{"zone": "{{ firewalld_default_zone }}", "immediate": "yes", "masquerade": "yes", "permanent": "yes", "state": enabled}]` | List of rules to apply to the firewall zones.                                                                                                                                                             |
| `firewalld_default_zone_networks`  | `[127.0.0.0/8, 172.0.0.0/8, 10.0.0.0/8, 192.168.0.0/16]`                      | List of default networks for the internal zone.                                                                                                                                                             |
| `firewalld_flush_all_handlers`     | `true`                                                                        | Whether to flush all handlers before applying new configurations.                                                                                                                                           |

## Usage

To use this role, include it in your playbook and define the necessary variables as per your requirements. Here is an example:

```yaml
- name: Bootstrap firewalld on target hosts
  hosts: all
  roles:
    - role: bootstrap_linux_firewalld
      vars:
        firewalld_action: install
        firewalld_default_zone: public
        firewalld_zones:
          - name: public
            interfaces: eth0
        firewalld_services:
          - name: ssh
            custom: false
        firewalld_ports:
          - port: 80/tcp
            permanent: yes
```

## Dependencies

This role does not have any external dependencies other than the Ansible control node having access to the target hosts and the necessary permissions to install packages and manage services.

## Tags

- `install`: Installs firewalld and its required packages.
- `configure`: Configures firewalld based on provided variables.
- `uninstall`: Uninstalls firewalld from the system.

## Best Practices

- Always ensure that your firewall rules are correctly defined to avoid locking yourself out of the system.
- Use the `firewalld_configs` variable to customize the firewalld configuration file as needed.
- Test configurations in a non-production environment before applying them to production systems.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, ensure you have Molecule installed and execute the following commands:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_firewalld/defaults/main.yml)
- [tasks/configure.yml](../../roles/bootstrap_linux_firewalld/tasks/configure.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_linux_firewalld/tasks/init-vars.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_firewalld/tasks/main.yml)
- [tasks/setup.yml](../../roles/bootstrap_linux_firewalld/tasks/setup.yml)
- [tasks/uninstall.yml](../../roles/bootstrap_linux_firewalld/tasks/uninstall.yml)
- [handlers/main.yml](../../roles/bootstrap_linux_firewalld/handlers/main.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_linux_firewalld` role, including its purpose, variables, usage, and best practices.