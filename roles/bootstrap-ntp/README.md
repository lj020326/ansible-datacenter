# Ansible Role: bootstrap-ntp

Installs NTP on Linux.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

    bootstrap_ntp__enabled: true

Whether to start the ntpd service and enable it at system boot. On many virtual machines that run inside a container (like OpenVZ or VirtualBox), it's recommended you don't run the NTP daemon, since the host itself should be set to synchronize time for all its child VMs.

    bootstrap_ntp__timezone: Etc/UTC

Set the timezone for your server.

    bootstrap_ntp__package: ntp

The package to install which provides NTP functionality. The default is `ntp` for most platforms, or `chrony` on RHEL/CentOS 7 and later.

    bootstrap_ntp__daemon: [various]

The default NTP daemon should be correct for your distribution, but there are some cases where you may want to override the default, e.g. if you're running `ntp` on newer versions of RHEL/CentOS.

    bootstrap_ntp__config_file: /etc/ntp.conf

The path to the NTP configuration file. The default is `/etc/ntp.conf` for most platforms, or `/etc/chrony.conf` on RHEL/CentOS 7 and later.

    bootstrap_ntp__manage_config: false

Set to true to allow this role to manage the NTP configuration file (`/etc/ntp.conf`).

    bootstrap_ntp__driftfile: [various]

The default NTP driftfile should be correct for your distribution, but there are some cases where you may want to override the default.

    bootstrap_ntp__area: ''

Set the [NTP Pool Area](http://support.ntp.org/bin/view/Servers/NTPPoolServers) to use. Defaults to none, which uses the worldwide pool.

    bootstrap_ntp__servers_options: "iburst xleave"

Set the [NTP Server Options](https://www.systutorials.com/docs/linux/man/5-ntp/) to use. Defaults to 'iburst xleave'.

    bootstrap_ntp__servers:
      - "0{{ '.' + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org iburst"
      - "1{{ '.' + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org iburst"
      - "2{{ '.' + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org iburst"
      - "3{{ '.' + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org iburst"

Specify the NTP servers you'd like to use. Only takes effect if you allow this role to manage NTP's configuration, by setting `bootstrap_ntp__manage_config` to `True`.

    bootstrap_ntp__allow_networks:
      - "192.168.0.0/16"

Allow NTP access to these hosts using CIDR network

    bootstrap_ntp__restrict:
      - "127.0.0.1"
      - "::1"
      - "192.168.56.0 mask 255.255.255.0 nomodify notrap"
      - "192.168.0.0 mask 255.255.255.0 notrust"

Restrict NTP access to these hosts; loopback only, by default.

    bootstrap_ntp__cron_handler_enabled: false

Whether to restart the cron daemon after the timezone has changed.

    bootstrap_ntp__tinker_panic: true

Enable tinker panic, which is useful when running NTP in a VM.

## Dependencies

None.

## Example Playbook

    - hosts: all
      roles:
        - bootstrap-ntp

*Inside `vars/main.yml`*:

    bootstrap_ntp__timezone: America/Chicago
