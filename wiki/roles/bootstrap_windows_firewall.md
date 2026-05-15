---
title: Bootstrap Windows Firewall Role Documentation
role: bootstrap_windows_firewall
category: Security
type: Ansible Role
tags: windows, firewall, security, ansible
---

## Summary

The `bootstrap_windows_firewall` role is designed to configure and manage the Windows Firewall settings on target Windows hosts. It can either import a predefined firewall policy or create specific rules based on provided configurations. The role ensures that critical system services are allowed while blocking potentially harmful applications and ports.

## Variables

| Variable Name                              | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|--------------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `role_bootstrap_windows_firewall__win_temp_dir`  | `c:\Program Files\ansible`                                                                              | Temporary directory for storing files used by the role.                                                                                                                                                       |
| `role_bootstrap_windows_firewall__win_log_dir`   | `c:\ProgramData\ansible\log`                                                                            | Directory for logging firewall configuration activities.                                                                                                                                                    |
| `role_bootstrap_windows_firewall__win_firewall`  | `true`                                                                                                | Enable or disable Windows Firewall on the target host.                                                                                                                                                    |
| `role_bootstrap_windows_firewall__win_config`    | `import`                                                                                              | Configuration method: either `rule` to create individual rules or `import` to import a predefined policy file.                                                                                            |
| `role_bootstrap_windows_firewall__win_firewall_policy` | `policy.wfw`                                                                                          | Name of the firewall policy file to be imported if `win_config` is set to `import`.                                                                                                                        |
| `role_bootstrap_windows_firewall__win_fw_default_action` | `block`                                                                                             | Default action for firewall rules (either `allow` or `block`).                                                                                                                                              |
| `role_bootstrap_windows_firewall__win_msoffice_version_short` | `"16"`                                                                                            | Short version number of Microsoft Office installed on the system.                                                                                                                                         |
| `role_bootstrap_windows_firewall__win_fw_program_allowed_out_public` | List of programs allowed to send outgoing traffic in Public profile.                                                                  | List of executable paths for programs that are allowed to send outgoing traffic in the Public network profile.                                                                                            |
| `role_bootstrap_windows_firewall__win_fw_program_blocked_out_public` | List of programs blocked from sending outgoing traffic in Public profile.                                                               | List of executable paths for programs that are blocked from sending outgoing traffic in the Public network profile.                                                                                         |

## Usage

To use this role, include it in your playbook and configure the variables as needed. Here is an example playbook:

```yaml
---
- name: Configure Windows Firewall
  hosts: windows_servers
  roles:
    - role: bootstrap_windows_firewall
      vars:
        role_bootstrap_windows_firewall__win_temp_dir: "c:\\Program Files\\ansible"
        role_bootstrap_windows_firewall__win_log_dir: "c:\\ProgramData\\ansible\\log"
        role_bootstrap_windows_firewall__win_config: "rule"
```

## Dependencies

This role does not have any external dependencies. However, it requires the `community.windows` collection to be installed:

```bash
ansible-galaxy collection install community.windows
```

## Best Practices

- Ensure that the firewall policy file (`policy.wfw`) is securely stored and accessible by Ansible.
- Regularly review and update the list of allowed and blocked programs and ports to align with security best practices.
- Use the `win_config` variable to switch between importing a policy or defining rules manually based on your specific requirements.

## Molecule Tests

This role does not include Molecule tests. To ensure the role functions correctly, consider writing and running Molecule tests in the future.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_windows_firewall/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_windows_firewall/tasks/main.yml)
- [tasks/windows-firewall-import.yml](../../roles/bootstrap_windows_firewall/tasks/windows-firewall-import.yml)
- [tasks/windows-firewall-unit.yml](../../roles/bootstrap_windows_firewall/tasks/windows-firewall-unit.yml)
- [tasks/windows-firewall.yml](../../roles/bootstrap_windows_firewall/tasks/windows-firewall.yml)