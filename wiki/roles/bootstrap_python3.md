---
title: "Bootstrap Python3 Role"
role: bootstrap_python3
category: System
type: Role
tags: [ansible, role, bootstrap_python3]
---

# Bootstrap Python 3 Role

This Ansible role installs Python 3 on a system, ensuring that the specified version is available. It handles downloading, building, and installing Python from source, as well as setting up pip and virtualenv. The role is designed to be flexible and can be configured to create symbolic links to the installed Python and pip binaries.

## Variables

| Variable Name                          | Default Value                           | Description                                                                 |
|----------------------------------------|-----------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_python_install_base_dir`    | `/usr/local`                            | Base directory where Python will be installed.                               |
| `bootstrap_python_setup_symlinks`      | `false`                                 | Whether to create symbolic links to the installed Python and pip binaries.   |
| `bootstrap_python_release`             | `3.10.13`                               | The specific version of Python to install.                                   |
| `bootstrap_python_source_dir`          | `/var/lib/src`                          | Directory where the source code will be downloaded and extracted.            |
| `bootstrap_python_package_source_base_url` | `https://www.python.org/ftp/python` | Base URL for downloading Python source packages.                            |

## Usage

To use this role, include it in your playbook and configure the variables as needed:

```yaml
- hosts: all
  roles:
    - role: bootstrap_python3
      vars:
        bootstrap_python_release: "3.10.13"
        bootstrap_python_setup_symlinks: true
```

## Dependencies

This role does not have any external dependencies. It relies on standard Ansible modules and system packages.

## Best Practices

- Ensure that the system has the necessary build tools and libraries installed before running this role. Commonly needed packages include `build-essential`, `libssl-dev`, `zlib1g-dev`, `libncurses5-dev`, `libncursesw5-dev`, `xz-utils`, `tk-dev`, `libffi-dev`, and `liblzma-dev` on Debian-based systems.
- Test the role in a development environment before deploying it to production.
- Use the `bootstrap_python_setup_symlinks` variable to create symbolic links to the installed Python and pip binaries, which can simplify the management of Python versions on the system.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_python3/defaults/main.yml)
- [tasks/install-pip.yml](../../roles/bootstrap_python3/tasks/install-pip.yml)
- [tasks/main.yml](../../roles/bootstrap_python3/tasks/main.yml)