Bootstrap-Linux-Mount Role
==================

An ansible role for mounting devices.

Role Variables
--------------

```yaml
# list of dictionaries holding all devices that need to be mounted.
bootstrap_linux_mount__list:
  - name: /                         # NO default
    src: /dev/mapper/root           # NO default
    fstype: ext4                    # NO default
    opts: noatime,errors=remount-ro # default: omit (written to fstab as "defaults")
    state: present                  # default: "mounted"
    dump: 0                         # default: omit (written to fstab as "0")
    passno: 1                       # default: omit (written to fstab as "0")
    fstab: /etc/fstab               # default: "/etc/fstab"
```

Example Playbook
----------------

```yaml
- hosts: servers
  roles:
    - { role: bootstrap-linux-mount, become: true }
```

