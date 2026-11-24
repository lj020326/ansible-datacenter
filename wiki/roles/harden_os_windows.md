---
title: "Harden OS Windows Role"
role: roles/harden_os_windows
category: Roles
type: ansible-role
tags: [ansible, role, harden_os_windows]
---

# Harden OS Windows

The `harden_os_windows` Ansible role is designed to harden Windows operating systems by applying a variety of security configurations and best practices. This role covers a wide range of security measures, including registry settings, group policies, service configurations, and more.

## Table of Contents

- [Overview](#overview)
- [Variables](#variables)
- [Usage](#usage)
- [Dependencies](#dependencies)
- [Best Practices](#best-practices)
- [Examples](#examples)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)
- [Compatibility](#compatibility)

## Overview

This Ansible role applies security hardening measures to Windows operating systems. It includes configurations for registry settings, group policies, service configurations, and more. The role is designed to be flexible and customizable, allowing administrators to enable or disable specific hardening measures as needed.

## Variables

The following table lists the default values and descriptions for the variables used in this role:

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `harden_win_networkpath` | `''` | Network path for hardening operations. |
| `harden_win_networkdrive` | `''` | Network drive for hardening operations. |
| `harden_win_temp_dir` | `'c:\\Program Files\\ansible'` | Temporary directory for storing files during hardening. |
| `harden_win_log_dir` | `'c:\\ProgramData\\ansible\\log'` | Directory for storing log files. |
| `harden_win_securityupdates` | `false` | Whether to install security updates. |
| `harden_win_registry` | `true` | Whether to apply registry settings. |
| `harden_win_registry_hkcu_ansible_user` | `true` | Whether to apply registry settings for the Ansible user. |
| `harden_win_gpo_local` | `true` | Whether to apply local Group Policy settings. |
| `harden_win_gpo_action` | `'security_policy'` | Action to take for Group Policy settings. |
| `harden_win_gpo_inf` | `'win7-computer-security.inf'` | INF file for Group Policy settings. |
| `harden_win_gpo_db` | `"c:\\windows\\security\\database\\newdb.sdb"` | Database file for Group Policy settings. |
| `harden_win_gpo_log` | `{{ harden_win_log_dir }}\\secedit.txt` | Log file for Group Policy settings. |
| `harden_win_gpo_EnableLUA` | `true` | Whether to enable LUA (Least Privilege User Account). |
| `harden_win_inf_MinimumPasswordAge` | `1` | Minimum password age in days. |
| `harden_win_inf_MaximumPasswordAge` | `60` | Maximum password age in days. |
| `harden_win_inf_MinimumPasswordLength` | `14` | Minimum password length. |
| `harden_win_inf_PasswordHistorySize` | `24` | Password history size. |
| `harden_win_inf_PasswordComplexity` | `1` | Password complexity setting. |
| `harden_win_inf_LockoutBadCount` | `4` | Number of bad login attempts before lockout. |
| `harden_win_inf_ResetLockoutCount` | `15` | Time in minutes to reset lockout count. |
| `harden_win_inf_LockoutDuration` | `15` | Lockout duration in minutes. |
| `harden_win_inf_SeRemoteInteractiveLogonRight` | `'*S-1-5-32-544'` | Remote interactive logon right. |
| `harden_win_inf_SeTcbPrivilege` | `'*S-1-0-0'` | Trusted Computing Base (TCB) privilege. |
| `harden_win_inf_SeMachineAccountPrivilege` | `'*S-1-5-32-544'` | Machine account privilege. |
| `harden_win_inf_SeTrustedCredManAccessPrivilege` | `'*S-1-0-0'` | Trusted Credential Manager access privilege. |
| `harden_win_inf_SeNetworkLogonRight` | `'*S-1-0-0,*S-1-5-32-544'` | Network logon right. |
| `harden_win_inf_SeRemoteInteractiveLogonRight_list` | `['Administrators']` | List of users with remote interactive logon right. |
| `harden_win_inf_SeTcbPrivilege_list` | `['Null SID']` | List of users with TCB privilege. |
| `harden_win_inf_SeMachineAccountPrivilege_list` | `['Administrators']` | List of users with machine account privilege. |
| `harden_win_inf_SeTrustedCredManAccessPrivilege_list` | `['Null SID']` | List of users with Trusted Credential Manager access privilege. |
| `harden_win_inf_SeNetworkLogonRight_list` | `['Administrators']` | List of users with network logon right. |
| `harden_win_inf_SeDenyNetworkLogonRight_list` | `['Guests', 'Power Users']` | List of users denied network logon right. |
| `harden_win_inf_SeCreateSymbolicLinkPrivilege_list` | `['Administrators']` | List of users with symbolic link creation privilege. |
| `harden_win_inf_SeBatchLogonRight_list` | `['Null SID']` | List of users with batch logon right. |
| `harden_win_inf_SeDenyBatchLogonRight_list` | `[]` | List of users denied batch logon right. |
| `harden_win_inf_SeDenyInteractiveLogonRight_list` | `['Guests']` | List of users denied interactive logon right. |
| `harden_win_inf_SeDenyRemoteInteractiveLogonRight_list` | `['Guests']` | List of users denied remote interactive logon right. |

## Usage

To use this role, include it in your playbook and set the desired variables:

```yaml
- hosts: windows
  roles:
    - role: harden_os_windows
      vars:
        harden_win_networkpath: '\\\\server\\share'
        harden_win_networkdrive: 'Z:'
        harden_win_temp_dir: 'c:\\temp'
        harden_win_log_dir: 'c:\\logs'
        harden_win_securityupdates: true
        harden_win_registry: true
        harden_win_registry_hkcu_ansible_user: true
        harden_win_gpo_local: true
        harden_win_gpo_action: 'security_policy'
        harden_win_gpo_inf: 'win7-computer-security.inf'
        harden_win_gpo_db: 'c:\\windows\\security\\database\\newdb.sdb'
        harden_win_gpo_log: 'c:\\logs\\secedit.txt'
        harden_win_gpo_EnableLUA: true
        harden_win_inf_MinimumPasswordAge: 1
        harden_win_inf_MaximumPasswordAge: 60
        harden_win_inf_MinimumPasswordLength: 14
        harden_win_inf_PasswordHistorySize: 24
        harden_win_inf_PasswordComplexity: 1
        harden_win_inf_LockoutBadCount: 4
        harden_win_inf_ResetLockoutCount: 15
        harden_win_inf_LockoutDuration: 15
        harden_win_inf_SeRemoteInteractiveLogonRight: '*S-1-5-32-544'
        harden_win_inf_SeTcbPrivilege: '*S-1-0-0'
        harden_win_inf_SeMachineAccountPrivilege: '*S-1-5-32-544'
        harden_win_inf_SeTrustedCredManAccessPrivilege: '*S-1-0-0'
        harden_win_inf_SeNetworkLogonRight: '*S-1-0-0,*S-1-5-32-544'
        harden_win_inf_SeRemoteInteractiveLogonRight_list: ['Administrators']
        harden_win_inf_SeTcbPrivilege_list: ['Null SID']
        harden_win_inf_SeMachineAccountPrivilege_list: ['Administrators']
        harden_win_inf_SeTrustedCredManAccessPrivilege_list: ['Null SID']
        harden_win_inf_SeNetworkLogonRight_list: ['Administrators']
        harden_win_inf_SeDenyNetworkLogonRight_list: ['Guests', 'Power Users']
        harden_win_inf_SeCreateSymbolicLinkPrivilege_list: ['Administrators']
        harden_win_inf_SeBatchLogonRight_list: ['Null SID']
        harden_win_inf_SeDenyBatchLogonRight_list: []
        harden_win_inf_SeDenyInteractiveLogonRight_list: ['Guests']
        harden_win_inf_SeDenyRemoteInteractiveLogonRight_list: ['Guests']
```

## Dependencies

This role does not have any specific dependencies, but it assumes that Ansible is properly installed and configured on the control node, and that the Windows targets are properly set up to be managed by Ansible.

## Best Practices

- Test the role in a development or staging environment before applying it to production systems.
- Review and customize the variables to match your organization's security policies.
- Monitor the system after applying the role to ensure that the hardening measures do not negatively impact system functionality.
- Regularly update the role to incorporate the latest security best practices.

## Examples

### Basic Usage

A simple example of using the role with default variables:

```yaml
- hosts: windows
  roles:
    - role: harden_os_windows
```

### Customizing Variables

An example of customizing some of the variables:

```yaml
- hosts: windows
  roles:
    - role: harden_os_windows
      vars:
        harden_win_securityupdates: true
        harden_win_gpo_EnableLUA: false
        harden_win_inf_MinimumPasswordLength: 12
```

## Testing

To test the role, you can use Molecule, which is an isolation tool for testing Ansible roles. The role includes a Molecule scenario that you can use to test the role in a local Docker container.

To run the tests, execute the following commands:

```bash
# Install Molecule and its dependencies
pip install molecule[docker]

# Create a Docker container and run the tests
molecule test
```

## Contributing

Contributions to this role are welcome. Please follow these guidelines:

1. Fork the repository and create a new branch for your changes.
2. Make your changes and test them thoroughly.
3. Submit a pull request with a clear description of your changes.

## License

This role is licensed under the MIT License. See the LICENSE file for details.

## Compatibility

This role is compatible with the following Windows versions:

- Windows 7
- Windows 8
- Windows 10
- Windows Server 2008 R2
- Windows Server 2012
- Windows Server 2012 R2
- Windows Server 2016
- Windows Server 2019