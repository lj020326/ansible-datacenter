---
title: Bootstrap CNI Role Documentation
role: bootstrap_cni
category: Kubernetes Networking
type: Ansible Role
tags: kubernetes, cni, calico, flannel
---

## Summary

The `bootstrap_cni` role is designed to set up and configure Container Network Interface (CNI) plugins for a Kubernetes cluster. It supports both Calico and Flannel CNI configurations, ensuring that the specified network daemonset is deployed and operational on the controller host.

## Variables
| Variable Name                     | Default Value                                      | Description                                                                 |
|-----------------------------------|----------------------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_cni__calico_cni_opts`  | `interface={{ network_interface }}`                | Options for Calico CNI configuration, specifying the network interface.     |
| `bootstrap_cni__flannel_cni_opts` | `--iface={{ network_interface }}`                  | Options for Flannel CNI configuration, specifying the network interface.    |
| `bootstrap_cni__controller_host`  | `k8s.example.int`                                  | The hostname or IP address of the Kubernetes controller node where commands will be executed. |

## Usage
To use this role, include it in your playbook and specify the necessary variables such as `network_interface`, `kubeadmin_config`, and `network_dir`. Ensure that the templates for the CNI configurations are available in the specified directory.

Example Playbook:
```yaml
- hosts: k8s_controllers
  roles:
    - role: bootstrap_cni
      vars:
        network_interface: eth0
        kubeadmin_config: /etc/kubernetes/admin.conf
        network_dir: /etc/kubernetes/addons/network
        network: calico
```

## Dependencies
This role does not have any external dependencies. However, it assumes that `kubectl` is installed and configured on the controller host specified by `bootstrap_cni__controller_host`.

## Tags
No specific tags are defined in this role.

## Best Practices
- Ensure that the `network_interface` variable matches the network interface used by your Kubernetes nodes.
- Verify that the `kubeadmin_config` file has the correct permissions and is accessible to the user running the Ansible playbook.
- Regularly check the status of the CNI daemonset using `kubectl get ds --all-namespaces`.

## Molecule Tests
No Molecule tests are provided for this role.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_cni/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_cni/tasks/main.yml)