
# Guest Operating System Setup and Validation on vSphere using Ansible

## Getting Started

### Prerequisites

Make sure the following pip libraries are installed:
  - pyVmomi
  - vsphere-automation-sdk

## Role details

The role uses the list of hosts defined in "deploy_vm__vmware_vm_list" to iterate over and dereference (via hostvars) the dictionary variable "deploy_vm__vmware_vm_config" to define the vm configuration. 

### Set up the vm list in inventory

```yaml file=inventory/group_vars/vmware_control_host.yml
deploy_vm__vmware_vm_list: "{{ groups['vmware_vm'] | d([]) | difference(deploy_vm__vmware_appliance_list) }}"
```

### Set up the vm configuration in the inventory

Configuring the common host settings for all virtual machines:
```yaml file=inventory/hosts.yml
---
all:
  children:
    vmware_vm:
      vars:
        deploy_vm__vmware_vm_config:
          name: "{{ deploy_vm__vmware_vm_name }}"
          hostname: "{{ deploy_vm__vmware_vm_hostname }}"
          template_id: "{{ deploy_vm__vmware_vm_template_id }}"
          os_flavor: "{{ deploy_vm__vmware_vm_os_flavor }}"
          guest_id: "{{ deploy_vm__vmware_vm_guest_id }}"
          guest_domain: "{{ deploy_vm__vmware_guest_domain }}"
          datacenter: "{{ deploy_vm__vmware_datacenter}}"
          cluster: "{{ deploy_vm__vmware_vm_cluster }}"
          host: "{{ deploy_vm__vmware_vm_host }}"
          folder: "{{ deploy_vm__vmware_vm_folder }}"
          gateway_ipv4: "{{ deploy_vm__vmware_vm_gateway_ipv4 }}"
          dns_servers: "{{ deploy_vm__vmware_vm_dns_nameservers }}"
          nameservers: "{{ deploy_vm__vmware_vm_nameservers }}"
          datastore: "{{ deploy_vm__vmware_vm_datastore }}"
          datastore_folder: "{{ deploy_vm__vmware_vm_datastore_folder }}"
          services: "{{ deploy_vm__vmware_vm_services }}"
          hardware: "{{ deploy_vm__vmware_vm_hardware }}"
          controller_type: "{{ deploy_vm__vmware_vm_controller_type }}"
          disks: "{{ deploy_vm__vmware_vm_disks }}"
          networks: "{{ deploy_vm__vmware_vm_networks | d(omit) }}"
          deploy_groups: "{{ deploy_vm__vmware_vm_services | d([]) + vmware_new_vm_group_names | d([]) | flatten }}"
          vm_tags: "{{ vmware_new_vm_tags }}"
          dns_suffix: "{{ deploy_vm__vmware_guest_domain }}"
        #  dns_servers: "{{ deploy_vm__vmware_vm_dns_nameservers }}"
        #  netmask: "{{ deploy_vm__vmware_vm_gateway_ipv4_netmask | d(omit) }}"

```

Configure the specific vm group settings:
```yaml file=inventory/hosts.yml
---
all:
  children:
    vmware_vm:
      children:
        vmware_flavor_k8s:
          hosts:
            k8s-cp-[01:03]: {}
          vars:
            deploy_vm__vmware_vm_num_cpus: 4
            deploy_vm__vmware_vm_disk_size_gb: 100
            deploy_vm__vmware_vm_memory_mb: 16384
            deploy_vm__vmware_vm_disk_type: thin
            deploy_vm__vmware_vm_host: "esx03.{{ deploy_vm__vmware_guest_domain }}"
```

Then confirm that the respective hosts are configured correctly for one of the hosts.
E.g., for host "k8s-cp-01":
```shell
[ansible-datacenter](develop-lj)$ ansible --vault-password-file /Users/ljohnson/.vault_pass -e @/Users/ljohnson/repos/ansible/ansible-datacenter/vars/vault.yml -e /Users/ljohnson/repos/ansible/ansible-datacenter/inventory/PROD -m debug -a var="deploy_vm__vmware_vm_config" k8s-cp-01
k8s-cp-01 | SUCCESS => {
    "deploy_vm__vmware_vm_config": {
        "cluster": "Management",
        "controller_type": "paravirtual",
        "datacenter": "dettonville-dc-01",
        "datastore": "nfs_ds1",
        "datastore_folder": "vm",
        "deploy_groups": [
            "vmware_new_vm_linux",
            "deploy_vm_ip_dhcp"
        ],
        "disks": [
            {
                "datastore": "nfs_ds1",
                "size_gb": 100,
                "type": "thin"
            }
        ],
        "dns_servers": [
            "10.0.0.1"
        ],
        "dns_suffix": "dettonville.int",
        "folder": "/dettonville-dc-01/vm/vm",
        "gateway_ipv4": "10.0.0.1",
        "guest_domain": "dettonville.int",
        "guest_id": "ubuntu64Guest",
        "hardware": {
            "memory_mb": 16384,
            "num_cpus": 4,
            "scsi": "paravirtual"
        },
        "host": "esx00.dettonville.int",
        "hostname": "k8s-cp-01.dettonville.int",
        "name": "k8s-cp-01",
        "nameservers": {
            "addresses": [
                "10.0.0.1"
            ],
            "search": [
                "johnson.int",
                "dettonville.int",
                "dettonville.cloud"
            ]
        },
        "networks": [
            {
                "connected": true,
                "device_type": "vmxnet3",
                "name": "VM Network",
                "start_connected": true,
                "type": "dhcp"
            }
        ],
        "os_flavor": "linux",
        "services": [],
        "template_id": "ubuntu24",
        "vm_tags": [
            "vm_pre_bootstrap",
            "vm_new",
            "vm_new_linux"
        ]
    }
}
[ansible-datacenter](develop-lj)$
```


## Reference

* [ansible-vsphere-gos-validation](https://github.com/vmware/ansible-vsphere-gos-validation)
