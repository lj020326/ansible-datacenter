---
title: Bootstrap Linux Package Role Documentation
role: bootstrap_linux_package
category: Ansible Roles
type: Configuration Management
tags: linux, package-management, ansible-role

---

## Summary

The `bootstrap_linux_package` role is designed to manage and configure package repositories, install packages using the system's native package manager (e.g., APT for Debian-based systems, YUM/DNF for Red Hat-based systems), and optionally handle Node.js and Snap packages. This role ensures that the system has the necessary repositories configured and installs or removes specified packages as required.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_linux_package__state` | `present` | The desired state of the package (present/absent). |
| `bootstrap_linux_package__priority_default` | `100` | Default priority for packages. |
| `bootstrap_linux_package__exclude_list` | `[]` | List of packages to exclude from installation. |
| `bootstrap_linux_package__update_cache` | `true` | Whether to update the package cache before installing packages. |
| `bootstrap_linux_package__cache_valid_time` | `3600` | Time in seconds after which the package cache is considered stale. |
| `bootstrap_linux_package__install_snap_libs` | `false` | Whether to install Snap packages. |
| `bootstrap_linux_package__snap_list_default` | `[yq]` | Default list of Snap packages to install. |
| `bootstrap_linux_package__install_npm_libs` | `false` | Whether to install Node.js packages. |
| `bootstrap_linux_package__npm_list_default` | `[]` | Default list of Node.js packages to install. |
| `bootstrap_linux_package__yum_repo_list` | `[]` | List of custom YUM repositories to configure. |
| `bootstrap_linux_package__custom_repo_list` | `{ apt: [], yum: [] }` | Custom repository lists for APT and YUM/DNF. |
| `bootstrap_linux_package__apt_mirror_url` | `us.archive.ubuntu.com/{{ ansible_facts['distribution'] \| lower }}` | Base URL for the APT mirror. |
| `bootstrap_linux_package__apt_security_mirror_url` | `us.archive.ubuntu.com/{{ ansible_facts['distribution'] \| lower }}` | Base URL for the APT security mirror. |
| `bootstrap_linux_package__apt_updates_mirror_url` | `us.archive.ubuntu.com/{{ ansible_facts['distribution'] \| lower }}` | Base URL for the APT updates mirror. |
| `bootstrap_linux_package__apt_backports_mirror_url` | `archive.debian.org/{{ ansible_facts['distribution'] \| lower }}` | Base URL for the APT backports mirror. |
| `bootstrap_linux_package__apt_ubuntu_mirror_base_url` | `"http://mirrors.rit.edu"` | Base URL for Ubuntu mirrors. |
| `bootstrap_linux_package__apt_ubuntu_security_mirror_base_url` | `"http://mirrors.rit.edu"` | Base URL for Ubuntu security mirrors. |
| `bootstrap_linux_package__apt_repo_path` | `/etc/apt/sources.list.d` | Path to store APT repository files. |
| `bootstrap_linux_package__apt_repo_use_https` | `true` | Whether to use HTTPS for APT repositories. |
| `bootstrap_linux_package__apt_sources_file` | `/etc/apt/sources.list` | Path to the main APT sources file. |
| `bootstrap_linux_package__apt_backports_file` | `"{{ bootstrap_linux_package__apt_repo_path }}/backports.list"` | Path to the backports repository file. |
| `bootstrap_linux_package__apt_experimental_file` | `"{{ bootstrap_linux_package__apt_repo_path }}/experimental.list"` | Path to the experimental repository file. |
| `bootstrap_linux_package__apt_debsrc` | `true` | Whether to include source packages in APT repositories. |
| `bootstrap_linux_package__apt_sources` | `true` | Whether to configure main APT sources. |
| `bootstrap_linux_package__apt_sources_tpl` | `apt-sources.list.j2` | Template for the main APT sources file. |
| `bootstrap_linux_package__apt_backports` | `true` | Whether to configure backports repository. |
| `bootstrap_linux_package__apt_backports_tpl` | `apt-backports.list.j2` | Template for the backports repository file. |
| `bootstrap_linux_package__apt_experimental` | `false` | Whether to configure experimental repository. |
| `bootstrap_linux_package__apt_experimental_tpl` | `apt-experimental.list.j2` | Template for the experimental repository file. |
| `bootstrap_linux_package__apt_contrib_nonfree` | `true` | Whether to include contrib and non-free components in APT repositories. |
| `bootstrap_linux_package__apt_sources_ubuntu_tpl` | `apt-sources-ubuntu.list.j2` | Template for Ubuntu-specific APT sources. |
| `bootstrap_linux_package__apt_sources_ubuntu_file` | `/etc/apt/sources.list.d/ubuntu.sources` | Path to the Ubuntu-specific APT sources file. |
| `bootstrap_linux_package__setup_yum_repos` | `true` | Whether to configure YUM repositories. |
| `bootstrap_linux_package__setup_epel_from_rpm` | `true` | Whether to set up EPEL repository from RPM. |
| `bootstrap_linux_package__epel_repo_url` | `https://dl.fedoraproject.org/pub/epel` | Base URL for the EPEL repository. |
| `bootstrap_linux_package__epel_rpm_url` | `"{{ bootstrap_linux_package__epel_repo_url }}/epel-release-latest-{{ ansible_facts['distribution_major_version'] \| string }}.noarch.rpm"` | URL to download the EPEL RPM. |
| `bootstrap_linux_package__epel_gpg_key` | `"{{ bootstrap_linux_package__epel_repo_url }}/RPM-GPG-KEY-EPEL-{{ ansible_facts['distribution_major_version'] \| string }}"` | URL for the EPEL GPG key. |
| `bootstrap_linux_package__redhat_install_centos_repos` | `false` | Whether to install CentOS repositories on Red Hat systems. |
| `bootstrap_linux_package__redhat_use_rhsm` | `false` | Whether to use Red Hat Subscription Manager for repository configuration. |
| `bootstrap_linux_package__centos_gpg_key_url` | `https://centos.org/keys/RPM-GPG-KEY-CentOS-Official` | URL for the CentOS GPG key. |
| `bootstrap_linux_package__centos_gpg_rpm_key` | `/etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial` | Path to store the CentOS GPG key. |

## Usage

To use this role, include it in your playbook and define any necessary variables as needed. Here is an example of how to include the role with custom package lists:

```yaml
---
- name: Bootstrap Linux Package Installation
  hosts: all
  roles:
    - role: bootstrap_linux_package
      vars:
        bootstrap_linux_package__package_list_default:
          - vim
          - curl
        bootstrap_linux_package__snap_list_default:
          - htop
        bootstrap_linux_package__npm_list_default:
          - express
```

## Dependencies

- `bootstrap_nodejs` (if `bootstrap_linux_package__install_npm_libs` is set to `true`)
- `bootstrap_epel_repo` (if `bootstrap_linux_package__setup_epel_from_rpm` is set to `true`)

## Tags

This role uses the following tags:

- `init-vars`: Initializes variables.
- `packages`: Manages package installation and removal.
- `snap-packages`: Manages Snap packages.
- `npm-packages`: Manages Node.js packages.

To run specific tasks, you can use these tags. For example:

```bash
ansible-playbook playbook.yml --tags "packages,snap-packages"
```

## Best Practices

- Ensure that the correct package manager is used for your target operating system.
- Use custom repository lists when necessary to include additional or alternative repositories.
- Exclude packages from installation if they are not required on all systems.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

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