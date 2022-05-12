# ansible-harden-linux (Ansible Role)

## Description

This role provides numerous security-related configurations, providing all-round base protection.  It is intended to be compliant with the [DevSec Linux Baseline](https://github.com/dev-sec/linux-baseline).

It configures:

 * Configures package management e.g. allows only signed packages
 * Remove packages with known issues
 * Configures `pam` and `pam_limits` module
 * Shadow password suite configuration
 * Configures system path permissions
 * Disable core dumps via soft limits
 * Restrict root Logins to System Console
 * Set SUIDs
 * Configures kernel parameters via sysctl
 * Install and configure auditd

It will not:

 * Update system packages
 * Install security patches

## Requirements

* Ansible 2.5.0

## Warning

If you're using inspec to test your machines after applying this role, please make sure to add the connecting user to the `harden_linux_os_ignore_users`-variable.
Otherwise inspec will fail. For more information, see [issue #124](https://github.com/dev-sec/ansible-os-hardening/issues/124).

If you're using Docker / Kubernetes+Docker you'll need to override the ipv4 ip forward sysctl setting.

```yaml
- hosts: localhost
  roles:
    - dev-sec.os-hardening
  vars:
    harden_linux_sysctl_overwrite:
      # Enable IPv4 traffic forwarding.
      net.ipv4.ip_forward: 1
```



## Variables

| Name           | Default Value | Description                        |
| -------------- | ------------- | -----------------------------------|
| `harden_linux_os_desktop_enable`| false |  true if this is a desktop system, ie Xorg, KDE/GNOME/Unity/etc|
| `harden_linux_os_env_extra_user_paths`| [] | add additional paths to the user's `PATH` variable (default is empty).|
| `harden_linux_os_env_umask`| 027| set default permissions for new files to `750` |
| `harden_linux_os_auth_pw_max_age`| 60 | maximum password age (set to `99999` to effectively disable it) |
| `harden_linux_os_auth_pw_min_age`| 7 | minimum password age (before allowing any other password change)|
| `harden_linux_os_auth_retries`| 5 | the maximum number of authentication attempts, before the account is locked for some time|
| `harden_linux_os_auth_lockout_time`| 600 | time in seconds that needs to pass, if the account was locked due to too many failed authentication attempts|
| `harden_linux_os_auth_timeout`| 60 | authentication timeout in seconds, so login will exit if this time passes|
| `harden_linux_os_auth_allow_homeless`| false | true if to allow users without home to login|
| `os_auth_pam_passwdqc_enable`| true | true if you want to use strong password checking in PAM using passwdqc|
| `os_auth_pam_passwdqc_options`| "min=disabled,disabled,16,12,8" | set to any option line (as a string) that you want to pass to passwdqc|
| `harden_linux_os_security_users_allow`| [] | list of things, that a user is allowed to do. May contain `change_user`.
| `harden_linux_os_security_kernel_enable_module_loading`| true | true if you want to allowed to change kernel modules once the system is running (eg `modprobe`, `rmmod`)|
| `harden_linux_os_security_kernel_enable_core_dump`| false | kernel is crashing or otherwise misbehaving and a kernel core dump is created |
| `harden_linux_os_security_suid_sgid_enforce`| true | true if you want to reduce SUID/SGID bits. There is already a list of items which are searched for configured, but you can also add your own|
| `harden_linux_os_security_suid_sgid_blacklist`| [] | a list of paths which should have their SUID/SGID bits removed|
| `harden_linux_os_security_suid_sgid_whitelist`| [] | a list of paths which should not have their SUID/SGID bits altered|
| `harden_linux_os_security_suid_sgid_remove_from_unknown`| false | true if you want to remove SUID/SGID bits from any file, that is not explicitly configured in a `blacklist`. This will make every Ansible-run search through the mounted filesystems looking for SUID/SGID bits that are not configured in the default and user blacklist. If it finds an SUID/SGID bit, it will be removed, unless this file is in your `whitelist`.|
| `harden_linux_os_security_packages_clean`| true | removes packages with known issues. See section packages.|
| `harden_linux_os_selinux_state` | enforcing | Set the SELinux state, can be either disabled, permissive, or enforcing. |
| `harden_linux_os_selinux_policy` | targeted | Set the SELinux polixy. |
| `harden_linux_ufw_manage_defaults` | true | true means apply all settings with `ufw_` prefix|
| `harden_linux_ufw_ipt_sysctl` | '' | by default it disables IPT_SYSCTL in /etc/default/ufw. If you want to overwrite /etc/sysctl.conf values using ufw - set it to your sysctl dictionary, for example `/etc/ufw/sysctl.conf`
| `harden_linux_ufw_default_input_policy` | DROP | set default input policy of ufw to `DROP` |
| `harden_linux_ufw_default_output_policy` | ACCEPT | set default output policy of ufw to `ACCEPT` |
| `harden_linux_ufw_default_forward_policy` | DROP | set default forward policy of ufw to `DROP` |
| `harden_linux_os_auditd_enabled` | true | Set to false to disable installing and configuring auditd. |
| `harden_linux_os_auditd_max_log_file_action` | `keep_logs` | Defines the behaviour of auditd when its log file is filled up. Possible other values are described in the auditd.conf man page. The most common alternative to the default may be `rotate`. |
| `harden_linux_hidepid_option` | `2` | `0`: This is the default setting and gives you the default behaviour. `1`: With this option an normal user would not see other processes but their own about ps, top etc, but he is still able to see process IDs in /proc. `2`: Users are only able too see their own processes (like with hidepid=1), but also the other process IDs are hidden for them in /proc. |
| `harden_linux_proc_mnt_options` | `rw,nosuid,nodev,noexec,relatime,hidepid={{ harden_linux_hidepid_option }}` | Mount proc with hardenized options, including `hidepid` with variable value. |

## Packages

We remove the following packages:

 * xinetd ([NSA](https://apps.nsa.gov/iaarchive/library/ia-guidance/security-configuration/operating-systems/guide-to-the-secure-configuration-of-red-hat-enterprise.cfm), Chapter 3.2.1)
 * inetd ([NSA](https://apps.nsa.gov/iaarchive/library/ia-guidance/security-configuration/operating-systems/guide-to-the-secure-configuration-of-red-hat-enterprise.cfm), Chapter 3.2.1)
 * tftp-server ([NSA](https://apps.nsa.gov/iaarchive/library/ia-guidance/security-configuration/operating-systems/guide-to-the-secure-configuration-of-red-hat-enterprise.cfm), Chapter 3.2.5)
 * ypserv ([NSA](https://apps.nsa.gov/iaarchive/library/ia-guidance/security-configuration/operating-systems/guide-to-the-secure-configuration-of-red-hat-enterprise.cfm), Chapter 3.2.4)
 * telnet-server ([NSA](https://apps.nsa.gov/iaarchive/library/ia-guidance/security-configuration/operating-systems/guide-to-the-secure-configuration-of-red-hat-enterprise.cfm), Chapter 3.2.2)
 * rsh-server ([NSA](https://apps.nsa.gov/iaarchive/library/ia-guidance/security-configuration/operating-systems/guide-to-the-secure-configuration-of-red-hat-enterprise.cfm), Chapter 3.2.3)
 * prelink ([open-scap](https://static.open-scap.org/ssg-guides/ssg-sl7-guide-ospp-rhel7-server.html#xccdf_org.ssgproject.content_rule_disable_prelink))

## Disabled filesystems

We disable the following filesystems, because they're most likely not used:

 * "cramfs"
 * "freevxfs"
 * "jffs2"
 * "hfs"
 * "hfsplus"
 * "squashfs"
 * "udf"
 * "vfat" # only if uefi is not in use

To prevent some of the filesystems from being disabled, add them to the `harden_linux_os_filesystem_whitelist` variable.

## Installation

Install the role with ansible-galaxy:

```
ansible-galaxy install dev-sec.os-hardening
```

## Example Playbook

```yaml
- hosts: localhost
  roles:
    - dev-sec.os-hardening
```

## Changing sysctl variables

If you want to override sysctl-variables, you can use the `harden_linux_sysctl_overwrite` variable (in older versions you had to override the whole `sysctl_dict`).
So for example if you want to change the IPv4 traffic forwarding variable to `1`, do it like this:

```yaml
- hosts: localhost
  roles:
    - dev-sec.os-hardening
  vars:
    harden_linux_sysctl_overwrite:
      # Enable IPv4 traffic forwarding.
      net.ipv4.ip_forward: 1
```

Alternatively you can change Ansible's [hash-behaviour](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#default-hash-behaviour) to `merge`, then you only have to overwrite the single hash you need to. But please be aware that changing the hash-behaviour changes it for all your playbooks and is not recommended by Ansible.

## Improving Kernel Audit logging

By default, any process that starts before the `auditd` daemon will have an AUID of `4294967295`. To improve this and provide more accurate logging, it's recommended to add the kernel boot parameter `audit=1` to you configuration. Without doing this, you will find that your `auditd` logs fail to properly audit all processes. 

For more information, please see this [upstream documentation](https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html) and your system's boot loader documentation for how to configure additional kernel parameters. 

## Local Testing

The preferred way of locally testing the role is to use Docker. You will have to install Docker on your system. See [Get started](https://docs.docker.com/) for a Docker package suitable to for your system.

You can also use vagrant and Virtualbox or VMWare to run tests locally. You will have to install Virtualbox and Vagrant on your system. See [Vagrant Downloads](http://downloads.vagrantup.com/) for a vagrant package suitable for your system. For all our tests we use `test-kitchen`. If you are not familiar with `test-kitchen` please have a look at [their guide](http://kitchen.ci/docs/getting-started).

Next install test-kitchen:

```bash
# Install dependencies
gem install bundler
bundle install
```

### Testing with Docker
```
# fast test on one machine
bundle exec kitchen test default-ubuntu-1404

# test on all machines
bundle exec kitchen test

# for development
bundle exec kitchen create default-ubuntu-1404
bundle exec kitchen converge default-ubuntu-1404
```

### Testing with Virtualbox
```
# fast test on one machine
KITCHEN_YAML=".kitchen.vagrant.yml" bundle exec kitchen test default-ubuntu-1404

# test on all machines
KITCHEN_YAML=".kitchen.vagrant.yml" bundle exec kitchen test

# for development
KITCHEN_YAML=".kitchen.vagrant.yml" bundle exec kitchen create default-ubuntu-1404
KITCHEN_YAML=".kitchen.vagrant.yml" bundle exec kitchen converge default-ubuntu-1404
```
For more information see [test-kitchen](http://kitchen.ci/docs/getting-started)

## Contributors + Kudos

...

This role is mostly based on guides by:

* [Arch Linux wiki, Sysctl hardening](https://wiki.archlinux.org/index.php/Sysctl)
* [NSA: Guide to the Secure Configuration of Red Hat Enterprise Linux 5](http://www.nsa.gov/ia/_files/os/redhat/rhel5-guide-i731.pdf)
* [Ubuntu Security/Features](https://wiki.ubuntu.com/Security/Features)
* [Deutsche Telekom, Group IT Security, Security Requirements (German)](https://www.telekom.com/psa)


[1]: http://travis-ci.org/dev-sec/ansible-os-hardening
[2]: https://gitter.im/dev-sec/general
[3]: https://galaxy.ansible.com/dev-sec/os-hardening
