---
title: "Bootstrap Kubernetes Controller Role"
role: roles/bootstrap_kubernetes_controller
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_kubernetes_controller]
---

# Bootstrap Kubernetes Controller Role

The `bootstrap_kubernetes_controller` role is designed to install and configure the Kubernetes API server, scheduler, and controller manager. This role sets up the necessary user accounts, directories, and configuration files to ensure the Kubernetes control plane components are properly configured and operational.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_kubernetes_controller__conf_dir` | `/etc/kubernetes/controller` | Directory to store Kubernetes controller configuration files |
| `bootstrap_kubernetes_controller__pki_dir` | `{{ bootstrap_kubernetes_controller__conf_dir }}/pki` | Directory to store PKI (Public Key Infrastructure) files |
| `bootstrap_kubernetes_controller__bin_dir` | `/usr/local/bin` | Directory to store Kubernetes binaries |
| `bootstrap_kubernetes_controller__release` | `1.33.4` | Kubernetes release version |
| `bootstrap_kubernetes_controller__interface` | `eth0` | Network interface for Kubernetes components |
| `bootstrap_kubernetes_controller__run_as_user` | `kubernetes` | User to run Kubernetes control plane processes |
| `bootstrap_kubernetes_controller__run_as_user_shell` | `/bin/false` | Shell for the Kubernetes user |
| `bootstrap_kubernetes_controller__run_as_user_system` | `true` | Indicates if the Kubernetes user is a system user |
| `bootstrap_kubernetes_controller__run_as_group` | `kubernetes` | Group to run Kubernetes control plane processes |
| `bootstrap_kubernetes_controller__run_as_group_system` | `true` | Indicates if the Kubernetes group is a system group |
| `bootstrap_kubernetes_controller__delegate_to` | `127.0.0.1` | Host to delegate tasks to |
| `bootstrap_kubernetes_controller__api_endpoint_host` | `{{ ansible_facts['default_ipv4']['address'] }}` | API endpoint host for Kubernetes |
| `bootstrap_kubernetes_controller__api_endpoint_port` | `6443` | API endpoint port for Kubernetes |
| `bootstrap_kubernetes_controller__log_base_dir` | `/var/log/kubernetes` | Base directory for Kubernetes log files |
| `bootstrap_kubernetes_controller__log_base_dir_mode` | `0770` | Permissions for the log base directory |
| `bootstrap_kubernetes_controller__etcd_client_port` | `2379` | ETCD client port |
| `bootstrap_kubernetes_controller__etcd_interface` | `eth0` | Network interface for ETCD |
| `bootstrap_kubernetes_controller__ca_conf_directory` | `/usr/local/ssl/certs` | Directory to store CA configuration files |
| `bootstrap_kubernetes_controller__admin_conf_dir` | `{{ '~/k8s/configs' | expanduser }}` | Directory to store admin configuration files |
| `bootstrap_kubernetes_controller__admin_conf_dir_perm` | `0700` | Permissions for the admin configuration directory |
| `bootstrap_kubernetes_controller__admin_conf_owner` | `root` | Owner of the admin configuration directory |
| `bootstrap_kubernetes_controller__admin_conf_group` | `root` | Group of the admin configuration directory |
| `bootstrap_kubernetes_controller__admin_api_endpoint_host` | `{{ ansible_facts['default_ipv4']['address'] }}` | Admin API endpoint host for Kubernetes |
| `bootstrap_kubernetes_controller__admin_api_endpoint_port` | `6443` | Admin API endpoint port for Kubernetes |
| `bootstrap_kubernetes_controller__apiserver_audit_log_dir` | `{{ bootstrap_kubernetes_controller__log_base_dir }}/kube-apiserver` | Directory to store API server audit logs |
| `bootstrap_kubernetes_controller__apiserver_conf_dir` | `{{ bootstrap_kubernetes_controller__conf_dir }}/kube-apiserver` | Directory to store API server configuration files |
| `bootstrap_kubernetes_controller__apiserver_plugins` | List of API server plugins | List of plugins to enable in the API server (e.g., `["authentication", "authorization"]`) |
| `bootstrap_kubernetes_controller__apiserver_settings` | Various settings for the API server | Various settings for the API server (e.g., `{"timeout": 30, "maxRequestSize": "10Mi"}`) |

## Usage

To use the `bootstrap_kubernetes_controller` role, include it in your playbook and set the necessary variables:

```yaml
---
- hosts: kubernetes_controllers
  roles:
    - role: bootstrap_kubernetes_controller
      vars:
        bootstrap_kubernetes_controller__release: "1.33.4"
        bootstrap_kubernetes_controller__interface: "eth0"
        bootstrap_kubernetes_controller__run_as_user: "kubernetes"
        bootstrap_kubernetes_controller__run_as_group: "kubernetes"
        bootstrap_kubernetes_controller__api_endpoint_host: "{{ ansible_facts['default_ipv4']['address'] }}"
        bootstrap_kubernetes_controller__api_endpoint_port: 6443
        bootstrap_kubernetes_controller__log_base_dir: "/var/log/kubernetes"
        bootstrap_kubernetes_controller__etcd_client_port: 2379
        bootstrap_kubernetes_controller__etcd_interface: "eth0"
        bootstrap_kubernetes_controller__apiserver_plugins:
          - "authentication"
          - "authorization"
        bootstrap_kubernetes_controller__apiserver_settings:
          timeout: 30
          maxRequestSize: "10Mi"
```

## Dependencies

This role depends on the following Ansible collections:

- `ansible.posix`
- `kubernetes.core`

## Best Practices

1. **User and Group Management**: Ensure that the Kubernetes user and group are properly configured with the correct permissions. Use system users and groups for Kubernetes components.
2. **Directory Structure**: Maintain a clean and organized directory structure for configuration files, logs, and binaries. Use appropriate permissions for sensitive directories.
3. **Security**: Use appropriate permissions for sensitive files and directories, especially those related to PKI and configuration files. Regularly rotate certificates and keys.
4. **Logging**: Ensure that log files are properly configured and monitored. Set appropriate log rotation policies to prevent disk space issues.
5. **Configuration Management**: Regularly review and update configuration settings to align with best practices and security guidelines. Use configuration management tools to maintain consistency across environments.
6. **High Availability**: For production environments, consider setting up multiple controller nodes to ensure high availability of the Kubernetes control plane.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_kubernetes_controller/defaults/main.yml)
- [tasks/kube-admin-user.yml](../../roles/bootstrap_kubernetes_controller/tasks/kube-admin-user.yml)
- [tasks/kube-controller-manager.yml](../../roles/bootstrap_kubernetes_controller/tasks/kube-controller-manager.yml)
- [tasks/kube-scheduler.yml](../../roles/bootstrap_kubernetes_controller/tasks/kube-scheduler.yml)
- [tasks/main.yml](../../roles/bootstrap_kubernetes_controller/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_kubernetes_controller/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_kubernetes_controller/handlers/main.yml)