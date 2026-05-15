---
title: Kubernetes Worker Bootstrap Role Documentation
role: bootstrap_kubernetes_worker
category: Ansible Roles
type: Infrastructure as Code (IaC)
tags: kubernetes, worker, ansible

## Summary
The `bootstrap_kubernetes_worker` role is designed to install and configure a Kubernetes worker node. It handles the installation of necessary OS packages, configuration directories setup, certificate management, and kubelet/kube-proxy configurations. This role ensures that the worker nodes are properly integrated into an existing Kubernetes cluster.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_kubernetes_worker__worker_conf_dir` | `/etc/kubernetes/worker` | Base directory for Kubernetes worker configuration files. |
| `bootstrap_kubernetes_worker__worker_pki_dir` | `{{ bootstrap_kubernetes_worker__worker_conf_dir }}/pki` | Directory to store PKI certificates and keys. |
| `bootstrap_kubernetes_worker__worker_bin_dir` | `/usr/local/bin` | Directory where Kubernetes binaries will be installed. |
| `bootstrap_kubernetes_worker__arch` | `{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}` | Architecture of the worker node (automatically detected). |
| `bootstrap_kubernetes_worker__worker_release` | `1.31.11` | Version of Kubernetes to install on the worker node. |
| `bootstrap_kubernetes_worker__interface` | `eth0` | Network interface used for communication within the cluster. |
| `bootstrap_kubernetes_worker__ca_conf_directory` | `{{ '~/k8s/certs' \| expanduser }}` | Directory containing CA certificates and keys. |
| `bootstrap_kubernetes_worker__worker_api_endpoint_host` | `{{ ansible_facts['default_ipv4']['address'] }}` | IP address of the Kubernetes API server. |
| `bootstrap_kubernetes_worker__worker_api_endpoint_port` | `6443` | Port number for the Kubernetes API server. |
| `bootstrap_kubernetes_worker__worker_os_packages` | `[ebtables, ethtool, ipset, conntrack, iptables, iptstate, netstat-nat, socat, netbase]` | List of OS packages required by Kubernetes worker nodes. |
| `bootstrap_kubernetes_worker__worker_kubelet_conf_dir` | `{{ bootstrap_kubernetes_worker__worker_conf_dir }}/kubelet` | Directory for kubelet configuration files. |
| `bootstrap_kubernetes_worker__worker_kubelet_settings` | Configured settings for kubelet (see defaults/main.yml) | Settings for the kubelet service. |
| `bootstrap_kubernetes_worker__worker_kubelet_conf_yaml` | KubeletConfiguration YAML (see defaults/main.yml) | Configuration file content for kubelet. |
| `bootstrap_kubernetes_worker__worker_kubeproxy_conf_dir` | `{{ bootstrap_kubernetes_worker__worker_conf_dir }}/kube-proxy` | Directory for kube-proxy configuration files. |
| `bootstrap_kubernetes_worker__worker_kubeproxy_settings` | Configured settings for kube-proxy (see defaults/main.yml) | Settings for the kube-proxy service. |
| `bootstrap_kubernetes_worker__worker_kubeproxy_conf_yaml` | KubeProxyConfiguration YAML (see defaults/main.yml) | Configuration file content for kube-proxy. |

## Usage
To use this role, include it in your Ansible playbook and ensure that all required variables are set appropriately. Here is an example of how to include the role in a playbook:

```yaml
- name: Bootstrap Kubernetes Worker Nodes
  hosts: kubernetes_workers
  become: yes
  roles:
    - role: bootstrap_kubernetes_worker
      vars:
        bootstrap_kubernetes_worker__worker_release: "1.31.11"
        bootstrap_kubernetes_worker__interface: "eth0"
```

## Dependencies
- `ansible.posix.mount`
- `ansible.builtin.command`
- `ansible.builtin.file`
- `ansible.builtin.apt`
- `ansible.builtin.copy`
- `ansible.builtin.get_url`
- `ansible.builtin.stat`
- `ansible.builtin.shell`
- `ansible.builtin.debug`
- `ansible.builtin.systemd`
- `ansible.builtin.service`

## Best Practices
1. **Backup Configuration Files**: Always back up existing configuration files before applying changes.
2. **Use Secure Certificates**: Ensure that all certificates and keys are securely managed and stored.
3. **Test Changes in a Staging Environment**: Before deploying changes to production, test them in a staging environment to ensure stability.

## Molecule Tests
This role does not include Molecule tests at this time. Consider adding Molecule tests for automated testing of the role.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_kubernetes_worker/defaults/main.yml)
- [tasks/kube-proxy.yml](../../roles/bootstrap_kubernetes_worker/tasks/kube-proxy.yml)
- [tasks/kubelet.yml](../../roles/bootstrap_kubernetes_worker/tasks/kubelet.yml)
- [tasks/main.yml](../../roles/bootstrap_kubernetes_worker/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_kubernetes_worker/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_kubernetes_worker/handlers/main.yml)