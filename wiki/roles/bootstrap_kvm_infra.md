---
title: "Bootstrap KVM Infrastructure Role"
role: bootstrap_kvm_infra
category: Virtualization
type: Role
tags: [ansible, role, bootstrap_kvm_infra]
---

# Bootstrap KVM Infrastructure Role

The `bootstrap_kvm_infra` role is designed to automate the setup and management of KVM virtual machines and their infrastructure. It provides a comprehensive set of tasks to create, configure, and manage VMs, networks, storage pools, and virtual BMCs on a KVM host. This role is particularly useful for setting up development, testing, or production environments with virtual machines.

## Summary

- Automates the setup and management of KVM virtual machines.
- Manages VMs, networks, storage pools, and virtual BMCs.
- Useful for development, testing, or production environments.

## Variables

| Variable Name                                      | Default Value                                                                 | Description                                                                                                 |
|----------------------------------------------------|---------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| `bootstrap_kvm_infra__kvm_host`                    | `kvm.example.int`                                                           | The hostname of the KVM host.                                                                               |
| `bootstrap_kvm_infra__is_kvm_host`                 | `false`                                                                   | Boolean indicating if the current host is a KVM host.                                                        |
| `bootstrap_kvm_infra__state`                       | `"running"`                                                                | The desired state of the VMs (running, undefined, etc.).                                                    |
| `bootstrap_kvm_infra__autostart`                   | `"no"`                                                                    | Whether the VMs should autostart.                                                                           |
| `bootstrap_kvm_infra__user`                        | `{{ lookup('env', 'USER' ) }}`                                             | The user for the VMs.                                                                                       |
| `bootstrap_kvm_infra__password`                    | `"password"`                                                               | The password for the VMs.                                                                                   |
| `bootstrap_kvm_infra__ram`                         | `"1024"`                                                                  | Amount of RAM allocated to the VMs.                                                                         |
| `bootstrap_kvm_infra__ram_max`                     | `{{ bootstrap_kvm_infra__ram }}`                                          | Maximum amount of RAM allocated to the VMs.                                                                 |
| `bootstrap_kvm_infra__cpus`                        | `"1"`                                                                     | Number of CPUs allocated to the VMs.                                                                       |
| `bootstrap_kvm_infra__cpus_max`                    | `{{ bootstrap_kvm_infra__cpus }}`                                         | Maximum number of CPUs allocated to the VMs.                                                                |
| `bootstrap_kvm_infra__cpu_model`                   | `"host-passthrough"`                                                       | CPU model for the VMs.                                                                                      |
| `bootstrap_kvm_infra__machine_type`                | `"q35"`                                                                   | Machine type for the VMs.                                                                                   |
| `bootstrap_kvm_infra__ssh_keys`                    | `[]`                                                                     | List of SSH public keys for cloud-init.                                                                      |
| `bootstrap_kvm_infra__ssh_key_size`                | `"2048"`                                                                  | Size of the SSH key.                                                                                         |
| `bootstrap_kvm_infra__ssh_key_type`                | `"rsa"`                                                                   | Type of the SSH key.                                                                                         |
| `bootstrap_kvm_infra__ssh_pwauth`                  | `true`                                                                   | Enable/disable SSH password authentication.                                                                  |
| `bootstrap_kvm_infra__networks`                    | `[{"name": "default", "type": "nat", "model": "virtio"}]`                 | List of networks for the VMs.                                                                               |
| `bootstrap_kvm_infra__disk_size`                   | `"20"`                                                                    | Size of the disk for the VMs.                                                                               |
| `bootstrap_kvm_infra__disk_bus`                    | `"scsi"`                                                                  | Disk bus type for the VMs.                                                                                  |
| `bootstrap_kvm_infra__disk_io`                     | `"threads"`                                                               | Disk I/O mode for the VMs.

... [truncated - large file] ...