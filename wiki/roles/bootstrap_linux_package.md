---
title: "Ansible Role Documentation"
role: bootstrap_linux_package
category: Ansible Roles
type: Configuration Management
tags: [linux, package management, ansible]
---

# Ansible Role: `bootstrap_linux_package`

## Summary

The `bootstrap_linux_package` role is designed to manage and configure the package repositories and install essential packages on Linux systems. It supports various package managers such as APT (for Debian-based distributions) and YUM/DNF (for Red Hat-based distributions). The role also handles the installation of Node.js libraries via npm, Snap packages, and custom repository configurations.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_linux_package__state` | `present` | Desired state for package installations. |
| `bootstrap_linux_package__priority_default` | `100` | Default priority for package sources. |
| `bootstrap_linux_package__skip_repo_management` | `false` | Skip repository management if set to true. |
| `bootstrap_linux_package__exclude_list` | `[]` | List of packages to exclude from installation. |
| `bootstrap_linux_package__update_cache` | `true` | Update the package cache before installing packages. |
| `bootstrap_linux_package__cache_valid_time` | `3600` | Cache validity time in seconds. |
| `bootstrap_linux_package__install_snap_libs` | `false` | Install Snap libraries if set to true. |
| `bootstrap_linux_package__snap_list_default` | `[yq]` | Default list of Snap packages to install. |
| `bootstrap_linux_package__install_npm_libs` | `false` | Install Node.js libraries via npm if set to true. |
| `bootstrap_linux_package__npm_list_default` | `[]` | Default list of Node.js packages to install. |
| `bootstrap_linux_package__package_source_dir` | `/etc/apt/sources.list.d` | Directory for package source files. |
| `bootstrap_linux_package__reset_sources` | `false` | Reset all repository sources if set to true. |
| `bootstrap_linux_package__preserve_nvidia_repos` | `true` | Preserve NVIDIA repositories on DGX systems. |
| `bootstrap_linux_package__package_list` | `[]` | List of packages to install. |
| `bootstrap_linux_package__npm_list` | `[]` | List of Node.js packages to install. |
| `bootstrap_linux_package__snap_list` | `[yq]` | List of Snap packages to install. |
| `bootstrap_linux_package__yum_repo_list` | `[]` | List of YUM repositories to configure. |
| `bootstrap_linux_package__custom_repo_list` | `{ apt: [], yum: [] }` | Custom repository configurations for APT and YUM. |
| `bootstrap_linux_package__apt_mirror_url` | `us.archive.ubuntu.com/{{ ansible_facts['distribution'] \| lower }}` | Base URL for APT mirrors. |
| `bootstrap_linux_package__apt_security_mirror_url` | `us.archive.ubuntu.com/{{ ansible_facts['distribution'] \| lower }}` | Security mirror URL for APT. |
| `bootstrap_linux_package__apt_updates_mirror_url` | `us.archive.ubuntu.com/{{ ansible_facts['distribution'] \| lower }}` | Updates mirror URL for APT. |
| `bootstrap_linux_package__apt_backports_mirror_url` | `archive.debian.org/{{ ansible_facts['distribution'] \| lower }}` | Backports mirror URL for APT. |
| `bootstrap_linux_package__apt_ubuntu_mirror_base_url` | `"http://mirrors.rit.edu"` | Base URL for Ubuntu mirrors. |
| `bootstrap_linux_package__apt_ubuntu_security_mirror_base_url` | `"http://mirrors.rit.edu"` | Security mirror base URL for Ubuntu. |
| `bootstrap_linux_package__apt_repo_use_https` | `true` | Use HTTPS for APT repositories if set to true. |
| `bootstrap_linux_package__setup_yum_repos` | `true` | Setup YUM repositories if set to true. |
| `bootstrap_linux_package__setup_epel_from_rpm` | `true` | Install EPEL repository from RPM if set to true. |
| `bootstrap_linux_package__epel_repo_url` | `https://dl.fedoraproject.org/pub/epel` | URL for the EPEL repository. |
| `bootstrap_linux_package__epel_rpm_url` | `{{ bootstrap_linux_package__epel_repo_url }}/epel-release-latest-{{ ansible_facts['distribution_major_version'] \| string }}.noarch.rpm` | URL for the EPEL RPM package. |
| `bootstrap_linux_package__epel_gpg_key` | `{{ bootstrap_linux_package__epel_repo_url }}/RPM-GPG-KEY-EPEL-{{ ansible_facts['distribution_major_version'] \| string }}` | GPG key for the EPEL repository. |
| `bootstrap_linux_package__redhat_install_centos_repos` | `false` | Install CentOS repositories on Red Hat systems if set to true. |
| `bootstrap_linux_package__redhat_use_rhsm` | `false` | Use Red Hat Subscription Manager if set to true. |
| `bootstrap_linux_package__centos_gpg_key_url` | `https://centos.org/keys/RPM-GPG-KEY-CentOS-Official` | URL for the CentOS GPG key. |
| `bootstrap_linux_package__centos_gpg_rpm_key` | `/etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial` | Path to the CentOS GPG key file. |

## Usage

To use the `bootstrap_linux_package` role, include it in your playbook and configure the necessary variables as per your requirements.

### Example Playbook

```yaml
---
- hosts: all
  become: yes
  roles:
    - role: bootstrap_linux_package
      vars:
        bootstrap_linux_package__package_list:
          - vim
          - curl
        bootstrap_linux_package__npm_list:
          - name: yargs
            version: latest
        bootstrap_linux_package__snap_list:
          - helm
```

## Dependencies

- `bootstrap_nodejs` (if `bootstrap_linux_package__install_npm_libs` is true)
- `bootstrap_epel_repo` (if `bootstrap_linux_package__setup_epel_from_rpm` is true)

## Best Practices

1. **Backup Repository Sources**: Before resetting repository sources, ensure that you have backups of existing configurations.
2. **Custom Repositories**: Use the `custom_repo_list` variable to add custom repositories with appropriate keys and URLs.
3. **Node.js and Snap Packages**: Enable installation of Node.js libraries and Snap packages only if required by your environment.

## Molecule Tests

This role includes Molecule tests to verify its functionality across different Linux distributions. To run the tests, ensure you have Molecule installed and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_package/defaults/main.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_linux_package/tasks/init-vars.yml)
- [tasks/install-npm-packages.yml](../../roles/bootstrap_linux_package/tasks/install-npm-packages.yml)
- [tasks/install-packages.yml](../../roles/bootstrap_linux_package/tasks/install-packages.yml)
- [tasks/install-snap-packages.yml](../../roles/bootstrap_linux_package/tasks/install-snap-packages.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_package/tasks/main.yml)
- [tasks/update-repo-apt-ubuntu.yml](../../roles/bootstrap_linux_package/tasks/update-repo-apt-ubuntu.yml)
- [tasks/update-repo-apt.yml](../../roles/bootstrap_linux_package/tasks/update-repo-apt.yml)
- [tasks/update-repo-dnf.yml](../../roles/bootstrap_linux_package/tasks/update-repo-dnf.yml)
- [tasks/update-repo-yum-rhel-centos.yml](../../roles/bootstrap_linux_package/tasks/update-repo-yum-rhel-centos.yml)
- [tasks/update-repo-yum.yml](../../roles/bootstrap_linux_package/tasks/update-repo-yum.yml)
- [handlers/main.yml](../../roles/bootstrap_linux_package/handlers/main.yml)