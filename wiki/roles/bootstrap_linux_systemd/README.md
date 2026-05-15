```markdown
---
title: Bootstrap Linux Systemd Configuration
original_path: roles/bootstrap_linux_systemd/README.md
category: Ansible Roles
tags: [systemd, journald, tmpfiles, timezone, timesyncd, vconsole, networkd, resolved, modules-load]
---

# Bootstrap Linux Systemd

This role allows you to define and configure various systemd components:

- [journald.conf](https://www.freedesktop.org/software/systemd/man/journald.conf.html)
- [tmpfiles.d](https://www.freedesktop.org/software/systemd/man/tmpfiles.d.html)
- Set timezone via [systemd-timedatectl](https://www.freedesktop.org/software/systemd/man/timedatectl.html)
- [timesyncd](https://www.freedesktop.org/software/systemd/man/systemd-timesyncd.service.html) support
- Set console settings via [vconsole.conf](https://www.freedesktop.org/software/systemd/man/vconsole.conf.html)
- [networkd](https://www.freedesktop.org/software/systemd/man/systemd-networkd.html) support
- [resolved](https://www.freedesktop.org/software/systemd/man/systemd-resolved.html) support
- [modules-load.d](https://www.freedesktop.org/software/systemd/man/modules-load.d.html) support

## Requirements

- Ansible 3.0.0+

## Additional Information

- **journald options**: Not validated and passed as-is. For all possible options, consult `man journald.conf(5)`.
- **tmpfiles**: Validated by real-time execution (online apply settings).
- **udev rules syntax**: Validated via external script.
- **networkd address declaration**:
  - **Simple**: One or many addresses and gateway.

    ```yaml
    systemd_networkd:
      - interfaces:
        - interface: 'eth0'
          type: 'ether'
          physaddr: '18:66:da:e6:be:88'
          address: '10.10.10.2/24'
          gateway: '10.10.10.1'
    ```

  - **Complex**: More `ip` options.

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

- **networkd device matching**: Can use shell-style globs to match devices.

  ```yaml
  systemd_networkd:
    - interfaces:
      - interface: 'ethernet'
        type: 'ether'
        dhcp: 'yes'
        match_override:
          - match_entry: 'Name'
            match_value: 'e*' # Matches any `ens*/enp*/eth*` device
  ```

## Example Configuration

```yaml
# systemd-tmpfiles configuration for volatile and temporary files.
systemd_tmpfiles:
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

# systemd-modules-load configuration for loading kernel modules.
systemd_modules_load:
  - drop_exists: 'true'
    modules_load:
      - file_name: '99-ipvs'
        modules:
          - 'ip_vs'
          - 'virtio_net'
      - file_name: 'facebook'
        modules:
          - 'tls'

# systemd-timesyncd configuration for network time synchronization.
systemd_timesyncd:
  - enable: 'true'
    restart: 'true'
    timezone: 'Asia/Yekaterinburg'
    timesyncd:
      ntp:
        - '0.ru.pool.ntp.org'
        - '1.ru.pool.ntp.org'
      fallback: ''
      root_distance_max_sec: '5'
      poll_interval_min_sec: '32'
      poll_interval_max_sec: '2048'

# journald configuration for logging.
systemd_journald_settings:
  Storage: 'persistent'
  SystemMaxUse: '10G'

# udev rules configuration for device management.
systemd_udev:
  - file_name: '10-persistent-net'
    rules:
      - 'ACTION=="add", SUBSYSTEM=="net", DRIVERS=="?*", ATTR{type}=="32", ATTR{address}=="?*00:02:c9:03:00:31:78:f2", NAME="mlx4_ib3"'
      - 'SUBSYSTEM=="net", ATTR{address}=="18:66:da:e6:be:88", NAME="gig0"'
  - file_name: '90-otcash'
    rules:
      - 'ATTRS{idVendor}=="079b", ATTRS{idProduct}=="0028", GROUP="100", MODE="0660", SYMLINK+="ingenico"'
      - 'ATTRS{idVendor}=="abcd", ATTRS{idProduct}=="1980", GROUP="100", MODE="0660"'
```

## Backlinks

- [Ansible Roles Documentation](/roles)
- [Systemd Configuration Guide](/systemd-config)

```

This improved Markdown document maintains the original content and meaning while adhering to clean, professional formatting standards suitable for GitHub rendering.