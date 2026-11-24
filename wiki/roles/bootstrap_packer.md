---
title: "Bootstrap Packer Role"
role: bootstrap_packer
category: Provisioning
type: Role
tags: [ansible, role, bootstrap_packer]
---

# Bootstrap Packer Role

This Ansible role installs and configures Packer, a popular tool for creating identical machine images for multiple platforms from a single source configuration.

## Variables

| Variable Name                           | Default Value        | Description                                                                 |
|-----------------------------------------|---------------------|-----------------------------------------------------------------------------|
| `bootstrap_packer__version`             | `1.9.5`             | The version of Packer to install.                                           |
| `bootstrap_packer__arch`                | `amd64`             | The architecture for which to download the Packer binary.                   |
| `bootstrap_packer__bin_path`            | `/usr/local/bin`    | The directory where the Packer binary will be installed.                     |
| `bootstrap_packer__install_from_source_force_update` | `false` | Force update of Packer even if the desired version is already installed.    |
| `bootstrap_packer__reinstall_from_source` | `false` | Force reinstallation of Packer from source.                                |
| `bootstrap_packer__required_packages`   | `['unzip', 'xorriso']` | List of required packages to be installed before Packer installation.       |

## Usage

To use this role, include it in your playbook and set the desired variables. Here's an example:

```yaml
- hosts: all
  roles:
    - role: bootstrap_packer
      vars:
        bootstrap_packer__version: "1.9.5"
        bootstrap_packer__arch: "amd64"
        bootstrap_packer__bin_path: "/usr/local/bin"
        bootstrap_packer__install_from_source_force_update: false
        bootstrap_packer__reinstall_from_source: false
        bootstrap_packer__required_packages:
          - unzip
          - xorriso
```

## Dependencies

This role does not have any external dependencies. However, it requires that the target system has internet access to download the Packer binary and that the required packages (`unzip` and `xorriso`) are installed.

## Best Practices

- Use the `bootstrap_packer__install_from_source_force_update` variable to force an update of Packer if needed.
- Use the `bootstrap_packer__reinstall_from_source` variable to force reinstallation of Packer from source if necessary.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_packer/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_packer/tasks/main.yml)