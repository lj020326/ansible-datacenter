---
title: "Bootstrap Linux Systemd Mount Role"
role: bootstrap_linux_systemd_mount
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_linux_systemd_mount]
---

# Bootstrap Linux Systemd Mount Role

This Ansible role configures systemd-based mounts on Linux systems. It supports various mount types, including fuse.s3fs and glusterfs, and handles the installation of necessary packages and repositories. The role is designed to be flexible and configurable, allowing users to specify mount points, types, and options through variables.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_linux_systemd_mount__systemd_centos_epel_mirror` | `http://download.fedoraproject.org/pub/epel` | URL for the CentOS EPEL mirror |
| `bootstrap_linux_systemd_mount__systemd_centos_epel_key` | `http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-{{ ansible_facts.distribution_major_version }}` | URL for the CentOS EPEL GPG key |
| `bootstrap_linux_systemd_mount__systemd_default_mount_options` | `defaults` | Default mount options |
| `bootstrap_linux_systemd_mounts` | `[]` | List of mounts to configure |

## Usage

To use this role, include it in your playbook and define the `bootstrap_linux_systemd_mounts` variable with the desired mount configurations. Here is an example:

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_linux_systemd_mount
  vars:
    bootstrap_linux_systemd_mounts:
      - type: fuse.s3fs
        what: s3fs#bucket-name
        where: /mnt/s3fs
        options: "_netdev,allow_other,use_inode,uid=1000,gid=1000"
        credentials: "/path/to/credentials"
        enabled: true
        state: mounted
```

## Dependencies

This role depends on the `systemd_service` role for applying systemd overrides. Make sure to include this role in your playbook if it's not already included. You can find the `systemd_service` role in the same repository under `roles/systemd_service`.

## Best Practices

- Ensure that the `bootstrap_linux_systemd_mounts` variable is properly configured with the desired mount points and options.
- Test the role in a development environment before deploying it to production.
- Regularly update the role to ensure compatibility with the latest versions of Ansible and systemd.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_systemd_mount/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_systemd_mount/tasks/main.yml)
- [tasks/systemd_install.yml](../../roles/bootstrap_linux_systemd_mount/tasks/systemd_install.yml)
- [tasks/systemd_mounts.yml](../../roles/bootstrap_linux_systemd_mount/tasks/systemd_mounts.yml)
- [handlers/main.yml](../../roles/bootstrap_linux_systemd_mount/handlers/main.yml)