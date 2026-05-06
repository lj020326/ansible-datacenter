---
title: Bootstrap Kubernetes Worker Role Documentation
role: bootstrap_kubernetes_worker
category: Kubernetes
type: Ansible Role
tags: kubernetes, worker, automation

## Summary
The `bootstrap_kubernetes_worker` role is designed to install and configure a Kubernetes worker node. This includes setting up necessary directories, installing required OS packages, copying certificates, downloading Kubernetes binaries, and configuring the kubelet and kube-proxy services.

## Variables

| Variable Name                                      | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|----------------------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_kubernetes_worker__worker_conf_dir`     | `/etc/kubernetes/worker`                                                                                | The base directory for Kubernetes worker configuration files.                                                                                                                                                 |
| `bootstrap_kubernetes_worker__worker_pki_dir`      | `{{ bootstrap_kubernetes_worker__worker_conf_dir }}/pki`                                                  | Directory where PKI (Public Key Infrastructure) certificates and keys are stored.                                                                                                                           |
| `bootstrap_kubernetes_worker__worker_bin_dir`      | `/usr/local/bin`                                                                                        | Directory where Kubernetes binaries will be installed.                                                                                                                                                        |
| `bootstrap_kubernetes_worker__worker_release`      | `1.31.11`                                                                                               | The version of Kubernetes to install on the worker node.                                                                                                                                                    |
| `bootstrap_kubernetes_worker__interface`           | `eth0`                                                                                                  | Network interface used for communication with the Kubernetes API server.                                                                                                                                    |
| `bootstrap_kubernetes_worker__ca_conf_directory`   | `{{ '~/k8s/certs' \| expanduser }}`                                                                       | Directory containing CA (Certificate Authority) certificates and keys.                                                                                                                                      |
| `bootstrap_kubernetes_worker__worker_api_endpoint_host` | `{{ ansible_facts['default_ipv4']['address'] }}`                                                       | Hostname or IP address of the Kubernetes API server.                                                                                                                                                          |
| `bootstrap_kubernetes_worker__worker_api_endpoint_port` | `6443`                                                                                                 | Port number for the Kubernetes API server.                                                                                                                                                                    |
| `bootstrap_kubernetes_worker__worker_os_packages`  | `[ebtables, ethtool, ipset, conntrack, iptables, iptstate, netstat-nat, socat, netbase]`                 | List of OS packages required by Kubernetes worker nodes.                                                                                                                                                    |
| `bootstrap_kubernetes_worker__worker_kubelet_conf_dir` | `{{ bootstrap_kubernetes_worker__worker_conf_dir }}/kubelet`                                          | Directory for kubelet configuration files.                                                                                                                                                                  |
| `bootstrap_kubernetes_worker__worker_kubelet_settings` | Configured with various settings including node IP, kubeconfig path, etc.                             | Settings for the kubelet service.                                                                                                                                                                           |
| `bootstrap_kubernetes_worker__worker_kubelet_conf_yaml` | YAML configuration for kubelet, including authentication, authorization, and network settings.      | YAML content for the kubelet configuration file.                                                                                                                                                            |
| `bootstrap_kubernetes_worker__worker_kubeproxy_conf_dir` | `{{ bootstrap_kubernetes_worker__worker_conf_dir }}/kube-proxy`                                       | Directory for kube-proxy configuration files.                                                                                                                                                               |
| `bootstrap_kubernetes_worker__worker_kubeproxy_settings` | Configured with various settings including config path, etc.                                          | Settings for the kube-proxy service.                                                                                                                                                                        |
| `bootstrap_kubernetes_worker__worker_kubeproxy_conf_yaml` | YAML configuration for kube-proxy, including bind address and mode settings.                      | YAML content for the kube-proxy configuration file.                                                                                                                                                         |

## Usage
To use this role in your Ansible playbook, include it as follows:

```yaml
- hosts: kubernetes_workers
  roles:
    - role: bootstrap_kubernetes_worker
      vars:
        bootstrap_kubernetes_worker__worker_release: "1.31.11"
```

Ensure that the `bootstrap_kubernetes_worker__ca_conf_directory` contains the necessary CA certificates and keys for Kubernetes.

## Dependencies
- The role requires the following Ansible modules: `ansible.builtin.stat`, `ansible.builtin.shell`, `ansible.builtin.debug`, `ansible.builtin.file`, `ansible.posix.mount`, `ansible.builtin.command`, `ansible.builtin.apt`, `ansible.builtin.copy`, and `ansible.builtin.get_url`.
- The role is compatible with Ubuntu focal, jammy, and noble.

## Tags
- `kubelet`: Tasks related to kubelet configuration.
- `kubeproxy`: Tasks related to kube-proxy configuration.
- `certificates`: Tasks related to copying certificates.
- `binaries`: Tasks related to downloading Kubernetes binaries.

## Best Practices
- Ensure that the CA certificates and keys are securely stored in the specified directory.
- Verify that the network interface specified matches the one used for communication with the Kubernetes API server.
- Regularly update the Kubernetes version by changing the `bootstrap_kubernetes_worker__worker_release` variable.

## Molecule Tests
This role does not include Molecule tests. Ensure to manually test the role in a controlled environment before deploying it in production.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_kubernetes_worker/defaults/main.yml)
- [tasks/kube-proxy.yml](../../roles/bootstrap_kubernetes_worker/tasks/kube-proxy.yml)
- [tasks/kubelet.yml](../../roles/bootstrap_kubernetes_worker/tasks/kubelet.yml)
- [tasks/main.yml](../../roles/bootstrap_kubernetes_worker/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_kubernetes_worker/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_kubernetes_worker/handlers/main.yml)