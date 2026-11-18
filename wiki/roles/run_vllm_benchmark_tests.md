---
title: "Run VLLM Benchmark Tests Role"
role: roles/run_vllm_benchmark_tests
category: Roles
type: ansible-role
tags: [ansible, role, run_vllm_benchmark_tests]
---

# Run VLLM Benchmark Tests

This Ansible role is designed to run benchmark tests for VLLM (Virtual Large Language Models) using various configurations. It supports running tests in different environments, including native, Docker, and Docker Swarm. The role allows for flexible configuration of benchmark profiles, model parameters, and execution environments.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `run_vllm_benchmark_tests__runtime` | `"native"` | Specifies the runtime environment for running the benchmarks (native, docker, or swarm). |
| `run_vllm_benchmark_tests__docker_stack_name` | `"llm"` | Name of the Docker stack when using Docker Swarm. |
| `run_vllm_benchmark_tests__service_name` | `"vllm-execution"` | Name of the service within the Docker stack. |
| `run_vllm_benchmark_tests__container_name` | `"vllm-execution"` | Name of the Docker container. |
| `run_vllm_benchmark_tests__container_data_dir` | `"/data"` | Data directory inside the container. |
| `run_vllm_benchmark_tests__model_name` | `"nemotron-lightning"` | Name of the model to be benchmarked. |
| `run_vllm_benchmark_tests__tokenizer` | `"nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4"` | Tokenizer to be used with the model. |
| `run_vllm_benchmark_tests__base_url` | `"http://localhost:8000"` | Base URL for the VLLM service. |
| `run_vllm_benchmark_tests__endpoint` | `"/v1/chat/completions"` | API endpoint for the VLLM service. |
| `run_vllm_benchmark_tests__api_key` | `""` | API key for authentication (if required). |
| `run_vllm_benchmark_tests__remote_results_dir` | `"/tmp/vllm_benchmark_results"` | Directory on the remote host to store benchmark results. |
| `run_vllm_benchmark_tests__fetch_results` | `false` | Whether to fetch results from the remote host to the local machine. |
| `run_vllm_benchmark_tests__local_results_dir` | `"{{ playbook_dir }}/benchmark_results/{{ inventory_hostname }}"` | Local directory to store fetched benchmark results. |
| `run_vllm_benchmark_tests__profiles` | See defaults/main.yml | Dictionary of benchmark profiles with various configurations. |

## Tags
- ansible
- role
- run_vllm_benchmark_tests

## Usage

To use this role, include it in your playbook and set the desired variables. Here is an example playbook:

```yaml
---
- hosts: localhost
  roles:
    - role: run_vllm_benchmark_tests
      vars:
        run_vllm_benchmark_tests__runtime: "docker"
        run_vllm_benchmark_tests__container_name: "my-vllm-container"
        run_vllm_benchmark_tests__model_name: "my-model"
        run_vllm_benchmark_tests__profiles:
          custom_profile:
            dataset_name: "custom-dataset"
            num_prompts: 50
            random_input_len: 1024
            random_output_len: 2048
            request_rate: "10"
            max_concurrency: 16
```

## Dependencies

This role does not have any external dependencies. However, it assumes that Docker and Docker Swarm are installed and configured correctly on the target system if using those runtimes.

## Best Practices

1. **Environment Configuration**: Ensure that the runtime environment (native, Docker, or Docker Swarm) is correctly set up and that the necessary services are running.
2. **Model and Tokenizer Selection**: Choose the appropriate model and tokenizer for your benchmarking needs.
3. **Profile Customization**: Customize the benchmark profiles to match your specific use case and performance requirements.
4. **Resource Management**: Monitor resource usage during benchmarking to ensure that the system is not overloaded.

## Backlinks
- [defaults/main.yml](../../roles/run_vllm_benchmark_tests/defaults/main.yml)
- [tasks/main.yml](../../roles/run_vllm_benchmark_tests/tasks/main.yml)