---
title: "Bootstrap Vmware Esxi Hostconf Role"
role: roles/bootstrap_vmware_esxi_hostconf
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_vmware_esxi_hostconf]
---

# Role Documentation: `bootstrap_vmware_esxi_hostconf`

## Overview

The `bootstrap_vmware_esxi_hostconf` role is designed to automate the configuration of VMware ESXi hosts using Ansible. This role provides a comprehensive set of tasks to configure various aspects of an ESXi host, including hostname, license, DNS settings, NTP, users, network, storage, autostart, logging, certificates, and software.

## Role Path

```
roles/bootstrap_vmware_esxi_hostconf
```

## Default Variables

The following variables are defined in `defaults/main.yml` and can be overridden by the user:

| Variable Name                             | Description                                                                 | Default Value                                                                 |
|-------------------------------------------|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| `esx_asm_cmd`                             | Command to manage ESXi autostart settings.                                | `vim-cmd hostsvc/autostartmanager`                                            |
| `esx_domain`                              | Domain name for the ESXi host.                                              | `example.int`                                                                 |
| `esx_serial`                              | License serial number for the ESXi host.                                    | `XXXXX-XXXXX-XXXX-XXXXX-XXXXX`                                                |
| `esx_regenerate_certs`                    | Flag to regenerate self-signed certificates.                                | `false`                                                                       |
| `esx_dns_servers`                         | List of DNS servers.                                                        | `['192.168.0.1']`                                                             |
| `esx_search_domains`                      | List of search domains.                                                     | `['subdomain.example.int', 'example.int']`                                    |
| `esxi_local_users`                        | List of local users to be configured on the ESXi host.                      | `[]`                                                                          |
| `esxi_fqdn`                               | Fully Qualified Domain Name for the ESXi host.                              | `"{{ inventory_hostname }}.{{ esx_domain }}"`                                  |
| `esx_vmfs_guid`                           | VMFS GUID to be used when creating new datastores.                          | `AA31E02A400F11DB9590000C2911D1B8`                                            |
| `esx_force_reboot`                        | Flag to force a reboot of the ESXi host after configuration.                | `false`                                                                       |
| `esx_ssh_timeout`                         | SSH timeout value in seconds.                                               | `3600`                                                                        |
| `esx_syslog_host`                         | Syslog server hostname or IP address.                                       | `log.{{ esx_domain }}`                                                        |
| `esx_local_datastores`                    | Dictionary of local datastores to be configured on the ESXi host.           | `{}`                                                                          |
| `esx_rename_datastores`                   | Flag to rename existing datastores if necessary.                            | `true`                                                                        |
| `esx_create_datastores`                   | Flag to create new datastores on vacant LUNs.                               | `true`                                                                        |
| `esx_permit_ssh_from`                     | IP range or address from which SSH access is permitted.                   | `192.168.0.*`                                                                 |
| `esx_autostart_only_listed`               | Flag to enable autostart only for listed VMs.                               | `false`                                                                       |
| `esx_vswitch_def`                         | Default vSwitch name.                                                       | `vSwitch0`                                                                    |
| `esx_create_vmotion_iface`                | Flag to create a vMotion interface.                                         | `false`                                                                       |
| `esx_vmotion_iface_name`                  | Name of the vMotion interface.                                              | `vmk1`                                                                        |
| `esx_vmotion_portgroup_name`              | Portgroup name for vMotion traffic.                                         | `vMotion`                                                                     |
| `esx_vmotion_subnet_number`               | Subnet number for vMotion IP address calculation.                           | `241`                                                                         |
| `bootstrap_vmware_esxi_hostconf__setup_hostname` | Flag to configure hostname.                                             | `false`                                                                       |
| `bootstrap_vmware_esxi_hostconf__setup_license`  | Flag to configure license.                                              | `false`                                                                       |
| `bootstrap_vmware_esxi_hostconf__setup_dns`      | Flag to configure DNS settings.                                           | `false`                                                                       |
| `bootstrap_vmware_esxi_hostconf__setup_ntp`      | Flag to configure NTP settings.                                           | `true`                                                                        |
| `bootstrap_vmware_esxi_hostconf__setup_users`    | Flag to configure local users.                                            | `false`                                                                       |
| `bootstrap_vmware_esxi_hostconf__setup_network`  | Flag to configure network settings.                                       | `false`                                                                       |
| `bootstrap_vmware_esxi_hostconf__setup_storage`  | Flag to configure storage settings.                                       | `false`                                                                       |
| `bootstrap_vmware_esxi_hostconf__setup_autostart`| Flag to configure autostart settings.                                     | `false`                                                                       |
| `bootstrap_vmware_esxi_hostconf__setup_logging`  | Flag to configure logging settings.                                       | `false`                                                                       |
| `bootstrap_vmware_esxi_hostconf__setup_certs`    | Flag to configure certificates.                                         | `false`                                                                       |
| `bootstrap_vmware_esxi_hostconf__setup_software` | Flag to configure software settings.                                      | `false`                                                                       |

## Tasks

### Main Task File (`tasks/main.yml`)

The main task file orchestrates the execution of other tasks based on the flags set in the default variables.

```yaml
- name: Run hostname.yml
  when: bootstrap_vmware_esxi_hostconf__setup_hostname | bool
  ansible.builtin.include_tasks: hostname.yml

# Additional tasks are included similarly...
```

### Detailed Task Files

#### `tasks/autostart.yml`
Configures autostart settings for VMs on the ESXi host.

- **Tasks**:
  - Retrieves current autostart options.
  - Converts retrieved options to a structured format.
  - Enables autostart if not already enabled.
  - Sets default autostart behavior.
  - Manages autostart settings for individual VMs based on provided lists.

#### `tasks/certs.yml`
Manages SSL certificates on the ESXi host.

- **Tasks**:
  - Regenerates self-signed certificates if specified.
  - Checks and copies server certificates from a designated directory.

#### `tasks/dns.yml`
Configures DNS settings for the ESXi host using a template file.

- **Tasks**:
  - Creates or updates the `/etc/resolv.conf` file with provided DNS servers and search domains.

#### `tasks/hostname.yml`
Sets the hostname of the ESXi host.

- **Tasks**:
  - Retrieves the current hostname.
  - Sets the hostname to the specified FQDN if it differs from the current one.

#### `tasks/license.yml`
Configures the license for the ESXi host.

- **Tasks**:
  - Retrieves the current license serial number.
  - Assigns a new license if the current one is invalid or not set.

#### `tasks/logging.yml`
Configures logging settings on the ESXi host.

- **Tasks**:
  - Configures syslog server settings.
  - Enables syslog client through the firewall.
  - Sets logging levels for various services like vpxa, rhttpproxy, and hostd.

#### `tasks/network.yml`
Configures network settings including portgroups and interfaces on the ESXi host.

- **Tasks**:
  - Manages portgroups: adds, deletes, or updates VLAN tags.
  - Blocks BPDUs from guests.
  - Creates a vMotion interface if specified.

#### `tasks/ntp.yml`
Configures NTP settings for time synchronization on the ESXi host.

- **Tasks**:
  - Updates the `/etc/ntp.conf` file with provided NTP servers.
  - Enables NTP client through the firewall.
  - Ensures the NTP service is running and enabled to start at boot.

#### `tasks/software.yml`
Manages software installations on the ESXi host using VIBs (vSphere Installation Bundles).

- **Tasks**:
  - Checks and installs required VIBs from specified URLs.

#### `tasks/storage.yml`
Configures storage settings including datastores on the ESXi host.

- **Tasks**:
  - Retrieves information about existing filesystems and devices.
  - Renames or creates new datastores based on provided configurations.

#### `tasks/users.yml`
Manages local users on the ESXi host.

- **Tasks**:
  - Retrieves current user list.
  - Adds, modifies, or deletes users as specified.
  - Configures SSH timeout settings and firewall rules for SSH access.

## Handlers

Handlers are used to perform actions after certain tasks have been executed. They ensure that services are reloaded or restarted when necessary.

- **Handlers**:
  - `reload syslog config`: Reloads the syslog configuration.
  - `restart vpxa`, `restart rhttpproxy`, `restart hostd`: Restarts various ESXi services.
  - `restart ntpd`: Restarts the NTP service.

## Usage

To use this role, include it in your Ansible playbook and set the appropriate flags to enable the desired configurations. For example:

```yaml
- name: Configure ESXi Hosts
  hosts: esxi_hosts
  roles:
    - role: bootstrap_vmware_esxi_hostconf
      vars:
        bootstrap_vmware_esxi_hostconf__setup_hostname: true
        bootstrap_vmware_esxi_hostconf__setup_license: true
        bootstrap_vmware_esxi_hostconf__setup_dns: true
        bootstrap_vmware_esxi_hostconf__setup_ntp: true
        esx_serial: "AAAAA-BBBBB-CCCCC-DDDDD-EEEEE"
```

## Important Notes

- **Double-underscore variables**: These are internal to the role and should not be modified unless necessary.
- **Related Roles**: This documentation does not define any related roles. The `bootstrap_vmware_esxi_hostconf` role is self-contained.
- **Markdown Format**: This documentation uses standard GitHub Markdown for formatting.

This comprehensive guide provides a detailed overview of the `bootstrap_vmware_esxi_hostconf` role, its variables, tasks, and usage instructions to help you effectively manage VMware ESXi host configurations using Ansible.