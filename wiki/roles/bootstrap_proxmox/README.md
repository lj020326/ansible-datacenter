```markdown
---
title: bootstrap_proxmox Role Documentation
original_path: roles/bootstrap_proxmox/README.md
category: Ansible Roles
tags: [proxmox, ansible, cluster, ceph, ipmi, https]
---

# bootstrap_proxmox

Installs and configures a Proxmox 5.x/6.x cluster with the following features:

- Ensures all hosts can connect to one another as root.
- Ability to create/manage groups, users, access control lists, and storage.
- Ability to create or add nodes to a PVE cluster.
- Ability to set up Ceph on the nodes.
- IPMI watchdog support.
- Bring Your Own HTTPS certificate support.
- Ability to use either `pve-no-subscription` or `pve-enterprise` repositories.

## Quickstart

The primary goal for this role is to configure and manage a [Proxmox VE cluster][pve-cluster] (see example playbook). However, this role can also be used to quickly install single-node Proxmox servers.

### Prerequisites

- Ensure you have [Ansible installed][install-ansible].
- Use an external machine for the installation process due to the reboot required during setup.

### Example Playbook

Create a file named `install_proxmox.yml` with the following content:

```yaml
- hosts: all
  become: True
  roles:
    - role: geerlingguy.ntp
      ntp_manage_config: true
      ntp_servers:
        - clock.sjc.he.net
        - clock.fmt.he.net
        - clock.nyc.he.net
    - role: bootstrap_proxmox
      pve_group: all
      pve_reboot_on_kernel_update: true
```

### Install Roles

Install the required roles using `ansible-galaxy`:

```bash
ansible-galaxy install geerlingguy.ntp bootstrap_proxmox
```

### Run Playbook

Execute the playbook with the following command, replacing `$SSH_HOST_FQDN` and `$SSH_USER` as needed:

```bash
ansible-playbook install_proxmox.yml -i $SSH_HOST_FQDN, -u $SSH_USER
```

- Use `-K` if your `SSH_USER` has a sudo password.
- Use `-k` for password authentication (ensure `sshpass` is installed).

Once complete, access your Proxmox VE instance at `https://$SSH_HOST_FQDN:8006`.

## Deploying a Fully-Featured PVE 5.x Cluster

### Directory Structure

Create a new playbook directory. Here's an example structure:

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

### SSL Certificates

Place your private keys and SSL certificates in the `files/pve01/` directory. Use Ansible Vault to encrypt these files:

```bash
ansible-vault encrypt files/pve01/*.key
```

### Inventory File

Define your cluster hosts in the `inventory` file:

```
[pve01]
lab-node01.local
lab-node02.local
lab-node03.local
```

### Role Requirements

Specify role requirements in `roles/requirements.yml`:

```yaml
---
- src: geerlingguy.ntp
- src: bootstrap_proxmox
```

### Group Variables

#### NTP Configuration (`group_vars/all`)

Set NTP-related variables:

```yaml
---
ntp_manage_config: true
ntp_servers:
  - lab-ntp01.local iburst
  - lab-ntp02.local iburst
```

#### Cluster Configuration (`group_vars/pve01`)

Define cluster-specific variables:

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

### Notes

- `pve_group` sets the cluster name and ensures all hosts within this group can connect to each other.
- `pve_fetch_directory` is used for downloading host public keys and root user's public key.

## Support/Contributing

For support or contributions, join our Discord server: [https://discord.gg/cjqr6Fg](https://discord.gg/cjqr6Fg)

## Backlinks

- [Proxmox VE Cluster Setup Guide][pve-cluster]
- [Ansible Installation Guide][install-ansible]

[pve-cluster]: https://pve.proxmox.com/wiki/Cluster_Manager
[install-ansible]: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
```

This improved Markdown document adheres to clean, professional standards suitable for GitHub rendering while preserving all original information and meaning.