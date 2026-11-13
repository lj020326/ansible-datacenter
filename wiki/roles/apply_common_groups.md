---
title: "Apply Common Groups Role"
role: roles/apply_common_groups
category: Roles
type: ansible-role
tags: [ansible, role, apply_common_groups]
---

```markdown
---
title: Apply Common Groups
role: apply_common_groups
category: System
type: Role
---

## Summary

The `apply_common_groups` role is designed to categorize hosts into groups based on their operating system, machine type, and systemd status. This role helps in organizing inventory and applying configurations more effectively by leveraging Ansible's dynamic grouping capabilities.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `__apply_common_groups_container_types` | `['docker', 'container', 'containerd']` | List of container types used to identify containerized environments. |
| `__apply_common_groups__base_groupname_default` | `common_groups` | Default base group name for common groups. |
| `__apply_common_groups__base_groupname` | `{{ apply_common_groups__base_groupname \| d(__apply_common_groups__base_groupname_default) }}` | Base group name for common groups. |
| `__apply_common_groups__os_base_groupname` | `{{ __apply_common_groups__base_groupname }}_os` | Base group name for OS-specific groups. |
| `__apply_common_groups__machine_base_groupname` | `{{ __apply_common_groups__base_groupname }}_machine` | Base group name for machine-specific groups. |
| `__apply_common_groups__network_base_groupname` | `{{ __apply_common_groups__base_groupname }}_network` | Base group name for network-specific groups. |
| `__apply_common_groups__dns_servers_default` | `['192.168.0.4', '192.168.0.11', '192.168.1.12', '192.168.1.11']` | Default DNS servers to query for machine IP. |
| `__apply_common_groups__dns_servers` | `{{ apply_common_groups__dns_servers \| d(__apply_common_groups__dns_servers_default) }}` | DNS servers to query for machine IP. |
| `__apply_common_groups__machine_dns_ipv4` | `{{ query('community.dns.lookup', inventory_hostname, server=__apply_common_groups__dns_servers, nxdomain_handling='empty') \| first }}` | Machine's IPv4 address resolved from DNS. |
| `__apply_common_groups__machine_address_list_ipv4` | `{{ ansible_facts.all_ipv4_addresses \| d(ansible_facts \| community.general.json_query('interfaces[*].ipv4.address')) \| d([], true) \| unique }}` | List of IPv4 addresses on the machine. |
| `__apply_common_groups__machine_ipv4` | `{{ ansible_facts['default_ipv4']['address'] \| d(__apply_common_groups__machine_dns_ipv4) \| d(__apply_common_groups__machine_address_list_ipv4 \| first) }}` | Machine's primary IPv4 address. |
| `__apply_common_groups__machine_ip` | `{{ __apply_common_groups__machine_ipv4 }}` | Machine's IP address. |

## Usage

To use the `apply_common_groups` role, include it in your playbook as follows:

```yaml
- hosts: all
  roles:
    - apply_common_groups
```

This will categorize all hosts into groups based on their OS, machine type, and systemd status. The groups will be created dynamically based on the facts gathered by Ansible.

## Dependencies

This role does not have any external dependencies. However, it relies on the following Ansible collections:

- `community.dns`
- `community.general`

Make sure these collections are installed in your Ansible environment.

## Best Practices

- Customize the DNS servers in the `apply_common_groups__dns_servers` variable if your environment uses different DNS servers.
- Ensure that the `community.dns` and `community.general` collections are installed to leverage the full functionality of this role.
- Review the dynamically created groups to understand the categorization and adjust your playbooks accordingly.

## Backlinks

- [defaults/main.yml](../../roles/apply_common_groups/defaults/main.yml)
- [tasks/main.yml](../../roles/apply_common_groups/tasks/main.yml)
- [tasks/set-machine-groups.yml](../../roles/apply_common_groups/tasks/set-machine-groups.yml)
- [tasks/set-os-groups.yml](../../roles/apply_common_groups/tasks/set-os-groups.yml)
- [tasks/set-systemd-status.yml](../../roles/apply_common_groups/tasks/set-systemd-status.yml)
```