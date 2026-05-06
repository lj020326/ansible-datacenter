---
title: "AIBrix Bootstrap Role Documentation"
role: bootstrap_aibrix
category: Ansible Roles
type: Kubernetes Deployment
tags: kubernetes, llm, ai, ml, containers, vllm, aibrix
---

## Summary

The `bootstrap_aibrix` Ansible role is designed to deploy AIBrix on a Kubernetes cluster for Large Language Model (LLM) container management. This role automates the setup of necessary namespaces, dependencies, and core components required by AIBrix, ensuring that all configurations are applied correctly.

## Variables

| Variable Name                              | Default Value          | Description                                                                 |
|--------------------------------------------|------------------------|-----------------------------------------------------------------------------|
| `bootstrap_aibrix__version`                | `"v0.3.0"`             | The version of AIBrix to deploy.                                            |
| `bootstrap_aibrix__dependency_namespaces`  | `["kube-system", "aibrix-system", "ray-system"]` | List of namespaces where dependencies are installed.                        |
| `bootstrap_aibrix__gateway_replicas`       | `2`                    | Number of replicas for the AIBrix gateway deployment.                       |
| `bootstrap_aibrix__gateway_cpu_request`    | `"500m"`               | CPU request per gateway pod.                                                |
| `bootstrap_aibrix__gateway_memory_request` | `"1Gi"`                | Memory request per gateway pod.                                             |
| `bootstrap_aibrix__gateway_cpu_limit`      | `"2"`                  | CPU limit per gateway pod.                                                  |
| `bootstrap_aibrix__gateway_memory_limit`   | `"4Gi"`                | Memory limit per gateway pod.                                               |
| `bootstrap_aibrix__autoscaling_enabled`    | `true`                 | Enable autoscaling for the AIBrix gateway deployment.                       |
| `bootstrap_aibrix__autoscaling_min_replicas` | `1`                  | Minimum number of replicas for autoscaling.                                 |
| `bootstrap_aibrix__autoscaling_max_replicas` | `10`                 | Maximum number of replicas for autoscaling.                                 |
| `bootstrap_aibrix__autoscaling_target_cpu` | `70`                   | Target CPU utilization percentage for autoscaling.                          |
| `bootstrap_aibrix__runtime_backend`        | `"vllm"`               | Backend runtime to use (e.g., vLLM).                                        |
| `bootstrap_aibrix__model_cache_enabled`    | `true`                 | Enable model caching.                                                       |
| `bootstrap_aibrix__model_cache_size`       | `"50Gi"`               | Size of the model cache.                                                    |
| `bootstrap_aibrix__distributed_inference_enabled` | `true`          | Enable distributed inference.                                               |
| `bootstrap_aibrix__distributed_strategy`   | `"ray"`                | Strategy for distributed inference (e.g., Ray).                             |
| `bootstrap_aibrix__kv_cache_enabled`       | `true`                 | Enable key-value cache.                                                     |
| `bootstrap_aibrix__kv_cache_distributed`   | `true`                 | Enable distributed key-value cache.                                         |
| `bootstrap_aibrix__gpu_enabled`            | `true`                 | Enable GPU support.                                                         |
| `bootstrap_aibrix__gpu_type`               | `"v100"`               | Type of GPU to use (e.g., v100, a100, h100, t4).                          |
| `bootstrap_aibrix__gpu_count`              | `1`                    | Number of GPUs per pod.                                                     |
| `bootstrap_aibrix__gpu_failure_detection_enabled` | `true`          | Enable GPU failure detection.                                               |
| `bootstrap_aibrix__gpu_check_interval`     | `"30s"`                | Interval for GPU health checks.                                             |
| `bootstrap_aibrix__monitoring_enabled`     | `true`                 | Enable monitoring for AIBrix components.                                    |
| `bootstrap_aibrix__ingress_enabled`        | `false`                | Enable ingress resource creation.                                           |
| `bootstrap_aibrix__domain`                 | `"aibrix.example.com"` | Domain name for the ingress resource (if enabled).                          |
| `bootstrap_aibrix__cert_issuer`            | `"letsencrypt-prod"`   | Certificate issuer for TLS (if ingress is enabled).                       |
| `bootstrap_aibrix__rbac_enabled`           | `true`                 | Enable Role-Based Access Control (RBAC) for AIBrix components.              |
| `bootstrap_aibrix__network_policies_enabled` | `true`               | Enable network policies to control traffic between pods.                    |

## Usage

To use the `bootstrap_aibrix` role, include it in your Ansible playbook and specify any required variables as needed:

```yaml
- hosts: k8s_control_plane
  roles:
    - role: bootstrap_aibrix
      vars:
        bootstrap_aibrix__version: "v0.3.0"
        bootstrap_aibrix__ingress_enabled: true
```

## Dependencies

This role requires the following Ansible collections:

- `kubernetes.core`

Ensure that these collections are installed in your environment before running the playbook.

```bash
ansible-galaxy collection install kubernetes.core
```

## Tags

The following tags can be used to control which parts of the role are executed:

- `aibrix-deploy`: Deploy AIBrix core components.
- `aibrix-dependencies`: Install AIBrix dependencies.
- `aibrix-config`: Apply AIBrix configuration.

Example usage with tags:

```bash
ansible-playbook -i inventory playbook.yml --tags aibrix-deploy
```

## Best Practices

1. **Version Control**: Always specify the version of AIBrix to deploy using the `bootstrap_aibrix__version` variable.
2. **Resource Management**: Adjust resource requests and limits based on your cluster's capacity and workload requirements.
3. **Security**: Enable RBAC and network policies to secure your deployment.
4. **Monitoring**: Keep monitoring enabled to track the health and performance of AIBrix components.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, ensure you have Molecule installed and configured:

```bash
pip install molecule ansible-lint yamllint
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_aibrix/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_aibrix/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_aibrix/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_aibrix/handlers/main.yml)