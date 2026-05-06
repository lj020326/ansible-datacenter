---
title: Bootstrap OS Client Role Documentation
role: bootstrap_osclient
category: Ansible Roles
type: Configuration
tags: openstack, credentials, ansible-role
---

## Summary

The `bootstrap_osclient` role is designed to read OpenStack credentials from a specified file and set them as an Ansible fact. This allows other roles or tasks within the playbook to utilize these credentials for interacting with OpenStack services.

## Variables

| Variable Name       | Default Value                      | Description                                                                 |
|---------------------|------------------------------------|-----------------------------------------------------------------------------|
| `credentials_file`  | `/etc/kolla/admin-openrc.sh`       | The path to the file containing the OpenStack admin credentials.            |

## Usage

To use this role, include it in your playbook and ensure that the `credentials_file` points to a valid OpenStack RC file. Here is an example of how you might include this role in a playbook:

```yaml
- name: Bootstrap OS Client Credentials
  hosts: localhost
  roles:
    - role: bootstrap_osclient
      vars:
        credentials_file: /path/to/your/admin-openrc.sh
```

## Dependencies

This role does not have any external dependencies beyond the standard Ansible modules used.

## Best Practices

- Ensure that the `credentials_file` is correctly specified and accessible by the user running the playbook.
- Use this role early in your playbook to set up the necessary credentials for subsequent tasks that interact with OpenStack services.

## Molecule Tests

This role does not currently include any Molecule tests. Consider adding Molecule scenarios to ensure the role functions as expected under various conditions.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_osclient/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_osclient/tasks/main.yml)