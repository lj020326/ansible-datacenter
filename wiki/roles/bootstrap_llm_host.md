---
title: "bootstrap_llm_host Role Documentation"
role: bootstrap_llm_host
category: Ansible Roles
type: Configuration
tags: [llm, ollama, llama_cpp, webui, proxy, firewall]
---

## Summary

The `bootstrap_llm_host` role is designed to automate the setup of a Large Language Model (LLM) server. It handles the installation and configuration of necessary components such as GPU drivers, Ollama API, llama.cpp server, WebUIs, reverse proxies (Nginx or Traefik), and firewall rules. The role ensures that all services are properly installed, configured, and running on the target host.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_llm_host__install_gpu_drivers` | `true` | Whether to install GPU drivers for NVIDIA hardware. |
| `bootstrap_llm_host__install_ollama` | `true` | Whether to install the Ollama API. |
| `bootstrap_llm_host__install_ollama_webui` | `false` | Whether to install the Ollama WebUI. |
| `bootstrap_llm_host__install_open_webui` | `true` | Whether to install the Open WebUI for LLMs. |
| `bootstrap_llm_host__configure_firewall` | `true` | Whether to configure firewall rules for the services. |
| `bootstrap_llm_host__download_models` | `true` | Whether to download pre-trained models. |
| `bootstrap_llm_host__configure_proxy` | `true` | Whether to configure a reverse proxy (Nginx or Traefik). |
| `bootstrap_llm_host__ollama_runtime` | `"native"` | The runtime environment for Ollama (`native`, `docker`, `swarm`). |
| `bootstrap_llm_host__ollama_container_name` | `"ollama"` | The name of the Docker container for Ollama. |
| `bootstrap_llm_host__ollama_host_volume_path` | `"/home/docker/ollama/data"` | Host path for Ollama data volume. |
| `bootstrap_llm_host__docker_compose_project_name` | `"docker"` | Name of the Docker Compose project. |
| `bootstrap_llm_host__ollama_service_name` | `"ollama"` | Service name for Ollama in Docker/Swarm. |
| `bootstrap_llm_host__docker_stack_name` | `"docker_stack"` | Stack name for Docker Swarm. |
| `bootstrap_llm_host__proxy_port` | `"80"` | Port for the reverse proxy. |
| `bootstrap_llm_host__proxy_type` | `traefik` | Type of reverse proxy to use (`nginx`, `traefik`). |
| `bootstrap_llm_host__server_name` | `{{ ansible_facts['fqdn'] \| d(ansible_facts['hostname']) \| d(ansible_host) }}` | Server name for the services. |
| `bootstrap_llm_host__traefik_entrypoint` | `web` | Traefik entry point for routing. |
| `bootstrap_llm_host__traefik_config_path` | `"/etc/traefik/conf.d"` | Path to Traefik configuration files. |
| `bootstrap_llm_host__traefik_archive_url` | `"https://github.com/traefik/traefik/releases/download/v3.3.4/traefik_v3.3.4_linux_{{ 'amd64' if ansible_facts['architecture'] == 'x86_64' else 'arm64' }}.tar.gz"` | URL to download Traefik binary. |
| `bootstrap_llm_host__ollama_user` | `ollama` | User for running Ollama services. |
| `bootstrap_llm_host__webui_user` | `webui` | User for running WebUI services. |
| `bootstrap_llm_host__ollama_home_dir` | `"/home/{{ bootstrap_llm_host__ollama_user }}"` | Home directory for the Ollama user. |
| `bootstrap_llm_host__webui_home_dir` | `"/home/{{ bootstrap_llm_host__webui_user }}"` | Home directory for the WebUI user. |
| `bootstrap_llm_host__ollama_port` | `"11434"` | Port for Ollama API. |
| `bootstrap_llm_host__webui_port` | `"8080"` | Port for WebUI. |
| `bootstrap_llm_host__model_storage_dir` | `"{{ bootstrap_llm_host__ollama_home_dir }}/.ollama/models"` | Directory to store models. |
| `bootstrap_llm_host__webui_venv_dir` | `"/home/{{ bootstrap_llm_host__webui_user }}/open-webui-venv"` | Virtual environment directory for WebUI. |
| `bootstrap_llm_host__webui_tmpdir` | `"/home/{{ bootstrap_llm_host__webui_user }}/tmp"` | Temporary directory for WebUI operations. |
| `bootstrap_llm_host__webui_secret_key` | `"{{ lookup('community.general.random_string', length=32) }}"` | Secret key for WebUI authentication. |
| `bootstrap_llm_host__model_download_timeout` | `3600` | Timeout for model downloads in seconds. |
| `bootstrap_llm_host__service_timeout` | `300` | Timeout for services to become ready in seconds. |
| `bootstrap_llm_host__models` | `[]` | List of models to download and configure. |
| `bootstrap_llm_host__system_packages` | `- curl<br>- wget<br>- git<br>- python3<br>- python3-pip<br>- python3-venv<br>- nodejs<br>- npm<br>- nginx` | System packages to install. |
| `bootstrap_llm_host__nvidia_package_dist` | `"{{ ansible_facts['distribution'] \| lower }}{{ ansible_facts['distribution_version'] \| replace('.', '') }}"` | Distribution string for NVIDIA package. |
| `bootstrap_llm_host__nvidia_package_version` | `1.1-1` | Version of the NVIDIA package. |
| `bootstrap_llm_host__nvidia_package` | `"cuda-keyring_{{ bootstrap_llm_host__nvidia_package_version }}_all.deb"` | Name of the NVIDIA package. |
| `bootstrap_llm_host__nvidia_package_url` | `"https://developer.download.nvidia.com/compute/cuda/repos/{{ bootstrap_llm_host__nvidia_package_dist }}/x86_64/{{ bootstrap_llm_host__nvidia_package }}"` | URL to download the NVIDIA package. |
| `bootstrap_llm_host__install_llama_cpp` | `false` | Whether to install llama.cpp server. |
| `bootstrap_llm_host__llama_cpp_runtime` | `"{{ bootstrap_llm_host__ollama_runtime }}"` | Runtime environment for llama.cpp (`native`, `docker`, `swarm`). |
| `bootstrap_llm_host__llama_cpp_container_name` | `"llama-cpp"` | Name of the Docker container for llama.cpp. |
| `bootstrap_llm_host__llama_cpp_service_name` | `"llama-cpp"` | Service name for llama.cpp in Docker/Swarm. |
| `bootstrap_llm_host__llama_cpp_host_volume_path` | `"/home/container-user/docker/llama-cpp/models"` | Host path for llama.cpp data volume. |
| `bootstrap_llm_host__llama_cpp_port` | `"8081"` | Port for llama.cpp OpenAI-compatible API. |
| `bootstrap_llm_host__llama_cpp_models` | `- repo: unsloth/gemma-4-E2B-it-GGUF<br>  filename: gemma-4-E2B-it-Q5_K_M.gguf<br>- repo: unsloth/gemma-4-31B-it-GGUF<br>  filename: gemma-4-31B-it-Q5_K_M.gguf` | List of GGUF models to download for llama.cpp. |
| `bootstrap_llm_host__llama_cpp_ctx_size` | `32768` | Context size for llama.cpp. |
| `bootstrap_llm_host__llama_cpp_n_gpu_layers` | `99` | Number of GPU layers for llama.cpp. |
| `bootstrap_llm_host__llama_cpp_temp` | `0.7` | Temperature parameter for llama.cpp. |
| `bootstrap_llm_host__llama_cpp_flash_attn` | `1` | Enable flash attention in llama.cpp. |

## Usage

To use the `bootstrap_llm_host` role, include it in your Ansible playbook and provide any necessary variables as needed. Here is an example playbook:

```yaml
---
- name: Bootstrap LLM Host
  hosts: llm_servers
  become: true
  roles:
    - role: bootstrap_llm_host
      vars:
        bootstrap_llm_host__install_gpu_drivers: true
        bootstrap_llm_host__install_ollama: true
        bootstrap_llm_host__install_open_webui: true
        bootstrap_llm_host__configure_firewall: true
        bootstrap_llm_host__download_models: true
        bootstrap_llm_host__models:
          - name: "gemma-4-E2B-it-GGUF"
            type: pull
```

## Dependencies

The `bootstrap_llm_host` role depends on the following:

- The `ansible.builtin` module for core Ansible tasks.
- The `community.general.random_string` lookup plugin for generating a random secret key.
- The `community.general.npm` module for managing Node.js packages.

Ensure these dependencies are available in your Ansible environment.

## Best Practices

1. **Backup Configuration Files**: Always back up existing configuration files before applying changes.
2. **Test Changes**: Use Molecule or another testing framework to test the role in a controlled environment.
3. **Monitor Services**: After deployment, monitor the services to ensure they are running as expected and logs are being generated correctly.
4. **Security**: Ensure that all services are properly secured, especially when exposing them over the network.

## Molecule Tests

This role does not include specific Molecule tests at this time. However, it is recommended to create Molecule scenarios to test different configurations and ensure the role behaves as expected in various environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_llm_host/defaults/main.yml)
- [tasks/dependencies.yml](../../roles/bootstrap_llm_host/tasks/dependencies.yml)
- [tasks/firewall.yml](../../roles/bootstrap_llm_host/tasks/firewall.yml)
- [tasks/llama_cpp.yml](../../roles/bootstrap_llm_host/tasks/llama_cpp.yml)
- [tasks/main.yml](../../roles/bootstrap_llm_host/tasks/main.yml)
- [tasks/models.yml](../../roles/bootstrap_llm_host/tasks/models.yml)
- [tasks/ollama.yml](../../roles/bootstrap_llm_host/tasks/ollama.yml)
- [tasks/proxy.yml](../../roles/bootstrap_llm_host/tasks/proxy.yml)
- [tasks/webui.yml](../../roles/bootstrap_llm_host/tasks/webui.yml)
- [handlers/main.yml](../../roles/bootstrap_llm_host/handlers/main.yml)