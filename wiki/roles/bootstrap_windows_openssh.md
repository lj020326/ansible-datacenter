---
title: Bootstrap Windows OpenSSH Role Documentation
role: bootstrap_windows_openssh
category: Ansible Roles
type: Configuration Management
tags: windows, openssh, ansible

---

## Summary

The `bootstrap_windows_openssh` role is designed to automate the installation and configuration of OpenSSH on Windows systems. This includes downloading the latest version of OpenSSH, extracting it to a specified directory, setting up environment variables, configuring firewall rules, and managing SSH services.

## Variables

| Variable Name                           | Default Value                          | Description                                                                 |
|-----------------------------------------|----------------------------------------|-----------------------------------------------------------------------------|
| `role_bootstrap_windows_openssh__architecture` | `64`                                 | Specifies the architecture of OpenSSH to install (32 or 64).                |
| `role_bootstrap_windows_openssh__firewall_profiles` | `domain,private`                   | Firewall profiles to allow SSH connections.                                   |
| `role_bootstrap_windows_openssh__install_path`    | `C:\Program Files\OpenSSH`         | Installation path for OpenSSH.                                              |
| `role_bootstrap_windows_openssh__port`            | `22`                                 | Port number for SSH service.                                                |
| `role_bootstrap_windows_openssh__pubkey_auth`     | `true`                               | Enable public key authentication.                                             |
| `role_bootstrap_windows_openssh__password_auth`   | `true`                               | Enable password authentication.                                               |
| `role_bootstrap_windows_openssh__setup_service`   | `true`                               | Setup and configure SSH services (sshd, ssh-agent).                           |
| `role_bootstrap_windows_openssh__shared_admin_key`| `false`                              | Use a shared admin key for administrators.                                    |
| `role_bootstrap_windows_openssh__skip_start`      | `false`                              | Skip starting the SSH services after installation.                            |
| `role_bootstrap_windows_openssh__temp_path`       | `C:\Windows\TEMP`                  | Temporary path used during installation.                                      |
| `role_bootstrap_windows_openssh__version`         | `latest`                             | Version of OpenSSH to install (can be a specific version or 'latest').      |
| `role_bootstrap_windows_openssh__zip_remote_src`  | `false`                              | Specifies whether the zip file is sourced from a remote location.             |

## Usage

To use this role, include it in your playbook and specify any desired variables as needed:

```yaml
- hosts: windows_servers
  roles:
    - role: bootstrap_windows_openssh
      vars:
        role_bootstrap_windows_openssh__architecture: 64
        role_bootstrap_windows_openssh__port: 2222
```

## Dependencies

This role depends on the following Ansible collections:

- `ansible.windows`
- `community.windows`

Ensure these collections are installed in your environment before running this role.

```bash
ansible-galaxy collection install ansible.windows community.windows
```

## Best Practices

1. **Security**: Always ensure that public key authentication is enabled and properly configured to enhance security.
2. **Firewall Configuration**: Adjust the `role_bootstrap_windows_openssh__firewall_profiles` variable as needed based on your network environment.
3. **Version Control**: Specify a specific version of OpenSSH in `role_bootstrap_windows_openssh__version` for consistent deployments.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure that you have Docker installed on your system as it is required by Molecule for testing.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_windows_openssh/defaults/main.yml)
- [tasks/download.yml](../../roles/bootstrap_windows_openssh/tasks/download.yml)
- [tasks/main.yml](../../roles/bootstrap_windows_openssh/tasks/main.yml)
- [tasks/pubkeys.yml](../../roles/bootstrap_windows_openssh/tasks/pubkeys.yml)
- [tasks/service.yml](../../roles/bootstrap_windows_openssh/tasks/service.yml)
- [tasks/sshd_config.yml](../../roles/bootstrap_windows_openssh/tasks/sshd_config.yml)
- [handlers/main.yml](../../roles/bootstrap_windows_openssh/handlers/main.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_windows_openssh` role, including its purpose, configuration options, usage instructions, and best practices.