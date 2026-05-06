---
title: "Kubernetes Controller Bootstrap Role"
role: bootstrap_kubernetes_controller
category: Kubernetes
type: Ansible Role
tags: k8s-controller, system, containers, orchestration, setup

## Summary
The `bootstrap_kubernetes_controller` role is designed to install and configure the Kubernetes API server, scheduler, and controller manager on a control plane node. It handles the creation of necessary directories, users, groups, and configuration files required for these components to function correctly.

## Variables

| Variable Name                                       | Default Value                                                                 | Description                                                                                                                                                                                                 |
|-----------------------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_kubernetes_controller__conf_dir`         | `/etc/kubernetes/controller`                                                  | Base directory for Kubernetes control plane configuration files.                                                                                                                                            |
| `bootstrap_kubernetes_controller__pki_dir`          | `"{{ bootstrap_kubernetes_controller__conf_dir }}/pki"`                         | Directory where PKI (Public Key Infrastructure) files are stored.                                                                                                                                         |
| `bootstrap_kubernetes_controller__bin_dir`          | `/usr/local/bin`                                                              | Directory where Kubernetes binaries will be installed.                                                                                                                                                      |
| `bootstrap_kubernetes_controller__release`          | `"1.33.4"`                                                                    | Version of Kubernetes to install.                                                                                                                                                                         |
| `bootstrap_kubernetes_controller__interface`        | `"eth0"`                                                                      | Network interface used for Kubernetes API server and etcd communication.                                                                                                                                  |
| `bootstrap_kubernetes_controller__run_as_user`      | `"kubernetes"`                                                                | User under which Kubernetes control plane processes will run.                                                                                                                                             |
| `bootstrap_kubernetes_controller__run_as_user_shell`| `"/bin/false"`                                                                | Shell for the Kubernetes user, set to `/bin/false` to prevent login.                                                                                                                                      |
| `bootstrap_kubernetes_controller__run_as_user_system`| `true`                                                                         | Whether the Kubernetes user should be a system user.                                                                                                                                                      |
| `bootstrap_kubernetes_controller__run_as_group`     | `"kubernetes"`                                                                | Group under which Kubernetes control plane processes will run.                                                                                                                                            |
| `bootstrap_kubernetes_controller__run_as_group_system`| `true`                                                                        | Whether the Kubernetes group should be a system group.                                                                                                                                                  |
| `bootstrap_kubernetes_controller__delegate_to`      | `"127.0.0.1"`                                                                 | Host to delegate tasks to, typically localhost.                                                                                                                                                           |
| `bootstrap_kubernetes_controller__api_endpoint_host`| `"{{ ansible_facts['default_ipv4']['address'] }}"`                              | IP address of the API server endpoint.                                                                                                                                                                    |
| `bootstrap_kubernetes_controller__api_endpoint_port`| `"6443"`                                                                      | Port for the API server endpoint.                                                                                                                                                                         |
| `bootstrap_kubernetes_controller__log_base_dir`     | `"/var/log/kubernetes"`                                                       | Base directory for Kubernetes logs.                                                                                                                                                                       |
| `bootstrap_kubernetes_controller__log_base_dir_mode`| `"0770"`                                                                      | Permissions mode for the log base directory.                                                                                                                                                              |
| `bootstrap_kubernetes_controller__etcd_client_port` | `"2379"`                                                                      | Port used by etcd client connections.                                                                                                                                                                     |
| `bootstrap_kubernetes_controller__etcd_interface`   | `"eth0"`                                                                      | Network interface used for etcd communication.                                                                                                                                                            |
| `bootstrap_kubernetes_controller__ca_conf_directory`| `/usr/local/ssl/certs`                                                        | Directory where CA (Certificate Authority) configuration files are stored.                                                                                                                                |
| `bootstrap_kubernetes_controller__admin_conf_dir`   | `"{{ '~/k8s/configs' \| expanduser }}"`                                       | Directory to store the admin kubeconfig file.                                                                                                                                                             |
| `bootstrap_kubernetes_controller__admin_conf_dir_perm`| `"0700"`                                                                     | Permissions mode for the admin configuration directory.                                                                                                                                                   |
| `bootstrap_kubernetes_controller__admin_conf_owner` | `"root"`                                                                      | Owner of the admin configuration directory.                                                                                                                                                               |
| `bootstrap_kubernetes_controller__admin_conf_group` | `"root"`                                                                      | Group owner of the admin configuration directory.                                                                                                                                                         |
| `bootstrap_kubernetes_controller__admin_api_endpoint_host`| `"{{ ansible_facts['default_ipv4']['address'] }}"`                        | IP address for the admin API endpoint.                                                                                                                                                                    |
| `bootstrap_kubernetes_controller__admin_api_endpoint_port`| `"6443"`                                                                   | Port for the admin API endpoint.                                                                                                                                                                          |
| `bootstrap_kubernetes_controller__apiserver_audit_log_dir`| `"{{ bootstrap_kubernetes_controller__log_base_dir }}/kube-apiserver"`  | Directory to store kube-apiserver audit logs.                                                                                                                                                           |
| `bootstrap_kubernetes_controller__apiserver_conf_dir`| `"{{ bootstrap_kubernetes_controller__conf_dir }}/kube-apiserver"`           | Directory for kube-apiserver configuration files.                                                                                                                                                       |
| `bootstrap_kubernetes_controller__apiserver_plugins`| List of plugins                                                              | List of admission controllers to enable in the kube-apiserver.                                                                                                                                            |
| `bootstrap_kubernetes_controller__apiserver_settings`| Dictionary of settings                                                       | Configuration settings for the kube-apiserver, including parameters like advertise-address and others (truncated in example).                                                                               |

## Usage
To use this role, include it in your playbook with the desired variables set according to your environment. Here is an example:

```yaml
---
- hosts: k8s_control_plane
  roles:
    - role: bootstrap_kubernetes_controller
      vars:
        bootstrap_kubernetes_controller__release: "1.34.0"
```

## Dependencies
This role depends on the following Ansible collections:
- `ansible.posix`
- `kubernetes.core`

Ensure these collections are installed in your environment.

## Tags
The role uses tags to allow selective task execution. Commonly used tags include:
- `k8s-controller`: For all tasks related to Kubernetes controllers.
- `k8s-controller-base`: For base setup tasks like directory creation and user/group management.

To run only the base setup tasks, you can use:

```bash
ansible-playbook your_playbook.yml --tags k8s-controller-base
```

## Best Practices
- Always specify the version of Kubernetes to install using `bootstrap_kubernetes_controller__release`.
- Ensure that network interfaces (`bootstrap_kubernetes_controller__interface` and `bootstrap_kubernetes_controller__etcd_interface`) are correctly configured for your environment.
- Use tags to selectively run tasks based on your needs.

## Molecule Tests
This role does not include Molecule tests at this time. Future versions may include test scenarios to validate the role's functionality.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_kubernetes_controller/defaults/main.yml)
- [tasks/kube-admin-user.yml](../../roles/bootstrap_kubernetes_controller/tasks/kube-admin-user.yml)
- [tasks/kube-controller-manager.yml](../../roles/bootstrap_kubernetes_controller/tasks/kube-controller-manager.yml)
- [tasks/kube-scheduler.yml](../../roles/bootstrap_kubernetes_controller/tasks/kube-scheduler.yml)
- [tasks/main.yml](../../roles/bootstrap_kubernetes_controller/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_kubernetes_controller/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_kubernetes_controller/handlers/main.yml)