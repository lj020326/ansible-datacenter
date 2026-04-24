---
title: "Ansible Role for Deploying AIBrix on Kubernetes"
original_role: bootstrap_aibrix
category: Ansible Roles
type: Documentation
tags: kubernetes, llm, ai, ml, containers, vllm, aibrix
---

## Summary

The `bootstrap_aibrix` Ansible role is designed to deploy and configure AIBrix on a Kubernetes cluster. AIBrix is a container management solution for Large Language Models (LLMs), providing scalable and efficient deployment of AI models in production environments.

## Variables

The following variables can be customized in the `defaults/main.yml` file:

- **Version Configuration:**
  - `bootstrap_aibrix__version`: Specifies the version of AIBrix to deploy.
  - `bootstrap_aibrix__dependency_namespaces`: Lists namespaces where dependencies are installed.

- **Gateway Configuration:**
  - `bootstrap_aibrix__gateway_replicas`, `bootstrap_aibrix__gateway_cpu_request`, `bootstrap_aibrix__gateway_memory_request`, `bootstrap_aibrix__gateway_cpu_limit`, `bootstrap_aibrix__gateway_memory_limit`: Configure the gateway deployment's resource requests and limits.

- **Autoscaling Configuration:**
  - `bootstrap_aibrix__autoscaling_enabled`, `bootstrap_aibrix__autoscaling_min_replicas`, `bootstrap_aibrix__autoscaling_max_replicas`, `bootstrap_aibrix__autoscaling_target_cpu`: Enable or configure autoscaling for the gateway deployment.

- **Runtime Configuration:**
  - `bootstrap_aibrix__runtime_backend`, `bootstrap_aibrix__model_cache_enabled`, `bootstrap_aibrix__model_cache_size`, `bootstrap_aibrix__distributed_inference_enabled`, `bootstrap_aibrix__distributed_strategy`, `bootstrap_aibrix__kv_cache_enabled`, `bootstrap_aibrix__kv_cache_distributed`: Configure the runtime backend and caching strategies.

- **GPU Configuration:**
  - `bootstrap_aibrix__gpu_enabled`, `bootstrap_aibrix__gpu_type`, `bootstrap_aibrix__gpu_count`, `bootstrap_aibrix__gpu_failure_detection_enabled`, `bootstrap_aibrix__gpu_check_interval`: Enable or configure GPU usage and failure detection.

- **Monitoring Configuration:**
  - `bootstrap_aibrix__monitoring_enabled`: Enable monitoring for AIBrix components.

- **Ingress Configuration:**
  - `bootstrap_aibrix__ingress_enabled`, `bootstrap_aibrix__domain`, `bootstrap_aibrix__cert_issuer`: Configure ingress settings and SSL certificates.

- **Security Configuration:**
  - `bootstrap_aibrix__rbac_enabled`, `bootstrap_aibrix__network_policies_enabled`: Enable Role-Based Access Control (RBAC) and network policies for security.

[View `defaults/main.yml`](roles/bootstrap_aibrix/defaults/main.yml)

## Usage

To use the `bootstrap_aibrix` role, include it in your Ansible playbook:

```yaml
- hosts: k8s_control_plane
  roles:
    - role: bootstrap_aibrix
      vars:
        bootstrap_aibrix__version: "v0.3.0"
```

Ensure that the Kubernetes control plane is accessible from the host running the Ansible playbook and that the necessary permissions are in place.

## Dependencies

- **Collections:**
  - `kubernetes.core`: Required for interacting with Kubernetes resources.

[View `meta/main.yml`](roles/bootstrap_aibrix/meta/main.yml)

## Tags

The role uses tags to allow selective execution of tasks:

- `aibrix-deployment`: Deploys AIBrix components.
- `aibrix-dependencies`: Installs AIBrix dependencies.
- `aibrix-config`: Configures AIBrix settings.

To run specific tagged tasks, use the `--tags` option with Ansible:

```bash
ansible-playbook -i inventory playbook.yml --tags aibrix-deployment
```

## Key Features:

- **Complete Installation Process**: Installs both AIBrix dependencies and core components using the stable v0.3.0 release
- **Core Components**:

    **Gateway and Routing**: Manages traffic across multiple LLM models and replicas
    **Runtime Management**: Handles model loading, caching, and execution
    **Autoscaling**: Dynamically scales based on demand
    **Distributed Inference**: Supports multi-node LLM deployment
    **GPU Management**: Includes GPU failure detection and resource allocation

- **Configuration Options**:

  * Customizable resource limits and requests
  * Autoscaling parameters (min/max replicas, CPU targets)
  * GPU configuration (type, count, failure detection)
  * Model caching and distributed KV cache settings
  * Monitoring and ingress setup

- **Production-Ready Features**:

  * Health checks and readiness probes
  * Prometheus monitoring integration
  * Ingress configuration with TLS support
  * RBAC and network policies support
  * Rolling update capabilities

## Best Practices

- **Version Control:** Always specify a version for AIBrix to ensure consistency across deployments.
- **Resource Management:** Configure resource requests and limits based on the expected load and available resources in your Kubernetes cluster.
- **Security:** Enable RBAC and network policies to secure your deployment.

## Molecule Tests

Molecule tests are not included in this role. However, it is recommended to create test scenarios using Molecule to validate the role's functionality across different environments.

## Related Roles

- [kubernetes.core](https://galaxy.ansible.com/kubernetes/core): Provides modules for managing Kubernetes resources.
- [community.general](https://galaxy.ansible.com/community/general): Offers a wide range of general-purpose Ansible modules.

## Backlinks

- [defaults/main.yml](roles/bootstrap_aibrix/defaults/main.yml)
- [tasks/main.yml](roles/bootstrap_aibrix/tasks/main.yml)
- [meta/main.yml](roles/bootstrap_aibrix/meta/main.yml)
- [handlers/main.yml](roles/bootstrap_aibrix/handlers/main.yml)

## References

- https://github.com/vllm-project/aibrix
