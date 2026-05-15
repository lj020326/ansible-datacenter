```markdown
---
title: "apply_common_groups Role Documentation"
original_path: roles/apply_common_groups/README.md
category: Ansible Roles
type: Configuration Management
tags: ansible, role, common-groups, os-detection, machine-type, systemd-status
---

# apply_common_groups Role Documentation

## Summary

The `apply_common_groups` Ansible role is designed to dynamically assign hosts to specific groups based on their operating system type, machine type (e.g., container, VM, baremetal), and the status of the systemd service manager. This role helps in organizing inventory into meaningful groups that can be used for targeted configuration management and automation tasks.

## Variables

The following variables are configurable by users:

- `apply_common_groups__base_groupname`: The base name used to construct group names for OS, machine type, and network configurations. Defaults to `"common_groups"`.
  
- `apply_common_groups__dns_servers`: A list of DNS servers used to resolve the host's IP address via DNS lookup. Defaults to a predefined set of IPs.

## Usage

To use this role in your Ansible playbook, include it as follows:

```yaml
---
- name: "Apply common groups to hosts"
  tags: always
  hosts: all,!local,!host_offline
  gather_facts: yes
  roles:
    - role: apply_common_groups

- name: "Display common group information"
  debug:
    msg:
      ## dynamically derived common_groups__oc_* groups
      - "common_groups__network_group={{ common_groups__network_group }}"
      - "common_groups__oc_family={{ common_groups__oc_family }}"
      - "common_groups__oc_distribution={{ common_groups__oc_distribution }}"
      - "common_groups__oc_distribution_version={{ common_groups__oc_distribution_version }}"
      - "common_groups__oc_machine_type={{ common_groups__oc_machine_type }}"

## Should see the hosts added to the common groups in group_names in this task
- name: "Display group_names"
  debug:
    var: group_names | d('')
```

### Example Playbook

Here is an example playbook that demonstrates how to use the `apply_common_groups` role with custom DNS servers and a custom base group name:

```yaml
---
- name: Configure common groups for managed nodes
  hosts: all
  vars:
    apply_common_groups__base_groupname: "custom_groups"
    apply_common_groups__dns_servers:
      - 8.8.8.8
      - 8.8.4.4
  roles:
    - apply_common_groups
```

## Dependencies

This role does not have any external dependencies, but it requires the `community.dns` collection for DNS lookups:

```bash
ansible-galaxy collection install community.dns
```

## Tags

- `os-groups`: Applies OS-specific groups.
- `machine-groups`: Applies machine type-specific groups.
- `systemd-status`: Checks and applies systemd status-based groups.

To run tasks with specific tags, use the `--tags` option:

```bash
ansible-playbook playbook.yml --tags os-groups,machine-groups
```

## Best Practices

1. **Customize DNS Servers**: Adjust the `apply_common_groups__dns_servers` variable to match your network's DNS infrastructure.
2. **Consistent Group Naming**: Use a consistent base group name via `apply_common_groups__base_groupname` for better organization and readability.
3. **Regular Updates**: Ensure that the role is regularly updated to accommodate new operating systems and machine types.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, execute:

```bash
molecule test
```

Ensure you have Molecule installed along with any necessary drivers (e.g., Docker).

## Backlinks

- [defaults/main.yml](../../roles/apply_common_groups/defaults/main.yml)
- [tasks/main.yml](../../roles/apply_common_groups/tasks/main.yml)
- [tasks/set-machine-groups.yml](../../roles/apply_common_groups/tasks/set-machine-groups.yml)
- [tasks/set-os-groups.yml](../../roles/apply_common_groups/tasks/set-os-groups.yml)
- [tasks/set-systemd-status.yml](../../roles/apply_common_groups/tasks/set-systemd-status.yml)
```