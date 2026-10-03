---
harvested_date: '2026-08-07T18:07:09.440314+00:00'
original_path: roles/bootstrap_vmware_esxi_hostconf/README.md
source_type: legacy_markdown
title: "Bootstrap VMware ESXi Host Configuration Role"
category: "Ansible Role"
tags: ["VMware", "ESXi", "Ansible", "Configuration Management"]
---

# Bootstrap VMware ESXi Host Configuration

Role to manage standalone ESXi hosts with direct SSH connection and esxcli.

## Table of Contents
- [Details](#details)
- [General Configuration](#general-configuration)
- [Typical Variables](#typical-variables)
- [Host-specific Configuration](#host-specific-configuration)
- [Initial Host Setup](#initial-host-setup)
- [Notes](#notes)
- [Assumptions about Environment](#assumptions-about-environment)
- [Dependencies](#dependencies)

## Details

This role takes care of many aspects of standalone ESXi server configuration, including:

### License and Host Configuration
- ESXi license key (if set)
- Host name, DNS servers

### Time Configuration
- NTP servers
- Enable NTP client
- Set time

### User Management
- Create missing users, remove extra ones
- Assign random passwords to new users (and store in `creds/`)
- Make SSH keys persist across reboots
- Grant DCUI rights

### Network Configuration
- Portgroups
  - Create missing, remove extra
  - Assign specified tags
- Block BPDUs from guests
- Create vMotion interface (off by default, see `esx_create_vmotion_iface` in role defaults)

### Storage Configuration
- Datastores
  - Partition specified devices if required
  - Create missing datastores
  - Rename empty ones with wrong names

### VM Configuration
- Autostart for specified VMs (optionally disabling it for all others)

### Logging and Certificates
- Logging to syslog server
- Lower `vpxa` and other noisy components logging level from default `verbose` to `info`
- Certificates for Host UI and SSL communication (if present)

### VIB Management
- Install or update specified VIBs

## General Configuration

- `ansible.cfg`: specify remote user, inventory path, etc.; specify vault pass method if using one for certificate private key encryption.
- `group_vars/all.yaml`: specify global parameters like NTP and syslog servers there.
- `group_vars/<site>.yaml`: set specific params for each `<site>` in inventory.
- `host_vars/<host>.yaml`: override global and group values with e.g., host-specific users list or datastore config.
- Put public keys for users into `roles/hostconf-esxi/files/id_rsa.<user>@<keyname>.pub` for referencing them later in user list `host_vars` or `group_vars`.

## Typical Variables

### Global Variables
- Serial number to assign, usually set in global `group_vars/all.yaml`; does not get changed if not set.

  ```yaml
  esx_serial: "XXXXX-XXXXX-XXXX-XXXXX-XXXXX"
  ```

### Site-specific Variables
- General network environment, usually set in `group_vars/<site>.yaml`.

  ```yaml
  esx_domain: "m0.maxidom.ru"

  esx_dns_servers:
    - 10.0.128.1
    - 10.0.128.2

  esx_ntp_servers:
    - 10.1.131.1
    - 10.1.131.2

  # defaults: "log." + esx_domain
  # esx_syslog_host: log.m0.example.int
  ```

### User Configuration
- User configuration: those users are created (if not present) and assigned random passwords (printed out and stored in `creds/<user>.<host>.pass.out`), have SSH keys assigned to them (persistently) and restricted to specified hosts (plus global list in `esx_permit_ssh_from`), are granted administrative rights and access to the console.

  ```yaml
  esxi_local_users:
    "<user>":
      desc: "<user description>"
      pubkeys:
        - name: "<keyname>"
          hosts: "1.2.3.4,some-host.com"
  ```

  Users that are not in this list (except root) are removed from the host, so be careful.

### Network Configuration
- Network configuration: portgroups list in `esxi_portgroups` are exhaustive, i.e., those and only those portgroups (with exactly matched tags) should be present on the host after the playbook run (missing are created, wrong names are fixed, extra are removed if not used).

  ```yaml
  esxi_portgroups:
    all-tagged: { tag: 4095 }
    adm-srv:    { tag:  210 }
    srv-netinf: { tag:  131 }
    pvt-netinf: { tag:  199 }
    # could also specify vSwitch (default is vSwitch0)
    adm-stor:   { tag:   21, vswitch: vSwitch1 }
  ```

### Datastore Configuration
- Datastore configuration: datastores would be created on those devices if missed and `esx_create_datastores` is set; existing datastores would be renamed to match the specified name if `esx_rename_datastores` is set and they are empty.

  ```yaml
  esx_local_datastores:
    "vmhba0:C0:T0:L1": "nest-test-sys"
    "vmhba0:C0:T0:L2": "nest-test-apps"
  ```

### VIB Configuration
- VIBs to install or update (like the latest esx-ui host client fling).

  ```yaml
  vib_list:
    - name: esx-ui
      url: "http://www-distr.m1.maxidom.ru/suse_distr/iso/esxui-signed-6360286.vib"
  ```

### Autostart Configuration
- Autostart configuration: listed VMs are added to the ESXi auto-start list, in specified order if order is present, else just randomly; if `esx_autostart_only_listed` is set, only those VMs will be autostarted on the host with extra VMs removed from autostart.

  ```yaml
  vms_to_autostart:
    eagle-m0:
      order: 1
    hawk-m0:
      order: 2
    falcon-u1:
  ```

## Host-specific Configuration

- Add the host into the corresponding group in `inventory.esxi`.
- Set a custom certificate for the host.
  - Put the certificate into `files/<host>.rui.crt`.
  - Put the key into `files/<host>.key.vault` (and encrypt the vault).
- Override any group vars in `host_vars/hostname.yaml`.

## Initial Host Setup and Later Convergence Runs

For the initial config, only the "root" user is available, so run the playbook like this:

```sh
ansible-playbook all.yaml -l new-host -u root -k --tags hostconf --diff
```

After local users are configured (and SSH key auth is in place), just use `remote_user` from `ansible.cfg` and run it like:

```sh
ansible-playbook all.yaml -l host-or-group --tags hostconf --diff
```

## Notes

- Only one vSwitch (`vSwitch0`) is currently supported.
- Password policy checks (introduced in 6.5) are turned off to allow for truly random passwords (those are sometimes miss one of the character classes).

## Assumptions about Environment

- Ansible 2.10+
- Local modules `netaddr` and `dnspython`
- For VM customization like setting IPs, etc., [ovfconf](https://github.com/veksh/ovfconf) must be configured on the clone source VM (to take advantage of passing OVF params to VM).

## Dependencies

- Ansible 2.10+
- Python modules: `netaddr`, `dnspython`
- [ovfconf](https://github.com/veksh/ovfconf) for VM customization

## Backlinks

<!-- Add backlinks here if applicable -->