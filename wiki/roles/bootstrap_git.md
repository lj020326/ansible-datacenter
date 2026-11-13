---
title: "Bootstrap Git Role"
role: bootstrap_git
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_git]
---

# Bootstrap Git Role Documentation

## Purpose

The `bootstrap_git` role is designed to ensure that Git is installed on a system, either from the package manager or by building it from source. This role provides flexibility in specifying the version of Git to be installed and supports various operating systems, including RedHat-based and Debian-based distributions.

## Variables

| Variable Name                      | Default Value            | Description                                                                 |
|------------------------------------|--------------------------|-----------------------------------------------------------------------------|
| `bootstrap_git__workspace`         | `/root`                  | The workspace directory for downloading and building Git from source.       |
| `bootstrap_git__enablerepo`        | `""`                     | Repository to enable for installing Git packages.                          |
| `bootstrap_git__packages`          | `["git"]`                | List of packages to install.                                                |
| `bootstrap_git__install_from_source` | `false`                 | Boolean to determine if Git should be installed from source.               |
| `bootstrap_git__install_path`      | `/usr`                   | Installation path for Git when installed from source.                      |
| `bootstrap_git__version`           | `2.34.1`                 | Version of Git to install.                                                   |
| `bootstrap_git__force_update`      | `false`                  | Boolean to force update of Git even if the correct version is already installed. |
| `bootstrap_git__reinstall_from_source` | `false` | Boolean to force reinstallation of Git from source.                        |

## Usage

To use this role, include it in your playbook and configure the variables as needed. Here is an example playbook:

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_git
      vars:
        bootstrap_git__install_from_source: true
        bootstrap_git__version: "2.35.1"
```

## Dependencies

This role does not have any external dependencies on other Ansible roles. It relies on the system's package manager for installing Git or the source code from the official Git repository.

## Best Practices

- Use the `bootstrap_git__install_from_source` variable to control whether Git should be installed from the package manager or from source. Use source installation when you need a specific version that is not available in the package manager.
- Specify the desired version of Git using the `bootstrap_git__version` variable.
- Use the `bootstrap_git__force_update` variable to ensure that Git is updated even if the correct version is already installed.
- Ensure that the `bootstrap_git__workspace` directory has sufficient permissions for downloading and building Git from source.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_git/defaults/main.yml)
- [tasks/install-from-source.yml](../../roles/bootstrap_git/tasks/install-from-source.yml)
- [tasks/main.yml](../../roles/bootstrap_git/tasks/main.yml)