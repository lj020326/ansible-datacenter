---
title: "Harden OS Linux"
role: roles/harden_os_linux
category: Security
type: Role
tags: [ansible, harden_os_linux, role]
---

```yaml
---
title: Harden OS Linux
role: harden_os_linux
category: Security
type: Role
summary: |
  The `harden_os_linux` role is designed to enhance the security of Linux operating systems by implementing a variety of hardening measures. These measures include configuring system settings, securing user accounts, managing packages, and enforcing security policies. This role is highly configurable, allowing administrators to enable or disable specific hardening tasks based on their requirements.

variables: |
  | Variable Name | Default Value | Description |
  |---------------|---------------|-------------|
  | `harden_os_linux__system_owner` | `dettonville.org` | The owner of the system. |
  | `harden_os_linux__auditd_enabled` | `true` | Enable or disable auditd hardening. |
  | `harden_os_linux__limits_enabled` | `true` | Enable or disable limits hardening. |
  | `harden_os_linux__login_defs_enabled` | `true` | Enable or disable login_defs hardening. |
  | `harden_os_linux__access_enabled` | `false` | Enable or disable access hardening. |
  | `harden_os_linux__modprobe_enabled` | `false` | Enable or disable modprobe hardening. |
  | `harden_os_linux__profile_enabled` | `true` | Enable or disable profile hardening. |
  | `harden_os_linux__securetty_enabled` | `true` | Enable or disable securetty hardening. |
  | `harden_os_linux__user_accounts_enabled` | `false` | Enable or disable user accounts hardening. |
  | `harden_os_linux__rhosts_enabled` | `true` | Enable or disable rhosts hardening. |
  | `harden_os_linux__package_agent_enabled` | `true` | Enable or disable package agent hardening. |
  | `harden_os_linux__selinux_enabled` | `false` | Enable or disable SELinux hardening. |
  | `harden_os_linux__hostname_enabled` | `false` | Enable or disable hostname hardening. |
  | `harden_os_linux__boot_enabled` | `false` | Enable or disable boot hardening. |
  | `harden_os_linux__ssh_enabled` | `false` | Enable or disable SSH hardening. |
  | `harden_os_linux__pam_enabled` | `false` | Enable or disable PAM hardening. |
  | `harden_os_linux__account_settings_enabled` | `false` | Enable or disable account settings hardening. |
  | `harden_os_linux__misc_enabled` | `false` | Enable or disable miscellaneous hardening. |
  | `harden_os_linux__ntp_enabled` | `false` | Enable or disable NTP hardening. |
  | `harden_os_linux__cron_enabled` | `true` | Enable or disable cron hardening. |
  | `harden_os_linux__core_dumps_enabled` | `true` | Enable or disable core dumps hardening. |
  | `harden_os_linux__sysctl_enabled` | `true` | Enable or disable sysctl hardening. |
  | `harden_os_linux__kernel_enabled` | `true` | Enable or disable kernel hardening. |
  | `harden_os_linux__reload_sysctl_conf_handler` | `true` | Enable or disable sysctl configuration reload handler. |
  | `harden_os_linux__desktop_enable` | `false` | Enable or disable desktop environment hardening. |
  | `harden_os_linux__env_extra_user_paths` | `[]` | Additional user paths for environment variables. |
  | `harden_os_linux__auth_pw_max_age` | `60` | Maximum password age in days. |
  | `harden_os_linux__auth_pw_min_age` | `7` | Minimum password age in days. |
  | `harden_os_linux__auth_retries` | `5` | Maximum number of authentication retries. |
  | `harden_os_linux__auth_lockout_time` | `600` | Lockout time in seconds after failed authentication attempts. |
  | `harden_os_linux__auth_timeout` | `60` | Authentication timeout in seconds. |
  | `harden_os_linux__auth_allow_homeless` | `false` | Allow users without a home directory. |
  | `harden_os_linux__auth_pam_passwdqc_enable` | `true` | Enable or disable PAM passwdqc. |
  | `harden_os_linux__auth_pam_passwdqc_options` | `min=disabled,disabled,16,12,8` | PAM passwdqc options for RHEL6. |
  | `harden_os_linux__auth_pam_pwquality_options` | `try_first_pass retry=3 type=` | PAM pwquality options for RHEL7. |
  | `harden_os_linux__auth_root_ttys` | `[console, tty1, tty2, tty3, tty4, tty5, tty6]` | TTYs allowed for root login. |
  | `harden_os_linux__chfn_restrict` | `""` | Restrict chfn command. |
  | `harden_os_linux__security_users_allow` | `[]` | List of users allowed to change system settings. |
  | `harden_os_linux__ignore_users` | `[vagrant, kitchen]` | List of users to ignore during hardening. |
  | `harden_os_linux__security_kernel_enable_module_loading` | `true` | Enable or disable kernel module loading. |
  | `harden_os_linux__security_kernel_enable_core_dump` | `false` | Enable or disable kernel core dumps. |
  | `harden_os_linux__security_suid_sgid_enforce` | `true` | Enforce SUID/SGID restrictions. |
  | `harden_os_linux__security_suid_sgid_blocklist` | `[]` | List of SUID/SGID binaries to block. |
  | `harden_os_linux__security_suid_sgid_allowlist` | `[]` | List of SUID/SGID binaries to allow. |
  | `harden_os_linux__security_suid_sgid_remove_from_unknown` | `true` | Remove SUID/SGID from unknown binaries. |
  | `harden_os_linux__grub_secure_boot` | `$1$askldfsdklfj;sadf.sdfsdfr.` | GRUB secure boot password. |
  | `harden_os_linux__security_ipv6_grub_disable` | `true` | Disable IPv6 in GRUB. |
  | `harden_os_linux__security_packages_clean` | `true` | Clean up deprecated or insecure packages. |
  | `harden_os_linux__security_packages_list` | `[xinetd, inetd, ypserv, telnet-server, rsh-server, prelink]` | List of packages to remove. |
  | `harden_os_linux__security_init_prompt` | `true` | Enable or disable init prompt. |
  | `harden_os_linux__security_init_single` | `false` | Enable or disable single-user mode. |
  | `harden_os_linux__ufw_manage_defaults` | `true` | Manage UFW defaults. |
  | `harden_os_linux__ufw_ipt` | `See UFW documentation for details` | UFW iptables settings. |

usage: |
  To use the `harden_os_linux` role, include it in your playbook and configure the desired variables. Here is an example playbook:

  ```yaml
  ---
  - hosts: all
    roles:
      - role: harden_os_linux
        vars:
          harden_os_linux__system_owner: "example.org"
          harden_os_linux__auditd_enabled: true
          harden_os_linux__limits_enabled: true
          # Add more variables as needed
  ```

dependencies: |
  The `harden_os_linux` role does not have any external dependencies. However, it relies on the following Ansible modules:
  - `ansible.builtin.package`
  - `ansible.builtin.template`
  - `ansible.builtin.file`
  - `ansible.builtin.lineinfile`
  - `ansible.posix.sysctl`
  - `ansible.posix.mount`
  - `community.general.pam_limits`
  - `amazon.aws.ec2_metadata_facts`
  - `amazon.aws.ec2_tag`

best_practices: |
  - Review and customize the variables to match your organization's security policies.
  - Test the role in a development environment before applying it to production systems.
  - Regularly update the role to incorporate the latest security best practices.
  - Monitor the system after applying the role to ensure that the hardening measures do not impact normal operations.

potential_risks: |
  - Some hardening measures may impact system functionality or performance.
  - Certain configurations may not be compatible with all Linux distributions.
  - Improper configuration could lead to system instability or reduced security.

backlinks: |
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
```