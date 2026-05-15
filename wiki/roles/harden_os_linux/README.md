```markdown
---
title: harden_os_linux Ansible Role Documentation
original_path: roles/harden_os_linux/README.md
category: Ansible Roles
tags: [security, linux, ansible, hardening]
---

# harden_os_linux (Ansible Role)

## Description

This role provides comprehensive security-related configurations to offer all-around base protection. It is designed to be compliant with the [DevSec Linux Baseline](https://github.com/dev-sec/linux-baseline).

### Configurations Applied:

- Package management configuration: Allows only signed packages.
- Removal of packages with known issues.
- Configuration of `pam` and `pam_limits` modules.
- Shadow password suite configuration.
- System path permissions setup.
- Disabling core dumps via soft limits.
- Restricting root logins to the system console.
- Setting SUIDs.
- Kernel parameter configurations via `sysctl`.
- Installation and configuration of `auditd`.

### Configurations Not Applied:

- Updating system packages.
- Installing security patches.

## Requirements

- Ansible 2.5.0 or later.

## Warning

If you're using InSpec to test your machines after applying this role, ensure that the connecting user is added to the `harden_os_linux__ignore_users` variable. Otherwise, InSpec will fail. For more information, see [issue #124](https://github.com/dev-sec/ansible-os-hardening/issues/124).

For Docker or Kubernetes+Docker environments, you may need to override the IPv4 IP forward `sysctl` setting:

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

| Name                                       | Default Value                           | Description                                                                 |
|--------------------------------------------|-----------------------------------------|-----------------------------------------------------------------------------|
| `harden_os_linux__desktop_enable`          | `false`                                 | Set to `true` if this is a desktop system (e.g., Xorg, KDE/GNOME/Unity).   |
| `harden_os_linux__env_extra_user_paths`    | `[]`                                    | Additional paths to add to the user's `PATH` variable.                      |
| `harden_os_linux__env_umask`               | `027`                                   | Default permissions for new files set to `750`.                             |
| `harden_os_linux__auth_pw_max_age`         | `60`                                    | Maximum password age (set to `99999` to disable).                           |
| `harden_os_linux__auth_pw_min_age`         | `7`                                     | Minimum password age before allowing changes.                               |
| `harden_os_linux__auth_retries`            | `5`                                     | Maximum authentication attempts before account lockout.                     |
| `harden_os_linux__auth_lockout_time`       | `600`                                   | Time in seconds required to unlock an account after too many failed attempts.|
| `harden_os_linux__auth_timeout`            | `60`                                    | Authentication timeout in seconds; login will exit if this time is exceeded.|
| `harden_os_linux__auth_allow_homeless`     | `false`                                 | Allow users without home directories to log in.                             |
| `os_auth_pam_passwdqc_enable`              | `true`                                  | Use strong password checking in PAM using `passwdqc`.                       |
| `os_auth_pam_passwdqc_options`             | `"min=disabled,disabled,16,12,8"`       | Options passed to `passwdqc` as a string.                                 |
| `harden_os_linux__security_users_allow`    | `[]`                                    | List of actions allowed for users (e.g., `change_user`).                    |
| `harden_os_linux__security_kernel_enable_module_loading` | `true`       | Allow changing kernel modules during runtime (e.g., `modprobe`, `rmmod`).|
| `harden_os_linux__security_kernel_enable_core_dump` | `false`      | Enable or disable core dumps.                                             |
| `harden_os_linux__security_suid_sgid_enforce` | `true`       | Reduce SUID/SGID bits; configure a list of items to search and modify.     |
| `harden_os_linux__security_suid_sgid_blocklist` | `[]`        | List of paths with SUID/SGID bits to remove.                              |
| `harden_os_linux__security_suid_sgid_allowlist` | `[]`       | List of paths with SUID/SGID bits not to alter.                           |
| `harden_os_linux__security_suid_sgid_remove_from_unknown` | `false` | Remove SUID/SGID bits from files not explicitly configured in the blocklist.|
| `harden_os_linux__security_packages_clean` | `true`                                  | Remove packages with known issues.                                        |
| `harden_os_linux__selinux_state`           | `enforcing`                             | Set SELinux state (`disabled`, `permissive`, or `enforcing`).             |
| `harden_os_linux__selinux_policy`          | `targeted`                              | Set SELinux policy.                                                       |
| `harden_os_linux__ufw_manage_defaults`     | `true`                                  | Apply all settings with the `ufw_` prefix.                                |
| `harden_os_linux__ufw_ipt_sysctl`          | `''`                                    | Overwrite `/etc/sysctl.conf` values using UFW; set to a sysctl dictionary.  |
| `harden_os_linux__ufw_default_input_policy`| `DROP`                                  | Set default input policy of UFW to `DROP`.                                |
| `harden_os_linux__ufw_default_output_policy`| `ACCEPT`                               | Set default output policy of UFW to `ACCEPT`.                             |
| `harden_os_linux__ufw_default_forward_policy`| `DROP`                                | Set default forward policy of UFW to `DROP`.                              |
| `harden_os_linux__auditd_enabled`          | `true`                                  | Enable or disable installing and configuring `auditd`.                    |
| `harden_os_linux__auditd_max_log_file_action` | `keep_logs`  | Define behavior when log file is filled up; other values in `auditd.conf`.|
| `harden_os_linux__hidepid_option`          | `2`                                     | Control visibility of process IDs in `/proc`; options: `0`, `1`, or `2`.    |
| `harden_os_linux__proc_mnt_options`        | `rw,nosuid,nodev,noexec,relatime,hidepid={{ harden_os_linux__hidepid_option }}` | Mount `proc` with hardened options.                                       |

## Packages

The following packages are removed:

- `xinetd`
- `inetd`
- `tftp-server`
- `ypserv`
- `telnet-server`
- `rsh-server`
- `prelink`

For more details, refer to the [NSA](https://apps.nsa.gov/iaarchive/library/ia-guidance/security-configuration/operating-systems/guide-to-the-secure-configuration-of-red-hat-enterprise.cfm) and [open-scap](https://static.open-scap.org/ssg-guides/ssg-sl7-guide-ospp-rhel7-server.html#xccdf_org.ssgproject.content_rule_disable_prelink) guidelines.

## Disabled Filesystems

The following filesystems are disabled:

- `cramfs`
- `freevxfs`
- `jffs2`
- `hfs`
- `hfsplus`
- `squashfs`
- `udf`
- `vfat` (only if UEFI is not in use)

To prevent certain filesystems from being disabled, add them to the `harden_os_linux__filesystem_allowlist` variable.

## Installation

Install the role using `ansible-galaxy`:

```bash
ansible-galaxy install harden_os_linux
```

## Example Playbook

```yaml
- hosts: localhost
  roles:
    - harden_os_linux
```

## Changing Sysctl Variables

To override `sysctl` variables, use the `harden_os_linux__sysctl_overwrite` variable. For example:

```yaml
- hosts: localhost
  roles:
    - harden_os_linux
  vars:
    harden_os_linux__sysctl_overwrite:
      # Enable IPv4 traffic forwarding.
      net.ipv4.ip_forward: 1
```

Alternatively, change Ansible's [hash-behaviour](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#default-hash-behaviour) to `merge` for selective overrides. However, this affects all playbooks and is not recommended.

## Improving Kernel Audit Logging

To ensure accurate logging, add the kernel boot parameter `audit=1`. Without this, processes starting before `auditd` will have an AUID of `4294967295`.

For more information, see the [upstream documentation](https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html) and your system's boot loader documentation.

## Local Testing

### Using Docker

1. Install Docker on your system: [Get started with Docker](https://docs.docker.com/).
2. Use `test-kitchen` for testing:

```bash
# Install dependencies
gem install bundler
bundle install
```

- Fast test on one machine:
  ```bash
  bundle exec kitchen test default-ubuntu-1404
  ```

- Test on all machines:
  ```bash
  bundle exec kitchen test
  ```

- For development:
  ```bash
  bundle exec kitchen create default-ubuntu-1404
  bundle exec kitchen converge default-ubuntu-1404
  ```

### Using Virtualbox

1. Install Virtualbox and Vagrant: [Vagrant Downloads](http://downloads.vagrantup.com/).
2. Use `test-kitchen` for testing:

- Fast test on one machine:
  ```bash
  KITCHEN_YAML=".kitchen.vagrant.yml" bundle exec kitchen test default-ubuntu-1404
  ```

- Test on all machines:
  ```bash
  KITCHEN_YAML=".kitchen.vagrant.yml" bundle exec kitchen test
  ```

- For development:
  ```bash
  KITCHEN_YAML=".kitchen.vagrant.yml" bundle exec kitchen create default-ubuntu-1404
  KITCHEN_YAML=".kitchen.vagrant.yml" bundle exec kitchen converge default-ubuntu-1404
  ```

For more information, see [test-kitchen](http://kitchen.ci/docs/getting-started).

## Contributors + Kudos

This role is based on guides by:

- [Arch Linux wiki, Sysctl hardening](https://wiki.archlinux.org/index.php/Sysctl)
- [NSA: Guide to the Secure Configuration of Red Hat Enterprise Linux 5](http://www.nsa.gov/ia/_files/os/redhat/rhel5-guide-i731.pdf)
- [Ubuntu Security/Features](https://wiki.ubuntu.com/Security/Features)
- [Deutsche Telekom, Group IT Security, Security Requirements (German)](https://www.telekom.com/psa)

## Backlinks

- [DevSec Linux Baseline](https://github.com/dev-sec/linux-baseline)
- [Ansible Galaxy: harden_os_linux](https://galaxy.ansible.com/dev-sec/os-hardening)
```

This improved version maintains all original information while adhering to clean, professional Markdown standards suitable for GitHub rendering.