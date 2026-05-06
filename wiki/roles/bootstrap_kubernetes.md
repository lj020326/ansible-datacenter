---
title: Ansible Role - bootstrap_kubernetes
role: bootstrap_kubernetes
category: System Setup
type: Kubernetes Bootstrap
tags: kubernetes, kubeadm, setup, control-plane, node

## Summary

The `bootstrap_kubernetes` role is designed to prepare a server for running a basic single-node or multi-node Kubernetes cluster. It handles the installation of necessary packages, configuration of system settings, and initialization of the Kubernetes control plane using `kubeadm`. The role supports both Debian-based (e.g., Ubuntu) and Red Hat-based distributions.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_kubernetes__packages` | `[ { name: 'kubelet', state: 'present' }, { name: 'kubectl', state: 'present' }, { name: 'kubeadm', state: 'present' }, { name: 'kubernetes-cni', state: 'present' } ]` | List of Kubernetes packages to install. |
| `bootstrap_kubernetes__version` | `'1.33'` | The version of Kubernetes to install. |
| `bootstrap_kubernetes__version_rhel_package` | `'1.33'` | The version of Kubernetes package for Red Hat-based systems. |
| `bootstrap_kubernetes__role` | `'control_plane'` | Role type, either 'control_plane' or 'node'. |
| `bootstrap_kubernetes__kubelet_extra_args` | `""` | Extra arguments to pass to kubelet. |
| `bootstrap_kubernetes__kubeadm_init_extra_opts` | `""` | Extra options for kubeadm init command. |
| `bootstrap_kubernetes__join_command_extra_opts` | `""` | Extra options for kubeadm join command. |
| `bootstrap_kubernetes__allow_pods_on_control_plane` | `true` | Allow pods to be scheduled on the control plane node. |
| `bootstrap_kubernetes__pod_network` | `{ cni: 'flannel', cidr: '10.244.0.0/16' }` | Configuration for pod network, including CNI plugin and CIDR range. |
| `bootstrap_kubernetes__kubeadm_kubelet_config_file_path` | `'/etc/kubernetes/kubeadm-kubelet-config.yaml'` | Path to the kubeadm kubelet configuration file. |
| `bootstrap_kubernetes__config_kubeadm_apiversion` | `'v1beta4'` | API version for kubeadm configuration. |
| `kubenetes_config_kubelet_apiversion` | `'v1beta1'` | API version for kubelet configuration. |
| `bootstrap_kubernetes__config_kube_proxy_apiversion` | `'v1alpha1'` | API version for kube-proxy configuration. |
| `bootstrap_kubernetes__config_kubelet_configuration` | `{ cgroupDriver: "systemd" }` | Configuration options for kubelet. |
| `bootstrap_kubernetes__config_init_configuration` | `{ localAPIEndpoint: { advertiseAddress: "{{ bootstrap_kubernetes__apiserver_advertise_address \| default(ansible_facts['default_ipv4'].address, true) }}" } }` | Initialization configuration for kubeadm. |
| `bootstrap_kubernetes__config_cluster_configuration` | `{ networking: { podSubnet: "{{ bootstrap_kubernetes__pod_network.cidr }}" }, kubernetesVersion: "{{ bootstrap_kubernetes__version_kubeadm }}" }` | Cluster configuration for kubeadm. |
| `bootstrap_kubernetes__config_kube_proxy_configuration` | `{}` | Configuration options for kube-proxy. |
| `bootstrap_kubernetes__apiserver_advertise_address` | `''` | Advertise address for the API server. |
| `bootstrap_kubernetes__version_kubeadm` | `'stable-{{ bootstrap_kubernetes__version }}'` | Version of kubeadm to use. |
| `bootstrap_kubernetes__ignore_preflight_errors` | `'all'` | Preflight errors to ignore during initialization. |
| `bootstrap_kubernetes__apt_release_channel` | `"stable"` | Release channel for Kubernetes packages on Debian-based systems. |
| `bootstrap_kubernetes__apt_repository` | `"https://pkgs.k8s.io/core:/{{ bootstrap_kubernetes__apt_release_channel }}:/v{{ bootstrap_kubernetes__version }}/deb/"` | Repository URL for Kubernetes packages on Debian-based systems. |
| `bootstrap_kubernetes__yum_base_url` | `"https://pkgs.k8s.io/core:/stable:/v{{ bootstrap_kubernetes__version }}/rpm/"` | Base URL for Kubernetes packages on Red Hat-based systems. |
| `bootstrap_kubernetes__yum_gpg_key` | `"https://pkgs.k8s.io/core:/stable:/v{{ bootstrap_kubernetes__version }}/rpm/repodata/repomd.xml.key"` | GPG key for verifying Kubernetes packages on Red Hat-based systems. |
| `bootstrap_kubernetes__yum_gpg_check` | `true` | Enable GPG check for Kubernetes packages on Red Hat-based systems. |
| `bootstrap_kubernetes__yum_repo_gpg_check` | `true` | Enable repository GPG check for Kubernetes packages on Red Hat-based systems. |
| `bootstrap_kubernetes__flannel_manifest_file` | `"https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml"` | URL to the Flannel network manifest file. |
| `bootstrap_kubernetes__calico_manifest_file` | `"https://projectcalico.docs.tigera.io/manifests/calico.yaml"` | URL to the Calico network manifest file. |

## Usage

To use this role, include it in your playbook and specify the desired variables as needed. Here is an example of how to set up a control plane node:

```yaml
- hosts: control_plane_nodes
  roles:
    - role: bootstrap_kubernetes
      vars:
        bootstrap_kubernetes__role: 'control_plane'
        bootstrap_kubernetes__pod_network:
          cni: 'calico'
```

To add worker nodes to the cluster, specify the `node` role:

```yaml
- hosts: worker_nodes
  roles:
    - role: bootstrap_kubernetes
      vars:
        bootstrap_kubernetes__role: 'node'
```

## Dependencies

This role depends on the following collections:

- `ansible.posix`
- `kubernetes.core`

## Tags

The following tags are available for this role:

- `skip_ansible_lint`: Skips linting checks for specific tasks.

## Best Practices

1. **Version Control**: Always specify a version of Kubernetes to avoid unexpected changes.
2. **Network Configuration**: Ensure network settings align with your infrastructure requirements, especially when using different CNI plugins.
3. **Security**: Regularly update the role and its dependencies to incorporate security patches.

## Molecule Tests

This role includes Molecule tests to verify functionality across supported platforms. To run the tests:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_kubernetes/defaults/main.yml)
- [tasks/control-plane-setup.yml](../../roles/bootstrap_kubernetes/tasks/control-plane-setup.yml)
- [tasks/kubelet-setup.yml](../../roles/bootstrap_kubernetes/tasks/kubelet-setup.yml)
- [tasks/main.yml](../../roles/bootstrap_kubernetes/tasks/main.yml)
- [tasks/node-setup.yml](../../roles/bootstrap_kubernetes/tasks/node-setup.yml)
- [tasks/setup-Debian.yml](../../roles/bootstrap_kubernetes/tasks/setup-Debian.yml)
- [tasks/setup-RedHat.yml](../../roles/bootstrap_kubernetes/tasks/setup-RedHat.yml)
- [tasks/sysctl-setup.yml](../../roles/bootstrap_kubernetes/tasks/sysctl-setup.yml)
- [meta/main.yml](../../roles/bootstrap_kubernetes/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_kubernetes/handlers/main.yml)