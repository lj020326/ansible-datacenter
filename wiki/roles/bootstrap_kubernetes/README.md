```markdown
---
title: Ansible Role for Kubernetes Installation
original_path: roles/bootstrap_kubernetes/README.md
category: Ansible Roles
tags: [Kubernetes, Ansible, Container Runtime]
---

# Ansible Role: Kubernetes

This Ansible role installs [Kubernetes](https://kubernetes.io) on Linux systems.

## Requirements

- A compatible [Container Runtime](https://kubernetes.io/docs/setup/production-environment/container-runtimes); recommended role for CRI installation: `geerlingguy.containerd`.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

### Kubernetes Packages

```yaml
bootstrap_kubernetes__packages:
  - name: kubelet
    state: present
  - name: kubectl
    state: present
  - name: kubeadm
    state: present
  - name: kubernetes-cni
    state: present
```

Kubernetes packages to be installed on the server. You can either provide a list of package names, or set `name` and `state` to have more control over whether the package is `present`, `absent`, `latest`, etc.

### Kubernetes Version

```yaml
bootstrap_kubernetes__version: '1.32'
bootstrap_kubernetes__version_rhel_package: '1.32'
```

The minor version of Kubernetes to install. The plain `bootstrap_kubernetes__version` is used to pin an apt package version on Debian, and as the Kubernetes version passed into the `kubeadm init` command (see `bootstrap_kubernetes__version_kubeadm`). The `bootstrap_kubernetes__version_rhel_package` variable must be a specific Kubernetes release, and is used to pin the version on Red Hat / CentOS servers.

### Role Type

```yaml
bootstrap_kubernetes__role: control_plane
```

Whether the particular server will serve as a Kubernetes `control_plane` (default) or `node`. The control plane will have `kubeadm init` run on it to initialize the entire K8s control plane, while `node`s will have `kubeadm join` run on them to join them to the `control_plane`.

### Kubeadm and Kubelet Configuration

With this role, `kubeadm init` will be run with `--config <FILE>`.

#### Config File Path

```yaml
bootstrap_kubernetes__kubeadm_kubelet_config_file_path: '/etc/kubernetes/kubeadm-kubelet-config.yaml'
```

Path for `<FILE>`. If the directory does not exist, this role will create it.

The following variables are parsed as options to <FILE>. To understand its syntax, see [kubelet-integration](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/kubelet-integration) and [kubeadm-config-file](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#config-file). The skeleton (`apiVersion`, `kind`) of the config file will be created by this role, so do not define them within the variables. (See `templates/kubeadm-kubelet-config.j2`).

#### Init Configuration

```yaml
bootstrap_kubernetes__config_init_configuration:
  localAPIEndpoint:
    advertiseAddress: "{{ bootstrap_kubernetes__apiserver_advertise_address | default(ansible_default_ipv4.address, true) }}"
```

Defines the options under `kind: InitConfiguration`. Including `bootstrap_kubernetes__apiserver_advertise_address` here is for backward-compatibility to older versions of this role, where `bootstrap_kubernetes__apiserver_advertise_address` was used with a command-line-option.

#### Cluster Configuration

```yaml
bootstrap_kubernetes__config_cluster_configuration:
  networking:
    podSubnet: "{{ bootstrap_kubernetes__pod_network.cidr }}"
  kubernetesVersion: "{{ bootstrap_kubernetes__version_kubeadm }}"
```

Options under `kind: ClusterConfiguration`. Including `bootstrap_kubernetes__pod_network.cidr` and `bootstrap_kubernetes__version_kubeadm` here are for backward-compatibility to older versions of this role, where they were used with command-line-options.

#### Kubelet Configuration

```yaml
bootstrap_kubernetes__config_kubelet_configuration:
  cgroupDriver: systemd
```

Options to configure kubelet on any nodes in your cluster through the `kubeadm init` process. For syntax options read the [kubelet config file](https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file) and [kubelet integration](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/kubelet-integration) documentation.

**NOTE:** This is the recommended way to do kubelet configuration. Most command-line options are deprecated.

**NOTE:** The recommended `cgroupDriver` depends on your [Container Runtime](https://kubernetes.io/docs/setup/production-environment/container-runtimes). When using this role with Docker instead of containerd, this value should be changed to `cgroupfs`.

#### Kube Proxy Configuration

```yaml
bootstrap_kubernetes__config_kube_proxy_configuration: {}
```

Options to configure kubelet's proxy configuration in the `KubeProxyConfiguration` section of the kubelet configuration.

### Command-Line Options for Kubeadm and Kubelet

**NOTE:** These options are deprecated. Please use the config file method instead.

#### Kubelet Extra Args

```yaml
bootstrap_kubernetes__kubelet_extra_args: ""
bootstrap_kubernetes__kubelet_extra_args_config_file: /etc/default/kubelet
```

Extra args to pass to `kubelet` during startup. E.g., to allow `kubelet` to start up even if swap is enabled on your server, set this to: `"--fail-swap-on=false"`. Or to specify the node-ip advertised by `kubelet`, set this to `"--node-ip={{ ansible_host }}"`.

#### Kubeadm Init Extra Options

```yaml
bootstrap_kubernetes__kubeadm_init_extra_opts: ""
```

Extra args to pass to `kubeadm init` during K8s control plane initialization. E.g., to specify extra Subject Alternative Names for API server certificate, set this to: `"--apiserver-cert-extra-sans my-custom.host"`

#### Join Command Extra Options

```yaml
bootstrap_kubernetes__join_command_extra_opts: ""
```

Extra args to pass to the generated `kubeadm join` command during K8s node initialization. E.g., to ignore certain preflight errors like swap being enabled, set this to: `--ignore-preflight-errors=Swap`

### Additional Variables

#### Allow Pods on Control Plane

```yaml
bootstrap_kubernetes__allow_pods_on_control_plane: true
```

Whether to remove the taint that denies pods from being deployed to the Kubernetes control plane. If you have a single-node cluster, this should definitely be `True`. Otherwise, set to `False` if you want a dedicated Kubernetes control plane which doesn't run any other pods.

#### Pod Network Configuration

```yaml
bootstrap_kubernetes__pod_network:
  # Flannel CNI.
  cni: 'flannel'
  cidr: '10.244.0.0/16'
  #
  # Calico CNI.
  # cni: 'calico'
  # cidr: '192.168.0.0/16'
  #
  # Weave CNI.
  # cni: 'weave'
  # cidr: '192.168.0.0/16'
```

This role currently supports `flannel` (default), `calico`, or `weave` for cluster pod networking. Choose only one for your cluster; converting between them is not done automatically and could result in broken networking; if you need to switch from one to another, it should be done outside of this role.

#### API Server Advertise Address

```yaml
bootstrap_kubernetes__apiserver_advertise_address: ''
```

The address the Kubernetes API server will advertise. Defaults to `ansible_default_ipv4.address` if left empty.

#### Kubeadm Version

```yaml
bootstrap_kubernetes__version_kubeadm: 'stable-{{ bootstrap_kubernetes__version }}'
```

The version of kubeadm to use during initialization.

#### Ignore Preflight Errors

```yaml
bootstrap_kubernetes__ignore_preflight_errors: 'all'
```

Errors to ignore during the preflight checks. Setting this to `'all'` will ignore all errors, but it is recommended to address any issues that arise during installation.

#### Apt Repository Options

```yaml
bootstrap_kubernetes__apt_release_channel: "stable"
bootstrap_kubernetes__apt_repository: "https://pkgs.k8s.io/core:/{{ bootstrap_kubernetes__apt_release_channel }}:/v{{ bootstrap_kubernetes__version }}/deb/"
```

Apt repository options for Kubernetes installation.

#### Yum Repository Options

```yaml
bootstrap_kubernetes__yum_base_url: "https://pkgs.k8s.io/core:/stable:/v{{ bootstrap_kubernetes__version }}/rpm/"
bootstrap_kubernetes__yum_gpg_key: "https://pkgs.k8s.io/core:/stable:/v{{ bootstrap_kubernetes__version }}/rpm/repodata/repomd.xml.key"
bootstrap_kubernetes__yum_gpg_check: true
bootstrap_kubernetes__yum_repo_gpg_check: true
```

Yum repository options for Kubernetes installation. You can change `kubernete_yum_gpg_key` to a different URL if you are behind a firewall or provide a trustworthy mirror. Usually in combination with changing `bootstrap_kubernetes__yum_base_url` as well.

#### CNI Manifest Files

```yaml
bootstrap_kubernetes__flannel_manifest_file: https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

Flannel manifest file to apply to the Kubernetes cluster to enable networking. You can copy your own files to your server and apply them instead, if you need to customize the Flannel networking configuration.

```yaml
bootstrap_kubernetes__calico_manifest_file: https://projectcalico.docs.tigera.io/manifests/calico.yaml
```

Calico manifest file to apply to the Kubernetes cluster (if using Calico instead of Flannel).

## Dependencies

- None.

## Example Playbooks

### Single Node (Control-Plane Only) Cluster

```yaml
- hosts: all

  vars:
    bootstrap_kubernetes__allow_pods_on_control_plane: true

  roles:
    - geerlingguy.docker
    - geerlingguy.kubernetes
```

### Two or More Nodes (Single Control-Plane) Cluster

#### Inventory Vars

**Control Plane:**

```yaml
bootstrap_kubernetes__role: "control_plane"
```

**Nodes:**

```yaml
bootstrap_kubernetes__role: "node"
```

#### Playbook

```yaml
- hosts: all

  vars:
    bootstrap_kubernetes__allow_pods_on_control_plane: true

  roles:
    - geerlingguy.docker
    - geerlingguy.kubernetes
```

After running the playbook, log into the Kubernetes control plane and run `kubectl get nodes` as root to see a list of all the servers.

## Backlinks

- [Ansible Roles](/ansible-roles)
- [Kubernetes Setup](/kubernetes-setup)
```
```