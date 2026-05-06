---
title: Bootstrap Linux Systemd Mount Role Documentation
role: bootstrap_linux_systemd_mount
category: Ansible Roles
type: Configuration Management
tags: ansible, systemd, mount, linux

## Summary
The `bootstrap_linux_systemd_mount` role is designed to manage and configure systemd mounts on Linux systems. It handles the installation of necessary packages, configuration of mount points, and management of systemd mount units. This role supports various types of mounts including standard filesystems, swap partitions, and network-based mounts like s3fs.

## Variables

| Variable Name                                      | Default Value                                                                                          | Description                                                                                                                                                                                                 |
|----------------------------------------------------|--------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_linux_systemd_mount__systemd_centos_epel_mirror` | `http://download.fedoraproject.org/pub/epel`                                                       | The URL for the EPEL repository mirror.                                                                                                                                                                       |
| `bootstrap_linux_systemd_mount__systemd_centos_epel_key`    | `http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-\|ansible_facts['distribution_major_version']\|` | The URL for the EPEL GPG key.                                                                                                                                                                                 |
| `bootstrap_linux_systemd_mount__systemd_default_mount_options` | `defaults`                                                                                             | Default mount options to be used if none are specified in the mount configuration.                                                                                                                            |
| `bootstrap_linux_systemd_mounts`                       | `[]`                                                                                                   | A list of dictionaries defining the mounts to be configured. Each dictionary should contain details like `what`, `where`, `type`, `options`, etc. |

## Usage
To use this role, define the `bootstrap_linux_systemd_mounts` variable in your playbook with a list of mount configurations. Here is an example:

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_systemd_mount
      vars:
        bootstrap_linux_systemd_mounts:
          - what: /dev/sdb1
            where: /mnt/data
            type: ext4
            options: defaults,noatime
            state: present
          - what: s3fs#my-bucket
            where: /mnt/s3
            type: fuse.s3fs
            credentials: "access_key_id=YOUR_ACCESS_KEY\nsecret_access_key=YOUR_SECRET_KEY"
            state: present
```

## Dependencies
- The role includes tasks that depend on the `systemd_service` role for configuring GlusterFS. Ensure this role is available in your Ansible environment if you plan to use GlusterFS mounts.

## Tags
- `always`: Applied to tasks that gather variables and are always executed.
- `systemd-mount`: Applied to tasks related to creating and managing systemd mount units.
- `skip_ansible_lint`: Used to skip linting for specific tasks that may not conform to standard practices but are necessary for functionality.

## Best Practices
- Ensure the `bootstrap_linux_systemd_mounts` variable is correctly formatted with all required fields.
- For network-based mounts like s3fs, ensure the credentials provided have the appropriate permissions and are securely stored.
- Use tags to selectively run parts of the role during playbook execution based on your needs.

## Molecule Tests
This role does not include Molecule tests. Consider adding Molecule scenarios to test different mount configurations and ensure the role behaves as expected across various environments.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_linux_systemd_mount/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_systemd_mount/tasks/main.yml)
- [tasks/systemd_install.yml](../../roles/bootstrap_linux_systemd_mount/tasks/systemd_install.yml)
- [tasks/systemd_mounts.yml](../../roles/bootstrap_linux_systemd_mount/tasks/systemd_mounts.yml)
- [handlers/main.yml](../../roles/bootstrap_linux_systemd_mount/handlers/main.yml)