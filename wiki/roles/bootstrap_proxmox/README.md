---
title: bootstrap_proxmox
original_path: roles/bootstrap_proxmox/README.md
category: Ansible Roles
tags: [Proxmox, Cluster, Automation, DevOps]
---

# bootstrap_proxmox

Installs and configures a Proxmox 5.x/6.x cluster with the following features:

- Ensures all hosts can connect to one another as root
- Ability to create/manage groups, users, access control lists, and storage
- Ability to create or add nodes to a PVE cluster
- Ability to setup Ceph on the nodes
- IPMI watchdog support
- BYO HTTPS certificate support
- Ability to use either `pve-no-subscription` or `pve-enterprise` repositories

## Quickstart

The primary goal for this role is to configure and manage a [Proxmox VE cluster][pve-cluster] (see example playbook), however this role can be used to quickly install single node Proxmox servers.

I'm assuming you already have [Ansible installed][install-ansible]. You will need to use an external machine to the one you're installing Proxmox on (primarily because of the reboot in the middle of the installation, though I may handle this somewhat differently for this use case later).

Copy the following playbook to a file like `install_proxmox.yml`:

```yaml
- hosts: all
  become: True
  roles:
    - {
        role: geerlingguy.ntp,
        ntp_manage_config: true,
        ntp_servers: [
          clock.sjc.he.net,
          clock.fmt.he.net,
          clock.nyc.he.net
        ]
      }
    - {
        role: bootstrap_proxmox,
        pve_group: all,
        pve_reboot_on_kernel_update: true
      }
```

Install this role and a role for configuring NTP:

```bash
ansible-galaxy install bootstrap_proxmox geerlingguy.ntp
```

Now you can perform the installation:

```bash
ansible-playbook install_proxmox.yml -i $SSH_HOST_FQDN, -u $SSH_USER
```

If your `SSH_USER` has a sudo password, pass the `-K` flag to the above command. If you also authenticate to the host via password instead of pubkey auth, pass the `-k` flag (make sure you have `sshpass` installed as well). You can set those variables prior to running the command or just replace them. Do note the comma is important, as a list is expected (otherwise it'll attempt to look up a file containing a list of hosts).

Once complete, you should be able to access your Proxmox VE instance at `https://$SSH_HOST_FQDN:8006`.

## Support/Contributing

For support or if you'd like to contribute to this role but want guidance, feel free to join this Discord server: [Discord Server](https://discord.gg/cjqr6Fg)

## Deploying a Fully-Featured PVE 5.x Cluster

Create a new playbook directory. We call ours `lab-cluster`. Our playbook will eventually look like this, but yours does not have to follow all of the steps:

```
lab-cluster/
├── files
│   └── pve01
│       ├── lab-node01.local.key
│       ├── lab-node01.local.pem
│       ├── lab-node02.local.key
│       ├── lab-node02.local.pem
│       ├── lab-node03.local.key
│       └── lab-node03.local.pem
├── group_vars
│   ├── all
│   └── pve01
├── inventory
├── roles
│   └── requirements.yml
├── site.yml
└── templates
    └── interfaces-pve01.j2

6 directories, 12 files
```

First thing you may note is that we have a bunch of `.key` and `.pem` files. These are private keys and SSL certificates that this role will use to configure the web interface for Proxmox across all the nodes. These aren't necessary, however, if you want to keep using the signed certificates by the CA that Proxmox sets up internally. You may typically use Ansible Vault to encrypt the private keys, e.g.:

```bash
ansible-vault encrypt files/pve01/*.key
```

This would then require you to pass the Vault password when running the playbook.

Let's first specify our cluster hosts. Our `inventory` file may look like this:

```
[pve01]
lab-node01.local
lab-node02.local
lab-node03.local
```

You could have multiple clusters, so it's a good idea to have one group for each cluster. Now, let's specify our role requirements in `roles/requirements.yml`:

```yaml
---
- src: geerlingguy.ntp
- src: bootstrap_proxmox
```

We need an NTP role to configure NTP, so we're using Jeff Geerling's role to do so. You wouldn't need it if you already have NTP configured or have a different method for configuring NTP.

Now, let's specify some group variables. First off, let's create `group_vars/all` for setting NTP-related variables:

```yaml
---
ntp_manage_config: true
ntp_servers:
  - lab-ntp01.local iburst
  - lab-ntp02.local iburst
```

Of course, replace those NTP servers with ones you prefer.

Now for the flesh of your playbook, `pve01`'s group variables. Create a file `group_vars/pve01`, add the following, and modify accordingly for your environment.

```yaml
---
pve_group: pve01
pve_fetch_directory: "fetch/{{ pve_group }}/"
pve_watchdog: ipmi
pve_ssl_private_key: "{{ lookup('file', pve_group + '/' + inventory_hostname + '.key') }}"
pve_ssl_certificate: "{{ lookup('file', pve_group + '/' + inventory_hostname + '.pem') }}"
pve_cluster_enabled: yes
pve_groups:
  - name: ops
    comment: Operations Team
pve_users:
  - name: admin1@pam
    email: admin1@lab.local
    firstname: Admin
    lastname: User 1
    groups: [ "ops" ]
  - name: admin2@pam
    email: admin2@lab.local
    firstname: Admin
    lastname: User 2
    groups: [ "ops" ]
pve_acls:
  - path: /
    roles: [ "Administrator" ]
    groups: [ "ops" ]
pve_storages:
  - name: localdir
    type: dir
    content: [ "images", "iso", "backup" ]
    path: /plop
    maxfiles: 4
pve_ssh_port: 22

interfaces_template: "interfaces-{{ pve_group }}.j2"
```

`pve_group` is set to the group name of our cluster, `pve01` - it will be used for the purposes of ensuring all hosts within that group can connect to each other and are clustered together. Note that the PVE cluster name will be set to this group name as well, unless otherwise specified by `pve_clustername`. Leaving this undefined will default to `proxmox`.

`pve_fetch_directory` will be used to download the host public key and root user's public key from all hosts in the cluster.

## Backlinks

[Add backlinks to related pages if applicable]