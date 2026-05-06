---
title: Bootstrap GOVC Role Documentation
role: bootstrap_govc
category: Ansible Roles
type: Infrastructure Automation
tags: govc, vmware, automation, cloud-init, ova-import
---

## Summary

The `bootstrap_govc` role is designed to automate the installation of the VMware vSphere CLI tool (`govc`) and manage virtual machine operations such as deploying OVA files and configuring cloud-init on a VMware ESXi or vCenter server. This role ensures that the correct version of `govc` is installed, imports specified OVA templates into the vCenter inventory, and optionally configures cloud-init for automated VM setup.

## Variables

| Variable Name                         | Default Value                                                                                          | Description                                                                                                                                                                                                 |
|---------------------------------------|--------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_govc__version`             | `0.20.0`                                                                                               | The version of `govc` to install.                                                                                                                                                                             |
| `bootstrap_govc__path`                | `/usr/bin`                                                                                             | The installation path for the `govc` binary.                                                                                                                                                                  |
| `bootstrap_govc__tmp`                 | `/tmp`                                                                                                 | Temporary directory used during the installation process.                                                                                                                                                       |
| `bootstrap_govc__file`                | `{{ bootstrap_govc__path }}/govc`                                                                      | The full path to the installed `govc` binary.                                                                                                                                                                 |
| `bootstrap_govc__download_url`        | `https://github.com/vmware/govmomi/releases/download/v{{ bootstrap_govc__version }}`                    | Base URL for downloading the `govc` binary.                                                                                                                                                                   |
| `bootstrap_govc__host`                | `esx-a.home.local`                                                                                     | The hostname or IP address of the vCenter server or ESXi host.                                                                                                                                                |
| `bootstrap_govc__username`            | `administrator@home.local`                                                                             | Username for authenticating with the vCenter server or ESXi host.                                                                                                                                             |
| `bootstrap_govc__password`            | `password`                                                                                             | Password for authenticating with the vCenter server or ESXi host. **Note:** It is recommended to use Ansible Vault for sensitive information.                                                                     |
| `bootstrap_govc__ova_imports`         | `[]`                                                                                                   | A list of OVA files and their deployment specifications to import into the vCenter inventory.                                                                                                                 |
| `bootstrap_govc__deploy_cloud_init`   | `false`                                                                                                | Boolean flag to enable or disable cloud-init configuration for VMs.                                                                                                                                           |
| `bootstrap_govc__insecure`            | `1`                                                                                                    | Flag to allow insecure connections (e.g., self-signed certificates).                                                                                                                                          |
| `bootstrap_govc__datacenter`          | `Datacenter`                                                                                           | The name of the datacenter in vCenter where VMs will be deployed.                                                                                                                                             |
| `bootstrap_govc__datastore`           | `Datastore`                                                                                            | The datastore to use for storing VM files and cloud-init ISOs.                                                                                                                                                  |
| `bootstrap_govc__network`             | `VM Network`                                                                                           | The network label to connect the VMs to.                                                                                                                                                                      |
| `bootstrap_govc__resource_pool`       | `Pool`                                                                                                 | The resource pool where VMs will be deployed.                                                                                                                                                                   |

## Usage

To use this role, include it in your Ansible playbook and provide the necessary variables as shown below:

```yaml
- hosts: vcenter_servers
  roles:
    - role: bootstrap_govc
      vars:
        bootstrap_govc__host: "vcenter.home.local"
        bootstrap_govc__username: "admin@vsphere.local"
        bootstrap_govc__password: "{{ vault_vsphere_password }}"
        bootstrap_govc__ova_imports:
          - name: "Ubuntu-20.04"
            ova: "/path/to/ubuntu-20.04.ova"
            spec: "/path/to/ubuntu-20.04.json"
        bootstrap_govc__deploy_cloud_init: true
```

## Dependencies

This role does not have any external dependencies other than the `ansible.builtin` module, which is part of Ansible core.

## Tags

The following tags are available for this role:

- `install`: Installs or updates the `govc` binary.
- `deploy_ova`: Imports OVA files into vCenter.
- `cloud_init_boot`: Configures and boots VMs with cloud-init.

To run specific tasks, use the `--tags` option in your Ansible playbook execution command:

```bash
ansible-playbook -i inventory.yml playbook.yml --tags install
```

## Best Practices

1. **Secure Credentials**: Always use Ansible Vault to manage sensitive information such as passwords.
2. **Version Control**: Ensure that the version of `govc` specified in your playbooks is compatible with your vCenter server and ESXi hosts.
3. **Resource Management**: Properly configure resource pools, datastores, and networks to optimize VM deployment.

## Molecule Tests

This role does not include any Molecule tests at this time. Consider adding Molecule scenarios for automated testing of the role's functionality.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_govc/defaults/main.yml)
- [tasks/cloud_init_boot.yml](../../roles/bootstrap_govc/tasks/cloud_init_boot.yml)
- [tasks/deploy_ova.yml](../../roles/bootstrap_govc/tasks/deploy_ova.yml)
- [tasks/install.yml](../../roles/bootstrap_govc/tasks/install.yml)
- [tasks/main.yml](../../roles/bootstrap_govc/tasks/main.yml)