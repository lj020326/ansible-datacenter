---
title: "Bootstrap Python3 Role"
role: bootstrap_python3
category: Ansible Roles
type: Installation
tags: python, pip, virtualenv, ansible-role
---

# Bootstrap Python3 Role

## Summary

The `bootstrap_python3` role is designed to install a specific version of Python (defaulting to 3.10.13) on target systems along with its package manager `pip`, and optionally sets up symbolic links for easier access. It also installs the `virtualenv` tool, which is essential for creating isolated Python environments.

## Variables

| Variable Name                         | Default Value                                 | Description                                                                 |
|---------------------------------------|-----------------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_python3__install_base_dir` | `/usr/local`                                  | The base directory where Python will be installed.                          |
| `bootstrap_python3__setup_symlinks`   | `false`                                       | Whether to create symbolic links for the installed Python and pip binaries. |
| `bootstrap_python3__release`          | `3.10.13`                                     | The specific version of Python to install.                                  |
| `bootstrap_python3__source_dir`       | `/var/lib/src`                                | Directory where the Python source code will be downloaded and extracted.  |
| `bootstrap_python3__package_source_base_url` | `https://www.python.org/ftp/python`     | Base URL for downloading the Python source package.                       |

## Usage

To use this role, include it in your playbook and optionally override any of the default variables as needed.

### Example Playbook

```yaml
- hosts: all
  roles:
    - role: bootstrap_python3
      vars:
        bootstrap_python3__release: "3.10.15"
        bootstrap_python3__setup_symlinks: true
```

## Dependencies

This role does not have any external dependencies, but it requires the target system to have basic build tools and libraries installed (e.g., `gcc`, `make`). These are typically specified in a distribution-specific variable file included by the role.

## Best Practices

- **Version Control**: Always specify the exact version of Python you want to install using the `bootstrap_python3__release` variable.
- **Symbolic Links**: Enabling symbolic links can simplify command usage but may cause conflicts if multiple versions of Python are installed. Use with caution.
- **Testing**: Before deploying this role in production, test it in a staging environment to ensure compatibility and that all required packages are correctly installed.

## Molecule Tests

This role includes Molecule tests to verify its functionality across different operating systems. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_python3/defaults/main.yml)
- [tasks/install-pip.yml](../../roles/bootstrap_python3/tasks/install-pip.yml)
- [tasks/main.yml](../../roles/bootstrap_python3/tasks/main.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_python3` role, including its purpose, configuration options, usage examples, and best practices. For further details on specific tasks or variables, refer to the linked source files.