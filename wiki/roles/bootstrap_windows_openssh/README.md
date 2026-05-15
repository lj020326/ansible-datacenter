```markdown
---
title: Ansible Role win_openssh
original_path: roles/bootstrap_windows_openssh/README.md
category: Ansible Roles
tags: [Ansible, Windows, OpenSSH, Automation]
---

# Ansible Role: win_openssh

Installs [Win32-OpenSSH](https://github.com/PowerShell/Win32-OpenSSH) on a Windows host.

**Note:** This role has been tested on Win32-OpenSSH v7.7.2.0p1-Beta. Newer versions should work, but this is not guaranteed.

With the default settings, this role will:

- Install `Win32-OpenSSH` to `C:\Program Files\OpenSSH` based on the latest release available on GitHub.
- Set up the `sshd` and `ssh-agent` services and configure them to start automatically.
- Create a firewall rule that allows inbound traffic on port `22` for the `domain` and `private` network profiles.
- Configure the `sshd_config` file to allow public key and password authentication.

Additional configurations can be set using optional variables:

- Specify a specific version to download from GitHub or another URL pointing to the zip file.
- Define the installation path for the binaries.
- Control whether to set up the SSH server services.
- Control whether to configure the SSH services to start automatically.
- Define the firewall profiles that allow inbound SSH traffic.
- Specify the port and other selected `sshd_config` values.
- Add public key(s) to the current user's profile.

## Requirements

- Windows Server 2008 R2+

## Variables

### Mandatory Variables

No mandatory variables are required. The role will run with default options set.

### Optional Variables

| Variable                          | Description                                                                                           | Default Value                      |
|-----------------------------------|-------------------------------------------------------------------------------------------------------|--------------------------------------|
| `opt_openssh_architecture`        | The Windows architecture, must be set to either `32` or `64`.                                         | `64`                               |
| `opt_openssh_firewall_profiles`   | The firewall profiles to allow inbound SSH traffic.                                                   | `domain,private`                   |
| `opt_openssh_install_path`        | The directory to install the OpenSSH binaries.                                                        | `C:\Program Files\OpenSSH`         |
| `opt_openssh_pubkeys`             | Either a string or list of strings to add to the user's `authorized_keys` file.                       | None                               |
| `opt_openssh_setup_service`       | Whether to install the sshd service components or just stick with the client executables.           | `True`                             |
| `opt_openssh_skip_start`          | Will not start the `sshd` and `ssh-agent` services and also not set them to `auto start`.             | `False`                            |
| `opt_openssh_temp_path`           | The temporary directory to download the zip file and extracted files.                                 | `C:\Windows\TEMP`                  |
| `opt_openssh_url`                 | Sets the download location of the OpenSSH zip, if omitted then this will be sourced from GitHub.     | Latest release on GitHub           |
| `opt_openssh_version`             | Sets a specific version to download from GitHub, valid only when `opt_openssh_url` is not set.       | `latest`                           |
| `opt_openssh_zip_file`            | The path to an OpenSSH zip release file that will be used to install OpenSSH.                         | None                               |
| `opt_openssh_zip_remote_src`      | Controls whether the path in `opt_openssh_zip_file` is local to the controller or Windows host.       | `False`                            |

You can also customize the following `sshd_config` values:

| Variable                          | Description                                                                                           | Default Value                      |
|-----------------------------------|-------------------------------------------------------------------------------------------------------|--------------------------------------|
| `opt_openssh_port`                | Aligns to `Port`, the port the SSH service will listen on.                                          | `22`                               |
| `opt_openssh_pubkey_auth`         | Aligns to `PubkeyAuthentication`, whether the SSH service will allow authentication with SSH keys.  | `True`                             |
| `opt_openssh_password_auth`       | Aligns to `PasswordAuthentication`, whether the SSH service will allow authentication with passwords.| `True`                             |
| `opt_openssh_shared_admin_key`    | Set to `True` to have Administrators use a shared authorization key at `__PROGRAMDATA__/ssh/administrators_authorized_keys`. Set to `False` for individual user keys. | `False`                            |

You can customize the shell options to control how the sshd service starts a new shell:

| Variable                          | Description                                                                                           | Default Value                      |
|-----------------------------------|-------------------------------------------------------------------------------------------------------|--------------------------------------|
| `opt_openssh_default_shell`       | Override the default shell set by the OpenSSH install. This should be the absolute path to an executable you want to run when starting an SSH session. | None                               |
| `opt_openssh_default_shell_command_option` | Set the arguments used when invoking the shell, this should not be adjusted in normal circumstances. | None                               |
| `opt_openssh_default_shell_escape_args`  | Skip the automatic escaping of arguments when invoking the shell.                             | None                               |
| `opt_openssh_powershell_subsystem` | Set subsystem for PowerShell remoting, needs to be a 8.3 path like: `C:\PROGRA~1\POWERS~1\7\pwsh.exe`. | `undefined`                        |

### Output Variables

None

## Role Dependencies

None

## Example Playbook

```yaml
- name: Install Win32-OpenSSH with the defaults
  hosts: windows
  gather_facts: no
  roles:
    - jborean93.win_openssh

- name: Install specific version of Win32-OpenSSH to custom folder
  hosts: windows
  gather_facts: no
  roles:
    - role: jborean93.win_openssh
      opt_openssh_install_path: C:\OpenSSH
      opt_openssh_version: v7.7.2.0p1-Beta

- name: Only install client components of Win32-OpenSSH
  hosts: windows
  gather_facts: no
  roles:
    - role: jborean93.win_openssh
      opt_openssh_setup_service: False
```

## Testing

To test this role, navigate to the [tests](tests) folder and run `vagrant up`. This will spin up a Windows Server 2019 host to test the role against. If the host is already online, running `vagrant provision` will rerun the tests.

## Backlog

None - feature requests are welcome

## Backlinks

- [Ansible Roles](/ansible-roles)
```

This improved version of the documentation page adheres to clean and professional Markdown standards suitable for GitHub rendering. It includes a structured format with clear headings, tables for variable descriptions, and additional metadata in the frontmatter.