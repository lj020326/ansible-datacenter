---
title: Remove CloudStack Setup Role Documentation
role: remove_cloudstack_setup
category: Ansible Roles
type: Infrastructure Management
tags: cloudstack, ansible, package management, cleanup

---

## Summary

The `remove_cloudstack_setup` role is designed to uninstall all CloudStack-related packages and clean up specific directories and files associated with a CloudStack setup. This ensures that the system is returned to a state prior to any CloudStack installation.

## Variables

| Variable Name                | Default Value                                                                                           | Description                                                                 |
|------------------------------|---------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| `role_remove_cloudstack_setup__cloudstack_packages` | `['cloudstack-agent', 'cloudstack-usage', 'cloudstack-management', 'cloudstack-common', 'openvswitch', 'openvswitch-controller', 'MySQL-python', 'qemu-kvm', 'qemu-common', 'libvirt-daemon', 'libvirt-libs', 'libvirt-client', 'libvirt-python', 'libvirt-daemon-driver-qemu', 'libvirt-daemon-config-network']` | List of CloudStack-related packages to be removed.                          |
| `role_remove_cloudstack_setup__directories_to_clean` | `/usr/lib64/python2.7/site-packages/cloudutils, /var/lib/mysql, /etc/my.cnf`    | List of directories and files to be cleaned up after package removal.       |

## Usage

To use the `remove_cloudstack_setup` role, include it in your playbook as follows:

```yaml
- hosts: cloudstack_servers
  roles:
    - remove_cloudstack_setup
```

You can override the default variables by specifying them in your inventory or playbook:

```yaml
- hosts: cloudstack_servers
  vars:
    role_remove_cloudstack_setup__cloudstack_packages:
      - cloudstack-agent
      - cloudstack-management
    role_remove_cloudstack_setup__directories_to_clean:
      - /usr/lib64/python2.7/site-packages/cloudutils
      - /var/lib/mysql
  roles:
    - remove_cloudstack_setup
```

## Dependencies

This role does not have any external dependencies.

## Best Practices

- Ensure that the target hosts are backed up before running this role, as it will permanently remove CloudStack packages and data.
- Verify that no active services or processes are using the CloudStack components being removed to avoid disruptions.

## Molecule Tests

No Molecule tests are currently available for this role. Consider adding them to ensure the role behaves as expected in different environments.

## Backlinks

- [tasks/main.yml](../../roles/remove_cloudstack_setup/tasks/main.yml)