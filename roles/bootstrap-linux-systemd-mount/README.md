
# bootstrap-linux-systemd-mount

This Ansible role configures systemd mount files.

----

###### Example playbook

> See the "defaults.yml" file for a full list of all available options.

``` yaml
- name: Create a systemd mount file for Mount1 and 2
  hosts: localhost
  become: true
  roles:
    - role: bootstrap-linux-systemd-mount
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

## References

* https://github.com/openstack/ansible-role-systemd_mount
* https://github.com/openstack/ansible-role-systemd_service.git
* 