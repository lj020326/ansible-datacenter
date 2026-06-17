---
title: "Bootstrap Linux Package Role"
role: bootstrap_linux_package
category: Ansible Roles
type: Documentation
tags: ansible, role, package-management, automation
---

## Summary

The `bootstrap_linux_package` Ansible role is designed to manage and install packages on Linux systems. It supports various package managers like APT (Advanced Package Tool) for Debian-based distributions and YUM/DNF for Red Hat-based distributions. The role can handle repository management, package installation, and configuration of snap and npm packages.

## Variables

| Variable Name                                      | Default Value                                                                                   | Description                                                                                                                                                                                                                                                                                                                                 |
|----------------------------------------------------|-------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_linux_package__state`                   | `present`                                                                                       | The state of the package (e.g., present, absent).                                                                                                                                                                                                                                                                                           |
| `bootstrap_linux_package__priority_default`        | `100`                                                                                           | Default priority for package installations.                                                                                                                                                                                                                                                                                                   |
| `bootstrap_linux_package__skip_repo_management`    | `false`                                                                                         | Whether to skip repository management tasks.                                                                                                                                                                                                                                                                                                  |
| `bootstrap_linux_package__exclude_list`            | `[]`                                                                                            | List of packages to exclude from installation.                                                                                                                                                                                                                                                                                                |
| `bootstrap_linux_package__update_cache`            | `true`                                                                                          | Whether to update the package cache before installing packages.                                                                                                                                                                                                                                                                             |
| `bootstrap_linux_package__cache_valid_time`        | `3600`                                                                                          | Time in seconds for which the package cache is considered valid.                                                                                                                                                                                                                                                                            |
| `bootstrap_linux_package__install_snap_libs`       | `false`                                                                                         | Whether to install snap packages.                                                                                                                                                                                                                                                                                                           |
| `bootstrap_linux_package__snap_list_default`       | `[yq]`                                                                                          | Default list of snap packages to install.                                                                                                                                                                                                                                                                                                     |
| `bootstrap_linux_package__install_npm_libs`        | `false`                                                                                         | Whether to install npm packages.                                                                                                                                                                                                                                                                                                            |
| `bootstrap_linux_package__npm_list_default`        | `[]`                                                                                            | Default list of npm packages to install.                                                                                                                                                                                                                                                                                                      |
| `__bootstrap_linux_package__package_source_dir_default` | `/etc/apt/sources.list.d`                                                                      | Default directory for package source files.                                                                                                                                                                                                                                                                                                   |
| `__bootstrap_linux_package__package_source_dir`    | `{{ bootstrap_linux_package__package_source_dir \| d(__bootstrap_linux_package__package_source_dir_default) }}` | Directory for package source files, defaults to the default directory if not specified.                                                                                                                                                                                                                                                       |
| `__bootstrap_linux_package__reset_sources_default` | `false`                                                                                         | Default value for resetting sources.                                                                                                                                                                                                                                                                                                          |
| `__bootstrap_linux_package__reset_sources`         | `{{ bootstrap_linux_package__reset_sources \| d(__bootstrap_linux_package__reset_sources_default) }}` | Whether to reset the package source files.                                                                                                                                                                                                                                                                                                    |
| `__bootstrap_linux_package__is_dgx`                | Derived from facts                                                                              | Determines if the system is a DGX (NVIDIA Data Center GPU).                                                                                                                                                                                                                                                                                |
| `__bootstrap_linux_package__preserve_nvidia_repos_default` | `true`                                                                                      | Default value for preserving NVIDIA repositories.                                                                                                                                                                                                                                                                                             |
| `__bootstrap_linux_package__preserve_nvidia_repos` | `{{ bootstrap_linux_package__preserve_nvidia_repos \| d(__bootstrap_linux_package__preserve_nvidia_repos_default) }}` | Whether to preserve NVIDIA repository settings.                                                                                                                                                                                                                                                                                               |
| `__bootstrap_linux_package__package_list`          | `{{ bootstrap_linux_package__package_list \| d(__bootstrap_linux_package__package_list_default) \| d([], true) }}` | List of packages to install, defaults to an empty list if not specified.                                                                                                                                                                                                                                                                    |
| `__bootstrap_linux_package__npm_list`              | `{{ bootstrap_linux_package__npm_list \| d(bootstrap_linux_package__npm_list_default) \| d([], true) }}` | List of npm packages to install, defaults to the default list if not specified.                                                                                                                                                                                                                                                               |
| `__bootstrap_linux_package__snap_list`             | `{{ bootstrap_linux_package__snap_list \| d(bootstrap_linux_package__snap_list_default) \| d([], true) }}` | List of snap packages to install, defaults to the default list if not specified.                                                                                                                                                                                                                                                              |
| `bootstrap_linux_package__yum_repo_list`           | `[]`                                                                                            | List of YUM repositories to configure.                                                                                                                                                                                                                                                                                                        |
| `bootstrap_linux_package__custom_repo_list`        | `{ apt: [], yum: [] }`                                                                         | Custom repository lists for APT and YUM.                                                                                                                                                                                                                                                                                                      |
| `bootstrap_linux_package__apt_mirror_url`          | `us.archive.ubuntu.com/{{ ansible_facts['distribution'] \| lower }}`                             | Mirror URL for APT repositories.                                                                                                                                                                                                                                                                                                              |
| `bootstrap_linux_package__apt_security_mirror_url` | `us.archive.ubuntu.com/{{ ansible_facts['distribution'] \| lower }}`                             | Security mirror URL for APT repositories.                                                                                                                                                                                                                                                                                                     |
| `bootstrap_linux_package__apt_updates_mirror_url`  | `us.archive.ubuntu.com/{{ ansible_facts['distribution'] \| lower }}`                             | Updates mirror URL for APT repositories.                                                                                                                                                                                                                                                                                                      |
| `bootstrap_linux_package__apt_backports_mirror_url`| `archive.debian.org/{{ ansible_facts['distribution'] \| lower }}`                                | Backports mirror URL for APT repositories.                                                                                                                                                                                                                                                                                                    |

## Usage

To use the `bootstrap_linux_package` role, include it in your playbook and specify any necessary variables. Here is an example:

```yaml
- name: Bootstrap Linux Packages
  hosts: all
  roles:
    - role: bootstrap_linux_package
      vars:
        bootstrap_linux_package__package_list:
          - vim
          - curl
        bootstrap_linux_package__npm_list:
          - name: http-server
            version: latest
        bootstrap_linux_package__snap_list:
          - htop
```

## Dependencies

- `bootstrap_nodejs` (for npm package installation)
- `bootstrap_epel_repo` (for setting up EPEL repository)

## Best Practices

- Always specify the exact versions of packages when possible to avoid unexpected changes.
- Use the `exclude_list` variable to prevent unwanted packages from being installed.
- Consider using custom repositories for specific needs, such as internal package sources.

## Molecule Tests

This role does not include Molecule tests. However, it is recommended to write and run Molecule tests to ensure the role behaves as expected across different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_package/defaults/main.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_linux_package/tasks/init-vars.yml)
- [tasks/install-npm-packages.yml](../../roles/bootstrap_linux_package/tasks/install-npm-packages.yml)
- [tasks/install-packages.yml](../../roles/bootstrap_linux_package/tasks/install-packages.yml)
- [tasks/install-snap-packages.yml](../../roles/bootstrap_linux_package/tasks/install-snap-packages.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_package/tasks/main.yml)
- [tasks/update-repo-apt.yml](../../roles/bootstrap_linux_package/tasks/update-repo-apt.yml)
- [tasks/update-repo-dnf.yml](../../roles/bootstrap_linux_package/tasks/update-repo-dnf.yml)
- [tasks/update-repo-yum-rhel-centos.yml](../../roles/bootstrap_linux_package/tasks/update-repo-yum-rhel-centos.yml)
- [tasks/update-repo-yum.yml](../../roles/bootstrap_linux_package/tasks/update-repo-yum.yml)
- [handlers/main.yml](../../roles/bootstrap_linux_package/handlers/main.yml)