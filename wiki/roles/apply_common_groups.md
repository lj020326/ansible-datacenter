---
title: "apply_common_groups Role Documentation"
role: apply_common_groups
category: Ansible Roles
type: Configuration Management
tags: ansible, role, common-groups, os-grouping, machine-grouping, systemd-status

---

## Summary

The `apply_common_groups` Ansible role is designed to dynamically group hosts based on their operating system type, distribution, version, and whether they are running inside a container or as virtual machines. It also checks the status of systemd if applicable and groups hosts accordingly.

## Variables

| Variable Name                         | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|---------------------------------------|---------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `apply_common_groups__base_groupname` | `"common_groups"`                                                                                       | The base name used to construct group names for OS, machine type, and network configurations.                                                                                                               |
| `apply_common_groups__dns_servers`    | `["192.168.0.4", "192.168.0.11", "192.168.1.12", "192.168.1.11"]`                                         | A list of DNS servers used to resolve the host's IP address if `default_ipv4.address` is not available.                                                                                                      |

## Usage

To use this role, include it in your playbook and optionally override any variables as needed:

```yaml
- hosts: all
  roles:
    - apply_common_groups
```

Example of overriding the base group name and DNS servers:

```yaml
- hosts: all
  vars:
    apply_common_groups__base_groupname: "custom_groups"
    apply_common_groups__dns_servers:
      - 8.8.8.8
      - 8.8.4.4
  roles:
    - apply_common_groups
```

## Dependencies

This role does not have any external dependencies other than the standard Ansible modules used.

## Tags

No specific tags are defined in this role. However, you can use the default `always` tag to run all tasks within the role:

```bash
ansible-playbook your_playbook.yml -t always
```

## Best Practices

- Ensure that the DNS servers provided in `apply_common_groups__dns_servers` are reachable from the target hosts.
- Review the generated groups after running the playbook to ensure they align with your expectations.

## Molecule Tests

This role does not include any Molecule tests. Consider adding them for automated testing and validation of the role's functionality.

## Backlinks

- [defaults/main.yml](../../roles/apply_common_groups/defaults/main.yml)
- [tasks/main.yml](../../roles/apply_common_groups/tasks/main.yml)
- [tasks/set-machine-groups.yml](../../roles/apply_common_groups/tasks/set-machine-groups.yml)
- [tasks/set-os-groups.yml](../../roles/apply_common_groups/tasks/set-os-groups.yml)
- [tasks/set-systemd-status.yml](../../roles/apply_common_groups/tasks/set-systemd-status.yml)

---

This documentation provides a comprehensive overview of the `apply_common_groups` role, including its purpose, configuration options, and usage instructions.