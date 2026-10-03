---
title: "Bootstrap Linux Systemd"
original_path: "roles/bootstrap_linux_systemd/README.md"
category: "Ansible Role"
tags: ["Ansible", "Systemd", "Linux", "Configuration"]
---

# Bootstrap Linux Systemd

This Ansible role allows you to define and configure various systemd components on a Linux system, including:

- [journald.conf](https://www.freedesktop.org/software/systemd/man/journald.conf.html)
- [tmpfiles](https://www.freedesktop.org/software/systemd/man/tmpfiles.d.html)
- Set timezone via [systemd-timedatectl](https://www.freedesktop.org/software/systemd/man/timedatectl.html)
- [timesyncd](https://www.freedesktop.org/software/systemd/man/systemd-timesyncd.service.html) support
- Set console settings via [vconsole.conf](https://www.freedesktop.org/software/systemd/man/vconsole.conf.html)
- [networkd](https://www.freedesktop.org/software/systemd/man/systemd-networkd.html) support
- [resolved](https://www.freedesktop.org/software/systemd/man/systemd-resolved.html) support
- [modules-load](https://www.freedesktop.org/software/systemd/man/modules-load.d.html) support

## Requirements

- Ansible 3.0.0+

## Extra Information

- **journald** options are not validated and passed as-is. For all possible options, consult `man journald.conf(5)`.
- **tmpfiles** are validated by real-time execution (online apply settings).
- **udev** rules syntax is validated via an external script.
- **networkd** address declaration can be simple or complex:
  - **Simple**: One or many addresses and gateway:

    ```yaml
    systemd_networkd:
    - interfaces:
      - interface: 'eth0'
        type: 'ether'
        physaddr: '18:66:da:e6:be:88'
        address: '10.10.10.2/24'
        gateway: '10.10.10.1'
    ```

  - **Complex**: You can declare more `ip` options:

    ```yaml
    systemd_networkd:
    - interfaces:
      - interface: 'eth0'
        type: 'ether'
        physaddr: '18:66:da:e6:be:88'
        ip:
        - address: '10.10.10.2/24'
          gateway: '10.10.10.1'
          preferred_lifetime: 'forever'
          scope: 'global'
    ```

- **networkd** can use shell-style globs to match devices. For example, if your host just needs simple DHCP on Ethernet interfaces, you can define a simple 'match any eth iface' like this:

    ```yaml
    ---
    systemd_networkd:
    - interfaces:
      - interface: 'ethernet'
        type: 'ether'
        dhcp: 'yes'
        match_override:
        - match_entry: 'Name'
          match_value: 'e*' # <--- any linux `ens*/enp*/eth*` device
    ```

## Example Configuration

```yaml
---
# systemd-tmpfiles uses the configuration files from the above directories to
# describe the creation, cleaning, and removal of volatile and temporary files
# and directories which usually reside in directories such as '/run' or '/tmp'.
# Volatile and temporary files and directories are those located in '/run'
# (and its alias '/var/run'), '/tmp', '/var/tmp', the API file systems such
# as '/sys' or '/proc', as well as some other directories below '/var'.
systemd_tmpfiles:
# This option allows deleting '/etc/tmpfiles.d/*.conf' files before deployment.
- drop_exists: 'true'
  create:
  - file_name: 'set_sda_scheduler'
    path: '/sys/block/sda/queue/scheduler'
    type: 'w'
    arg: 'noop'
  - file_name: 'example1'
    path: '/tmp/example1'
    type: 'd'
    mode: '0755'
    uid: 'root'
    gid: 'root'
    age: '10d'
  clean:
  - file_name: 'example2'
    path: '/tmp/example2'
    type: 'd'
    mode: '0755'
    uid: 'root'
    gid: 'root'
    age: '1m'
  remove:
  - file_name: 'example3'
    path: '/tmp/example3'
    type: 'r'

systemd_modules_load:
# This option allows deleting '/etc/modules-load.d/*.conf' files before deployment.
- drop_exists: 'true'
  modules_load:
  - file_name: '99-ipvs'
    modules:
    - 'ip_vs'
    - 'virtio_net'
  - file_name: 'facebook'
    modules:
    - 'tls'

systemd_timesyncd:
# Enable systemd-timesyncd or not.
- enable: 'true'
# Restart systemd-timesyncd after deployment or not.
  restart: 'true'
# Set this timezone.
  timezone: 'Asia/Yekaterinburg'
  timesyncd:
# A list of NTP server host names or IP addresses. During runtime, this list is
# combined with any per-interface NTP servers acquired from systemd-networkd.
# systemd-timesyncd will contact all configured system or per-interface servers
# in turn until one is found that responds. When the empty string is assigned,
# the list of NTP servers is reset, and all assignments prior to this one will
# have no effect. This setting defaults to an empty list.
  - ntp:
    - '0.ru.pool.ntp.org'
    - '1.ru.pool.ntp.org'
# A list of NTP server host names or IP addresses to be used as the fallback
# NTP servers. Any per-interface NTP servers obtained from systemd-networkd
# take precedence over this setting, as do any servers set via 'ntp' above.
# This setting is hence only used if no other NTP server information is known.
# When the empty string is assigned, the list of NTP servers is reset, and all
# assignments prior to this one will have no effect. If this option is not
# given, a compiled-in list of NTP servers is used instead.
    fallback: ''
# Maximum acceptable root distance. Takes a time value (in seconds). Defaults
# to 5 seconds.
    root_distance_max_sec: '5'
# The minimum and maximum poll intervals for NTP messages. Each setting takes a
# time value (in seconds). PollIntervalMinSec= must not be smaller than 16
# seconds. 'poll_interval_max_sec' must be larger than 'poll_interval_min_sec'.
# 'poll_interval_min_sec' defaults to 32 seconds, and 'poll_interval_max_sec'
# defaults to 2048 seconds.
    poll_interval_min_sec: '32'
    poll_interval_max_sec: '2048'

systemd_journald_settings:
  Storage: 'persistent'
  SystemMaxUse: '10G'

systemd_udev:
- file_name: '10-persistent-net'
  rules:
  - 'ACTION=="add", SUBSYSTEM=="net", DRIVERS=="?*", ATTR{type}=="32", ATTR{address}=="?*00:02:c9:03:00:31:78:f2", NAME="mlx4_ib3"'
  - 'SUBSYSTEM=="net", ATTR{address}=="18:66:da:e6:be:88", NAME="gig0"'
- file_name: '90-otcash'
  rules:
  - 'ATTRS{idVendor}=="079b", ATTRS{idProduct}=="0028", GROUP="100", MODE="0660", SYMLINK+="ingenico"'
  - 'ATTRS{idVendor}=="abcd", ATTRS{idProduct}=="1980", GROUP="100", MODE="0660", SYMLINK+="ingenico"'
... [truncated - large file] ...

## Backlinks

This section will be automatically populated with links to other pages that reference this document.