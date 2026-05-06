---
title: Bootstrap Ansible Role Documentation
role: bootstrap_ansible
category: System Configuration
type: Role
tags: ansible, installation, setup
---

## Summary

The `bootstrap_ansible` role is designed to automate the installation of Ansible on various Linux distributions. It supports both package-based installations (via system package managers) and pip-based installations. The role dynamically selects the appropriate method based on the target operating system.

## Variables

| Variable Name                        | Default Value                 | Description                                                                 |
|--------------------------------------|-------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_ansible__default_release` | `""`                          | Specifies the default release for package installation, used primarily for Debian-based systems. |
| `bootstrap_ansible__install_method`  | `"package"`                   | Determines the method of Ansible installation (`package` or `pip`).         |
| `bootstrap_ansible__install_version_pip` | `""`                        | Specifies the version of Ansible to install when using pip.                 |
| `bootstrap_ansible__install_pip_extra_args` | `""`                      | Additional arguments to pass to pip during installation.                    |

## Usage

To use this role, include it in your playbook and specify the desired installation method. Here are some examples:

### Package Installation (Default)

```yaml
- hosts: all
  roles:
    - role: bootstrap_ansible
```

### Pip Installation with Specific Version

```yaml
- hosts: all
  roles:
    - role: bootstrap_ansible
      vars:
        bootstrap_ansible__install_method: "pip"
        bootstrap_ansible__install_version_pip: "5.0.0"
```

## Dependencies

This role does not have any external dependencies other than the system package manager or pip, depending on the installation method.

## Tags

No specific tags are defined in this role. However, you can use the default Ansible tags like `always`, `never`, etc., to control task execution.

## Best Practices

- Ensure that your target systems have the necessary permissions and network access to install packages or download from PyPI.
- For pip installations, consider using a virtual environment to avoid conflicts with system Python packages.
- Always test changes in a non-production environment before applying them to production systems.

## Molecule Tests

This role does not include any Molecule tests. However, it is recommended to write and run tests to ensure the role behaves as expected across different distributions and versions.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ansible/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_ansible/tasks/main.yml)
- [tasks/setup-Debian.yml](../../roles/bootstrap_ansible/tasks/setup-Debian.yml)
- [tasks/setup-Fedora.yml](../../roles/bootstrap_ansible/tasks/setup-Fedora.yml)
- [tasks/setup-RedHat.yml](../../roles/bootstrap_ansible/tasks/setup-RedHat.yml)
- [tasks/setup-Ubuntu.yml](../../roles/bootstrap_ansible/tasks/setup-Ubuntu.yml)
- [tasks/setup-pip.yml](../../roles/bootstrap_ansible/tasks/setup-pip.yml)