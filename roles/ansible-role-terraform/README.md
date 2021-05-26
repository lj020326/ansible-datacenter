# Terraform Vmware VM
 
This is a repo showing how you can create multiple VM's in vmware using ansible and terraform. While you could accomplish this with just ansible in a similar fashion this is to show the basic concept of interacting with terraform using ansible. It's meant to be expanded upon by adding post VM post creation functionallity with ansible to install your applications and configuration. Read a more thorough write up [Here](https://netsyncr.io/creating-virtual-machines-in-vsphere-with-terraform/)

## Requirements
* Ansible 
* Terraform 
* A VMware enviroment with a vCenter instance running
* A Datacenter and a cluster created in VMware
* Using Virtual Distributed Switches
* A Virtual Machine template with vm-tools and perl installed for post installation configuration ( I used Centos 7 )

## Configuration
1.) Clone the repo

    git clone https://github.com/dkraklan/terraform_vmware_vm.git
    
2.) Update the vars in the inventory.yml file to match your vmware enviroment. In my lab I used an administrator account, in production you will want to use more strict permissions as needed. 

```
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
            vcenter_cluster: "Cluster"

```

3.) Update individual VM settings `group_vars/vm_config.yml` you can add as many VM's as you like by repeating the below configuration.
````
  - {FQDN}:
    hostname: {hostname}
    domain: "{domain_name}"
    template: "{template_name}"
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
````

## Running the playbooks
To create your VM's 
    
    ansible-playbook -i inventory.yml 01_apply.yml

To destroy your VM's
    
    ansible-playbook -i inventory.yml 02_destroy.yml
