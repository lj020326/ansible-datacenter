# Ansible Role: ansible-bootstrap-windows

This role installs Windows drivers and spice-guest-tools:

* Virtio Network Driver ([netkvm](https://github.com/ansible-bootstrap-windows/kvm-guest-drivers-windows/tree/master/NetKVM))
* Virtio Block Driver ([viostor](https://github.com/ansible-bootstrap-windows/kvm-guest-drivers-windows/tree/master/viostor))
* QXL Graphics Driver (qxldod)
* VirtIO SCSI pass-through controller Driver ([vioscsi](https://github.com/ansible-bootstrap-windows/kvm-guest-drivers-windows/tree/master/vioscsi))
* Balloon Driver ([Balloon](https://github.com/ansible-bootstrap-windows/kvm-guest-drivers-windows/tree/master/Balloon))
* Virtio RNG driver ([viorng](https://github.com/ansible-bootstrap-windows/kvm-guest-drivers-windows/tree/master/viorng))
* Virtio serial driver ([vioserial](https://github.com/ansible-bootstrap-windows/kvm-guest-drivers-windows/tree/master/vioserial))
* Virtio Input driver ([vioinput](https://github.com/ansible-bootstrap-windows/kvm-guest-drivers-windows/tree/master/vioinput))
* pvpanic device driver ([pvpanic](https://github.com/ansible-bootstrap-windows/kvm-guest-drivers-windows/tree/master/pvpanic))
* Qemu Guest Agent ([qemu-ga-x86_64](https://wiki.libvirt.org/page/Qemu_guest_agent))
* SPICE Guest Tools ([vdagent-win](https://www.spice-space.org))

It's handy if you are running Windows on the KVM hypervisor in order to get the best performance using VirtIO drivers + tools.

## Requirements

Ansible 2.7 or later

## Role Variables

Available variables are listed below, along with default values
(see `defaults/main.yml`):

```yaml
# Find the available versions here https://www.spice-space.org/download/windows/vdagent/
bootstrap_windows_vdagent_win_version: 0.9.0

# URL of the ansible-bootstrap-windows.iso
bootstrap_windows_virtio_win_iso_url: https://fedorapeople.org/groups/virt/ansible-bootstrap-windows/direct-downloads/latest-virtio/ansible-bootstrap-windows.iso

# Path where the are the files/directories from ansible-bootstrap-windows.iso (usually CD-ROM).
# If this is set, then the ansible-bootstrap-windows.iso is going to be downloaded.
bootstrap_windows_virtio_win_iso_path: E:\\
```

## Dependencies

Windows 64 bit (amd64) (x64)

## Example Playbook

```yaml
- hosts: all
  roles:
    - { role: ruzickap.ansible-bootstrap-windows }
    # or
    - role: ruzickap.ansible-bootstrap-windows
      bootstrap_windows_virtio_win_iso_path: 'E:\\'
```

