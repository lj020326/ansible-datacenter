---
title: "Bootstrap VMware ESXi Host Configuration"
role: roles/bootstrap_vmware_esxi_hostconf
category: VMware
type: Role
tags: [ansible, role, bootstrap_vmware_esxi_hostconf]
---

```yaml
---
title: Bootstrap VMware ESXi Host Configuration
role: bootstrap_vmware_esxi_hostconf
category: VMware
type: Role
summary: |
  The `bootstrap_vmware_esxi_hostconf` role is designed to configure VMware ESXi hosts with a comprehensive set of settings, including hostname, DNS, NTP, users, networking, storage, autostart, logging, certificates, and software. This role ensures that ESXi hosts are configured consistently and securely according to best practices.

variables: |
  | Variable Name                          | Default Value                       | Description                                                                 |
  |----------------------------------------|-------------------------------------|-----------------------------------------------------------------------------|
  | `esx_asm_cmd`                          | `vim-cmd hostsvc/autostartmanager`  | Command to manage autostart settings.                                       |
  | `esx_domain`                           | `example.int`                       | Domain name for the ESXi host.                                               |
  | `esx_serial`                           | `XXXXX-XXXXX-XXXX-XXXXX-XXXXX`      | Serial number for the ESXi license.                                          |
  | `esx_regenerate_certs`                 | `false`                             | Whether to regenerate self-signed certificates.                              |
  | `esx_dns_servers`                      | `192.168.0.1`                       | List of DNS servers to configure.                                            |
  | `esx_search_domains`                   | `subdomain.example.int, example.int`| List of search domains to configure.                                          |
  | `esxi_local_users`                     | `[]`                                | List of local users to configure on the ESXi host.                           |
  | `esxi_fqdn`                            | `{{ inventory_hostname }}.{{ esx_domain }}` | Fully qualified domain name of the ESXi host.                                |
  | `esx_vmfs_guid`                        | `AA31E02A400F11DB9590000C2911D1B8` | GUID for VMFS datastores.                                                    |
  | `esx_force_reboot`                     | `false`                             | Whether to force a reboot after configuration.                               |
  | `esx_ssh_timeout`                      | `3600`                              | SSH timeout in seconds.                                                      |
  | `esx_syslog_host`                      | `log.{{ esx_domain }}`              | Syslog host for logging.                                                     |
  | `esx_local_datastores`                 | `{}`                                | Dictionary of local datastores to configure.                                 |
  | `esx_rename_datastores`                | `true`                              | Whether to rename datastores.                                                |
  | `esx_create_datastores`                | `true`                              | Whether to create datastores.                                                |
  | `esx_permit_ssh_from`                  | `192.168.0.*`                       | IP address range permitted to SSH into the ESXi host.                        |
  | `esx_autostart_only_listed`            | `false`                             | Whether to autostart only listed VMs.                                        |
  | `esx_vswitch_def`                      | `vSwitch0`                          | Default vSwitch name.                                                        |
  | `esx_create_vmotion_iface`             | `false`                             | Whether to create a vMotion interface.                                       |
  | `esx_vmotion_iface_name`               | `vmk1`                              | Name of the vMotion interface.                                               |
  | `esx_vmotion_portgroup_name`           | `vMotion`                           | Name of the vMotion portgroup.                                               |
  | `esx_vmotion_subnet_number`            | `241`                               | Subnet number for the vMotion interface.                                     |
  | `bootstrap_vmware_esxi_hostconf__setup_hostname` | `false` | Whether to set up the hostname.                                             |
  | `bootstrap_vmware_esxi_hostconf__setup_license` | `false` | Whether to set up the license.                                              |
  | `bootstrap_vmware_esxi_hostconf__setup_dns` | `false` | Whether to set up DNS.                                                      |
  | `bootstrap_vmware_esxi_hostconf__setup_ntp` | `true` | Whether to set up NTP.                                                      |
  | `bootstrap_vmware_esxi_hostconf__setup_users` | `false` | Whether to set up users.                                                    |
  | `bootstrap_vmware_esxi_hostconf__setup_network` | `false` | Whether to set up networking.                                               |
  | `bootstrap_vmware_esxi_hostconf__setup_storage` | `false` | Whether to set up storage.                                                  |
  | `bootstrap_vmware_esxi_hostconf__setup_autostart` | `false` | Whether to set up autostart.                                                |
  | `bootstrap_vmware_esxi_hostconf__setup_logging` | `false` | Whether to set up logging.                                                  |
  | `bootstrap_vmware_esxi_hostconf__setup_certs` | `false` | Whether to set up certificates.                                             |
  | `bootstrap_vmware_esxi_hostconf__setup_software` | `false` | Whether to set up software.                                                 |

usage: |
  To use this role, include it in your playbook and set the desired variables. For example:

  ```yaml
  - hosts: esxi_hosts
    roles:
      - role: bootstrap_vmware_esxi_hostconf
        vars:
          esx_domain: "example.com"
          esx_serial: "ABCD1234EFGH5678IJKL"
          esx_dns_servers:
            - 8.8.8.8
            - 8.8.4.4
          esx_search_domains:
            - subdomain.example.com
            - example.com
          esxi_local_users:
            - name: "user1"
              desc: "User 1 description"
            - name: "user2"
              desc: "User 2 description"
          esx_local_datastores:
            datastore1:
              name: "datastore1"
            datastore2:
              name: "datastore2"
          bootstrap_vmware_esxi_hostconf__setup_hostname: true
          bootstrap_vmware_esxi_hostconf__setup_license: true
          bootstrap_vmware_esxi_hostconf__setup_dns: true
          bootstrap_vmware_esxi_hostconf__setup_ntp: true
          bootstrap_vmware_esxi_hostconf__setup_users: true
          bootstrap_vmware_esxi_hostconf__setup_network: true
          bootstrap_vmware_esxi_hostconf__setup_storage: true
          bootstrap_vmware_esxi_hostconf__setup_autostart: true
          bootstrap_vmware_esxi_hostconf__setup_logging: true
          bootstrap_vmware_esxi_hostconf__setup_certs: true
          bootstrap_vmware_esxi_hostconf__setup_software: true
  ```

dependencies: |
  This role does not have any external dependencies, but it relies on the following Ansible modules:
  - `esxi_vm_info`
  - `esxi_autostart`
  - `esxi_vib`

best_practices: |
  1. Always test the role in a development environment before applying it to production hosts.
  2. Ensure that the ESXi hosts are reachable and that the necessary credentials are provided.
  3. Regularly review and update the role to accommodate changes in the ESXi environment.
  4. Use the role in conjunction with other automation tools to achieve a fully automated ESXi deployment.

backlinks: |
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