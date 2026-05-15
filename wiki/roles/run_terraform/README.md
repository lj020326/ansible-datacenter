```markdown
---
title: Terraform VMware VM Creation with Ansible
original_path: roles/run_terraform/README.md
category: Infrastructure Automation
tags: [ansible, terraform, vmware, vcenter, virtual-machines]
---

# Terraform VMware VM Creation with Ansible

This repository demonstrates how to create multiple VMs in a VMware environment using both Ansible and Terraform. While this can be achieved solely with Ansible, the purpose of this setup is to illustrate the basic concept of integrating Terraform with Ansible. The setup can be expanded by adding post-VM creation functionality with Ansible to install applications and configurations. For a more detailed explanation, refer to [this article](https://netsyncr.io/creating-virtual-machines-in-vsphere-with-terraform/).

## Requirements

- **Ansible**
- **Terraform**
- A VMware environment with a vCenter instance running
- A Datacenter and cluster created in VMware
- Use of Virtual Distributed Switches (VDS)
- A virtual machine template with VM Tools and Perl installed for post-installation configuration (e.g., CentOS 7)

## Configuration

### Step 1: Clone the Repository

```bash
git clone https://github.com/dkraklan/terraform_vmware_vm.git
```

### Step 2: Update Inventory Variables

Update the variables in `inventory.yml` to match your VMware environment. For security reasons, use a more restricted account in production.

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

### Step 3: Configure Individual VM Settings

Modify `group_vars/vm_config.yml` to define the settings for each virtual machine. You can add as many VMs as needed by repeating the configuration block.

```yaml
- FQDN:
    hostname: {hostname}
    domain: "{domain_name}"
    ansible.builtin.template: "{template_name}"
    hardware:
      vcpu: 2
      ram: 2048
      disk_size: 40
      datastore: "{datastore_name}"
    network:
      ip_address: "192.168.0.2"
      ip_netmask: "24"
      ip_gateway: "192.168.0.1"
      vdsport: "{vds_name}"
```

## Running the Playbooks

### Create VMs

To create the virtual machines, run:

```bash
ansible-playbook -i inventory.yml 01_apply.yml
```

### Destroy VMs

To destroy the virtual machines, execute:

```bash
ansible-playbook -i inventory.yml 02_destroy.yml
```

## Backlinks

- [Ansible and Terraform Integration](https://netsyncr.io/creating-virtual-machines-in-vsphere-with-terraform/)
```

This improved version maintains all original information while adhering to clean, professional Markdown standards suitable for GitHub rendering.