---
title: "apply_ping_test Role Documentation"
role: apply_ping_test
category: Ansible Roles
type: Technical Documentation
tags: ansible, role, ping, testing, automation
---

## Summary

The `apply_ping_test` role is designed to perform a ping test on target hosts using specified modules (`ping`, `win_ping`, or `net_ping`). It provides flexibility in handling different types of hosts and includes options for fallback mechanisms and failure conditions.

## Variables

| Variable Name                           | Default Value                  | Description                                                                 |
|-----------------------------------------|------------------------------|-----------------------------------------------------------------------------|
| `apply_ping_test__module`               | `ping`                       | Specifies the module to use for the ping test. Valid values are `ping`, `win_ping`, and `net_ping`. |
| `apply_ping_test__fallback_to_cli`      | `false`                      | If set to true, the role will attempt a fallback mechanism using CLI commands if the initial ping fails. (Not implemented in current version) |
| `apply_ping_test__fail_when_discovered_offline` | `true`                  | Determines whether the playbook should fail when a host is unreachable during the ping test. |

## Usage

To use this role, include it in your Ansible playbook and specify the desired module for the ping test via the `apply_ping_test__module` variable.

**Example Playbook:**

```yaml
---
- name: Perform ping tests on target hosts
  hosts: all
  roles:
    - role: apply_ping_test
      vars:
        apply_ping_test__module: win_ping
```

## Dependencies

This role does not have any external dependencies beyond the Ansible core modules and collections it uses (`ansible.builtin`, `ansible.windows`, `ansible.netcommon`).

## Tags

- `ping-test`: This tag can be used to run only the tasks related to the ping test.

**Example Command:**

```bash
ansible-playbook -i inventory playbook.yml --tags "ping-test"
```

## Best Practices

1. **Module Selection**: Choose the appropriate module (`ping`, `win_ping`, or `net_ping`) based on the type of target hosts.
2. **Error Handling**: Set `apply_ping_test__fail_when_discovered_offline` to `true` if you want the playbook to fail when a host is unreachable, ensuring that issues are caught early in the automation process.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding them for automated testing and validation of the role's functionality.

## Backlinks

- [defaults/main.yml](../../roles/apply_ping_test/defaults/main.yml)
- [tasks/main.yml](../../roles/apply_ping_test/tasks/main.yml)

---

**Note:** Ensure that the relative paths in the backlinks section match your project structure. Adjust them as necessary to point to the correct files.