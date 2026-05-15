---
title: "Ansible Role Documentation"
role: bootstrap_sshd
category: System Configuration
type: Role
tags: networking system ssh openssh sshd server ubuntu debian centos redhat fedora freebsd openbsd aix el6 el7 el8 el9 el10
---

## Summary

The `bootstrap_sshd` Ansible role is designed to configure and manage the OpenSSH SSH daemon (sshd) on various operating systems. It handles package installation, configuration file management, service management, firewall rules, SELinux policies, and more. This role ensures that the SSH server is properly set up with customizable options for security, performance, and functionality.

## Variables

| Variable Name                                      | Default Value                                                                                       | Description                                                                                                                                                                                                 |
|----------------------------------------------------|-----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_sshd__enable`                           | `true`                                                                                            | Enable or disable the execution of this role.                                                                                                                                                               |
| `bootstrap_sshd__skip_defaults`                    | `false`                                                                                           | Skip applying default configurations if set to true.                                                                                                                                                        |
| `bootstrap_sshd__manage_service`                   | `true`                                                                                            | Manage the SSH service (start, stop, enable, disable).                                                                                                                                                    |
| `bootstrap_sshd__allow_reload`                     | `true`                                                                                            | Allow reloading of the SSH service when configuration changes are made.                                                                                                                                     |
| `bootstrap_sshd__install_service`                  | `false`                                                                                           | Install custom systemd service files for SSHD.                                                                                                                                                              |
| `bootstrap_sshd__service_template_service`         | `sshd.service.j2`                                                                                 | Template file for the main SSHD service unit.                                                                                                                                                               |
| `bootstrap_sshd__service_template_at_service`      | `sshd@.service.j2`                                                                                | Template file for the instanced SSHD service unit.                                                                                                                                                          |
| `bootstrap_sshd__service_template_socket`          | `sshd.socket.j2`                                                                                  | Template file for the SSHD socket unit.                                                                                                                                                                     |
| `bootstrap_sshd__backup`                           | `true`                                                                                            | Backup existing configuration files before making changes.                                                                                                                                                    |
| `bootstrap_sshd__sysconfig`                        | `false`                                                                                           | Manage the `/etc/sysconfig/sshd` file on RedHat-based systems.                                                                                                                                            |
| `bootstrap_sshd__sysconfig_override_crypto_policy` | `false`                                                                                           | Override the crypto policy in the sysconfig file.                                                                                                                                                         |
| `bootstrap_sshd__sysconfig_use_strong_rng`         | `0`                                                                                               | Use a strong random number generator in the sysconfig file.                                                                                                                                                 |
| `bootstrap_sshd__config`                           | `{}`                                                                                                | Custom SSHD configuration options as a dictionary.                                                                                                                                                        |
| `bootstrap_sshd__config_file`                      | `"{{ __bootstrap_sshd__config_file }}"`                                                             | Path to the main SSHD configuration file.                                                                                                                                                                   |
| `bootstrap_sshd__trusted_user_ca_keys_list`        | `[]`                                                                                                | List of trusted user CA keys.                                                                                                                                                                               |
| `bootstrap_sshd__principals`                       | `{}`                                                                                                | Dictionary of authorized principals for users.                                                                                                                                                              |
| `bootstrap_sshd__packages`                         | `"{{ __bootstrap_sshd__packages }}"`                                                                | List of packages to install for SSHD.                                                                                                                                                                       |
| `bootstrap_sshd__config_owner`                     | `"{{ __bootstrap_sshd__config_owner }}"`                                                            | Owner of the SSHD configuration file.                                                                                                                                                                       |
| `bootstrap_sshd__config_group`                     | `"{{ __bootstrap_sshd__config_group }}"`                                                            | Group owner of the SSHD configuration file.                                                                                                                                                                 |
| `bootstrap_sshd__config_mode`                      | `"0644"`                                                                                          | Permissions mode for the SSHD configuration file.                                                                                                                                                           |
| `bootstrap_sshd__binary`                           | `"{{ __bootstrap_sshd__binary }}"`                                                                  | Path to the SSHD binary.                                                                                                                                                                                    |
| `bootstrap_sshd__service`                          | `"{{ __bootstrap_sshd__service }}"`                                                                 | Name of the SSHD service.                                                                                                                                                                                   |
| `bootstrap_sshd__sftp_server`                      | `"{{ __bootstrap_sshd__sftp_server }}"`                                                             | Path to the SFTP server binary.                                                                                                                                                                             |
| `bootstrap_sshd__drop_in_dir_mode`                 | `"{{ __bootstrap_sshd__drop_in_dir_mode }}"`                                                        | Permissions mode for the drop-in configuration directory.                                                                                                                                                   |
| `bootstrap_sshd__main_config_file`                 | `"{{ __bootstrap_sshd__main_config_file }}"`                                                        | Path to the main SSHD configuration file (used for include directives).                                                                                                                                   |
| `bootstrap_sshd__trustedusercakeys_directory_owner`| `"{{ __bootstrap_sshd__trustedusercakeys_directory_owner }}"`                                     | Owner of the directory containing trusted user CA keys.                                                                                                                                                     |
| `bootstrap_sshd__trustedusercakeys_directory_group`| `"{{ __bootstrap_sshd__trustedusercakeys_directory_group }}"`                                     | Group owner of the directory containing trusted user CA keys.                                                                                                                                             |
| `bootstrap_sshd__trustedusercakeys_directory_mode` | `"{{ __bootstrap_sshd__trustedusercakeys_directory_mode }}"`                                      | Permissions mode for the directory containing trusted user CA keys.                                                                                                                                         |
| `bootstrap_sshd__trustedusercakeys_file_owner`     | `"{{ __bootstrap_sshd__trustedusercakeys_file_owner }}"`                                          | Owner of the trusted user CA key files.                                                                                                                                                                     |
| `bootstrap_sshd__trustedusercakeys_file_group`     | `"{{ __bootstrap_sshd__trustedusercakeys_file_group }}"`                                          | Group owner of the trusted user CA key files.                                                                                                                                                               |
| `bootstrap_sshd__trustedusercakeys_file_mode`      | `"{{ __bootstrap_sshd__trustedusercakeys_file_mode }}"`                                           | Permissions mode for the trusted user CA key files.                                                                                                                                                         |
| `bootstrap_sshd__authorizedprincipals_directory_owner` | `"{{ __bootstrap_sshd__authorizedprincipals_directory_owner }}"`                              | Owner of the directory containing authorized principals files.                                                                                                                                                |
| `bootstrap_sshd__authorizedprincipals_directory_group` | `"{{ __bootstrap_sshd__authorizedprincipals_directory_group }}"`                            | Group owner of the directory containing authorized principals files.                                                                                                                                          |
| `bootstrap_sshd__authorizedprincipals_directory_mode`  | `"{{ __bootstrap_sshd__authorizedprincipals_directory_mode }}"`                               | Permissions mode for the directory containing authorized principals files.                                                                                                                                    |
| `bootstrap_sshd__authorizedprincipals_file_owner`    | `"{{ __bootstrap_sshd__authorizedprincipals_file_owner }}"`                                     | Owner of the authorized principals files.                                                                                                                                                                   |
| `bootstrap_sshd__authorizedprincipals_file_group`    | `"{{ __bootstrap_sshd__authorizedprincipals_file_group }}"`                                     | Group owner of the authorized principals files.                                                                                                                                                             |
| `bootstrap_sshd__authorizedprincipals_file_mode`     | `"{{ __bootstrap_sshd__authorizedprincipals_file_mode }}"`                                      | Permissions mode for the authorized principals files.                                                                                                                                                       |
| `bootstrap_sshd__verify_hostkeys`                  | `auto`                                                                                            | Verify host keys on startup (can be `true`, `false`, or `auto`).                                                                                                                                          |
| `bootstrap_sshd__hostkey_owner`                    | `"{{ __bootstrap_sshd__hostkey_owner }}"`                                                           | Owner of the SSHD host key files.                                                                                                                                                                           |
| `bootstrap_sshd__hostkey_group`                    | `"{{ __bootstrap_sshd__hostkey_group }}"`                                                           | Group owner of the SSHD host key files.                                                                                                                                                                     |
| `bootstrap_sshd__hostkey_mode`                     | `"0640"`                                                                                          | Permissions mode for the SSHD host key files.                                                                                                                                                               |
| `bootstrap_sshd__config_namespace`                 | `{}`                                                                                                | Namespace for configuration snippets (used in `install_namespace.yml`).                                                                                                                                     |
| `bootstrap_sshd__manage_firewall`                  | `false`                                                                                           | Manage firewall rules to allow SSH traffic on specified ports.                                                                                                                                            |
| `bootstrap_sshd__manage_selinux`                   | `false`                                                                                           | Manage SELinux policies for custom SSH ports.                                                                                                                                                             |

## Usage

To use the `bootstrap_sshd` role, include it in your playbook and customize the variables as needed:

```yaml
- hosts: all
  roles:
    - role: dettonville.bootstrap_sshd
      vars:
        bootstrap_sshd__config:
          Port: 2222
          PasswordAuthentication: no
          PermitRootLogin: no
```

## Dependencies

This role depends on the following collections and roles:

- `ansible.posix`
- `fedora.linux_system_roles.firewall` (for managing firewall rules)
- `fedora.linux_system_roles.selinux` (for managing SELinux policies)

Ensure these dependencies are installed in your Ansible environment.

## Best Practices

1. **Backup Configuration Files**: Always enable the backup feature (`bootstrap_sshd__backup: true`) to prevent data loss.
2. **Customize Configurations**: Use the `bootstrap_sshd__config` dictionary to specify custom SSHD configurations.
3. **Manage Services**: Ensure that service management is enabled (`bootstrap_sshd__manage_service: true`) to automatically start and enable the SSH service.
4. **Firewall and SELinux**: If you need to open custom ports or manage SELinux policies, set `bootstrap_sshd__manage_firewall` and `bootstrap_sshd__manage_selinux` to `true`.

## Molecule Tests

This role includes Molecule tests to verify its functionality across different operating systems. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_sshd/defaults/main.yml)
- [tasks/certificates.yml](../../roles/bootstrap_sshd/tasks/certificates.yml)
- [tasks/check_fips.yml](../../roles/bootstrap_sshd/tasks/check_fips.yml)
- [tasks/find_ports.yml](../../roles/bootstrap_sshd/tasks/find_ports.yml)
- [tasks/firewall.yml](../../roles/bootstrap_sshd/tasks/firewall.yml)
- [tasks/install.yml](../../roles/bootstrap_sshd/tasks/install.yml)
- [tasks/install_config.yml](../../roles/bootstrap_sshd/tasks/install_config.yml)
- [tasks/install_namespace.yml](../../roles/bootstrap_sshd/tasks/install_namespace.yml)
- [tasks/install_service.yml](../../roles/bootstrap_sshd/tasks/install_service.yml)
- [tasks/main.yml](../../roles/bootstrap_sshd/tasks/main.yml)
- [tasks/selinux.yml](../../roles/bootstrap_sshd/tasks/selinux.yml)
- [tasks/sshd.yml](../../roles/bootstrap_sshd/tasks/sshd.yml)
- [tasks/variables.yml](../../roles/bootstrap_sshd/tasks/variables.yml)
- [meta/collection-requirements.yml](../../roles/bootstrap_sshd/meta/collection-requirements.yml)
- [meta/main.yml](../../roles/bootstrap_sshd/meta/main.yml)
- [meta/runtime.yml](../../roles/bootstrap_sshd/meta/runtime.yml)
- [handlers/main.yml](../../roles/bootstrap_sshd/handlers/main.yml)