```markdown
---
title: bootstrap_vmware_esxi_hostconf Role Documentation
original_path: roles/bootstrap_vmware_esxi_hostconf/README.md
category: Ansible Roles
tags: vmware, esxi, ansible, configuration
---

# bootstrap_vmware_esxi_hostconf

## Overview

This role is designed to manage standalone ESXi hosts using direct SSH connections and the `esxcli` command-line tool. It handles various aspects of ESXi server configuration.

## Key Features

- **ESXi License Management**: Applies an ESXi license key if specified.
- **Host Configuration**: Sets host name, DNS servers, NTP servers, and time synchronization.
- **User Management**:
  - Creates missing users and removes extra ones.
  - Assigns random passwords to new users (stored in `creds/`).
  - Ensures SSH keys persist across reboots.
  - Grants DCUI rights.
- **Portgroup Management**:
  - Creates missing portgroups and removes extras.
  - Assigns specified tags.
- **BPDU Blocking**: Blocks BPDUs from guests.
- **vMotion Interface**: Creates a vMotion interface (disabled by default; see `esx_create_vmotion_iface` in role defaults).
- **Datastore Management**:
  - Partitions specified devices if required.
  - Creates missing datastores.
  - Renames empty datastores with incorrect names.
- **VM Autostart Configuration**: Configures autostart for specified VMs (optionally disables it for all others).
- **Syslog Logging**: Configures logging to a syslog server and reduces the verbosity of `vpxa` and other noisy components from `verbose` to `info`.
- **Certificate Management**: Installs certificates for Host UI and SSL communication if provided.
- **VIB Installation/Update**: Installs or updates specified VIBs.

## Prerequisites

- Correctly configured network (especially uplinks).
- Reachability over SSH with root password.
- ESXi version 6.0+ (some newer versions of 5.5 may work due to Python 2.7 compatibility).

## Configuration

### General Configuration

- **`ansible.cfg`**: Specify remote user, inventory path, and vault pass method if using one for certificate private key encryption.
- **`group_vars/all.yaml`**: Set global parameters like NTP and syslog servers.
- **`group_vars/<site>.yaml`**: Define specific parameters for each `<site>` in the inventory.
- **`host_vars/<host>.yaml`**: Override global and group values with host-specific configurations, such as user lists or datastore settings.
- **Public Keys**: Place public keys for users in `roles/hostconf-esxi/files/id_rsa.<user>@<keyname>.pub` for later reference in user lists.

### Typical Variables

#### Global/Group-Specific Variables

- **Serial Number**:
  ```yaml
  esx_serial: "XXXXX-XXXXX-XXXX-XXXXX-XXXXX"
  ```

- **Network Configuration**:
  ```yaml
  esx_domain: "m0.maxidom.ru"
  esx_dns_servers:
    - 10.0.128.1
    - 10.0.128.2
  esx_ntp_servers:
    - 10.1.131.1
    - 10.1.131.2
  ```

#### Host-Specific Variables

- **User Configuration**:
  ```yaml
  esxi_local_users:
    "<user>":
      desc: "<user description>"
      pubkeys:
        - name: "<keyname>"
          hosts: "1.2.3.4,some-host.com"
  ```

- **Network Configuration**:
  ```yaml
  esxi_portgroups:
    all-tagged: { tag: 4095 }
    adm-srv:    { tag:  210 }
    srv-netinf: { tag:  131 }
    pvt-netinf: { tag:  199 }
    adm-stor:   { tag:   21, vswitch: vSwitch1 }
  ```

- **Datastore Configuration**:
  ```yaml
  esx_local_datastores:
    "vmhba0:C0:T0:L1": "nest-test-sys"
    "vmhba0:C0:T0:L2": "nest-test-apps"
  ```

- **VIB Installation/Update**:
  ```yaml
  vib_list:
    - name: esx-ui
      url: "http://www-distr.m1.maxidom.ru/suse_distr/iso/esxui-signed-6360286.vib"
  ```

- **Autostart Configuration**:
  ```yaml
  vms_to_autostart:
    eagle-m0:
      order: 1
    hawk-m0:
      order: 2
    falcon-u1:
  ```

## Host-Specific Setup

- Add the host to the appropriate group in `inventory.esxi`.
- Set custom certificates for the host:
  - Place the certificate in `files/<host>.rui.crt`.
  - Place the key in `files/<host>.key.vault` and encrypt it using Ansible Vault.
- Override any group variables in `host_vars/hostname.yaml`.

## Initial Setup and Convergence Runs

### Initial Configuration

For initial configuration, use only the "root" user:

```bash
ansible-playbook all.yaml -l new-host -u root -k --tags hostconf --diff
```

### Subsequent Configurations

After local users are configured and SSH key authentication is set up, use the `remote_user` specified in `ansible.cfg`:

```bash
ansible-playbook all.yaml -l host-or-group --tags hostconf --diff
```

## Notes

- Currently supports only one vSwitch (`vSwitch0`).
- Password policy checks (introduced in 6.5) are disabled to allow for truly random passwords.

## Assumptions about Environment

- Ansible version 2.10+.
- Local modules `netaddr` and `dnspython`.
- For VM customization like setting IPs, [ovfconf](https://github.com/veksh/ovfconf) must be configured on the clone source VM to utilize OVF parameters.

## Backlinks

- [Ansible Roles Documentation](../ansible_roles.md)
```

This improved version maintains all original information while adhering to clean and professional Markdown standards suitable for GitHub rendering.