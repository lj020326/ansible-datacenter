---
title: Bootstrap Linux Role Documentation
role: bootstrap_linux
category: System Configuration
type: Ansible Role
tags: linux, bootstrap, configuration, automation
---

## Summary

The `bootstrap_linux` role is designed to perform a comprehensive setup and configuration of a Linux system. It covers various aspects such as Python environment setup, user management, package installation, network configuration, security settings (including firewalld), and optional services like VMware Tools, NTP, Postfix, Java, SSHD, LDAP client, logrotate, NFS, Samba client, Webmin, Docker, and system hardening. This role ensures that the Linux system is configured according to best practices for a secure and functional environment.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_linux__os_python_interpreter` | `/usr/bin/env python3` | The path to the Python interpreter used by Ansible. |
| `bootstrap_linux__firewalld_default_zone` | `internal` | The default firewalld zone for the system. |
| `bootstrap_linux__firewalld_enabled` | `true` | Whether firewalld should be enabled on the system. |
| `bootstrap_linux__firewalld_ports__linux` | `[10000/tcp]` | List of ports to open in firewalld. |
| `bootstrap_linux__firewalld_services__ssh` | `[{name: ssh}]` | List of services to allow through firewalld, specifically SSH. |
| `bootstrap_linux__firewalld_default_zone_networks` | `[127.0.0.0/8, 172.0.0.0/8, 10.0.0.0/8, 192.168.0.0/16]` | List of networks to be included in the default firewalld zone. |
| `bootstrap_linux__install_vmware_tools` | `false` | Whether VMware Tools should be installed on the system. |
| `bootstrap_linux__install_ntp` | `true` | Whether NTP should be installed and configured for time synchronization. |
| `bootstrap_linux__setup_firewalld` | `true` | Whether firewalld should be set up according to specified configurations. |
| `bootstrap_linux__setup_postfix` | `true` | Whether Postfix should be installed and configured as the mail transfer agent. |
| `bootstrap_linux__setup_java` | `true` | Whether Java should be installed on the system. |
| `bootstrap_linux__setup_sshd` | `true` | Whether SSHD should be set up with default configurations. |
| `bootstrap_linux__setup_ldap_client` | `true` | Whether LDAP client should be configured for user authentication. |
| `bootstrap_linux__setup_logrotate` | `true` | Whether logrotate should be installed and configured to manage system logs. |
| `bootstrap_linux__setup_nfs` | `true` | Whether NFS service should be set up on the system. |
| `bootstrap_linux__setup_samba_client` | `false` | Whether Samba client should be installed for network file sharing. |
| `bootstrap_linux__setup_webmin` | `true` | Whether Webmin should be installed and configured as a web-based system administration tool. |
| `bootstrap_linux__setup_docker` | `true` | Whether Docker should be installed and configured on the system, provided the host is in the 'docker' group. |
| `bootstrap_linux__setup_network` | `true` | Whether network configurations (DNS, hostname, etc.) should be set up. |
| `bootstrap_linux__setup_stepca` | `false` | Whether Step CA should be installed and configured for certificate management. |
| `bootstrap_linux__setup_caroot` | `false` | Placeholder variable; not currently used in the role. |
| `bootstrap_linux__setup_crons` | `true` | Whether cron jobs should be set up according to specified configurations. |
| `bootstrap_linux__deploy_ca_certs` | `false` | Whether CA certificates should be deployed on the system. |
| `bootstrap_linux__deploy_pki_certs` | `true` | Whether PKI certificates should be deployed on the system. |
| `bootstrap_linux__harden` | `false` | Whether the system should undergo hardening procedures to enhance security. |
| `bootstrap_linux__container_types` | `[docker, container, containerd]` | List of container types supported by the role for Docker setup. |

## Usage

To use the `bootstrap_linux` role, include it in your playbook and adjust the variables as needed:

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux
      vars:
        bootstrap_linux__install_vmware_tools: true
        bootstrap_linux__setup_webmin: false
```

## Dependencies

This role depends on several other roles that are included conditionally based on the variables set. The dependent roles include:

- `bootstrap_pip`
- `bootstrap_ansible_user`
- `bootstrap_linux_user`
- `bootstrap_linux_package`
- `bootstrap_linux_mount`
- `bootstrap_linux_cron`
- `bootstrap_linux_core`
- `bootstrap_vmware_tools`
- `bootstrap_logrotate`
- `bootstrap_ntp`
- `bootstrap_postfix`
- `bootstrap_linux_firewalld`
- `bootstrap_java`
- `bootstrap_sshd`
- `bootstrap_ldap_client`
- `bootstrap_nfs_service`
- `bootstrap_samba_client`
- `bootstrap_stepca`
- `deploy_ca_certs`
- `deploy_pki_certs`
- `bootstrap_webmin`
- `bootstrap_docker`
- `harden_os_linux`

## Tags

The following tags can be used to selectively run parts of the role:

- `python` - Bootstrap Python environment.
- `ansible_user` - Bootstrap Ansible user.
- `linux_users` - Bootstrap Linux users.
- `packages` - Install Linux packages.
- `mounts` - Configure Linux mounts.
- `crons` - Setup Linux crons.
- `core_features` - Setup core features of the Linux system.
- `vmware_tools` - Install VMware Tools.
- `logrotate` - Setup logrotate.
- `ntp` - Setup NTP.
- `postfix` - Setup Postfix.
- `firewalld` - Configure firewalld.
- `java` - Install Java.
- `sshd` - Setup SSHD.
- `ldap_client` - Setup LDAP client.
- `nfs_service` - Setup NFS service.
- `samba_client` - Setup Samba client.
- `stepca` - Setup Step CA.
- `deploy_ca_certs` - Deploy CA certificates.
- `deploy_pki_certs` - Deploy PKI certificates.
- `webmin` - Setup Webmin.
- `docker` - Setup Docker.
- `harden_os_linux` - Harden the Linux OS.

## Best Practices

1. **Use Tags**: Utilize tags to run only specific parts of the role when necessary, reducing execution time and avoiding unnecessary changes.
2. **Customize Variables**: Adjust variables in your playbook to match your environment's requirements without modifying the role itself.
3. **Test Changes**: Use Molecule tests (if available) to ensure that changes do not break existing functionality.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure you have Molecule installed along with any required dependencies for your testing environment.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux/defaults/main.yml)
- [tasks/disable-systemd-tmpmount.yml](../../roles/bootstrap_linux/tasks/disable-systemd-tmpmount.yml)
- [tasks/main.yml](../../roles/bootstrap_linux/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_linux/handlers/main.yml)