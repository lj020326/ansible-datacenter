---
title: Harden OS Linux Role Documentation
role: harden_os_linux
category: Security
type: Ansible Role
tags: security, linux, hardening

---

## Summary

The `harden_os_linux` role is designed to enhance the security of Linux operating systems by applying a series of best practices and configurations. This includes tasks such as configuring auditd, setting limits on user resources, securing login definitions, minimizing access permissions, managing kernel modules, and more.

## Variables

Below is a comprehensive list of variables available in this role along with their default values and descriptions:

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `harden_os_linux__system_owner` | `dettonville.org` | Specifies the system owner for documentation or compliance purposes. |
| `harden_os_linux__auditd_enabled` | `true` | Enables or disables the configuration of auditd, a security auditing tool. |
| `harden_os_linux__limits_enabled` | `true` | Enables or disables setting user limits on resources such as core dumps and memory usage. |
| `harden_os_linux__login_defs_enabled` | `true` | Enables or disables configuring login definitions in `/etc/login.defs`. |
| `harden_os_linux__access_enabled` | `false` | Enables or disables minimizing access to system directories and files. |
| `harden_os_linux__modprobe_enabled` | `false` | Enables or disables managing kernel modules via modprobe configuration. |
| `harden_os_linux__profile_enabled` | `true` | Enables or disables configuring the profile scripts in `/etc/profile.d/`. |
| `harden_os_linux__securetty_enabled` | `true` | Enables or disables configuring secure TTY devices in `/etc/securetty`. |
| `harden_os_linux__user_accounts_enabled` | `false` | Enables or disables hardening user accounts by changing their shells and disabling password access. |
| `harden_os_linux__rhosts_enabled` | `true` | Enables or disables removing `.rhosts`, `hosts.equiv`, and `.netrc` files to prevent remote host authentication. |
| `harden_os_linux__package_agent_enabled` | `true` | Enables or disables cleaning up deprecated or insecure packages using the system's package manager. |
| `harden_os_linux__selinux_enabled` | `false` | Enables or disables configuring SELinux policies and states. |
| `harden_os_linux__hostname_enabled` | `false` | Enables or disables setting the hostname based on EC2 instance tags. |
| `harden_os_linux__boot_enabled` | `false` | Enables or disables securing bootloader configurations, such as GRUB. |
| `harden_os_linux__ssh_enabled` | `false` | Enables or disables hardening SSH server settings in `/etc/ssh/sshd_config`. |
| `harden_os_linux__pam_enabled` | `false` | Enables or disables configuring Pluggable Authentication Modules (PAM) for enhanced security. |
| `harden_os_linux__account_settings_enabled` | `false` | Enables or disables setting account-related configurations, such as password expiration and umask values. |
| `harden_os_linux__misc_enabled` | `false` | Enables or disables applying miscellaneous hardening settings. |
| `harden_os_linux__ntp_enabled` | `false` | Enables or disables configuring Network Time Protocol (NTP) for time synchronization. |
| `harden_os_linux__cron_enabled` | `true` | Enables or disables securing cron and at jobs by setting appropriate permissions and restricting access. |
| `harden_os_linux__core_dumps_enabled` | `true` | Enables or disables restricting core dumps to prevent sensitive information leakage. |
| `harden_os_linux__sysctl_enabled` | `true` | Enables or disables configuring kernel parameters via `/etc/sysctl.conf`. |
| `harden_os_linux__kernel_enabled` | `true` | Enables or disables hardening kernel modules and settings. |
| `harden_os_linux__reload_sysctl_conf_handler` | `true` | Enables or disables reloading the sysctl configuration after changes. |
| `harden_os_linux__desktop_enable` | `false` | **Deprecated** - Enables or disables desktop-specific configurations (not currently implemented). |
| `harden_os_linux__env_extra_user_paths` | `[]` | A list of additional paths to be included in the system's PATH environment variable. |
| `harden_os_linux__auth_pw_max_age` | `60` | Sets the maximum number of days a password can remain unchanged before it must be changed. |
| `harden_os_linux__auth_pw_min_age` | `7` | Sets the minimum number of days required between password changes to discourage cycling passwords frequently. |
| `harden_os_linux__auth_retries` | `5` | Specifies the maximum number of authentication retries allowed before locking an account. |
| `harden_os_linux__auth_lockout_time` | `600` (10 minutes) | Sets the duration for which an account is locked after reaching the maximum number of authentication retries. |
| `harden_os_linux__auth_timeout` | `60` | Specifies the timeout period in seconds for user authentication prompts. |
| `harden_os_linux__auth_allow_homeless` | `false` | **Deprecated** - Allows or disallows users without a home directory (not currently implemented). |
| `harden_os_linux__auth_pam_passwdqc_enable` | `true` | Enables or disables using the `passwdqc` module for strong password checking in PAM. |
| `harden_os_linux__auth_pam_passwdqc_options` | `min=disabled,disabled,16,12,8` | Specifies options for the `passwdqc` module used in RHEL 6 systems. |
| `harden_os_linux__auth_pam_pwquality_options` | `try_first_pass retry=3 type=` | Specifies options for the `pam_pwquality` module used in RHEL 7 and later systems. |
| `harden_os_linux__auth_root_ttys` | `[console, tty1, tty2, tty3, tty4, tty5, tty6]` | Lists the TTY devices that are allowed for root login. |
| `harden_os_linux__chfn_restrict` | `""` | **Deprecated** - Restricts user information changes via `chfn` (not currently implemented). |
| `harden_os_linux__security_users_allow` | `[]` | A list of users who are exempt from certain security configurations. |
| `harden_os_linux__ignore_users` | `[vagrant, kitchen]` | A list of system users to be ignored during hardening tasks. |
| `harden_os_linux__security_kernel_enable_module_loading` | `true` | Enables or disables loading kernel modules at runtime. |
| `harden_os_linux__security_kernel_enable_core_dump` | `false` | Enables or disables allowing core dumps, which can contain sensitive information. |
| `harden_os_linux__security_suid_sgid_enforce` | `true` | Enables or disables enforcing SUID and SGID bits on binaries. |
| `harden_os_linux__security_suid_sgid_blocklist` | `[]` | A list of binaries to have their SUID/SGID bits removed. |
| `harden_os_linux__security_suid_sgid_allowlist` | `[]` | A list of binaries that are allowed to retain their SUID/SGID bits. |
| `harden_os_linux__security_suid_sgid_remove_from_unknown` | `true` | Enables or disables removing SUID/SGID bits from unknown binaries not on the allowlist. |
| `harden_os_linux__grub_secure_boot` | `$1$askldfsdklfj;sadf.sdfsdfr.` | Sets a hashed password for GRUB secure boot. |
| `harden_os_linux__security_ipv6_grub_disable` | `true` | Enables or disables disabling IPv6 in the GRUB configuration. |
| `harden_os_linux__security_packages_clean` | `true` | Enables or disables removing deprecated or insecure packages from the system. |
| `harden_os_linux__security_packages_list` | `[xinetd, inetd, ypserv, telnet-server, rsh-server, prelink]` | A list of packages to be removed during hardening. |
| `harden_os_linux__security_init_prompt` | `true` | **Deprecated** - Enables or disables prompting for user input during system initialization (not currently implemented). |
| `harden_os_linux__security_init_single` | `false` | **Deprecated** - Allows or disallows single-user mode access (not currently implemented). |
| `harden_os_linux__ufw_manage_defaults` | `true` | Enables or disables managing the default settings for Uncomplicated Firewall (UFW) on Debian-based systems. |

## Usage

To use this role, include it in your Ansible playbook and configure the desired variables as needed:

```yaml
- hosts: all
  become: yes
  roles:
    - role: harden_os_linux
      vars:
        harden_os_linux__auditd_enabled: true
        harden_os_linux__limits_enabled: true
        harden_os_linux__login_defs_enabled: true
        harden_os_linux__cron_enabled: true
        harden_os_linux__core_dumps_enabled: true
        harden_os_linux__sysctl_enabled: true
        harden_os_linux__kernel_enabled: true
```

## Dependencies

This role does not have any external dependencies beyond the standard Ansible modules. However, certain tasks may require specific packages to be installed on the target system, such as `auditd`, `ntp`, or `ufw`.

## Best Practices

- **Backup Configuration Files**: Before applying hardening configurations, ensure that you have backups of critical configuration files.
- **Test in a Staging Environment**: Test the role in a staging environment before deploying it to production systems to verify its behavior and impact.
- **Monitor System Performance**: After applying hardening settings, monitor system performance to ensure that no critical services are adversely affected.
- **Review Logs Regularly**: Regularly review audit logs and other system logs to detect any unauthorized access attempts or anomalies.

## Molecule Tests

This role does not currently include Molecule tests. However, it is recommended to set up Molecule tests to automate the testing of this role in various environments.

## Backlinks

- [defaults/main.yml](../../roles/harden_os_linux/defaults/main.yml)
- [tasks/account_settings.yml](../../roles/harden_os_linux/tasks/account_settings.yml)
- [tasks/apt.yml](../../roles/harden_os_linux/tasks/apt.yml)
- [tasks/auditd.yml](../../roles/harden_os_linux/tasks/auditd.yml)
- [tasks/core_dumps.yml](../../roles/harden_os_linux/tasks/core_dumps.yml)
- [tasks/cron.yml](../../roles/harden_os_linux/tasks/cron.yml)
- [tasks/hardening.yml](../../roles/harden_os_linux/tasks/hardening.yml)
- [tasks/hostname.yml](../../roles/harden_os_linux/tasks/hostname.yml)
- [tasks/kernel_modules.yml](../../roles/harden_os_linux/tasks/kernel_modules.yml)
- [tasks/limits.yml](../../roles/harden_os_linux/tasks/limits.yml)
- [tasks/login_defs.yml](../../roles/harden_os_linux/tasks/login_defs.yml)
- [tasks/main.yml](../../roles/harden_os_linux/tasks/main.yml)
- [tasks/minimize_access.yml](../../roles/harden_os_linux/tasks/minimize_access.yml)
- [tasks/misc.yml](../../roles/harden_os_linux/tasks/misc.yml)
- [tasks/modprobe.yml](../../roles/harden_os_linux/tasks/modprobe.yml)
- [tasks/ntp.yml](../../roles/harden_os_linux/tasks/ntp.yml)
- [tasks/pam.yml](../../roles/harden_os_linux/tasks/pam.yml)
- [tasks/profile.yml](../../roles/harden_os_linux/tasks/profile.yml)
- [tasks/rhosts.yml](../../roles/harden_os_linux/tasks/rhosts.yml)
- [tasks/secure_boot.yml](../../roles/harden_os_linux/tasks/secure_boot.yml)
- [tasks/securetty.yml](../../roles/harden_os_linux/tasks/securetty.yml)
- [tasks/selinux.yml](../../roles/harden_os_linux/tasks/selinux.yml)
- [tasks/ssh_settings.yml](../../roles/harden_os_linux/tasks/ssh_settings.yml)
- [tasks/suid_sgid.yml](../../roles/harden_os_linux/tasks/suid_sgid.yml)
- [tasks/sysctl.yml](../../roles/harden_os_linux/tasks/sysctl.yml)
- [tasks/user_accounts.yml](../../roles/harden_os_linux/tasks/user_accounts.yml)
- [tasks/yum.yml](../../roles/harden_os_linux/tasks/yum.yml)
- [handlers/main.yml](../../roles/harden_os_linux/handlers/main.yml)