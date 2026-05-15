---
title: Bootstrap Linux Role Documentation
role: bootstrap_linux
category: System Configuration
type: Ansible Role
tags: linux, bootstrap, configuration, automation
---

## Summary

The `bootstrap_linux` role is designed to automate the initial setup and configuration of a Linux system. It covers a wide range of tasks including setting up Python environments, configuring users, installing packages, managing firewalls, and deploying various services like NTP, Postfix, Java, SSHD, LDAP client, log rotation, NFS, Samba, Webmin, GPU drivers, Docker, and more. The role is highly configurable through a set of variables that allow customization to fit specific requirements.

## Variables

| Variable Name                              | Default Value                                                                 | Description                                                                                                                                                                                                 |
|--------------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_linux__os_python_interpreter`   | `/usr/bin/env python3`                                                      | Path to the Python interpreter used by Ansible.                                                                                                                                                             |
| `bootstrap_linux__firewalld_default_zone`  | `internal`                                                                    | Default firewalld zone for the system.                                                                                                                                                                      |
| `bootstrap_linux__firewalld_enabled`       | `true`                                                                        | Whether to enable and configure firewalld on the system.                                                                                                                                                    |
| `bootstrap_linux__firewalld_ports__linux`  | `[10000/tcp]`                                                                 | List of ports to open in firewalld for Linux systems.                                                                                                                                                       |
| `bootstrap_linux__firewalld_services__ssh` | `[name: ssh]`                                                                | List of services to enable in firewalld, e.g., SSH.                                                                                                                                                         |
| `bootstrap_linux__firewalld_default_zone_networks` | `[127.0.0.0/8, 172.0.0.0/8, 10.0.0.0/8, 192.168.0.0/16]`              | List of networks to be associated with the default firewalld zone.                                                                                                                                          |
| `bootstrap_linux__install_vmware_tools`    | `false`                                                                       | Whether to install VMware Tools on the system.                                                                                                                                                              |
| `bootstrap_linux__install_ntp`             | `true`                                                                        | Whether to install and configure NTP (Network Time Protocol) on the system.                                                                                                                               |
| `bootstrap_linux__setup_firewalld`         | `true`                                                                        | Whether to set up firewalld rules according to the specified configurations.                                                                                                                              |
| `bootstrap_linux__setup_postfix`           | `true`                                                                        | Whether to install and configure Postfix for email handling on the system.                                                                                                                                |
| `bootstrap_linux__setup_java`              | `true`                                                                        | Whether to install Java on the system.                                                                                                                                                                      |
| `bootstrap_linux__setup_sshd`              | `true`                                                                        | Whether to configure SSHD (Secure Shell Daemon) settings on the system.                                                                                                                                   |
| `bootstrap_linux__setup_ldap_client`       | `true`                                                                        | Whether to set up LDAP client configuration on the system.                                                                                                                                                |
| `bootstrap_linux__setup_logrotate`         | `true`                                                                        | Whether to configure log rotation policies for system logs.                                                                                                                                                 |
| `bootstrap_linux__setup_nfs`               | `true`                                                                        | Whether to install and configure NFS (Network File System) client/server on the system.                                                                                                                   |
| `bootstrap_linux__setup_samba_client`      | `false`                                                                       | Whether to install and configure Samba client on the system.                                                                                                                                              |
| `bootstrap_linux__setup_webmin`            | `true`                                                                        | Whether to install and configure Webmin for web-based system administration.                                                                                                                              |
| `bootstrap_linux__setup_network`           | `true`                                                                        | Whether to configure network settings on the system.                                                                                                                                                        |
| `bootstrap_linux__setup_stepca`            | `false`                                                                       | Whether to set up Step CA (Certificate Authority) on the system.                                                                                                                                          |
| `bootstrap_linux__setup_caroot`            | `false`                                                                       | Whether to set up CAROOT for managing certificates on the system.                                                                                                                                         |
| `bootstrap_linux__setup_crons`             | `true`                                                                        | Whether to configure cron jobs on the system.                                                                                                                                                               |
| `bootstrap_linux__setup_docker`            | `false`                                                                       | Whether to install and configure Docker on the system.                                                                                                                                                    |
| `bootstrap_linux__setup_gpu_drivers`       | `false`                                                                       | Whether to install GPU drivers on the system.                                                                                                                                                             |
| `bootstrap_linux__deploy_ca_certs`         | `false`                                                                       | Whether to deploy CA certificates on the system.                                                                                                                                                          |
| `bootstrap_linux__deploy_pki_certs`        | `true`                                                                        | Whether to deploy PKI (Public Key Infrastructure) certificates on the system.                                                                                                                           |
| `bootstrap_linux__harden`                  | `false`                                                                       | Whether to apply hardening measures to secure the system.                                                                                                                                                 |
| `bootstrap_linux__container_types`         | `[docker, container, containerd]`                                             | List of container types supported by the role.                                                                                                                                                            |

## Usage

To use the `bootstrap_linux` role in your Ansible playbook, include it as follows:

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux
      vars:
        bootstrap_linux__install_vmware_tools: true
        bootstrap_linux__setup_webmin: false
```

This example enables the installation of VMware Tools and disables the setup of Webmin.

## Dependencies

The `bootstrap_linux` role depends on several other roles that are included based on the configuration variables. These roles include:

- `bootstrap_pip`
- `bootstrap_ansible_user`
- `bootstrap_linux_user`
- `bootstrap_linux_package`
- `bootstrap_linux_core`
- `bootstrap_linux_mount`
- `bootstrap_linux_cron`
- `bootstrap_vmware_tools`
- `bootstrap_logrotate`
- `bootstrap_ntp`
- `bootstrap_postfix`
- `bootstrap_java`
- `bootstrap_linux_firewalld`
- `bootstrap_sshd`
- `bootstrap_ldap_client`
- `bootstrap_nfs_service`
- `bootstrap_samba_client`
- `bootstrap_stepca`
- `deploy_ca_certs`
- `deploy_pki_certs`
- `bootstrap_webmin`
- `bootstrap_gpu_drivers`
- `bootstrap_docker`
- `harden_os_linux`

Ensure that these roles are available in your Ansible environment.

## Best Practices

1. **Customize Variables**: Adjust the variables to match your specific requirements before running the role.
2. **Test Thoroughly**: Use Molecule tests (if available) or other testing frameworks to ensure the role behaves as expected in different environments.
3. **Security Considerations**: Enable hardening measures (`bootstrap_linux__harden`) and manage certificates properly to secure your systems.

## Molecule Tests

This role does not include Molecule tests at this time. It is recommended to create and run Molecule tests to validate the functionality of the role in different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux/defaults/main.yml)
- [tasks/disable-systemd-tmpmount.yml](../../roles/bootstrap_linux/tasks/disable-systemd-tmpmount.yml)
- [tasks/main.yml](../../roles/bootstrap_linux/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_linux/handlers/main.yml)