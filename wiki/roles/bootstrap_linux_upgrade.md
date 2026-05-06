---
title: Bootstrap Linux Upgrade Role Documentation
role: bootstrap_linux_upgrade
category: System Management
type: Ansible Role
tags: linux, upgrade, reboot, package-management
---

## Summary

The `bootstrap_linux_upgrade` role is designed to automate the process of upgrading operating system packages on Linux systems. It supports various distributions such as Debian, Ubuntu, Red Hat, Fedora, and others by using the appropriate package manager commands (e.g., apt, dnf, yum). The role includes options for updating packages, handling reboots, excluding specific packages from updates, and installing additional packages.

## Variables

| Variable Name                             | Default Value                          | Description                                                                 |
|-------------------------------------------|----------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_linux_upgrade__debug_enabled_default` | `false`                              | Enable debug output during the execution of the role.                       |
| `bootstrap_linux_upgrade__update_default`       | `true`                               | Whether to update packages on the system.                                   |
| `bootstrap_linux_upgrade__reboot_default`       | `true`                               | Whether to reboot the system after upgrades if necessary.                   |
| `bootstrap_linux_upgrade__reboot_pre_delay`     | `5`                                  | Delay in seconds before initiating a reboot.                                |
| `bootstrap_linux_upgrade__reboot_pre_reboot_delay` | `0`                                 | Additional delay in seconds before the actual reboot command is issued.   |
| `bootstrap_linux_upgrade__reboot_post_reboot_delay` | `10`                               | Delay in seconds after the system reboots to ensure it's back online.       |
| `bootstrap_linux_upgrade__reboot_reboot_timeout`  | `600`                                | Maximum time in seconds to wait for the system to reboot and come back online.|
| `bootstrap_linux_upgrade__exclude_pkgs`         | `[]`                                 | List of packages to exclude from upgrades.                                  |
| `bootstrap_linux_upgrade__install_pkgs`         | `[]`                                 | List of additional packages to install during the upgrade process.          |
| `bootstrap_linux_upgrade__apt_exclude_default`  | `false`                              | Whether to use default exclusion rules for apt package manager.             |
| `bootstrap_linux_upgrade__apt_default`          | `full`                               | Default upgrade level for apt package manager (e.g., full, dist).           |

## Usage

To use the `bootstrap_linux_upgrade` role in your Ansible playbook, include it and configure any necessary variables as shown below:

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_upgrade
      vars:
        bootstrap_linux_upgrade__update_default: true
        bootstrap_linux_upgrade__reboot_default: true
        bootstrap_linux_upgrade__install_pkgs:
          - vim
          - curl
```

## Dependencies

This role does not have any external dependencies. However, it relies on the availability of package managers such as `apt`, `dnf`, and `yum` based on the target system's distribution.

## Tags

The following tags are available for this role:

- `upgrade`: Executes the upgrade tasks.
- `reboot`: Manages reboots if required after upgrades.

To run only specific tagged tasks, use the `--tags` option with Ansible:

```bash
ansible-playbook playbook.yml --tags "upgrade"
```

## Best Practices

1. **Backup Data**: Always ensure that critical data is backed up before performing system upgrades.
2. **Test in Staging**: Test the role in a staging environment to verify its behavior and handle any potential issues.
3. **Monitor Reboots**: Monitor systems after reboots to ensure they come back online correctly.
4. **Exclude Critical Packages**: Use `bootstrap_linux_upgrade__exclude_pkgs` to exclude critical packages from upgrades if necessary.

## Molecule Tests

This role includes Molecule tests to verify its functionality across different Linux distributions. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure that you have the required dependencies installed for Molecule and the target platforms.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_upgrade/defaults/main.yml)
- [tasks/apt.yml](../../roles/bootstrap_linux_upgrade/tasks/apt.yml)
- [tasks/dnf.yml](../../roles/bootstrap_linux_upgrade/tasks/dnf.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_upgrade/tasks/main.yml)
- [tasks/upgrade-debian.yml](../../roles/bootstrap_linux_upgrade/tasks/upgrade-debian.yml)
- [tasks/upgrade-redhat.yml](../../roles/bootstrap_linux_upgrade/tasks/upgrade-redhat.yml)
- [tasks/upgrade-ubuntu.yml](../../roles/bootstrap_linux_upgrade/tasks/upgrade-ubuntu.yml)
- [tasks/yum.yml](../../roles/bootstrap_linux_upgrade/tasks/yum.yml)