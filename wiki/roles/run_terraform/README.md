---
title: Terraform VMware VM
original_path: roles/run_terraform/README.md
category: Infrastructure as Code
tags:
  - Ansible
  - Terraform
  - VMware
  - vSphere
  - Virtual Machines
---

# Terraform VMware VM

This repository demonstrates how to create multiple virtual machines in VMware using Ansible and Terraform. While it's possible to achieve this using only Ansible, this example illustrates the basic concept of interacting with Terraform through Ansible. The setup is designed to be expanded by adding post-VM creation functionality with Ansible to install applications and configure settings. For a more detailed explanation, read the [comprehensive guide](https://netsyncr.io/creating-virtual-machines-in-vsphere-with-terraform/).

## Requirements

- Ansible
- Terraform
- A VMware environment with a running vCenter instance
- A Datacenter and a cluster created in VMware
- Using Virtual Distributed Switches
- A Virtual Machine template with VMware Tools and Perl installed for post-installation configuration (CentOS 7 is recommended)

## Configuration

1. **Clone the Repository**

    ```bash
    git clone https://github.com/dkraklan/terraform_vmware_vm.git
    ```

2. **Update Inventory Variables**

    Edit the `inventory.yml` file to match your VMware environment. In a production setting, use more restrictive permissions than an administrator account.

    ```yaml
    ---
    all:
      children:
        vms:
          hosts:
            host1.lab.local:
            host2.lab.local:
          vars:
            vcenter_address: vcenter.lab.local
            vcenter_user: "automation@vcenter.lab.local"
            vcenter_password: "Password"
            vcenter_allow_unverified_ssl: true
            vcenter_datacenter: "Datacenter"
            vsphere_deploy_dc_vcenter_cluster: "Cluster"
    ```

3. **Configure Individual VM Settings**

    Update the `group_vars/vm_config.yml` file to define the settings for each VM. You can add multiple VMs by repeating the configuration block.

    ```yaml
    vm1:
      hostname: vm1
      domain: "lab.local"
      ansible.builtin.template: "centos7-template"
      hardware:
        vcpu: 2
        ram: 2048
        disk_size: 40
        datastore: "datastore1"
      network:
        ip_address: "192.168.0.2"
        ip_netmask: "24"
        ip_gateway: "192.168.0.1"
        vdsport: "vds1"
    ```

## Running the Playbooks

To create your VMs:

```bash
ansible-playbook -i inventory.yml 01_apply.yml
```

To destroy your VMs:

```bash
ansible-playbook -i inventory.yml 02_destroy.yml
```

## Troubleshooting

- Ensure that your vCenter credentials have the necessary permissions to create and manage VMs
- Verify that the template specified in `group_vars/vm_config.yml` exists in your vCenter environment
- Check network connectivity between your Ansible control node and the vCenter server

## Example Files

### inventory.yml
```yaml
---
all:
  children:
    vms:
      hosts:
        host1.lab.local:
        host2.lab.local:
      vars:
        vcenter_address: vcenter.lab.local
        vcenter_user: "automation@vcenter.lab.local"
        vcenter_password: "Password"
        vcenter_allow_unverified_ssl: true
        vcenter_datacenter: "Datacenter"
        vsphere_deploy_dc_vcenter_cluster: "Cluster"
```

### group_vars/vm_config.yml
```yaml
vm1:
  hostname: vm1
  domain: "lab.local"
  ansible.builtin.template: "centos7-template"
  hardware:
    vcpu: 2
    ram: 2048
    disk_size: 40
    datastore: "datastore1"
  network:
    ip_address: "192.168.0.2"
    ip_netmask: "24"
    ip_gateway: "192.168.0.1"
    vdsport: "vds1"