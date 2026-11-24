---
title: "Bootstrap AIBrix Role"
role: bootstrap_aibrix
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_aibrix]
---

# Bootstrap AIBrix Role Documentation

The `bootstrap_aibrix` Ansible role is designed to deploy AIBrix on a Kubernetes cluster for managing LLM (Large Language Model) containers. This role automates the installation of AIBrix dependencies, core components, and configuration, ensuring a seamless setup process.

## Variables

The following table lists the variables used by this role, along with their default values and descriptions:

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_aibrix__version` | `"v0.3.0"` | The version of AIBrix to install. |
| `bootstrap_aibrix__dependency_namespaces` | `["kube-system", "aibrix-system", "ray-system"]` | Namespaces where AIBrix dependencies will be installed. |
| `bootstrap_aibrix__gateway_replicas` | `2` | Number of replicas for the AIBrix gateway. |
| `bootstrap_aibrix__gateway_cpu_request` | `"500m"` | CPU request for the AIBrix gateway. |
| `bootstrap_aibrix__gateway_memory_request` | `"1Gi"` | Memory request for the AIBrix gateway. |
| `bootstrap_aibrix__gateway_cpu_limit` | `"2"` | CPU limit for the AIBrix gateway. |
| `bootstrap_aibrix__gateway_memory_limit` | `"4Gi"` | Memory limit for the AIBrix gateway. |
| `bootstrap_aibrix__autoscaling_enabled` | `true` | Whether to enable autoscaling for the AIBrix gateway. |
| `bootstrap_aibrix__autoscaling_min_replicas` | `1` | Minimum number of replicas for autoscaling. |
| `bootstrap_aibrix__autoscaling_max_replicas` | `10` | Maximum number of replicas for autoscaling. |
| `bootstrap_aibrix__autoscaling_target_cpu` | `70` | Target CPU utilization percentage for autoscaling. |
| `bootstrap_aibrix__runtime_backend` | `"vllm"` | Runtime backend for AIBrix. |
| `bootstrap_aibrix__model_cache_enabled` | `true` | Whether to enable model caching. |
| `bootstrap_aibrix__model_cache_size` | `"50Gi"` | Size of the model cache. |
| `bootstrap_aibrix__distributed_inference_enabled` | `true` | Whether to enable distributed inference. |
| `bootstrap_aibrix__distributed_strategy` | `"ray"` | Strategy for distributed inference. |
| `bootstrap_aibrix__kv_cache_enabled` | `true` | Whether to enable KV cache. |
| `bootstrap_aibrix__kv_cache_distributed` | `true` | Whether to distribute the KV cache. |
| `bootstrap_aibrix__gpu_enabled` | `true` | Whether to enable GPU support. |
| `bootstrap_aibrix__gpu_type` | `"v100"` | Type of GPU to use (options: v100, a100, h100, t4). |
| `bootstrap_aibrix__gpu_count` | `1` | Number of GPUs to use. |
| `bootstrap_aibrix__gpu_failure_detection_enabled` | `true` | Whether to enable GPU failure detection. |
| `bootstrap_aibrix__gpu_check_interval` | `"30s"` | Interval for GPU failure detection checks. |
| `bootstrap_aibrix__monitoring_enabled` | `true` | Whether to enable monitoring for AIBrix. |
| `bootstrap_aibrix__ingress_enabled` | `false` | Whether to enable ingress for AIBrix. |
| `bootstrap_aibrix__domain` | `"aibrix.example.com"` | Domain name for AIBrix ingress. |
| `bootstrap_aibrix__cert_issuer` | `"letsencrypt-prod"` | Certificate issuer for AIBrix ingress. |
| `bootstrap_aibrix__rbac_enabled` | `true` | Whether to enable RBAC for AIBrix. |
| `bootstrap_aibrix__network_policies_enabled` | `true` | Whether to enable network policies for AIBrix. |

## Usage

To use this role, include it in your playbook and set the desired variables:

```yaml
---
- hosts: kubernetes
  roles:
    - role: bootstrap_aibrix
      vars:
        bootstrap_aibrix__version: "v0.3.0"
        bootstrap_aibrix__gateway_replicas: 3
        bootstrap_aibrix__dependency_namespaces:
          - kube-system
          - aibrix-system
          - ray-system
        bootstrap_aibrix__gateway_cpu_request: "750m"
        bootstrap_aibrix__gateway_memory_request: "2Gi"
        # Add other variables as needed
```

## Dependencies

This role requires the `kubernetes.core` collection to be installed. You can install it using the following command:

```bash
ansible-galaxy collection install kubernetes.core
```

## Best Practices

1. **Namespace Management**: Ensure that the namespaces specified in `bootstrap_aibrix__dependency_namespaces` exist before running the role. You can create them using the following command:

   ```yaml
   - name: Create required namespaces
     kubernetes.core.k8s:
       kind: Namespace
       api_version: v1
       name: "{{ item }}"
     loop: "{{ bootstrap_aibrix__dependency_namespaces }}"
   ```

2. **Resource Allocation**: Adjust the resource requests and limits (`bootstrap_aibrix__gateway_cpu_request`, `bootstrap_aibrix__gateway_memory_request`, etc.) based on your cluster's capacity and workload requirements. Use tools like `kubectl top nodes` to monitor resource usage.

3. **Autoscaling**: Enable autoscaling (`bootstrap_aibrix__autoscaling_enabled`) to handle varying workloads efficiently. Monitor the autoscaling behavior using `kubectl top pods` and adjust the `bootstrap_aibrix__autoscaling_target_cpu` value as needed.

4. **GPU Configuration**: If using GPUs, ensure that the GPU type (`bootstrap_aibrix__gpu_type`) and count (`bootstrap_aibrix__gpu_count`) match your cluster's GPU configuration. Verify GPU availability using `nvidia-smi` on your nodes.

5. **Monitoring**: Enable monitoring (`bootstrap_aibrix__monitoring_enabled`) to keep track of AIBrix's performance and health. Integrate with your existing monitoring stack (e.g., Prometheus, Grafana) for centralized visibility.

## Tasks and Handlers

The role performs the following tasks:

- Installs AIBrix dependencies in the specified namespaces
- Deploys the AIBrix gateway with the configured resources
- Configures autoscaling for the AIBrix gateway
- Sets up distributed inference using the specified strategy
- Enables and configures GPU support if enabled
- Sets up monitoring and ingress if enabled

The role includes the following handlers:

- Restart AIBrix gateway: Restarts the AIBrix gateway pods
- Reload AIBrix configuration: Reloads the AIBrix configuration without restarting pods

## Prerequisites and Assumptions

- A functioning Kubernetes cluster with appropriate permissions
- The `kubernetes.core` Ansible collection installed
- Helm installed on the control node if using Helm charts
- GPU nodes properly configured if GPU support is enabled

## Troubleshooting

- If the AIBrix gateway pods are not starting, check the pod logs using `kubectl logs <pod-name> -n <namespace>` and look for any error messages.
- If autoscaling is not working as expected, verify that the Kubernetes Cluster Autoscaler is properly configured and that there are enough resources in the cluster.
- If GPU support is enabled but not working, check that the NVIDIA device plugin is installed and that the GPUs are visible to the pods.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_aibrix/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_aibrix/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_aibrix/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_aibrix/handlers/main.yml)