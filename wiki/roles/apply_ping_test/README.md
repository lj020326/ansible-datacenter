```markdown
---
title: "apply_ping_test Role Documentation"
original_path: roles/apply_ping_test/README.md
category: Ansible Roles
type: Technical Documentation
tags: ansible, role, ping, testing, automation
---

# apply_ping_test Role Documentation

## Summary

The `apply_ping_test` role is designed to perform a ping test on target hosts using different modules based on the specified connection type. It supports standard SSH (`ping`), Windows (`win_ping`), and network devices (`net_ping`). The role provides flexibility in handling failures and can be configured to fall back to CLI commands if necessary.

The role will place each target host into `host_offline` and `discovered_host_offline` groups if the ping test fails. The `host_offline` group is expected to be an inventory-maintained group for hosts that have been taken offline for known reasons (maintenance, upgrade, etc.). The `discovered_host_offline` group supports issue escalation for hosts that are expected to be online but fail the ping test.

## Variables

| Variable                                        | Default Value | Description                                                                                                                  |
|-------------------------------------------------|---------------|------------------------------------------------------------------------------------------------------------------------------|
| `apply_ping_test__module`                       | `ping`        | Specifies the module to use for the ping test. Supported values: `ping`, `win_ping`, `net_ping`.                             |
| `apply_ping_test__fallback_to_cli`              | `false`       | Determines whether to fall back to CLI commands if the module fails. Currently, this feature is not implemented in the role. |
| `apply_ping_test__fail_when_discovered_offline` | `true`        | Specifies whether the play should fail when newly offline nodes are discovered during the ping test.                         |

## Usage

To use the `apply_ping_test` role, include it in your playbook and specify the desired module using the `apply_ping_test__module` variable.

### Example Playbook

```yaml
- name: "Run ping tests on target hosts (skip known host_offline group)"
  hosts: all,!host_offline
  roles:
    - role: apply_ping_test
      vars:
        apply_ping_test__module: ping

- name: Bootstrap linux
  hosts: os_linux,!host_offline
  gather_facts: false
  tags:
    - bootstrap-linux
    - bootstrap-host
  become: true
  roles:
    - role: bootstrap_linux

- name: "Report | Discovered Offline Hosts Summary"
  hosts: localhost
  gather_facts: false
  run_once: true
  tags:
    - always
    - ping-test
    - report-offline-hosts
  tasks:
    - name: Display summary of newly discovered offline hosts
      when: groups['discovered_host_offline'] | d([]) | length > 0
      ansible.builtin.debug:
        msg:
          - "##########################################################"
          - "THE FOLLOWING HOSTS WERE DISCOVERED OFFLINE DURING THIS RUN:"
          - "{{ groups['discovered_host_offline'] | d(['None']) }}"
          - "##########################################################"

    - name: Notify that all hosts were reachable
      when: groups['discovered_host_offline'] | d([]) | length == 0
      ansible.builtin.debug:
        msg: "All targeted hosts passed the connectivity pre-check."
```

## Dependencies

This role does not have any external dependencies. However, it requires the appropriate Ansible modules to be available based on the specified `apply_ping_test__module` value:

- `ansible.builtin.ping`
- `ansible.windows.win_ping`
- `ansible.netcommon.net_ping`

Ensure that the necessary collections are installed if using `win_ping` or `net_ping`.

## Tags

This role does not define any specific tags. However, you can use the default Ansible tags to target this role specifically:

```bash
ansible-playbook playbook.yml --tags apply_ping_test
```

## Best Practices

- **Avoid Hardcoding Inventory-Specific Variables**: The role is designed to be flexible and should not contain hardcoded inventory-specific variables.
- **Use Module Input Vars**: Configure the `apply_ping_test__module` variable based on your target hosts' connection types.
- **Handle Failures Gracefully**: Use the `apply_ping_test__fail_when_discovered_offline` variable to control whether the play should fail when offline nodes are detected.

## Molecule Tests

This role does not include any Molecule tests at this time. Consider adding Molecule scenarios to ensure the role behaves as expected across different environments and configurations.

## Backlinks

- [defaults/main.yml](../../roles/apply_ping_test/defaults/main.yml)
- [tasks/main.yml](../../roles/apply_ping_test/tasks/main.yml)
```