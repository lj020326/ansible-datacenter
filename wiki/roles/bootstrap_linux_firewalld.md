---
title: "Bootstrap Linux Firewalld Role"
role: roles/bootstrap_linux_firewalld
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_linux_firewalld]
---

```yaml
---
title: Bootstrap Linux Firewalld Role
role: bootstrap_linux_firewalld
category: System
type: Role
summary: |
  The `bootstrap_linux_firewalld` role is designed to manage the installation, configuration, and removal of the Firewalld service on Linux systems. It provides a flexible and comprehensive approach to setting up Firewalld with customizable zones, services, ports, and rules.

variables: |
  | Variable Name                         | Default Value                           | Description                                                                 |
  |---------------------------------------|-----------------------------------------|-----------------------------------------------------------------------------|
  | `firewalld_supported_actions`         | `['install', 'configure', 'uninstall']` | List of supported actions for the role.                                      |
  | `firewalld_action`                    | `install`                               | Action to perform (install, configure, uninstall).                           |
  | `firewalld_default_zone`              | `internal`                              | Default zone for Firewalld.                                                  |
  | `firewalld_zones_force_reset`         | `false`                                 | Force reset of zones.                                                        |
  | `firewalld_handler_reload`            | `true`                                  | Reload Firewalld after configuration changes.                                |
  | `firewalld_enabled`                   | `true`                                  | Enable Firewalld service.                                                    |
  | `firewalld_firewallbackend`           | `iptables`                              | Backend firewall system (iptables or nftables).                              |
  | `firewalld_conf_file`                 | `/etc/firewalld/firewalld.conf`         | Path to the Firewalld configuration file.                                    |
  | `firewalld_configs`                   | `{}`                                    | Dictionary of custom configurations for Firewalld.                            |
  | `firewalld_ipsets`                    | `[]`                                    | List of IP sets to configure.                                                |
  | `firewalld_services`                  | `[]`                                    | List of services to configure.                                               |
  | `firewalld_zones`                     | `[{'name': '{{ firewalld_default_zone }}'}]` | List of zones to configure.                                                  |
  | `firewalld_ports`                     | `[]`                                    | List of ports to configure.                                                  |
  | `firewalld_rules`                     | `[{'zone': '{{ firewalld_default_zone }}', 'immediate': 'yes', 'masquerade': 'yes', 'permanent': 'yes', 'state': 'enabled'}]` | List of rules to configure. |
  | `firewalld_default_zone_networks`     | `[127.0.0.0/8, 172.0.0.0/8, 10.0.0.0/8, 192.168.0.0/16]` | Default networks for the default zone.                                       |
  | `firewalld_flush_all_handlers`        | `true`                                  | Flush all handlers.                                                          |
  | `__bootstrap_firewalld__log_prefix_main` | `Bootstrap-firewalld | Install |` | Log prefix for main tasks.                                                   |
  | `__bootstrap_firewalld__log_prefix_initvars` | `Bootstrap-firewalld | Init-vars |` | Log prefix for initialization variables.                                     |
  | `__bootstrap_firewalld__log_prefix_configure` | `Bootstrap-firewalld | Configure |` | Log prefix for configuration tasks.                                          |
  | `__bootstrap_firewalld__log_prefix_setup` | `Bootstrap-firewalld | Setup |` | Log prefix for setup tasks.                                                  |
  | `__bootstrap_firewalld__log_prefix_remove` | `Bootstrap-firewalld | Remove |` | Log prefix for removal tasks.                                                |
  | `__firewalld_packages`                | `['firewalld', 'python3-firewall']`    | List of packages to install.                                                 |
  | `__firewalld_pip_libs`                | `['firewall']`                         | List of Python libraries to install.                                         |

usage: |
  To use the `bootstrap_linux_firewalld` role, include it in your playbook and configure the variables as needed. Here is an example playbook:

  ```yaml
  ---
  - hosts: all
    roles:
      - role: bootstrap_linux_firewalld
        vars:
          firewalld_action: install
          firewalld_default_zone: public
          firewalld_services:
            - name: http
              custom: true
          firewalld_ports:
            - zone: public
              port: 8080/tcp
              permanent: true
              state: enabled
  ```

dependencies: |
  This role does not have any external dependencies. However, it assumes that the target system is a Linux distribution that supports Firewalld.

best_practices: |
  - Always test the role in a development environment before deploying it to production.
  - Regularly update the role to ensure compatibility with the latest versions of Firewalld and the target Linux distribution.
  - Use the `configure` action to apply configuration changes without reinstalling Firewalld.
  - Customize the Firewalld configuration file (`firewalld.conf`) as needed to suit your specific requirements.

backlinks: |
  - [defaults/main.yml](../../roles/bootstrap_linux_firewalld/defaults/main.yml)
  - [tasks/configure.yml](../../roles/bootstrap_linux_firewalld/tasks/configure.yml)
  - [tasks/init-vars.yml](../../roles/bootstrap_linux_firewalld/tasks/init-vars.yml)
  - [tasks/main.yml](../../roles/bootstrap_linux_firewalld/tasks/main.yml)
  - [tasks/setup.yml](../../roles/bootstrap_linux_firewalld/tasks/setup.yml)
  - [tasks/uninstall.yml](../../roles/bootstrap_linux_firewalld/tasks/uninstall.yml)
  - [handlers/main.yml](../../roles/bootstrap_linux_firewalld/handlers/main.yml)
```