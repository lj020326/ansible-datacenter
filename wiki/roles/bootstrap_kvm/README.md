```markdown
---
title: bootstrap_kvm Ansible Role Documentation
original_path: roles/bootstrap_kvm/README.md
category: Ansible Roles
tags: [ansible, kvm, virtualization]
---

# bootstrap_kvm

An [Ansible](https://www.ansible.com) role to install [KVM](https://www.linux-kvm.org/page/Main_Page).

## Role Variables

Refer to [defaults/main.yml](defaults/main.yml) for a comprehensive list of available variables.

## Dependencies

- None

## Example Playbook

```yaml
- hosts: kvm_hosts
  vars: {}
  roles:
    - role: bootstrap_kvm
  tasks: []
```

## Booting a VM from ISO

You can boot a defined VM up with an ISO by using the following example:

> **NOTE:** Ensure that the default `kvm_manage_vms: false` is changed to `kvm_manage_vms: true`.

```yaml
kvm_manage_vms: true
kvm_vms:
  - name: test_vm
    autostart: true
    # Define boot devices in order of preference
    boot_devices:
      - cdrom
      - network
      - hd
    cdrom:
      source: /path/to/iso
    graphics: false
    # Define disks in MB
    disks:
      - disk_driver: virtio
        name: test_vm.1
        size: 36864
    memory: 512
    network_interfaces:
      - source: default
        network_driver: virtio
        portgroup: vlan-102
        type: network
    state: running
    vcpu: 1
```

## Backlinks

- [Ansible Roles](/ansible-roles)
- [KVM Setup Guide](/kvm-setup-guide)
```

This improved version includes a YAML frontmatter with additional metadata, clear headings, and a "Backlinks" section for better navigation.