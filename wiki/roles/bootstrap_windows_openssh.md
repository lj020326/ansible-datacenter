---
title: "Bootstrap Windows OpenSSH Role"
role: roles/bootstrap_windows_openssh
category: Windows
type: Role
tags: [ansible, role, bootstrap_windows_openssh]
---

# Bootstrap Windows OpenSSH Role

This Ansible role installs and configures the Win32-OpenSSH server on Windows systems. It handles downloading, extracting, installing, and configuring OpenSSH, including setting up the necessary services and firewall rules.

## Variables

| Variable Name                     | Default Value                       | Description                                                                 |
|-----------------------------------|-------------------------------------|-----------------------------------------------------------------------------|
| `opt_openssh_architecture`        | `64`                                | Architecture of the OpenSSH installation (32 or 64).                        |
| `opt_openssh_firewall_profiles`   | `domain,private`                    | Firewall profiles to apply the inbound rule to.                             |
| `opt_openssh_install_path`        | `C:\Program Files\OpenSSH`          | Path where OpenSSH will be installed.                                       |
| `opt_openssh_port`                | `22`                                | Port number for SSH connections.                                             |
| `opt_openssh_pubkey_auth`         | `true`                              | Enable or disable public key authentication.                                |
| `opt_openssh_password_auth`       | `true`                              | Enable or disable password authentication.                                  |
| `opt_openssh_setup_service`       | `true`                              | Whether to set up the OpenSSH service.                                      |
| `opt_openssh_shared_admin_key`    | `false`                             | Whether to use a shared admin key.                                          |
| `opt_openssh_skip_start`          | `false`                             | Whether to skip starting the OpenSSH service after installation.            |
| `opt_openssh_temp_path`           | `C:\Windows\TEMP`                   | Temporary path for downloading and extracting OpenSSH.                      |
| `opt_openssh_version`             | `latest`                            | Version of OpenSSH to install.                                              |
| `opt_openssh_zip_remote_src`      | `false`                             | Whether the OpenSSH zip file is located on the Ansible controller.          |

## Usage

To use this role, include it in your playbook and set the desired variables:

```yaml
- hosts: windows
  roles:
    - role: bootstrap_windows_openssh
      vars:
        opt_openssh_port: 2222
        opt_openssh_pubkey_auth: true
        opt_openssh_password_auth: false
```

## Dependencies

This role does not have any external dependencies. It uses standard Ansible modules for Windows.

## Best Practices

- Ensure that the target Windows systems have internet access if downloading the latest OpenSSH version.
- Verify that the specified installation path has the necessary permissions.
- Test the role in a development environment before applying it to production systems.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_windows_openssh/defaults/main.yml)
- [tasks/download.yml](../../roles/bootstrap_windows_openssh/tasks/download.yml)
- [tasks/main.yml](../../roles/bootstrap_windows_openssh/tasks/main.yml)
- [tasks/pubkeys.yml](../../roles/bootstrap_windows_openssh/tasks/pubkeys.yml)
- [tasks/service.yml](../../roles/bootstrap_windows_openssh/tasks/service.yml)
- [tasks/sshd_config.yml](../../roles/bootstrap_windows_openssh/tasks/sshd_config.yml)
- [handlers/main.yml](../../roles/bootstrap_windows_openssh/handlers/main.yml)