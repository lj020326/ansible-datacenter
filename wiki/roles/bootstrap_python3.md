---
title: "Bootstrap Python3 Role"
role: roles/bootstrap_python3
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_python3]
---

# Role Documentation: `bootstrap_python3`

## Overview

The `bootstrap_python3` role is designed to install a specific version of Python (defaulting to 3.10.13) from source on target systems. It also handles the installation and configuration of pip, ensuring that the system has a functional Python environment with essential tools like pip and virtualenv.

## Role Variables

### Default Variables

All default variables are defined in `defaults/main.yml`. These can be overridden by playbook-specific variables or group/host variables as needed.

| Variable Name                             | Description                                                                 | Default Value                                      |
|-------------------------------------------|-----------------------------------------------------------------------------|----------------------------------------------------|
| `bootstrap_python__install_base_dir`      | The base directory where Python will be installed.                          | `/usr/local`                                       |
| `bootstrap_python__setup_symlinks`        | Whether to create symbolic links for the installed Python and pip binaries. | `false`                                            |
| `bootstrap_python__release`               | The specific version of Python to install.                                  | `3.10.13`                                          |
| `__bootstrap_python__python_major_version`| Internal variable representing the major version of Python.                 | Derived from `bootstrap_python__release`           |
| `__bootstrap_python__install_bin_dir`     | Directory where Python binaries will be installed.                          | `{{ bootstrap_python__install_base_dir }}/bin`       |
| `__bootstrap_python__python_bin_path`     | Full path to the Python binary.                                             | `{{ __bootstrap_python__install_bin_dir }}/python{{ __bootstrap_python__release }}` |
| `bootstrap_python__source_dir`            | Directory where the Python source code will be downloaded and extracted.  | `/var/lib/src`                                     |
| `bootstrap_python__package_source_base_url`| Base URL for downloading the Python source package.                       | `https://www.python.org/ftp/python`                |
| `__bootstrap_python__source_package_url`  | Full URL to the Python source package.                                      | Derived from `bootstrap_python__package_source_base_url` and `bootstrap_python__release` |
| `__bootstrap_python__source_dir`          | Directory where the Python source code will be extracted.                   | `{{ bootstrap_python__source_dir }}/Python-{{ bootstrap_python__release }}` |

### Internal Variables

Variables prefixed with double underscores (`__`) are internal to this role and should not be overridden by users.

## Tasks Overview

The tasks in this role are organized into several key steps:

1. **Display Python Release Version**
   - Logs the version of Python that will be installed.

2. **Set Distribution Specific Variables**
   - Includes distribution-specific variables from files like `default.yml`, `<distribution>.yml`, or `<os_family>.yml`.

3. **Install Required Packages**
   - Installs packages required to build Python from source, as specified in the distribution-specific variable file.

4. **Check for Existing Python Installation**
   - Checks if the specified version of Python is already installed by verifying the existence of the binary at `__bootstrap_python__python_bin_path`.

5. **Check Current Python Version**
   - If no specific version of Python is found, checks the current system Python version to avoid reinstalling.

6. **Check for Existing Source Directory**
   - Checks if the source directory already exists to prevent unnecessary downloads and extractions.

7. **Unarchive Source Code**
   - Downloads and extracts the Python source code from the specified URL if it does not already exist.

8. **Build and Install Python**
   - Configures, builds, and installs Python using `make` commands with optimizations enabled.

9. **Check for Existing Pip Installation**
   - Checks if pip is installed by verifying the existence of the pip binary at `/usr/local/bin/pip{{ __bootstrap_python__python_major_version }}`.

10. **Install Pip**
    - If pip is not found, downloads `get-pip.py` and installs pip using the newly installed Python version.

11. **Create Symbolic Links**
    - Creates symbolic links for the Python and pip binaries if `bootstrap_python__setup_symlinks` is set to `true`.

12. **Install Virtualenv**
    - Installs virtualenv using pip, ensuring that a tool for creating isolated Python environments is available.

## Example Playbook

Here's an example playbook demonstrating how to use this role:

```yaml
---
- name: Bootstrap Python 3.10.13 on target hosts
  hosts: all
  become: yes
  roles:
    - role: bootstrap_python3
      vars:
        bootstrap_python__release: "3.10.13"
        bootstrap_python__setup_symlinks: true
```

## Notes

- **Double-underscore variables** are internal to the role and should not be overridden.
- The role does not invent related roles; all necessary tasks are included within this single role.
- Ensure that the target hosts have network access to download Python source packages and pip.

This documentation provides a comprehensive overview of the `bootstrap_python3` role, including its variables, tasks, and usage.