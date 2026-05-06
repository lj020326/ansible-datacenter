---
title: Bootstrap Packer Role Documentation
role: bootstrap_packer
category: Ansible Roles
type: Installation
tags: packer, automation, installation
---

## Summary

The `bootstrap_packer` role is designed to automate the installation of HashiCorp Packer on a target system. It ensures that the specified version of Packer is installed and handles the removal of any conflicting binaries (such as `/usr/sbin/packer`). The role also manages required packages necessary for Packer's operation.

## Variables

| Variable Name                             | Default Value                    | Description                                                                 |
|-------------------------------------------|----------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_packer__version`               | `1.9.5`                          | The version of Packer to be installed.                                      |
| `bootstrap_packer__arch`                  | `amd64`                          | The architecture for which the Packer binary should be downloaded.        |
| `bootstrap_packer__bin_path`              | `/usr/local/bin`                 | The directory where the Packer binary will be installed.                    |
| `bootstrap_packer__install_from_source_force_update` | `false`         | Forces the installation of Packer from source even if it is already installed.|
| `bootstrap_packer__reinstall_from_source`   | `false`                          | Indicates whether to reinstall Packer from source based on version checks.  |
| `bootstrap_packer__required_packages`     | `- unzip<br>- xorriso`           | List of required packages that need to be installed for Packer to function properly.|

## Usage

To use the `bootstrap_packer` role, include it in your playbook and optionally override any default variables as needed.

Example playbook:
```yaml
- hosts: all
  roles:
    - role: bootstrap_packer
      vars:
        bootstrap_packer__version: "1.9.5"
        bootstrap_packer__arch: "amd64"
```

## Dependencies

The `bootstrap_packer` role does not have any external dependencies on other Ansible roles.

## Best Practices

- Always specify the version of Packer you want to install using the `bootstrap_packer__version` variable.
- Ensure that the architecture specified in `bootstrap_packer__arch` matches your target system's architecture.
- Use the `bootstrap_packer__install_from_source_force_update` variable with caution, as it will reinstall Packer even if the correct version is already installed.

## Molecule Tests

This role does not include any Molecule tests at this time. Future updates may introduce test scenarios to validate the installation process.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_packer/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_packer/tasks/main.yml)