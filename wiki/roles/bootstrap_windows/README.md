```markdown
---
title: Ansible Role - bootstrap_windows
original_path: roles/bootstrap_windows/README.md
category: Ansible Roles
tags: [ansible, windows, kvm, virtio, spice]
---

# Ansible Role: bootstrap_windows

This role installs essential Windows drivers and SPICE Guest Tools:

- **Virtio Network Driver** ([netkvm](https://github.com/ansible-bootstrap-windows/kvm-guest-drivers-windows/tree/master/NetKVM))
- **Virtio Block Driver** ([viostor](https://github.com/ansible-bootstrap-windows/kvm-guest-drivers-windows/tree/master/viostor))
- **QXL Graphics Driver** (qxldod)
- **VirtIO SCSI Pass-through Controller Driver** ([vioscsi](https://github.com/ansible-bootstrap-windows/kvm-guest-drivers-windows/tree/master/vioscsi))
- **Balloon Driver** ([Balloon](https://github.com/ansible-bootstrap-windows/kvm-guest-drivers-windows/tree/master/Balloon))
- **Virtio RNG Driver** ([viorng](https://github.com/ansible-bootstrap-windows/kvm-guest-drivers-windows/tree/master/viorng))
- **Virtio Serial Driver** ([vioserial](https://github.com/ansible-bootstrap-windows/kvm-guest-drivers-windows/tree/master/vioserial))
- **Virtio Input Driver** ([vioinput](https://github.com/ansible-bootstrap-windows/kvm-guest-drivers-windows/tree/master/vioinput))
- **pvpanic Device Driver** ([pvpanic](https://github.com/ansible-bootstrap-windows/kvm-guest-drivers-windows/tree/master/pvpanic))
- **QEMU Guest Agent** ([qemu-ga-x86_64](https://wiki.libvirt.org/page/Qemu_guest_agent))
- **SPICE Guest Tools** ([vdagent-win](https://www.spice-space.org))

These drivers and tools are essential for optimal performance when running Windows on the KVM hypervisor using VirtIO.

## Requirements

- Ansible 2.7 or later

## Role Variables

Available variables are listed below, along with their default values (see `defaults/main.yml`):

```yaml
# Find available versions here: https://www.spice-space.org/download/windows/vdagent/
bootstrap_windows_vdagent_win_version: 0.9.0

# URL of the ansible-bootstrap-windows.iso
bootstrap_windows_virtio_win_iso_url: https://fedorapeople.org/groups/virt/ansible-bootstrap-windows/direct-downloads/latest-virtio/ansible-bootstrap-windows.iso

# Path where files/directories from ansible-bootstrap-windows.iso are located (usually CD-ROM).
# If set, the ansible-bootstrap-windows.iso will be downloaded.
bootstrap_windows_virtio_win_iso_path: E:\\
```

## Dependencies

- Windows 64-bit (amd64) (x64)

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: ruzickap.ansible-bootstrap-windows
      # or specify a custom ISO path
      bootstrap_windows_virtio_win_iso_path: 'E:\\'
```

## Backlinks

- [Ansible Roles](/categories/ansible-roles)
- [KVM Hypervisor](/tags/kvm)
- [VirtIO Drivers](/tags/virtio)
- [SPICE Guest Tools](/tags/spice)
```

This Markdown document is now clean, professional, and optimized for GitHub rendering while maintaining all original information and meaning.