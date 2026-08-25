# Ansible Role: `run_vllm_benchmark_tests`

An Ansible role designed to automate execution and collection of throughput, latency, and concurrency benchmark tests for **vLLM** instances across standalone Docker containers, Docker Swarm services, or native bare-metal host deployments.

It utilizes vLLM's official benchmark entrypoint (`vllm.entrypoints.openai.benchmarks.benchmark_serving`) to evaluate key operational metrics:
* **Time-to-First-Token (TTFT)** (Critical for reasoning/long-context prefill)
* **Time-per-Output-Token (TPOT)** (Critical for interactive code-completion)
* **Aggregate Token Throughput** (`tokens/sec`)

---

## Features

- **Multi-Runtime Support:** Seamlessly resolves target container IDs across standard Docker, single/multi-node Docker Swarm stacks, or native host runtimes.
- **Dynamic API Health Checks:** Uses pure Python HTTP libraries inside the target environment to verify `http://<base-url>/health` without requiring `curl` or `jq` dependencies.
- **Workload Profile Matrix:** Pre-configured for both continuous generation workloads (**Coding**) and extended context/chain-of-thought workloads (**Reasoning**).
- **Result Fetching:** Automatically retrieves JSON benchmark result files from target nodes back to the Ansible control host.

---

## Requirements

- Python 3.8+ on the target host/container.
- Access to the target Docker socket (`/var/run/docker.sock`) if running in `docker` or `swarm` mode.
- A running vLLM server instance accepting requests at the configured base URL.

---

## Role Variables

Available variables are listed below along with default values (see `defaults/main.yml`):

### Target Runtime & Identifiers

| Variable | Default | Description |
| :--- | :--- | :--- |
| `run_vllm_benchmark_tests__runtime` | `"swarm"` | Target runtime environment: `swarm`, `docker`, or `native`. |
| `run_vllm_benchmark_tests__container_name` | `"vllm"` | Container name used when runtime is `docker`. |
| `run_vllm_benchmark_tests__docker_stack_name` | `"llm"` | Swarm stack name used to build service filter queries. |
| `run_vllm_benchmark_tests__service_name` | `"vllm-execution"` | Swarm service name used to locate running tasks. |

### vLLM Server Configuration

| Variable | Default | Description |
| :--- | :--- | :--- |
| `run_vllm_benchmark_tests__model_name` | `"default"` | Name of the model served by the target vLLM engine. |
| `run_vllm_benchmark_tests__base_url` | `"http://localhost:8000"` | Base URL where vLLM listens inside the container/host. |
| `run_vllm_benchmark_tests__api_key` | `""` | Optional API key if `VLLM_API_KEY` authentication is enabled. |

### Output Management

| Variable | Default | Description |
| :--- | :--- | :--- |
| `run_vllm_benchmark_tests__remote_results_dir` | `"/tmp/vllm_benchmark_results"` | Directory on target where result JSONs are saved. |
| `run_vllm_benchmark_tests__fetch_results` | `true` | Whether to pull result JSONs back to the control node. |
| `run_vllm_benchmark_tests__local_results_dir` | `"{{ playbook_dir }}/benchmark_results/{{ inventory_hostname }}"` | Local destination path on the control node. |

### Benchmark Profiles Matrix

The `run_vllm_benchmark_tests__profiles` dictionary defines the execution matrix. Each profile runs a separate iteration of `benchmark_serving.py`.

```yaml
run_vllm_benchmark_tests__profiles:
  coding_burst:
    dataset_name: "random"
    num_prompts: 100
    random_input_len: 512
    random_output_len: 2048
    request_rate: "inf"
  coding_qps5:
    dataset_name: "random"
    num_prompts: 100
    random_input_len: 512
    random_output_len: 2048
    request_rate: "5"
  reasoning_burst:
    dataset_name: "random"
    num_prompts: 50
    random_input_len: 2048
    random_output_len: 4096
    request_rate: "inf"
  reasoning_qps2:
    dataset_name: "random"
    num_prompts: 50
    random_input_len: 2048
    random_output_len: 4096
    request_rate: "2"
```

---

## Dependencies

None.

---

## Example Playbook

```yaml
- name: Execute vLLM Throughput & Latency Benchmarks
  hosts: llm_gpu_hosts
  gather_facts: true
  vars:
    run_vllm_benchmark_tests__runtime: "swarm"
    run_vllm_benchmark_tests__docker_stack_name: "llm-stack"
    run_vllm_benchmark_tests__service_name: "vllm-execution"
    run_vllm_benchmark_tests__model_name: "DeepSeek-R1-Distill-Llama-70B"
    run_vllm_benchmark_tests__api_key: "your-vllm-api-key"

  roles:
    - role: run_vllm_benchmark_tests
```

---

## Output Metrics Analysis

Once playbooks complete execution, fetched JSON files located in `benchmark_results/<hostname>/` contain structured performance data including:

- **`completed`**: Total successfully processed requests.
- **`request_throughput`**: Handled requests per second (QPS).
- **`output_throughput`**: Generated output tokens per second across all users.
- **`mean_ttft_ms` / `p99_ttft_ms`**: Time-to-First-Token metrics (Prefill performance).
- **`mean_tpot_ms` / `p99_tpot_ms`**: Time-per-Output-Token metrics (Decode performance).

---

## License

MIT / BSD
