---
title: "bootstrap_linux_package Role Documentation"
role: bootstrap_linux_package
category: Ansible Roles
type: Technical Documentation
---

## Summary

The `bootstrap_linux_package` role is designed to manage package installations, repository configurations, and system updates across various Linux distributions. It supports both APT (Advanced Package Tool) for Debian-based systems and YUM/DNF for Red Hat-based systems. The role can handle the installation of packages, npm libraries, and snap packages, as well as manage custom repositories and system cache updates.

## Variables

| Variable Name                             | Default Value                                                                                     | Description                                                                                                                                                                                                 |
|-------------------------------------------|---------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_linux_package__state`          | `present`                                                                                         | The desired state of the package installations (e.g., present, absent).                                                                                                                                     |
| `bootstrap_linux_package__priority_default` | `100`                                                                                             | Default priority for package installation tasks.                                                                                                                                                              |
| `bootstrap_linux_package__skip_repo_management` | `false`                                                                                           | Whether to skip repository management tasks.                                                                                                                                                                  |
| `bootstrap_linux_package__exclude_list`   | `[]`                                                                                                | List of packages to exclude from installation.                                                                                                                                                                |
| `bootstrap_linux_package__update_cache`   | `true`                                                                                            | Whether to update the package cache before installing packages.                                                                                                                                             |
| `bootstrap_linux_package__cache_valid_time` | `3600`                                                                                            | Cache validity time in seconds for APT updates.                                                                                                                                                               |
| `bootstrap_linux_package__install_snap_libs` | `false`                                                                                           | Whether to install snap libraries.                                                                                                                                                                          |
| `bootstrap_linux_package__snap_list_default` | `[yq]`                                                                                            | Default list of snap packages to install.                                                                                                                                                                     |
| `bootstrap_linux_package__install_npm_libs` | `false`                                                                                           | Whether to install npm libraries.                                                                                                                                                                           |
| `bootstrap_linux_package__npm_list_default` | `[]`                                                                                                | Default list of npm packages to install.                                                                                                                                                                      |
| `bootstrap_linux_package__package_source_dir_default` | `/etc/apt/sources.list.d`                                                                     | Default directory for package source files.                                                                                                                                                                   |
| `bootstrap_linux_package__reset_sources`  | `false`                                                                                           | Whether to reset all existing repository sources before adding new ones.                                                                                                                                      |
| `bootstrap_linux_package__preserve_nvidia_repos_default` | `true`                                                                                      | Whether to preserve NVIDIA repositories on DGX systems.                                                                                                                                                     |
| `bootstrap_linux_package__package_list`   | `[]`                                                                                                | List of packages to install.                                                                                                                                                                                |
| `bootstrap_linux_package__npm_list`       | `[]`                                                                                                | List of npm packages to install.                                                                                                                                                                            |
| `bootstrap_linux_package__snap_list`      | `[yq]`                                                                                            | List of snap packages to install.                                                                                                                                                                           |
| `bootstrap_linux_package__yum_repo_list`  | `[]`                                                                                                | List of YUM repositories to configure.                                                                                                                                                                      |
| `bootstrap_linux_package__custom_repo_list` | `{ apt: [], yum: [] }`                                                                             | Custom repository lists for APT and YUM/DNF.                                                                                                                                                                |
| `bootstrap_linux_package__apt_mirror_url` | `us.archive.ubuntu.com/{{ ansible_facts['distribution'] \| lower }}`                                 | Base URL for the APT mirror.                                                                                                                                                                                |
| `bootstrap_linux_package__apt_security_mirror_url` | `us.archive.ubuntu.com/{{ ansible_facts['distribution'] \| lower }}`                        | Base URL for the APT security mirror.                                                                                                                                                                       |
| `bootstrap_linux_package__apt_updates_mirror_url` | `us.archive.ubuntu.com/{{ ansible_facts['distribution'] \| lower }}`                         | Base URL for the APT updates mirror.                                                                                                                                                                        |
| `bootstrap_linux_package__apt_backports_mirror_url` | `archive.debian.org/{{ ansible_facts['distribution'] \| lower }}`                           | Base URL for the APT backports mirror.                                                                                                                                                                      |

## Usage

To use the `bootstrap_linux_package` role, include it in your playbook and define any necessary variables as needed. Here is an example playbook that installs a set of packages and npm libraries:

```yaml
---
- name: Bootstrap Linux Packages
  hosts: all
  become: yes
  roles:
    - role: bootstrap_linux_package
      vars:
        bootstrap_linux_package__package_list:
          - vim
          - curl
          - git
        bootstrap_linux_package__install_npm_libs: true
        bootstrap_linux_package__npm_list:
          - name: express
            version: latest
```

## Dependencies

- `bootstrap_nodejs` (for npm package installation)
- `bootstrap_epel_repo` (for EPEL repository setup)

## Best Practices

1. **Custom Repositories**: Ensure that custom repositories are correctly configured and signed to avoid security issues.
2. **Cache Management**: Regularly update the package cache to ensure installations use the latest versions of packages.
3. **Exclusions**: Use the `exclude_list` variable to prevent unwanted packages from being installed.
4. **Snap Packages**: Only enable snap package installation if required, as it adds additional overhead and dependencies.

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