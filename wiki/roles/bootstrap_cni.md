---
title: "Bootstrap CNI Role"
role: roles/bootstrap_cni
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_cni]
---

# Bootstrap CNI Role Documentation

This Ansible role is designed to bootstrap a Container Network Interface (CNI) plugin for Kubernetes clusters. It supports multiple CNI plugins such as Calico and Flannel, and ensures that the necessary network configurations are applied to the Kubernetes nodes.

## Variables

| Variable Name | Default Value | Required | Description |
|---------------|---------------|----------|-------------|
| `bootstrap_cni__calico_cni_opts` | `interface={{ network_interface }}` | No | Options for the Calico CNI plugin. |
| `bootstrap_cni__flannel_cni_opts` | `--iface={{ network_interface }}` | No | Options for the Flannel CNI plugin. |
| `bootstrap_cni__controller_host` | `k8s.example.int` | No | The hostname or IP address of the Kubernetes control plane node. |
| `network_interface` | N/A | Yes | The network interface to use for the CNI plugin. |
| `network` | N/A | Yes | The CNI plugin to use (e.g., "calico" or "flannel"). |
| `kubeadmin_config` | N/A | Yes | Path to the kubeadmin configuration file. |
| `network_dir` | N/A | Yes | Directory where network configuration files are stored. |

## Usage

To use this role, include it in your playbook and set the necessary variables. Here are examples for using different CNI plugins:

### Using Calico
```yaml
- hosts: kubernetes_nodes
  roles:
    - role: bootstrap_cni
      vars:
        network_interface: "eth0"
        network: "calico"
        kubeadmin_config: "/path/to/kubeadmin.config"
        network_dir: "/path/to/network/dir"
```

### Using Flannel
```yaml
- hosts: kubernetes_nodes
  roles:
    - role: bootstrap_cni
      vars:
        network_interface: "eth0"
        network: "flannel"
        kubeadmin_config: "/path/to/kubeadmin.config"
        network_dir: "/path/to/network/dir"
```

## Dependencies

This role does not have any external dependencies. However, it assumes that Kubernetes is already installed and configured on the target nodes.

## Best Practices

- Ensure that the Kubernetes cluster is properly set up before applying this role.
- Verify that the network interface specified in the variables matches the actual network interface on the Kubernetes nodes.
- Regularly check the status of the CNI daemonset to ensure that the network configuration is applied correctly.
- Test the role in a development environment before applying it to production clusters.
- Monitor network performance and troubleshoot any connectivity issues that may arise after applying the role.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_cni/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_cni/tasks/main.yml)