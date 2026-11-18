---
title: "Bootstrap yq Role"
role: bootstrap_yq
category: System
type: Role
tags: [ansible, role, bootstrap_yq]
---

# Bootstrap yq Role

This Ansible role installs and configures `yq`, a lightweight and portable command-line YAML processor. It ensures that the specified version of `yq` is installed on the target system, and handles the download, extraction, and placement of the binary in the desired directory.

## Variables

| Variable Name                       | Default Value                           | Description                                                                 |
|-------------------------------------|-----------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_yq__version`             | `4.40.5`                                | The version of `yq` to install.                                             |
| `bootstrap_yq__binary`              | `yq_linux_amd64`                       | The binary name for the `yq` package.                                       |
| `bootstrap_yq__bin_path`            | `/usr/local/bin`                        | The path where the `yq` binary should be installed.                         |
| `bootstrap_yq__bin_url`             | `https://github.com/mikefarah/yq/releases/download/v{{ bootstrap_yq__version }}/{{ bootstrap_yq__binary }}.tar.gz` | The URL to download the `yq` binary from.                                   |
| `bootstrap_yq__install_from_source_force_update` | `false` | Force update of `yq` from source.                                          |
| `bootstrap_yq__reinstall_from_source` | `false` | Reinstall `yq` from source.                                                 |
| `bootstrap_yq__required_packages`   | `['jq']`                               | List of required packages that need to be installed before installing `yq`. |

## Usage

To use this role, include it in your playbook and set the desired variables. Here is an example:

```yaml
- hosts: all
  roles:
    - role: bootstrap_yq
      vars:
        bootstrap_yq__version: "4.40.5"
        bootstrap_yq__bin_path: "/usr/local/bin"
```

## Dependencies

This role requires the `jq` package to be installed, which is handled by the role itself.

## Best Practices

- Ensure that the target system has internet access to download the `yq` binary.
- Verify that the target system has sufficient permissions to install binaries in the specified path.
- Regularly update the `bootstrap_yq__version` variable to ensure you are using the latest stable version of `yq`.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_yq/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_yq/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_yq/handlers/main.yml)