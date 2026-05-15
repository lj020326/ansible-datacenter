---
title: "Bootstrap Linux Systemd Mount Role"
role: bootstrap_linux_systemd_mount
category: Ansible Roles
type: Configuration Management
tags: systemd, mount, linux, automation
---

## Summary

The `bootstrap_linux_systemd_mount` role is designed to automate the setup and management of systemd mounts on Linux systems. It supports various types of mounts, including network filesystems like GlusterFS and S3FS, and can handle swap partitions as well. The role ensures that required packages are installed, mount points are created, and systemd services are configured to manage these mounts.

## Variables

| Variable Name                                      | Default Value                                                                                         | Description                                                                                                                                                                                                 |
|----------------------------------------------------|-------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_linux_systemd_mount__systemd_centos_epel_mirror` | `http://download.fedoraproject.org/pub/epel`                                                        | The mirror URL for the EPEL repository. Used when installing packages like s3fs-fuse on CentOS systems.                                                                                                     |
| `bootstrap_linux_systemd_mount__systemd_centos_epel_key`  | `http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-{{ ansible_facts['distribution_major_version'] }}` | The URL for the EPEL GPG key. Used to verify packages from the EPEL repository on CentOS systems.                                                                                                             |
| `bootstrap_linux_systemd_mount__systemd_default_mount_options` | `defaults`                                                                                            | Default mount options used when no specific options are provided in the `bootstrap_linux_systemd_mounts` list.                                                                                              |
| `bootstrap_linux_systemd_mounts`                   | `[]`                                                                                                  | A list of dictionaries defining the mounts to be configured. Each dictionary can specify attributes like `what`, `where`, `type`, `options`, `credentials`, and more. See Usage for details.                |

## Usage

To use this role, you need to define the `bootstrap_linux_systemd_mounts` variable in your playbook or inventory file. Here is an example of how to configure a few different types of mounts:

```yaml
- name: Configure systemd mounts
  hosts: all
  roles:
    - role: bootstrap_linux_systemd_mount
      vars:
        bootstrap_linux_systemd_mounts:
          - what: "http://example.com/s3-bucket"
            where: "/mnt/s3fs"
            type: "fuse.s3fs"
            credentials: "access_key=your_access_key;secret_key=your_secret_key"
            options: "url=http://example.com,sigv2=true,use_path_request_style"
          - what: "gluster-server:/volume"
            where: "/mnt/gluster"
            type: "glusterfs"
            options: "_netdev,noatime"
          - what: "/dev/sdb1"
            where: "none"
            type: "swap"
```

## Dependencies

- **EPEL Repository**: Required for installing `s3fs-fuse` on CentOS systems.
- **GlusterFS Configuration**: If GlusterFS is specified in the mounts, additional configuration may be needed.

## Best Practices

1. **Use Specific Mount Options**: Always specify mount options to ensure the filesystem behaves as expected.
2. **Secure Credentials**: When using network filesystems that require credentials (e.g., S3FS), store these securely and avoid hardcoding them in playbooks.
3. **Test Configurations**: Use Molecule tests to verify that your configurations are applied correctly.

## Molecule Tests

This role includes Molecule tests to validate its functionality. To run the tests, ensure you have Molecule installed and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_systemd_mount/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_systemd_mount/tasks/main.yml)
- [tasks/systemd_install.yml](../../roles/bootstrap_linux_systemd_mount/tasks/systemd_install.yml)
- [tasks/systemd_mounts.yml](../../roles/bootstrap_linux_systemd_mount/tasks/systemd_mounts.yml)
- [handlers/main.yml](../../roles/bootstrap_linux_systemd_mount/handlers/main.yml)