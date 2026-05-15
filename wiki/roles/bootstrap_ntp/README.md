```markdown
---
title: Ansible Role - bootstrap_ntp
original_path: roles/bootstrap_ntp/README.md
category: Ansible Roles
tags: [ansible, ntp, time-sync]
---

# Ansible Role: bootstrap_ntp

Installs and configures NTP on Linux systems.

## Requirements

- None.

## Role Variables

Available variables are listed below, along with their default values (see `defaults/main.yml`):

- **bootstrap_ntp__enabled**: `true`
  - Whether to start the NTP daemon (`ntpd`) and enable it at system boot. It's recommended not to run the NTP daemon on virtual machines inside containers (e.g., OpenVZ or VirtualBox) since the host should handle time synchronization for all child VMs.

- **bootstrap_ntp__timezone**: `Etc/UTC`
  - Sets the timezone for your server.

- **bootstrap_ntp__package**: `ntp`
  - The package to install which provides NTP functionality. Defaults to `ntp` for most platforms, or `chrony` on RHEL/CentOS 7 and later.

- **bootstrap_ntp__daemon**: `[various]`
  - The default NTP daemon should be correct for your distribution, but you may override it if needed (e.g., using `ntp` on newer versions of RHEL/CentOS).

- **bootstrap_ntp__config_file**: `/etc/ntp.conf`
  - The path to the NTP configuration file. Defaults to `/etc/ntp.conf` for most platforms, or `/etc/chrony.conf` on RHEL/CentOS 7 and later.

- **bootstrap_ntp__manage_config**: `false`
  - Set to `true` to allow this role to manage the NTP configuration file (`/etc/ntp.conf`).

- **bootstrap_ntp__driftfile**: `[various]`
  - The default NTP driftfile should be correct for your distribution, but you may override it if needed.

- **bootstrap_ntp__area**: `''`
  - Sets the [NTP Pool Area](http://support.ntp.org/bin/view/Servers/NTPPoolServers) to use. Defaults to none, which uses the worldwide pool.

- **bootstrap_ntp__servers_options**: `"iburst xleave"`
  - Sets the [NTP Server Options](https://www.systutorials.com/docs/linux/man/5-ntp/) to use. Defaults to `'iburst xleave'`.

- **bootstrap_ntp__servers**:
  ```yaml
  - "0{{ '.' + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org iburst"
  - "1{{ '.' + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org iburst"
  - "2{{ '.' + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org iburst"
  - "3{{ '.' + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org iburst"
  ```
  - Specifies the NTP servers you'd like to use. Only takes effect if `bootstrap_ntp__manage_config` is set to `true`.

- **bootstrap_ntp__allow_networks**:
  ```yaml
  - "192.168.0.0/16"
  ```
  - Allows NTP access to these hosts using CIDR notation.

- **bootstrap_ntp__restrict**:
  ```yaml
  - "127.0.0.1"
  - "::1"
  - "192.168.56.0 mask 255.255.255.0 nomodify notrap"
  - "192.168.0.0 mask 255.255.255.0 notrust"
  ```
  - Restricts NTP access to these hosts; loopback only, by default.

- **bootstrap_ntp__cron_handler_enabled**: `false`
  - Whether to restart the cron daemon after the timezone has changed.

- **bootstrap_ntp__tinker_panic**: `true`
  - Enables tinker panic, which is useful when running NTP in a virtual machine.

## Dependencies

- None.

## Example Playbook

```yaml
- hosts: all
  roles:
    - bootstrap_ntp
```

*Inside `vars/main.yml`:*

```yaml
bootstrap_ntp__timezone: America/Chicago
```

## Backlinks

- [Ansible Roles Documentation](../README.md)
```

This improved Markdown document maintains the original content and meaning while adhering to clean, professional standards suitable for GitHub rendering.