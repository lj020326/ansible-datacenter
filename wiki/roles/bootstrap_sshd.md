---
title: "Ansible Role Documentation"
role: bootstrap_sshd
category: System Configuration
type: Role
tags: networking, system, ssh, openssh, sshd, server

---

## Summary

The `bootstrap_sshd` Ansible role is designed to configure the OpenSSH SSH daemon (`sshd`) on various operating systems. It handles package installation, configuration file management, service management, and optional firewall and SELinux configurations. This role provides flexibility in customizing the SSH daemon settings while ensuring best practices for security and system integrity.

## Variables

Below are the user-configurable variables along with their default values and descriptions:

| Variable Name                                      | Default Value                                                                                          | Description                                                                                                                                                                                                 |
|----------------------------------------------------|--------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_sshd__enable`                           | `true`                                                                                                 | Enable or disable the role execution.                                                                                                                                                                       |
| `bootstrap_sshd__skip_defaults`                    | `false`                                                                                                | Skip applying default configurations if set to true.                                                                                                                                                        |
| `bootstrap_sshd__manage_service`                   | `true`                                                                                                 | Manage the SSH service (start, stop, enable, disable).                                                                                                                                                    |
| `bootstrap_sshd__allow_reload`                     | `true`                                                                                                 | Allow reloading the SSH service after configuration changes.                                                                                                                                                |
| `bootstrap_sshd__install_service`                  | `false`                                                                                                | Install custom systemd service files for SSHD.                                                                                                                                                              |
| `bootstrap_sshd__service_template_service`         | `sshd.service.j2`                                                                                    | Template file for the main SSHD service unit.                                                                                                                                                               |
| `bootstrap_sshd__service_template_at_service`      | `sshd@.service.j2`                                                                                   | Template file for instanced SSHD service units.                                                                                                                                                             |
| `bootstrap_sshd__service_template_socket`          | `sshd.socket.j2`                                                                                     | Template file for the SSHD socket unit.                                                                                                                                                                     |
| `bootstrap_sshd__backup`                           | `true`                                                                                                 | Backup existing configuration files before making changes.                                                                                                                                                    |
| `bootstrap_sshd__sysconfig`                        | `false`                                                                                                | Manage `/etc/sysconfig/sshd` on RedHat-based systems.                                                                                                                                                       |
| `bootstrap_sshd__sysconfig_override_crypto_policy` | `false`                                                                                                | Override the crypto policy in `/etc/sysconfig/sshd`.                                                                                                                                                    |
| `bootstrap_sshd__sysconfig_use_strong_rng`         | `0`                                                                                                    | Use strong random number generator in `/etc/sysconfig/sshd`.                                                                                                                                              |
| `bootstrap_sshd__config`                           | `{}`                                                                                                   | Custom SSHD configuration settings.                                                                                                                                                                         |
| `bootstrap_sshd__config_file`                      | `"{{ __bootstrap_sshd__config_file }}"`                                                                | Path to the main SSHD configuration file.                                                                                                                                                                   |
| `bootstrap_sshd__trusted_user_ca_keys_list`        | `[]`                                                                                                   | List of trusted user CA keys.                                                                                                                                                                               |
| `bootstrap_sshd__principals`                       | `{}`                                                                                                   | Dictionary of authorized principals for users.                                                                                                                                                              |
| `bootstrap_sshd__packages`                         | `"{{ __bootstrap_sshd__packages }}"`                                                                   | List of packages to install for SSHD.                                                                                                                                                                       |
| `bootstrap_sshd__config_owner`                     | `"{{ __bootstrap_sshd__config_owner }}"`                                                               | Owner of the SSHD configuration file.                                                                                                                                                                       |
| `bootstrap_sshd__config_group`                     | `"{{ __bootstrap_sshd__config_group }}"`                                                               | Group owner of the SSHD configuration file.                                                                                                                                                                 |
| `bootstrap_sshd__config_mode`                      | `"0644"`                                                                                               | Permissions mode for the SSHD configuration file.                                                                                                                                                           |
| `bootstrap_sshd__binary`                           | `"{{ __bootstrap_sshd__binary }}"`                                                                     | Path to the SSHD binary.                                                                                                                                                                                    |
| `bootstrap_sshd__service`                          | `"{{ __bootstrap_sshd__service }}"`                                                                    | Name of the SSHD service.                                                                                                                                                                                   |
| `bootstrap_sshd__sftp_server`                      | `"{{ __bootstrap_sshd__sftp_server }}"`                                                                | Path to the SFTP server binary.                                                                                                                                                                             |
| `bootstrap_sshd__drop_in_dir_mode`                 | `"{{ __bootstrap_sshd__drop_in_dir_mode }}"`                                                           | Permissions mode for the drop-in configuration directory.                                                                                                                                                   |
| `bootstrap_sshd__main_config_file`                 | `"{{ __bootstrap_sshd__main_config_file }}"`                                                           | Path to the main SSHD configuration file (used for drop-in configurations).                                                                                                                               |
| `bootstrap_sshd__trustedusercakeys_directory_owner`| `"{{ __bootstrap_sshd__trustedusercakeys_directory_owner }}"`                                          | Owner of the directory containing trusted user CA keys.                                                                                                                                                     |
| `bootstrap_sshd__trustedusercakeys_directory_group`| `"{{ __bootstrap_sshd__trustedusercakeys_directory_group }}"`                                        | Group owner of the directory containing trusted user CA keys.                                                                                                                                             |
| `bootstrap_sshd__trustedusercakeys_directory_mode` | `"{{ __bootstrap_sshd__trustedusercakeys_directory_mode }}"`                                           | Permissions mode for the directory containing trusted user CA keys.                                                                                                                                         |
| `bootstrap_sshd__trustedusercakeys_file_owner`     | `"{{ __bootstrap_sshd__trustedusercakeys_file_owner }}"`                                               | Owner of the trusted user CA key files.                                                                                                                                                                     |
| `bootstrap_sshd__trustedusercakeys_file_group`     | `"{{ __bootstrap_sshd__trustedusercakeys_file_group }}"`                                               | Group owner of the trusted user CA key files.                                                                                                                                                               |
| `bootstrap_sshd__trustedusercakeys_file_mode`      | `"{{ __bootstrap_sshd__trustedusercakeys_file_mode }}"`                                                | Permissions mode for the trusted user CA key files.                                                                                                                                                         |
| `bootstrap_sshd__authorizedprincipals_directory_owner` | `"{{ __bootstrap_sshd__authorizedprincipals_directory_owner }}"`                                   | Owner of the directory containing authorized principals files.                                                                                                                                                |
| `bootstrap_sshd__authorizedprincipals_directory_group` | `"{{ __bootstrap_sshd__authorizedprincipals_directory_group }}"`                                 | Group owner of the directory containing authorized principals files.                                                                                                                                          |
| `bootstrap_sshd__authorizedprincipals_directory_mode`  | `"{{ __bootstrap_sshd__authorizedprincipals_directory_mode }}"`                                    | Permissions mode for the directory containing authorized principals files.                                                                                                                                    |
| `bootstrap_sshd__authorizedprincipals_file_owner`    | `"{{ __bootstrap_sshd__authorizedprincipals_file_owner }}"`                                          | Owner of the authorized principals files.                                                                                                                                                                   |
| `bootstrap_sshd__authorizedprincipals_file_group`    | `"{{ __bootstrap_sshd__authorizedprincipals_file_group }}"`                                        | Group owner of the authorized principals files.                                                                                                                                                             |
| `bootstrap_sshd__authorizedprincipals_file_mode`     | `"{{ __bootstrap_sshd__authorizedprincipals_file_mode }}"`                                           | Permissions mode for the authorized principals files.                                                                                                                                                       |
| `bootstrap_sshd__verify_hostkeys`                  | `auto`                                                                                                 | Verify host keys during installation (can be set to `true`, `false`, or `auto`).                                                                                                                           |
| `bootstrap_sshd__hostkey_owner`                    | `"{{ __bootstrap_sshd__hostkey_owner }}"`                                                              | Owner of the SSHD host key files.                                                                                                                                                                           |
| `bootstrap_sshd__hostkey_group`                    | `"{{ __bootstrap_sshd__hostkey_group }}"`                                                              | Group owner of the SSHD host key files.                                                                                                                                                                     |
| `bootstrap_sshd__hostkey_mode`                     | `"0640"`                                                                                               | Permissions mode for the SSHD host key files.                                                                                                                                                               |
| `bootstrap_sshd__config_namespace`                 | `{}`                                                                                                   | Namespace for configuration snippets.                                                                                                                                                                       |
| `bootstrap_sshd__manage_firewall`                  | `false`                                                                                                | Manage firewall rules to allow SSH traffic on specified ports.                                                                                                                                            |
| `bootstrap_sshd__manage_selinux`                   | `false`                                                                                                | Manage SELinux policies to allow SSH traffic on specified ports.                                                                                                                                          |

## Usage

To use the `bootstrap_sshd` role, include it in your playbook and define any necessary variables as needed:

```yaml
- hosts: all
  roles:
    - role: dettonville.bootstrap_sshd
      vars:
        bootstrap_sshd__config:
          Port: 2222
          PasswordAuthentication: no
```

This example configures SSHD to listen on port 2222 and disables password authentication.

## Dependencies

The `bootstrap_sshd` role depends on the following collections:

- `ansible.posix`
- `fedora.linux_system_roles`

Ensure these collections are installed in your Ansible environment:

```bash
ansible-galaxy collection install ansible.posix fedora.linux_system_roles
```

## Best Practices

1. **Backup Configuration Files**: Always enable backups (`bootstrap_sshd__backup: true`) to prevent data loss.
2. **Customize Configurations**: Use the `bootstrap_sshd__config` variable to customize SSHD settings according to your security policies.
3. **Manage Services**: Ensure that service management is enabled (`bootstrap_sshd__manage_service: true`) to maintain the SSH daemon's state across reboots.
4. **Firewall and SELinux**: Enable firewall and SELinux management if required (`bootstrap_sshd__manage_firewall: true` and `bootstrap_sshd__manage_selinux: true`) to secure your SSH access.

## Molecule Tests

This role includes Molecule tests to verify its functionality across different operating systems. To run the tests, ensure you have Molecule installed and execute:

```bash
molecule test
```

Refer to the [Molecule documentation](https://molecule.readthedocs.io/en/latest/) for more details on running and configuring tests.

## Backlinks

- **defaults/main.yml**: [../../roles/bootstrap_sshd/defaults/main.yml](../../roles/bootstrap_sshd/defaults/main.yml)
- **tasks/certificates.yml**: [../../roles/bootstrap_sshd/tasks/certificates.yml](../../roles/bootstrap_sshd/tasks/certificates.yml)
- **tasks/check_fips.yml**: [../../roles/bootstrap_sshd/tasks/check_fips.yml](../../roles/bootstrap_sshd/tasks/check_fips.yml)
- **tasks/find_ports.yml**: [../../roles/bootstrap_sshd/tasks/find_ports.yml](../../roles/bootstrap_sshd/tasks/find_ports.yml)
- **tasks/firewall.yml**: [../../roles/bootstrap_sshd/tasks/firewall.yml](../../roles/bootstrap_sshd/tasks/firewall.yml)
- **tasks/install.yml**: [../../roles/bootstrap_sshd/tasks/install.yml](../../roles/bootstrap_sshd/tasks/install.yml)
- **tasks/install_config.yml**: [../../roles/bootstrap_sshd/tasks/install_config.yml](../../roles/bootstrap_sshd/tasks/install_config.yml)
- **tasks/install_namespace.yml**: [../../roles/bootstrap_sshd/tasks/install_namespace.yml](../../roles/bootstrap_sshd/tasks/install_namespace.yml)
- **tasks/install_service.yml**: [../../roles/bootstrap_sshd/tasks/install_service.yml](../../roles/bootstrap_sshd/tasks/install_service.yml)
- **tasks/main.yml**: [../../roles/bootstrap_sshd/tasks/main.yml](../../roles/bootstrap_sshd/tasks/main.yml)
- **tasks/selinux.yml**: [../../roles/bootstrap_sshd/tasks/selinux.yml](../../roles/bootstrap_sshd/tasks/selinux.yml)
- **tasks/sshd.yml**: [../../roles/bootstrap_sshd/tasks/sshd.yml](../../roles/bootstrap_sshd/tasks/sshd.yml)
- **tasks/variables.yml**: [../../roles/bootstrap_sshd/tasks/variables.yml](../../roles/bootstrap_sshd/tasks/variables.yml)
- **meta/collection-requirements.yml**: [../../roles/bootstrap_sshd/meta/collection-requirements.yml](../../roles/bootstrap_sshd/meta/collection-requirements.yml)
- **meta/main.yml**: [../../roles/bootstrap_sshd/meta/main.yml](../../roles/bootstrap_sshd/meta/main.yml)
- **meta/runtime.yml**: [../../roles/bootstrap_sshd/meta/runtime.yml](../../roles/bootstrap_sshd/meta/runtime.yml)
- **handlers/main.yml**: [../../roles/bootstrap_sshd/handlers/main.yml](../../roles/bootstrap_sshd/handlers/main.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_sshd` Ansible role, including its purpose, configuration options, usage instructions, and best practices. For further details or troubleshooting, refer to the linked source files and Molecule tests.