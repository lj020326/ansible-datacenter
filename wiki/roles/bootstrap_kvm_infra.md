---
title: "bootstrap_kvm_infra Role Documentation"
role: bootstrap_kvm_infra
category: Infrastructure
type: Ansible Role
tags: kvm, libvirt, virtualization, cloud-init
---

## Summary

The `bootstrap_kvm_infra` role is designed to automate the setup and management of KVM-based virtual machines (VMs) using Ansible. It handles tasks such as creating and removing VMs, managing storage pools, configuring networks, setting up virtual BMCs for IPMI emulation, and ensuring that VMs are properly integrated into the host environment via SSH configuration and `/etc/hosts` entries.

## Variables

| Variable Name                              | Default Value                                                                                             | Description                                                                                                                                                                                                 |
|--------------------------------------------|-------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_kvm_infra__kvm_host`            | `kvm.example.int`                                                                                         | The hostname or IP address of the KVM host.                                                                                                                                                                 |
| `bootstrap_kvm_infra__is_kvm_host`         | `false`                                                                                                     | A boolean indicating whether the current host is the KVM host.                                                                                                                                            |
| `bootstrap_kvm_infra__state`               | `"running"`                                                                                                 | The desired state of the VM (`running`, `undefined`).                                                                                                                                                       |
| `bootstrap_kvm_infra__autostart`           | `"no"`                                                                                                      | Whether the VM should autostart on host boot.                                                                                                                                                               |
| `bootstrap_kvm_infra__user`                | `{{ lookup('env', 'USER' ) }}`                                                                             | The default user for SSH access to the VMs.                                                                                                                                                                 |
| `bootstrap_kvm_infra__password`            | `"password"`                                                                                                | The password for the default user (used in cloud-init).                                                                                                                                                    |
| `bootstrap_kvm_infra__ram`                 | `"1024"`                                                                                                    | The amount of RAM allocated to the VM in MB.                                                                                                                                                                |
| `bootstrap_kvm_infra__ram_max`             | `"{{ bootstrap_kvm_infra__ram }}"`                                                                          | The maximum amount of RAM that can be allocated to the VM.                                                                                                                                                |
| `bootstrap_kvm_infra__cpus`                | `"1"`                                                                                                       | The number of CPUs allocated to the VM.                                                                                                                                                                     |
| `bootstrap_kvm_infra__cpus_max`            | `"{{ bootstrap_kvm_infra__cpus }}"`                                                                         | The maximum number of CPUs that can be allocated to the VM.                                                                                                                                               |
| `bootstrap_kvm_infra__cpu_model`           | `"host-passthrough"`                                                                                        | The CPU model used by the VM.                                                                                                                                                                               |
| `bootstrap_kvm_infra__machine_type`        | `"q35"`                                                                                                     | The machine type for the VM.                                                                                                                                                                                |
| `bootstrap_kvm_infra__ssh_keys`            | `[]`                                                                                                        | A list of SSH public keys to be added to the VMs via cloud-init.                                                                                                                                            |
| `bootstrap_kvm_infra__ssh_key_size`        | `"2048"`                                                                                                    | The size of the generated SSH key (in bits).                                                                                                                                                                |
| `bootstrap_kvm_infra__ssh_key_type`        | `"rsa"`                                                                                                     | The type of the generated SSH key.                                                                                                                                                                          |
| `bootstrap_kvm_infra__ssh_pwauth`          | `true`                                                                                                      | Whether password authentication is allowed for SSH access to the VMs.                                                                                                                                       |
| `bootstrap_kvm_infra__networks`            | `[ { name: "default", type: "nat", model: "virtio" } ]`                                                      | A list of networks to be configured for the VMs.                                                                                                                                                            |
| `bootstrap_kvm_infra__disk_size`           | `"20"`                                                                                                      | The size of the boot disk in GB.                                                                                                                                                                            |
| `bootstrap_kvm_infra__disk_bus`            | `"scsi"`                                                                                                    | The bus type for the disks (`scsi`, `nvme`).                                                                                                                                                                |
| `bootstrap_kvm_infra__disk_io`             | `"threads"`                                                                                                 | The I/O mode for the disks.                                                                                                                                                                                 |
| `bootstrap_kvm_infra__disk_cache`          | `"writeback"`                                                                                               | The cache mode for the disks.                                                                                                                                                                               |
| `bootstrap_kvm_infra__disks`               | `[ { name: "boot", size: "{{ bootstrap_kvm_infra__disk_size }}", bus: "{{ virt_infra_disk_bus }}" } ]`        | A list of disks to be created and attached to the VMs.                                                                                                                                                    |
| `virt_infra_distro_image`                | `"CentOS-7-x86_64-GenericCloud.qcow2"`                                                                        | The name of the distribution image file used for booting the VMs.                                                                                                                                         |
| `virt_infra_distro`                      | `"centos"`                                                                                                  | The distribution type (e.g., `centos`, `ubuntu`).                                                                                                                                                         |
| `virt_infra_distro_release`              | `"7"`                                                                                                       | The release version of the distribution.                                                                                                                                                                    |
| `virt_infra_distro_image_url`            | `"https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"`                               | The URL to download the distribution image file.                                                                                                                                                          |
| `virt_infra_distro_image_checksum_url`     | `"https://cloud.centos.org/centos/7/images/sha256sum.txt"`                                                | The URL to download the checksum of the distribution image file.                                                                                                                                          |
| `virt_infra_host_libvirt_url`            | `"qemu:///system"`                                                                                          | The libvirt connection URI for the KVM host.                                                                                                                                                              |
| `virt_infra_host_image_path`             | `"/var/lib/libvirt/images"`                                                                                 | The path on the KVM host where VM images are stored.                                                                                                                                                        |
| `virt_infra_security_driver`               | `"none"`                                                                                                    | The security driver to be used by libvirt.                                                                                                                                                                  |
| `virt_infra_vbmc`                          | `false`                                                                                                     | Whether virtual BMC (IPMI emulation) should be enabled for the VMs.                                                                                                                                       |
| `virt_infra_vbmc_pip`                      | `true`                                                                                                      | Whether to install the virtual BMC package via pip.                                                                                                                                                         |
| `virt_infra_vbmc_service`                  | `"vbmcd"`                                                                                                   | The name of the virtual BMC service.                                                                                                                                                                        |
| `virt_infra_host_networks`               | `{ absent: [], present: [ { name: "default", type: "nat", ip_address: "192.168.112.1", subnet: "255.255.255.0", dhcp_start: "192.168.112.2", dhcp_end: "192.168.112.254" } ] }` | Configuration for the networks to be created on the KVM host.                                                                                                                                             |
| `virt_infra_mkiso_cmd`                   | `"genisoimage"`                                                                                             | The command used to create ISO images (e.g., for cloud-init).                                                                                                                                             |
| `virt_infra_host_deps`                   | `[ "qemu-img", "osinfo-query", "virsh", "virt-customize", "virt-sysprep" ]`                                | A list of dependencies required on the KVM host.                                                                                                                                                            |

## Usage

To use this role, include it in your Ansible playbook and specify the necessary variables as needed. Below is an example playbook that demonstrates how to deploy a VM using this role:

```yaml
---
- name: Deploy VMs using bootstrap_kvm_infra role
  hosts: kvmhost,guests
  become: yes
  vars:
    bootstrap_kvm_infra__kvm_host: "kvm.example.int"
    bootstrap_kvm_infra__state: "running"
    bootstrap_kvm_infra__ram: "2048"
    bootstrap_kvm_infra__cpus: "2"
    bootstrap_kvm_infra__disks:
      - name: "boot"
        size: "30"
  roles:
    - role: bootstrap_kvm_infra
```

In this example, the playbook targets both the KVM host and the VMs to be deployed. The `bootstrap_kvm_infra` role is included with specific variables set for RAM, CPUs, and disk configuration.

## Dependencies

This role depends on the following packages and modules:

- `qemu-img`
- `osinfo-query`
- `virsh`
- `virt-customize`
- `virt-sysprep`
- `community.libvirt` Ansible collection
- `community.crypto` Ansible collection

Ensure these dependencies are installed on the KVM host before running the playbook.

## Tags

The role includes several tags that allow you to target specific tasks:

- `validation`: Run only validation tasks.
- `network`: Manage network configurations.
- `storage`: Manage storage pools and disks.
- `vm`: Manage VM creation, removal, and configuration.
- `vbmc`: Manage virtual BMC (IPMI emulation).
- `ssh`: Configure SSH access for the VMs.

You can use these tags to run specific parts of the role. For example:

```bash
ansible-playbook -i inventory playbook.yml --tags vm,network
```

## Best Practices

1. **Inventory Configuration**: Ensure that your Ansible inventory is correctly configured with the KVM host and guest VMs.
2. **Variable Overrides**: Override default variables in your playbook or group_vars/host_vars as needed to customize the deployment.
3. **Security**: Use SSH keys for authentication instead of passwords whenever possible, and ensure that sensitive information (e.g., passwords) is encrypted or stored securely.
4. **Testing**: Test the role in a development environment before deploying it in production.

## Molecule Tests

This role does not include Molecule tests at this time. However, it is recommended to write and run Molecule tests to validate the functionality of the role.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_kvm_infra/defaults/main.yml)
- [tasks/defaults-get.yml](../../roles/bootstrap_kvm_infra/tasks/defaults-get.yml)
- [tasks/defaults-set.yml](../../roles/bootstrap_kvm_infra/tasks/defaults-set.yml)
- [tasks/disk-create.yml](../../roles/bootstrap_kvm_infra/tasks/disk-create.yml)
- [tasks/disk-remove.yml](../../roles/bootstrap_kvm_infra/tasks/disk-remove.yml)
- [tasks/hosts-add.yml](../../roles/bootstrap_kvm_infra/tasks/hosts-add.yml)
- [tasks/hosts-remove.yml](../../roles/bootstrap_kvm_infra/tasks/hosts-remove.yml)
- [tasks/main.yml](../../roles/bootstrap_kvm_infra/tasks/main.yml)
- [tasks/net-create.yml](../../roles/bootstrap_kvm_infra/tasks/net-create.yml)
- [tasks/net-list.yml](../../roles/bootstrap_kvm_infra/tasks/net-list.yml)
- [tasks/net-remove.yml](../../roles/bootstrap_kvm_infra/tasks/net-remove.yml)
- [tasks/pool-create.yml](../../roles/bootstrap_kvm_infra/tasks/pool-create.yml)
- [tasks/validations.yml](../../roles/bootstrap_kvm_infra/tasks/validations.yml)
- [tasks/vbmc-create.yml](../../roles/bootstrap_kvm_infra/tasks/vbmc-create.yml)
- [tasks/vbmc-list.yml](../../roles/bootstrap_kvm_infra/tasks/vbmc-list.yml)
- [tasks/vbmc-remove.yml](../../roles/bootstrap_kvm_infra/tasks/vbmc-remove.yml)
- [tasks/virt-create.yml](../../roles/bootstrap_kvm_infra/tasks/virt-create.yml)
- [tasks/virt-list.yml](../../roles/bootstrap_kvm_infra/tasks/virt-list.yml)
- [tasks/virt-remove.yml](../../roles/bootstrap_kvm_infra/tasks/virt-remove.yml)
- [tasks/wait.yml](../../roles/bootstrap_kvm_infra/tasks/wait.yml)
- [handlers/main.yml](../../roles/bootstrap_kvm_infra/handlers/main.yml)