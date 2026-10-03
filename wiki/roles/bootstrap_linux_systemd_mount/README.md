---
title: "Bootstrap Linux Systemd Mount"
original_path: "roles/bootstrap_linux_systemd_mount/README.md"
category: "Ansible Roles"
tags: ["Ansible", "Systemd", "Mount", "Linux"]
harvested_date: "2023-08-07T18:07:09.319366+00:00"
source_type: "legacy_markdown"
---

# Bootstrap Linux Systemd Mount

This Ansible role configures systemd mount files on Linux systems. It creates and manages mount units using systemd, allowing for flexible and powerful mount point management.

## Example Playbook

> See the "defaults/main.yml" file for a full list of all available options.

```yaml
- name: Create systemd mount files for Mount1 and Mount2
  hosts: localhost
  become: true
  roles:
    - role: bootstrap_linux_systemd_mount
      bootstrap_linux_systemd_mounts:
        - what: '/var/lib/machines.raw'
          where: '/var/lib/machines'
          type: 'btrfs'
          options: 'loop'
          unit:
            ConditionPathExists:
              - '/var/lib/machines.raw'
          state: 'started'
          enabled: true
        - config_overrides: {}
          what: "10.1.10.1:/srv/nfs"
          where: "/var/lib/glance/images"
          type: "nfs"
          options: "_netdev,auto"
          unit:
            After:
              - network.target
```

## Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `bootstrap_linux_systemd_mounts` | List of mount configurations to create | `[]` |

Each mount configuration can include:
- `what`: Source of the mount
- `where`: Mount point
- `type`: Filesystem type
- `options`: Mount options
- `unit`: Additional systemd unit configuration
- `state`: Desired state (started, stopped, etc.)
- `enabled`: Whether the mount should be enabled
- `config_overrides`: Overrides for the generated unit file

## References

- [OpenStack Ansible Role - systemd_mount](https://github.com/openstack/ansible-role-systemd_mount)
- [OpenStack Ansible Role - systemd_service](https://github.com/openstack/ansible-role-systemd_service)

## Dependencies

This role requires Ansible and systemd to be installed on the target system.

## License

This project is licensed under the Apache License. See LICENSE file for details.

## Author Information

Original author: Your Name <your.email@example.com>