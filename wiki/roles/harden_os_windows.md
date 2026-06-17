---
title: Windows Hardening Role Documentation
role: harden_os_windows
category: System Security
type: Ansible Role
tags: windows, security, hardening

## Summary
The `harden_os_windows` role is designed to enhance the security posture of Windows systems by applying a comprehensive set of hardening measures. This includes configuring system settings, managing user permissions, disabling unnecessary services, and enforcing strong security policies.

## Variables

| Variable Name                                      | Default Value                                                                 | Description                                                                                                                                                                                                 |
|----------------------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `harden_win_networkpath`                           | ``                                                                            | Network path for configuration files.                                                                                                                                                                       |
| `harden_win_networkdrive`                          | ``                                                                            | Network drive for additional resources.                                                                                                                                                                     |
| `harden_win_temp_dir`                              | `c:\Program Files\ansible`                                                    | Temporary directory for storing downloaded and generated files.                                                                                                                                             |
| `harden_win_log_dir`                               | `c:\ProgramData\ansible\log`                                                  | Directory for logging hardening activities.                                                                                                                                                                 |
| `harden_win_securityupdates`                       | `false`                                                                       | Whether to install all security/critical updates.                                                                                                                                                           |
| `harden_win_registry`                              | `true`                                                                        | Enable registry hardening tasks.                                                                                                                                                                            |
| `harden_win_registry_hkcu_ansible_user`            | `true`                                                                        | Apply specific registry settings for the Ansible user in HKCU.                                                                                                                                            |
| `harden_win_gpo_local`                             | `true`                                                                        | Apply local Group Policy Objects (GPOs).                                                                                                                                                                    |
| `harden_win_gpo_action`                            | `security_policy`                                                             | Method to apply GPOs (`secedit`, `ps`, `dsc`, or `security_policy`).                                                                                                                                      |
| `harden_win_gpo_inf`                               | `win7-computer-security.inf`                                                  | INF file for security policy settings.                                                                                                                                                                    |
| `harden_win_gpo_db`                                | `c:\\windows\\security\\database\\newdb.sdb`                                   | Security database path for secedit.                                                                                                                                                                       |
| `harden_win_gpo_log`                               | `{{ harden_win_log_dir }}\\secedit.txt`                                         | Log file for secedit operations.                                                                                                                                                                          |
| `harden_win_gpo_EnableLUA`                         | `true`                                                                        | Enable User Account Control (UAC).                                                                                                                                                                        |
| `harden_win_inf_MinimumPasswordAge`                | `1`                                                                           | Minimum password age in days.                                                                                                                                                                             |
| `harden_win_inf_MaximumPasswordAge`                | `60`                                                                          | Maximum password age in days.                                                                                                                                                                             |
| `harden_win_inf_MinimumPasswordLength`             | `14`                                                                          | Minimum password length in characters.                                                                                                                                                                    |
| `harden_win_inf_PasswordHistorySize`               | `24`                                                                          | Number of unique passwords that must be used before a given password can be reused.                                                                                                                        |
| `harden_win_inf_PasswordComplexity`                | `1`                                                                           | Enforce strong password complexity requirements.                                                                                                                                                            |
| `harden_win_inf_LockoutBadCount`                   | `4`                                                                           | Number of failed logon attempts that will cause the account to be locked.                                                                                                                                   |
| `harden_win_inf_ResetLockoutCount`                 | `15`                                                                          | Time in minutes after which the bad password count is reset to zero.                                                                                                                                      |
| `harden_win_inf_LockoutDuration`                   | `15`                                                                          | Time in minutes that an account will remain locked after reaching the maximum number of failed logon attempts.                                                                                              |
| `harden_win_inf_SeRemoteInteractiveLogonRight`     | `*S-1-5-32-544`                                                               | Security identifier (SID) for users allowed to log on locally.                                                                                                                                            |
| `harden_win_inf_SeTcbPrivilege`                    | `*S-1-0-0`                                                                    | SID for users with the ability to act as part of the operating system.                                                                                                                                      |
| `harden_win_inf_SeMachineAccountPrivilege`         | `*S-1-5-32-544`                                                               | SID for users allowed to add workstations and servers to a domain.                                                                                                                                        |
| `harden_win_inf_SeTrustedCredManAccessPrivilege`   | `*S-1-0-0`                                                                    | SID for users who can access the computer's stored credentials.                                                                                                                                             |
| `harden_win_inf_SeNetworkLogonRight`               | `*S-1-0-0,*S-1-5-32-544`                                                      | SID for users allowed to log on through network.                                                                                                                                                            |
| `harden_win_inf_SeRemoteInteractiveLogonRight_list`| `['Administrators']`                                                          | List of groups/users allowed to log on locally.                                                                                                                                                             |
| `harden_win_inf_SeTcbPrivilege_list`               | `['Null SID']`                                                              | List of groups/users with the ability to act as part of the operating system.                                                                                                                             |
| `harden_win_inf_SeMachineAccountPrivilege_list`    | `['Administrators']`                                                          | List of groups/users allowed to add workstations and servers to a domain.                                                                                                                                   |
| `harden_win_inf_SeTrustedCredManAccessPrivilege_list`| `['Null SID']`                                                              | List of groups/users who can access the computer's stored credentials.                                                                                                                                    |
| `harden_win_inf_SeNetworkLogonRight_list`          | `['Administrators']`                                                          | List of groups/users allowed to log on through network.                                                                                                                                                     |
| `harden_win_inf_SeDenyNetworkLogonRight_list`      | `['Guests', 'Power Users']`                                                   | List of groups/users denied access to log on through network.                                                                                                                                             |
| `harden_win_inf_SeCreateSymbolicLinkPrivilege_list`| `['Administrators']`                                                          | List of groups/users allowed to create symbolic links.                                                                                                                                                      |
| `harden_win_inf_SeBatchLogonRight_list`            | `['Null SID']`                                                              | List of groups/users allowed to log on as a batch job.                                                                                                                                                    |
| `harden_win_inf_SeDenyBatchLogonRight_list`        | `[]`                                                                          | List of groups/users denied access to log on as a batch job.                                                                                                                                              |
| `harden_win_inf_SeDenyInteractiveLogonRight_list`  | `['Guests']`                                                                | List of groups/users denied access to log on locally.                                                                                                                                                     |
| `harden_win_inf_SeDenyRemoteInteractiveLogonRight_list`| `['Guests']`                                                              | List of groups/users denied access to log on remotely.                                                                                                                                                    |

## Usage

To use the `harden_os_windows` role, include it in your playbook and configure the necessary variables as per your requirements.

Example Playbook:
```yaml
- name: Harden Windows Systems
  hosts: windows_servers
  gather_facts: yes
  roles:
    - role: harden_os_windows
      vars:
        harden_win_securityupdates: true
        harden_win_inf_MinimumPasswordLength: 16
```

## Dependencies

This role does not have any external dependencies. However, it utilizes several Ansible modules and collections such as `ansible.windows`, `community.windows`, and `chocolatey.chocolatey`.

## Best Practices

- Ensure that the target Windows systems are backed up before applying hardening measures.
- Review and customize the variables to align with your organization's security policies.
- Test the role in a non-production environment before deploying it to production systems.

## Molecule Tests

This role does not include Molecule tests. However, thorough testing is recommended in a controlled environment to ensure that all tasks are applied correctly without disrupting system functionality.

## Backlinks

- [defaults/main.yml](../../roles/harden_os_windows/defaults/main.yml)
- [tasks/adobereader.yml](../../roles/harden_os_windows/tasks/adobereader.yml)
- [tasks/dc-krgtbt-reset.yml](../../roles/harden_os_windows/tasks/dc-krgtbt-reset.yml)
- [tasks/dc-ldap-signing.yml](../../roles/harden_os_windows/tasks/dc-ldap-signing.yml)
- [tasks/extras.yml](../../roles/harden_os_windows/tasks/extras.yml)
- [tasks/forcing-afterhours-user-logoffs.yml](../../roles/harden_os_windows/tasks/forcing-afterhours-user-logoffs.yml)
- [tasks/join-domain.yml](../../roles/harden_os_windows/tasks/join-domain.yml)
- [tasks/main.yml](../../roles/harden_os_windows/tasks/main.yml)
- [tasks/mbrfilter.yml](../../roles/harden_os_windows/tasks/mbrfilter.yml)
- [tasks/palantir-AutorunsToWinEventLog.yml](../../roles/harden_os_windows/tasks/palantir-AutorunsToWinEventLog.yml)
- [tasks/passwd-filters.yml](../../roles/harden_os_windows/tasks/passwd-filters.yml)
- [tasks/process-mitigation.yml](../../roles/harden_os_windows/tasks/process-mitigation.yml)
- [tasks/testing-defender.yml](../../roles/harden_os_windows/tasks/testing-defender.yml)
- [tasks/testing-densityscout.yml](../../roles/harden_os_windows/tasks/testing-densityscout.yml)
- [tasks/testing-domain.yml](../../roles/harden_os_windows/tasks/testing-domain.yml)
- [tasks/testing-iad.yml](../../roles/harden_os_windows/tasks/testing-iad.yml)
- [tasks/testing-intelme.yml](../../roles/harden_os_windows/tasks/testing-intelme.yml)
- [tasks/testing-mimikatz.yml](../../roles/harden_os_windows/tasks/testing-mimikatz.yml)
- [tasks/testing-opf.yml](../../roles/harden_os_windows/tasks/testing-opf.yml)
- [tasks/testing-speculative.yml](../../roles/harden_os_windows/tasks/testing-speculative.yml)
- [tasks/testing-uac.yml](../../roles/harden_os_windows/tasks/testing-uac.yml)
- [tasks/testing.yml](../../roles/harden_os_windows/tasks/testing.yml)
- [tasks/windows-acl.yml](../../roles/harden_os_windows/tasks/windows-acl.yml)
- [tasks/windows-adminshares.yml](../../roles/harden_os_windows/tasks/windows-adminshares.yml)
- [tasks/windows-antiransomware.yml](../../roles/harden_os_windows/tasks/windows-antiransomware.yml)
- [tasks/windows-asr.yml](../../roles/harden_os_windows/tasks/windows-asr.yml)
- [tasks/windows-certificates.yml](../../roles/harden_os_windows/tasks/windows-certificates.yml)
- [tasks/windows-cortana.yml](../../roles/harden_os_windows/tasks/windows-cortana.yml)
- [tasks/windows-credentialguard.yml](../../roles/harden_os_windows/tasks/windows-credentialguard.yml)
- [tasks/windows-defender.yml](../../roles/harden_os_windows/tasks/windows-defender.yml)
- [tasks/windows-deviceguard.yml](../../roles/harden_os_windows/tasks/windows-deviceguard.yml)
- [tasks/windows-dirs.yml](../../roles/harden_os_windows/tasks/windows-dirs.yml)
- [tasks/windows-disallowrun.yml](../../roles/harden_os_windows/tasks/windows-disallowrun.yml)
- [tasks/windows-dma.yml](../../roles/harden_os_windows/tasks/windows-dma.yml)
- [tasks/windows-dnscrypt.yml](../../roles/harden_os_windows/tasks/windows-dnscrypt.yml)
- [tasks/windows-error-reporting.yml](../../roles/harden_os_windows/tasks/windows-error-reporting.yml)
- [tasks/windows-feature.yml](../../roles/harden_os_windows/tasks/windows-feature.yml)
- [tasks/windows-filescreening.yml](../../roles/harden_os_windows/tasks/windows-filescreening.yml)
- [tasks/windows-flash.yml](../../roles/harden_os_windows/tasks/windows-flash.yml)
- [tasks/windows-ie.yml](../../roles/harden_os_windows/tasks/windows-ie.yml)
- [tasks/windows-ipv6.yml](../../roles/harden_os_windows/tasks/windows-ipv6.yml)
- [tasks/windows-laps.yml](../../roles/harden_os_windows/tasks/windows-laps.yml)
- [tasks/windows-local-gpo.yml](../../roles/harden_os_windows/tasks/windows-local-gpo.yml)
- [tasks/windows-mimikatz.yml](../../roles/harden_os_windows/tasks/windows-mimikatz.yml)
- [tasks/windows-netcease.yml](../../roles/harden_os_windows/tasks/windows-netcease.yml)
- [tasks/windows-nxlog.yml](../../roles/harden_os_windows/tasks/windows-nxlog.yml)
- [tasks/windows-online.yml](../../roles/harden_os_windows/tasks/windows-online.yml)
- [tasks/windows-paging.yml](../../roles/harden_os_windows/tasks/windows-paging.yml)
- [tasks/windows-rdp-restricted.yml](../../roles/harden_os_windows/tasks/windows-rdp-restricted.yml)
- [tasks/windows-rdp.yml](../../roles/harden_os_windows/tasks/windows-rdp.yml)
- [tasks/windows-registry-hkcu.yml](../../roles/harden_os_windows/tasks/windows-registry-hkcu.yml)
- [tasks/windows-registry.yml](../../roles/harden_os_windows/tasks/windows-registry.yml)
- [tasks/windows-samri.yml](../../roles/harden_os_windows/tasks/windows-samri.yml)
- [tasks/windows-smb.yml](../../roles/harden_os_windows/tasks/windows-smb.yml)
- [tasks/windows-sticky-keys.yml](../../roles/harden_os_windows/tasks/windows-sticky-keys.yml)
- [tasks/windows-taskmanager.yml](../../roles/harden_os_windows/tasks/windows-taskmanager.yml)
- [tasks/windows-taskscheduler.yml](../../roles/harden_os_windows/tasks/windows-taskscheduler.yml)
- [tasks/windows-usb.yml](../../roles/harden_os_windows/tasks/windows-usb.yml)
- [tasks/windows-vss.yml](../../roles/harden_os_windows/tasks/windows-vss.yml)
- [tasks/windows-wef.yml](../../roles/harden_os_windows/tasks/windows-wef.yml)
- [tasks/windows-wmi-monitor.yml](../../roles/harden_os_windows/tasks/windows-wmi-monitor.yml)
- [tasks/windows-wmi.yml](../../roles/harden_os_windows/tasks/windows-wmi.yml)
- [tasks/windows-wsh.yml](../../roles/harden_os_windows/tasks/windows-wsh.yml)
- [tasks/windows-wsus.yml](../../roles/harden_os_windows/tasks/windows-wsus.yml)
- [tasks/windows.yml](../../roles/harden_os_windows/tasks/windows.yml)
- [tasks/windows10.yml](../../roles/harden_os_windows/tasks/windows10.yml)
- [tasks/wpad-disable.yml](../../roles/harden_os_windows/tasks/wpad-disable.yml)
- [meta/main.yml](../../roles/harden_os_windows/meta/main.yml)
- [handlers/main.yml](../../roles/harden_os_windows/handlers/main.yml)