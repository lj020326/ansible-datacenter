---
title: "Bootstrap Windows Firewall Role"
role: roles/bootstrap_windows_firewall
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_windows_firewall]
---

# Bootstrap Windows Firewall Role

## Purpose

The `bootstrap_windows_firewall` role is designed to configure and manage Windows Firewall settings on Windows systems. It provides a comprehensive set of tasks to create, modify, and import firewall rules, ensuring that the system's security posture is maintained according to specified policies.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `win_temp_dir` | `c:\Program Files\ansible` | Temporary directory for Ansible operations |
| `win_log_dir` | `c:\ProgramData\ansible\log` | Directory for Ansible logs |
| `win_firewall` | `true` | Enable or disable firewall configuration |
| `win_config` | `import` | Configuration mode: `rule` or `import` |
| `win_firewall_policy` | `policy.wfw` | Path to the firewall policy file |
| `win_fw_default_action` | `block` | Default action for firewall rules |
| `win_msoffice_version_short` | `"16"` | Short version of Microsoft Office |
| `win_fw_program_allowed_out_public` | List of allowed programs | Programs allowed to communicate outbound on the public network |
| `win_fw_program_blocked_out_public` | List of blocked programs | Programs blocked from communicating outbound on the public network |

## Usage

To use this role, include it in your playbook and set the necessary variables:

```yaml
- hosts: windows
  roles:
    - role: bootstrap_windows_firewall
      vars:
        win_firewall: true
        win_config: import
        win_firewall_policy: policy.wfw
```

## Dependencies

This role requires the following Ansible collections:

- `ansible.windows`
- `community.windows`

## Best Practices

- Ensure that the `win_firewall_policy` file is accessible and correctly configured.
- Review and customize the `win_fw_program_allowed_out_public` and `win_fw_program_blocked_out_public` variables to match your organization's security requirements.
- Regularly update the firewall rules to address new security threats and compliance requirements.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_windows_firewall/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_windows_firewall/tasks/main.yml)
- [tasks/windows-firewall-import.yml](../../roles/bootstrap_windows_firewall/tasks/windows-firewall-import.yml)
- [tasks/windows-firewall-unit.yml](../../roles/bootstrap_windows_firewall/tasks/windows-firewall-unit.yml)
- [tasks/windows-firewall.yml](../../roles/bootstrap_windows_firewall/tasks/windows-firewall.yml)
- [handlers/main.yml](../../roles/bootstrap_windows_firewall/handlers/main.yml)