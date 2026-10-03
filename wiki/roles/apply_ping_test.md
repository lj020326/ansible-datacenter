---
title: "Apply Ping Test Role"
role: roles/apply_ping_test
category: Roles
type: ansible-role
tags: [ansible, role, apply_ping_test]
---

```yaml
---
title: Apply Ping Test Role
role: apply_ping_test
category: Network
type: Role
---

# Apply Ping Test Role

The `apply_ping_test` role is designed to perform ping tests on hosts using various Ansible modules. This role supports testing connectivity using the `ping`, `win_ping`, and `net_ping` modules, providing flexibility for different types of hosts and network environments.

## Variables

| Variable Name                  | Default Value          | Description                                                                 |
|--------------------------------|------------------------|-----------------------------------------------------------------------------|
| `apply_ping_test__module`      | `ping`                 | Specifies the module to use for ping testing (`ping`, `win_ping`, `net_ping`). |
| `apply_ping_test__fallback_to_cli` | `false`          | Indicates whether to fallback to CLI for ping testing if the module fails. |
| `apply_ping_test__fail_when_discovered_offline` | `true` | Determines if the role should fail when a host is discovered to be offline. |

## Usage

To use this role, include it in your playbook and configure the variables as needed:

```yaml
- hosts: all
  roles:
    - role: apply_ping_test
      vars:
        apply_ping_test__module: "ping"
        apply_ping_test__fallback_to_cli: false
        apply_ping_test__fail_when_discovered_offline: true
```

## Dependencies

This role does not have any external dependencies. It relies solely on the Ansible modules `ping`, `win_ping`, and `net_ping`, which are included in the standard Ansible distribution.

## Best Practices

- Ensure that the appropriate Ansible modules are available on the control node.
- Configure the `apply_ping_test__module` variable based on the type of hosts you are testing (Linux, Windows, network devices).
- Use the `apply_ping_test__fallback_to_cli` variable to enable CLI fallback if module-based ping tests are not sufficient.
- Monitor the debug output for detailed information about the ping test results and connection variables.

## Backlinks

- [defaults/main.yml](../../roles/apply_ping_test/defaults/main.yml)
- [tasks/main.yml](../../roles/apply_ping_test/tasks/main.yml)

```