---
harvested_date: '2023-10-07T18:07:09.531522+00:00'
original_path: roles/harden_os_linux/README.md
source_type: legacy_markdown
title: harden_os_linux
category: Ansible
tags: [security, hardening, linux, ansible]
---

# harden_os_linux (Ansible Role)

## Description

This role provides numerous security-related configurations, offering comprehensive base protection. It is designed to be compliant with the [DevSec Linux Baseline](https://github.com/dev-sec/linux-baseline).

It configures:

- Package management (e.g., allows only signed packages)
- Removal of packages with known issues
- Configuration of `pam` and `pam_limits` modules
- Shadow password suite configuration
- System path permissions
- Disabling core dumps via soft limits
- Restricting root logins to the system console
- Setting SUIDs
- Kernel parameter configuration via sysctl
- Installation and configuration of auditd

It does **not**:

- Update system packages
- Install security patches

## Requirements

- Ansible 2.5.0
- Root or sudo access on the target system

## Important Notes

### Warning

If you're using InSpec to test your machines after applying this role, please ensure to add the connecting user to the `harden_os_linux__ignore_users` variable. Otherwise, InSpec will fail. For more information, see [issue #124](https://github.com/dev-sec/ansible-os-hardening/issues/124).

If you're using Docker/Kubernetes+Docker, you'll need to override the IPv4 IP forward sysctl setting:

```yaml
- hosts: localhost
  roles:
    - harden_os_linux
  vars:
    harden_os_linux__sysctl_overwrite:
      # Enable IPv4 traffic forwarding.
      net.ipv4.ip_forward: 1
```

## Variables

| Name                                    | Default Value | Description                                                                 |
|-----------------------------------------|---------------|-----------------------------------------------------------------------------|
| `harden_os_linux__desktop_enable`       | `false`       | Set to `true` if this is a desktop system (e.g., Xorg, KDE/GNOME/Unity/etc.) |
| `harden_os_linux__env_extra_user_paths` | `[]`          | Add additional paths to the user's `PATH` variable (default is empty).      |
| `harden_os_linux__env_umask`            | `027`         | Set default permissions for new files to `750`.                              |
| `harden_os_linux__auth_pw_max_age`      | `60`          | Maximum password age (set to `99999` to effectively disable it).            |
| `harden_os_linux__auth_pw_min_age`      | `7`           | Minimum password age (before allowing any other password change).           |
| `harden_os_linux__auth_retries`         | `5`           | Maximum number of authentication attempts before account lockout.           |
| `harden_os_linux__auth_lockout_time`    | `600`         | Time in seconds that needs to pass if the account is locked due to too many failed authentication attempts. |
| `harden_os_linux__auth_timeout`         | `60`          | Authentication timeout in seconds.                                           |
| `harden_os_linux__auth_allow_homeless`  | `false`       | Set to `true` to allow users without a home directory to log in.             |
| `os_auth_pam_passwdqc_enable`           | `true`        | Set to `true` to use strong password checking in PAM using passwdqc.         |
| `os_auth_pam_passwdqc_options`          | `"min=disabled,disabled,16,12,8"` | Set to any option line (as a string) that you want to pass to passwdqc.      |
| `harden_os_linux__security_users_allow` | `[]`          | List of actions that a user is allowed to perform. May contain `change_user`. |
| `harden_os_linux__security_kernel_enable_module_loading` | `true` | Set to `true` to allow changing kernel modules once the system is running (e.g., `modprobe`, `rmmod`). |
| `harden_os_linux__security_kernel_enable_core_dump` | `false` | Set to `true` if the kernel is crashing or otherwise misbehaving and a kernel core dump is created. |
| `harden_os_linux__security_suid_sgid_enforce` | `true` | Set to `true` to reduce SUID/SGID bits. There is already a list of items which are searched for configured, but you can also add your own. |
| `harden_os_linux__security_suid_sgid_blocklist` | `[]` | List of paths which should have their SUID/SGID bits removed. |
| `harden_os_linux__security_suid_sgid_allowlist` | `[]` | List of paths which should not have their SUID/SGID bits altered. |
| `harden_os_linux__security_suid_sgid_remove_from_unknown` | `false` | Set to `true` to remove SUID/SGID bits from any file that is not explicitly configured in a `blocklist`. This will make every Ansible-run search through the mounted filesystems looking for SUID/SGID bits that are not configured in the default and user blocklist. If it finds an SUID/SGID bit, it will be removed, unless this file is in your `allowlist`. |
| `harden_os_linux__security_packages_clean` | `true` | Removes packages with known issues. See section packages. |
| `harden_os_linux__selinux_state`        | `enforcing`   | Set the SELinux state, can be either `disabled`, `permissive`, or `enforcing`. |
| `harden_os_linux__selinux_policy`       | `targeted`    | Set the SELinux policy.                                                      |
| `harden_os_linux__ufw_manage_defaults`  | `true`        | Set to `true` to apply all settings with `ufw_` prefix.                      |
| `harden_os_linux__ufw_ipt_sysctl`       | `''`          | By default, it disables IPT_SYSCTL in `/etc/default/ufw`. If you want to overwrite `/etc/sysctl.conf` values using `ufw`, set it to your sysctl dictionary, for example `/etc/ufw/sysctl.conf`. |
| `harden_os_linux__ufw_default_input_policy` | `DROP` | Set default input policy of `ufw` to `DROP`. |
| `harden_os_linux__ufw_default_output_policy` | `ACCEPT` | Set default output policy of `ufw` to `ACCEPT`. |
| `harden_os_linux__ufw_default_forward_policy` | `DROP` | Set default forward policy of `ufw` to `DROP`. |
| `harden_os_linux__auditd_enabled`       | `true`        | Enable auditd service.                                                       |

... [continue with the rest of the variables if needed] ...