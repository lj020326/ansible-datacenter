---
title: Bootstrap Git Role Documentation
role: bootstrap_git
category: Ansible Roles
type: Configuration Management
tags: git, installation, source, ansible
---

## Summary

The `bootstrap_git` role is designed to ensure that the specified version of Git is installed on target systems. It supports both package-based installations and building from source, providing flexibility depending on the user's requirements.

## Variables

| Variable Name                         | Default Value                          | Description                                                                 |
|---------------------------------------|----------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_git__workspace`            | `/root`                                | The directory where Git will be downloaded and built if installing from source. |
| `bootstrap_git__enablerepo`           | `""`                                   | Repository to enable for package installation on RedHat-based systems.      |
| `bootstrap_git__packages`             | `- git`                                | List of packages to install via the system's package manager.               |
| `bootstrap_git__install_from_source`  | `false`                                | Boolean flag indicating whether Git should be installed from source.        |
| `bootstrap_git__install_path`         | `/usr`                                 | The installation path for Git if built from source.                         |
| `bootstrap_git__version`              | `2.34.1`                               | The version of Git to install.                                              |
| `bootstrap_git__force_update`         | `false`                                | Boolean flag indicating whether to force an update even if the correct version is installed. |
| `bootstrap_git__reinstall_from_source`| `false`                                | Boolean flag indicating whether to reinstall Git from source, regardless of the current installation status. |

## Usage

To use this role, include it in your playbook and optionally override any default variables as needed.

### Example Playbook

```yaml
- hosts: all
  roles:
    - role: bootstrap_git
      vars:
        bootstrap_git__install_from_source: true
        bootstrap_git__version: 2.35.0
```

## Dependencies

This role does not have any external dependencies, but it relies on the system's package manager and tools like `make` if installing from source.

## Tags

- `git-install`: Installs Git using the system's package manager.
- `git-source-install`: Builds and installs Git from source.

## Best Practices

- Ensure that the target systems have the necessary build tools installed if you plan to install Git from source.
- Use the `bootstrap_git__force_update` variable with caution, as it will reinstall Git even if the correct version is already installed.
- Specify a valid repository in `bootstrap_git__enablerepo` if required for your environment.

## Molecule Tests

This role does not include Molecule tests. However, you can create test scenarios to validate the installation process using Molecule.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_git/defaults/main.yml)
- [tasks/install-from-source.yml](../../roles/bootstrap_git/tasks/install-from-source.yml)
- [tasks/main.yml](../../roles/bootstrap_git/tasks/main.yml)