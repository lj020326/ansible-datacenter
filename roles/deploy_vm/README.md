
# "Deploy VM Role Documentation"

## Summary

The `deploy_vm` role is designed to automate the deployment of virtual machines (VMs) and appliances on VMware vSphere and Proxmox environments. This role handles the creation, configuration, and management of VMs, including setting boot order, power state, network configurations, and deploying OVF templates for appliances.

## Variables

| Variable Name                           | Default Value                                                                                          | Description                                                                                                                                                                                                 |
|-----------------------------------------|--------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `deploy_vm__python_pip_depends`         | `['pyVmomi']`                                                                                          | List of Python packages to be installed via pip.                                                                                                                                                            |
| `deploy_vm__vcenter_hostname`           | `vcenter.example.int`                                                                                  | The hostname or IP address of the vCenter server.                                                                                                                                                           |
| `deploy_vm__vcenter_username`           | `administrator`                                                                                        | Username for authenticating with the vCenter server.                                                                                                                                                        |
| `deploy_vm__vcenter_password`           | `password`                                                                                             | Password for authenticating with the vCenter server. **(Sensitive)**                                                                                                                                        |
| `deploy_vm__vcenter_validate_certs`     | `false`                                                                                                | Whether to validate SSL certificates when connecting to the vCenter server.                                                                                                                                   |
| `deploy_vm__tags_init_all`              | List of tags (e.g., `vm_pre_bootstrap`, `vm_new`)                                                      | Initial list of tags to be created in vSphere for categorizing VMs.                                                                                                                                         |
| `deploy_vm__vmware_appliance_list`      | `[]`                                                                                                   | List of VMware appliances to deploy using OVF templates.                                                                                                                                                  |
| `deploy_vm__vmware_vm_list`             | `[]`                                                                                                   | List of VMs to be deployed on vSphere.                                                                                                                                                                      |
| `deploy_vm__govc_version`               | `0.23.0`                                                                                               | Version of the govc tool to be used for VMware operations.                                                                                                                                                |
| `deploy_vm__govc_path`                  | `/usr/local/bin`                                                                                       | Path where the govc binary will be installed.                                                                                                                                                               |
| `deploy_vm__govc_file`                  | `"{{ deploy_vm__govc_path }}/govc"`                                                                     | Full path to the govc binary.                                                                                                                                                                               |
| `deploy_vm__govc_host`                  | `"{{ deploy_vm__vcenter_hostname }}"`                                                                    | Hostname or IP address of the vCenter server for govc operations.                                                                                                                                           |
| `deploy_vm__govc_username`              | `"{{ deploy_vm__vcenter_username }}"`                                                                    | Username for authenticating with the vCenter server using govc.                                                                                                                                             |
| `deploy_vm__govc_password`              | `"{{ deploy_vm__vcenter_password }}"`                                                                    | Password for authenticating with the vCenter server using govc. **(Sensitive)**                                                                                                                             |
| `deploy_vm__govc_insecure`              | `1`                                                                                                    | Whether to allow insecure connections when using govc.                                                                                                                                                    |
| `deploy_vm__govc_environment`           | Dictionary containing environment variables for govc operations (e.g., `GOVC_HOST`, `GOVC_USERNAME`)     | Environment variables required for govc operations.                                                                                                                                                       |
| `deploy_vm__create_async_delay`         | `30`                                                                                                   | Delay in seconds between asynchronous operations during VM creation.                                                                                                                                        |
| `deploy_vm__create_async_retries`       | `1000`                                                                                                 | Number of retries for asynchronous operations during VM creation.                                                                                                                                           |
| `deploy_vm__template_info`              | Dictionary containing template information (e.g., `ubuntu24`, `centos9`)                                | Information about the VM templates available for deployment, including their names and network services.                                                                                                    |

## Usage

### Deploying VMware VMs

To deploy VMs on a VMware vSphere environment, define the list of VMs in `deploy_vm__vmware_vm_list` with appropriate configurations such as name, template, datacenter, etc.

```yaml
deploy_vm__vmware_vm_list:
  - name: vm-ubuntu24-01
    template: ubuntu24-medium
    datacenter: Datacenter1
    cluster: Cluster1
    datastore: datastore1
    network: VM Network
    ip_address: 192.168.1.100
    netmask: 255.255.255.0
    gateway: 192.168.1.1
    dns_servers:
      - 8.8.8.8
      - 8.8.4.4
```

### Deploying VMware Appliances

To deploy appliances using OVF templates, define the list of appliances in `deploy_vm__vmware_appliance_list` with appropriate configurations such as name, datacenter, etc.

```yaml
deploy_vm__vmware_appliance_list:
  - name: appliance-01
    ova_path: /path/to/appliance.ova
    datacenter: Datacenter1
    cluster: Cluster1
    datastore: datastore1
    network: VM Network
    ip_address: 192.168.1.101
    netmask: 255.255.255.0
    gateway: 192.168.1.1
    dns_servers:
      - 8.8.8.8
      - 8.8.4.4
```

### Deploying Proxmox VMs

To deploy containers on a Proxmox environment, define the list of containers in `deploy_vm__containers` with appropriate configurations such as node, cores, memory, etc.

```yaml
deploy_vm__containers:
  - vmid: 100
    hostname: container-01
    deploy_vm__vm_proxmox_node: pve-node1
    cores: 2
    cpus: 2
    memory: 4096
    disk: 30G
    storage: lvm-thinpool
```

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

## Dependencies

- `community.vmware` collection for VMware operations.
- `community.general.proxmox` module for Proxmox operations.
- Python packages listed in `deploy_vm__python_pip_depends`.

## Best Practices

1. **Security**: Ensure that sensitive variables such as passwords are stored securely using Ansible Vault or environment variables.
2. **Validation**: Validate SSL certificates when connecting to vCenter servers by setting `deploy_vm__vcenter_validate_certs` to `true`.
3. **Configuration Management**: Use the provided templates and configurations to ensure consistent deployment practices across environments.

## Molecule Tests

This role does not include Molecule tests at this time. Consider adding Molecule scenarios for testing different deployment configurations.

## Backlinks

- [defaults/main.yml](./defaults/main.yml)
- [tasks/config-vmware-vm-linux.yml](./tasks/config-vmware-vm-linux.yml)
- [tasks/deploy-proxmox-vm.yml](./tasks/deploy-proxmox-vm.yml)
- [tasks/deploy-vmware-appliance.yml](./tasks/deploy-vmware-appliance.yml)
- [tasks/deploy-vmware-vm.yml](./tasks/deploy-vmware-vm.yml)
- [tasks/main.yml](./tasks/main.yml)
- [handlers/main.yml](./handlers/main.yml)

## Reference

* [ansible-vsphere-gos-validation](https://github.com/vmware/ansible-vsphere-gos-validation)
