---
title: "Ansible Role Documentation"
role: bootstrap_yq
category: Ansible Roles
type: Installation
tags: yq, automation, configuration
---

# Role: `bootstrap_yq`

## Summary

The `bootstrap_yq` role is designed to automate the installation and management of the `yq` command-line tool on target systems. It ensures that a specified version of `yq` is installed in a designated binary path, handles the cleanup of temporary files used during the installation process, and manages dependencies such as required packages.

## Variables

| Variable Name                             | Default Value                                                                 | Description                                                                                                                                                                                                 |
|-------------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_yq__version`                   | `4.40.5`                                                                      | The version of `yq` to be installed.                                                                                                                                                                        |
| `bootstrap_yq__binary`                    | `yq_linux_amd64`                                                              | The binary name for the `yq` tool, which is platform-specific.                                                                                                                                                |
| `bootstrap_yq__bin_path`                  | `/usr/local/bin`                                                              | The path where the `yq` binary will be installed.                                                                                                                                                             |
| `bootstrap_yq__bin_url`                   | `https://github.com/mikefarah/yq/releases/download/v{{ bootstrap_yq__version }}/{{ bootstrap_yq__binary }}.tar.gz` | The URL from which to download the `yq` binary archive.                                                                                                                                                    |
| `bootstrap_yq__install_from_source_force_update` | `false`                                                                      | Forces the installation process, even if `yq` is already installed and matches the specified version.                                                                                                         |
| `bootstrap_yq__reinstall_from_source`     | `false`                                                                       | A flag to determine whether to reinstall `yq` from source. This variable is set internally based on other conditions and should not be overridden.  |
| `bootstrap_yq__required_packages`         | `[jq]`                                                                        | A list of required packages that need to be installed before installing `yq`.                                                                                                                                |

## Usage

To use the `bootstrap_yq` role, include it in your Ansible playbook and optionally override any default variables as needed. Here is an example playbook:

```yaml
---
- name: Install yq using bootstrap_yq role
  hosts: all
  become: yes
  roles:
    - role: bootstrap_yq
      vars:
        bootstrap_yq__version: 4.40.5
```

## Dependencies

The `bootstrap_yq` role depends on the following packages:

- `jq`: A lightweight and flexible command-line JSON processor.

These dependencies are installed automatically by the role using the `ansible.builtin.package` module.

## Best Practices

1. **Version Management**: Always specify a version for `yq` to ensure consistency across environments.
2. **Force Update**: Use `bootstrap_yq__install_from_source_force_update: true` only when necessary, as it will reinstall `yq` even if the correct version is already installed.
3. **Temporary Directory Cleanup**: The role automatically cleans up temporary directories used during installation unless overridden by setting `__test_disable_cleanup` to `true`.

## Molecule Tests

This role does not currently include Molecule tests.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_yq/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_yq/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_yq/handlers/main.yml)

---

**Note**: Variables starting with `__` (e.g., `__bootstrap_yq__installed_version`) are internal to the role and should not be overridden in your inventory or command line.