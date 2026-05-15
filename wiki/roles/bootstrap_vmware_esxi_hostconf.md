---
title: "VMware ESXi Host Configuration Role"
role: bootstrap_vmware_esxi_hostconf
category: VMware
type: Ansible Role
tags: esxi, vmware, configuration, automation
---

## Summary

The `bootstrap_vmware_esxi_hostconf` role is designed to automate the configuration of VMware ESXi hosts. It handles various aspects such as hostname setup, license assignment, DNS and NTP configuration, user management, network settings, storage configuration, autostart options, logging, SSL certificates, and software installation. This role ensures that ESXi hosts are configured consistently and securely according to specified parameters.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `role_bootstrap_vmware_esxi_hostconf__esx_asm_cmd` | `vim-cmd hostsvc/autostartmanager` | Command used for managing ESXi autostart settings. |
| `role_bootstrap_vmware_esxi_hostconf__esx_domain` | `example.int` | Domain name for the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__esx_serial` | `XXXXX-XXXXX-XXXX-XXXXX-XXXXX` | License serial number for the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__esx_regenerate_certs` | `false` | Whether to regenerate self-signed SSL certificates. |
| `role_bootstrap_vmware_esxi_hostconf__esx_dns_servers` | `[192.168.0.1]` | List of DNS servers for the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__esx_search_domains` | `['subdomain.example.int', 'example.int']` | List of search domains for the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__esxi_local_users` | `[]` | List of local users to be configured on the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__esxi_fqdn` | `"{{ inventory_hostname }}.{{ role_bootstrap_vmware_esxi_hostconf__esx_domain }}"` | Fully Qualified Domain Name for the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__esx_vmfs_guid` | `AA31E02A400F11DB9590000C2911D1B8` | GUID used for VMFS partitions on the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__esx_force_reboot` | `false` | Whether to force a reboot of the ESXi host after configuration changes. |
| `role_bootstrap_vmware_esxi_hostconf__esx_ssh_timeout` | `3600` | SSH timeout value for the ESXi host in seconds. |
| `role_bootstrap_vmware_esxi_hostconf__esx_syslog_host` | `log.{{ role_bootstrap_vmware_esxi_hostconf__esx_domain }}` | Syslog server hostname or IP address. |
| `role_bootstrap_vmware_esxi_hostconf__esx_local_datastores` | `{}` | Dictionary of local datastores to be configured on the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__esx_rename_datastores` | `true` | Whether to rename existing datastores according to the configuration. |
| `role_bootstrap_vmware_esxi_hostconf__esx_create_datastores` | `true` | Whether to create new datastores on vacant LUNs. |
| `role_bootstrap_vmware_esxi_hostconf__esx_permit_ssh_from` | `192.168.0.*` | IP range allowed to SSH into the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__esx_autostart_only_listed` | `false` | Whether to disable autostart for VMs not listed in the configuration. |
| `role_bootstrap_vmware_esxi_hostconf__esx_vswitch_def` | `vSwitch0` | Default vSwitch name used for network configurations. |
| `role_bootstrap_vmware_esxi_hostconf__esx_create_vmotion_iface` | `false` | Whether to create a VMotion interface on the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__esx_vmotion_iface_name` | `vmk1` | Name of the VMotion interface. |
| `role_bootstrap_vmware_esxi_hostconf__esx_vmotion_portgroup_name` | `vMotion` | Portgroup name for the VMotion interface. |
| `role_bootstrap_vmware_esxi_hostconf__esx_vmotion_subnet_number` | `241` | Subnet number used for calculating the VMotion IP address. |
| `role_bootstrap_vmware_esxi_hostconf__setup_hostname` | `false` | Whether to configure the hostname of the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__setup_license` | `false` | Whether to assign a license to the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__setup_dns` | `false` | Whether to configure DNS settings on the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__setup_ntp` | `true` | Whether to configure NTP settings on the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__setup_users` | `false` | Whether to manage local users on the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__setup_network` | `false` | Whether to configure network settings on the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__setup_storage` | `false` | Whether to configure storage settings on the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__setup_autostart` | `false` | Whether to configure autostart options for VMs on the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__setup_logging` | `false` | Whether to configure logging settings on the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__setup_certs` | `false` | Whether to manage SSL certificates on the ESXi host. |
| `role_bootstrap_vmware_esxi_hostconf__setup_software` | `false` | Whether to install required VIBs (vSphere Installation Bundles) on the ESXi host. |

## Usage

To use this role, include it in your playbook and set the appropriate variables as needed. Here is an example of how to configure an ESXi host with specific settings:

```yaml
- name: Configure VMware ESXi Host
  hosts: esxi_hosts
  roles:
    - role: bootstrap_vmware_esxi_hostconf
      vars:
        role_bootstrap_vmware_esxi_hostconf__esx_domain: "yourdomain.com"
        role_bootstrap_vmware_esxi_hostconf__esx_serial: "AAAAA-BBBBB-CCCCC-DDDDD-EEEEE"
        role_bootstrap_vmware_esxi_hostconf__esx_dns_servers:
          - 8.8.8.8
          - 8.8.4.4
        role_bootstrap_vmware_esxi_hostconf__esx_search_domains:
          - sub.yourdomain.com
          - yourdomain.com
        role_bootstrap_vmware_esxi_hostconf__esxi_local_users:
          admin_user:
            desc: "Administrator User"
        role_bootstrap_vmware_esxi_hostconf__setup_hostname: true
        role_bootstrap_vmware_esxi_hostconf__setup_license: true
        role_bootstrap_vmware_esxi_hostconf__setup_dns: true
        role_bootstrap_vmware_esxi_hostconf__setup_ntp: true
        role_bootstrap_vmware_esxi_hostconf__setup_users: true
        role_bootstrap_vmware_esxi_hostconf__setup_network: true
        role_bootstrap_vmware_esxi_hostconf__setup_storage: true
        role_bootstrap_vmware_esxi_hostconf__setup_autostart: true
        role_bootstrap_vmware_esxi_hostconf__setup_logging: true
        role_bootstrap_vmware_esxi_hostconf__setup_certs: true
```

## Dependencies

This role does not have any external dependencies. However, it requires the `esxi_vm_info` and `esxi_autostart` modules from the VMware collection (`community.vmware`) for certain tasks.

## Best Practices

- Ensure that all variables are set appropriately before running the playbook to avoid configuration issues.
- Use secure methods for handling sensitive information such as license keys and passwords.
- Test configurations in a non-production environment before applying them to production systems.
- Regularly update the role to incorporate any necessary changes or improvements.

## Molecule Tests

This role does not currently include Molecule tests. However, it is recommended to create test scenarios using Molecule to ensure the role functions as expected under various conditions.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_vmware_esxi_hostconf/defaults/main.yml)
- [tasks/autostart.yml](../../roles/bootstrap_vmware_esxi_hostconf/tasks/autostart.yml)
- [tasks/certs.yml](../../roles/bootstrap_vmware_esxi_hostconf/tasks/certs.yml)
- [tasks/dns.yml](../../roles/bootstrap_vmware_esxi_hostconf/tasks/dns.yml)
- [tasks/hostname.yml](../../roles/bootstrap_vmware_esxi_hostconf/tasks/hostname.yml)
- [tasks/license.yml](../../roles/bootstrap_vmware_esxi_hostconf/tasks/license.yml)
- [tasks/logging.yml](../../roles/bootstrap_vmware_esxi_hostconf/tasks/logging.yml)
- [tasks/main.yml](../../roles/bootstrap_vmware_esxi_hostconf/tasks/main.yml)
- [tasks/network.yml](../../roles/bootstrap_vmware_esxi_hostconf/tasks/network.yml)
- [tasks/ntp.yml](../../roles/bootstrap_vmware_esxi_hostconf/tasks/ntp.yml)
- [tasks/software.yml](../../roles/bootstrap_vmware_esxi_hostconf/tasks/software.yml)
- [tasks/storage.yml](../../roles/bootstrap_vmware_esxi_hostconf/tasks/storage.yml)
- [tasks/users.yml](../../roles/bootstrap_vmware_esxi_hostconf/tasks/users.yml)
- [handlers/main.yml](../../roles/bootstrap_vmware_esxi_hostconf/handlers/main.yml)