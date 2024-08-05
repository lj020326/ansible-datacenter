
# bootstrap_vmware_esxi_hostconf

Role to manage standalone ESXi hosts with direct SSH connection and esxcli.

## Details

This role takes care of many aspects of standalone ESXi server configuration like

- ESXi license key (if set)
- host name, DNS servers
- NTP servers, enable NTP client, set time
- users
    - create missed, remove extra ones
    - assign random passwords to new users (and store in `creds/`)
    - make SSH keys persist across reboots
    - grant DCUI rights
- portgroups
    - create missed, remove extra
    - assign specified tags
- block BPDUs from guests
- create vMotion interface (off by default, see `esx_create_vmotion_iface` in role defaults)
- datastores
    - partition specified devices if required
    - create missed datastores
    - rename empty ones with wrong names
- autostart for specified VMs (optionally disabling it for all others)
- logging to syslog server; lower `vpxa` and other noisy components logging level from
  default `verbose` to `info`
- certificates for Host UI and SSL communication (if present)
- install or update specified VIBs

Only requirement is correctly configured network (especially uplinks) and reachability
over ssh with root password. ESXi must be reasonably recent (6.0+, although some
newer versions of 5.5 have working python 2.7 too).

## General configuration

- `ansible.cfg`: specify remote user, inventory path etc; specify vault pass method
  if using one for certificate private key encryption.
- `group_vars/all.yaml`: specify global parameters like NTP and syslog servers there
- `group_vars/<site>.yaml`: set specific params for each `<site>` in inventory
- `host_vars/<host>.yaml`: override global and group values with e.g. host-specific
  users list or datastore config
- put public keys for users into `roles/hostconf-esxi/files/id_rsa.<user>@<keyname>.pub`
  for referencing them later in user list `host_vars` or `group_vars`

## Typical variables for `(group|host)_vars`

- serial number to assign, usually set in global `group_vars/all.yaml`; does not get
  changed if not set

        esx_serial: "XXXXX-XXXXX-XXXX-XXXXX-XXXXX"

- general network environment, usually set in `group_vars/<site>.yaml`

        esx_domain: "m0.maxidom.ru"

        esx_dns_servers:
          - 10.0.128.1
          - 10.0.128.2

        esx_ntp_servers:
          - 10.1.131.1
          - 10.1.131.2

        # defaults: "log." + esx_domain
        # esx_syslog_host: log.m0.example.int

- user configuration: those users are created (if not present) and assigned random
  passwords (printed out and stored in `creds/<user>.<host>.pass.out`), have ssh keys assigned to them (persistently) and restricted to specified hosts (plus global list
  in `esx_permit_ssh_from`), are granted administrative rights and access to the console

        esxi_local_users:
        "<user>":
          desc: "<user description>""
          pubkeys:
            - name:  "<keyname>"
              hosts: "1.2.3.4,some-host.com"

    users that are not in this list (except root) are removed from host, so be careful.
- network configuration: portgroups list in `esxi_portgroups` are exhaustive, i.e. those
  and only those portgroups (with exactly matched tags) should be present oh host after
  playbook run (missed are created, wrong names are fixed, extra are removed if not used)

        esxi_portgroups:
          all-tagged: { tag: 4095 }
          adm-srv:    { tag:  210 }
          srv-netinf: { tag:  131 }
          pvt-netinf: { tag:  199 }
          # could also specify vSwitch (default is vSwitch0)
          adm-stor:   { tag:   21, vswitch: vSwitch1 }

- datastore configuration: datastores would be created on those devices if missed and
  `esx_create_datastores` is set; existent datastores would be renamed to match specified
  name if `esx_rename_datastores` is set and they are empty

        esx_local_datastores:
          "vmhba0:C0:T0:L1": "nest-test-sys"
          "vmhba0:C0:T0:L2": "nest-test-apps"

- VIBs to install or update (like latest esx-ui host client fling)

        vib_list:
          - name: esx-ui
            url: "http://www-distr.m1.maxidom.ru/suse_distr/iso/esxui-signed-6360286.vib"

- autostart configuration: listed VMs are added to esxi auto-start list, in specified order
  if order is present, else just randomly; if `esx_autostart_only_listed` is set, only those VMs
  will be autostarted on host with extra VMs removed from autostart

        vms_to_autostart:
          eagle-m0:
            order: 1
          hawk-m0:
            order: 2
          falcon-u1:

## Host-specific configuration

- add host into corresponding group in `inventory.esxi`
- set custom certificate for host
    - put certificate into `files/<host>.rui.crt`,
    - put key into `files/<host>.key.vault` (and encrypt vault)
- override any group vars in `host_vars/hostname.yaml`

## Initial host setup and later convergence runs

For the initial config only the "root" user is available, so run playbook like this:

      ansible-playbook all.yaml -l new-host -u root -k --tags hostconf --diff

After local users are configured (and ssh key auth is in place), just use `remote_user`
from `ansible.cfg` and run it like

      ansible-playbook all.yaml -l host-or-group --tags hostconf --diff

## Notes

- only one vSwitch (`vSwitch0`) is currently supported
- password policy checks (introduced in 6.5) are turned off to allow for truly random
  passwords (those are sometimes miss one of the character classes).
  
## Assumptions about environment

- ansible 2.10+
- local modules `netaddr` and `dnspython`
- for VM customization like setting IPs etc, [ovfconf](https://github.com/veksh/ovfconf)
  must be configured on clone source VM (to take advantage of passing OVF params to VM)
