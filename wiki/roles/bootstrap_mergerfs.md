---
title: Bootstrap MergerFS Role Documentation
role: bootstrap_mergerfs
category: Storage Management
type: Ansible Role
tags: mergerfs, samba, telegraf, file-sharing
---

## Summary

The `bootstrap_mergerfs` role is designed to automate the setup and configuration of a MergerFS storage system. It includes tasks for installing necessary tools, configuring disk mounts, setting up Samba for file sharing, and ensuring Telegraf has the appropriate permissions to interact with Docker.

## Variables

| Variable Name               | Default Value                      | Description                                                                 |
|-----------------------------|------------------------------------|-----------------------------------------------------------------------------|
| `mergerfs_tools_src_dir`    | `/var/lib/src/mergerfs-tools`      | The directory where the mergerfs-tools source code will be cloned.          |

## Usage

To use this role, include it in your playbook and ensure that you provide the necessary variables such as `parity_disks`, `data_disks`, `extra_mountpoints`, and `fstab_mergerfs`. Here is an example of how to include the role in a playbook:

```yaml
- hosts: storage_servers
  roles:
    - role: bootstrap_mergerfs
      vars:
        parity_disks:
          - path: /mnt/parity1
            diskbyid: /dev/disk/by-id/scsi-SATA_disk_parity1
            fs: ext4
            opts: defaults,noatime
        data_disks:
          - path: /mnt/data1
            diskbyid: /dev/disk/by-id/scsi-SATA_disk_data1
            fs: ext4
            opts: defaults,noatime
        extra_mountpoints:
          - path: /mnt/extra1
            diskbyid: /dev/disk/by-id/scsi-SATA_disk_extra1
            fs: ext4
            opts: defaults,noatime
        fstab_mergerfs:
          - mountpoint: /mnt/storage
            source: "/mnt/data1:/mnt/parity1"
            opts: defaults,allow_other,use_ino,category.create=mfs,cache.files=partial,dropcacheonclose=true,moveonenospc=true,minfreespace=5G
            fs: mergerfs
```

## Dependencies

- `ansible.posix.mount`
- `ansible.builtin.apt`
- `ansible.builtin.copy`
- `ansible.builtin.git`
- `ansible.builtin.command`
- `ansible.builtin.pip`
- `ansible.builtin.user`
- `ansible.builtin.service`
- `ansible.builtin.systemd`

## Tags

- `install-mergerfs-tools`: Installs the mergerfs-tools package.
- `configure-disks`: Configures the disks and mounts them according to the provided variables.

## Best Practices

1. **Disk Configuration**: Ensure that all disk paths, IDs, filesystem types, and mount options are correctly specified in your playbook.
2. **Permissions**: Verify that the user running the Ansible playbooks has the necessary permissions to install packages and manage system services.
3. **Testing**: Use Molecule tests (if available) to validate the role's functionality before deploying it to production environments.

## Molecule Tests

This role does not include any Molecule tests at this time. It is recommended to create test scenarios using Molecule to ensure the role behaves as expected in various environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_mergerfs/defaults/main.yml)
- [tasks/config-mergerfs-disks.yml](../../roles/bootstrap_mergerfs/tasks/config-mergerfs-disks.yml)
- [tasks/config-telegraf-fix.yml](../../roles/bootstrap_mergerfs/tasks/config-telegraf-fix.yml)
- [tasks/file-sharing.yml](../../roles/bootstrap_mergerfs/tasks/file-sharing.yml)
- [tasks/install-mergerfs-tools.yml](../../roles/bootstrap_mergerfs/tasks/install-mergerfs-tools.yml)
- [tasks/main.yml](../../roles/bootstrap_mergerfs/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_mergerfs/handlers/main.yml)