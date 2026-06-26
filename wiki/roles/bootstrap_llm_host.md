---
title: Bootstrap LLM Host Role Documentation
role: bootstrap_llm_host
category: Ansible Roles
type: Infrastructure Setup

## Summary
The `bootstrap_llm_host` role is designed to automate the setup of a Large Language Model (LLM) server. It handles various tasks including configuring firewalls, setting up proxies, downloading models, installing GPU drivers, and deploying different LLM services such as Ollama, NemoClaw, and llama.cpp. This role ensures that all necessary components are installed and configured to enable efficient operation of LLMs on the host.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_llm_host__configure_firewall` | `true` | Whether to configure firewall rules for required ports. |
| `bootstrap_llm_host__configure_proxy` | `false` | Whether to set up a reverse proxy (Nginx or Traefik). |
| `bootstrap_llm_host__download_models` | `true` | Whether to download specified models. |
| `bootstrap_llm_host__install_gpu_drivers` | `true` | Whether to install GPU drivers for NVIDIA hardware. |
| `bootstrap_llm_host__install_nemoclaw` | `false` | Whether to install NemoClaw, a secure application and sandboxing tool. |
| `bootstrap_llm_host__install_ollama` | `true` | Whether to install Ollama, an API for managing LLMs. |
| `bootstrap_llm_host__install_ollama_webui` | `false` | Whether to install the Ollama Web UI. |
| `bootstrap_llm_host__install_open_webui` | `false` | Whether to install Open WebUI for LLM interaction. |
| `bootstrap_llm_host__ollama_runtime` | `"native"` | Runtime environment for Ollama (`native`, `docker`, or `swarm`). |
| `bootstrap_llm_host__ollama_container_name` | `"ollama"` | Name of the Docker container for Ollama. |
| `bootstrap_llm_host__ollama_host_volume_path` | `"/home/docker/ollama/data"` | Host path for Ollama data volume. |
| `bootstrap_llm_host__docker_compose_project_name` | `"docker"` | Project name for Docker Compose. |
| `bootstrap_llm_host__ollama_service_name` | `"ollama"` | Service name for Ollama in Docker Swarm. |
| `bootstrap_llm_host__docker_stack_name` | `"docker_stack"` | Stack name for Docker Swarm. |
| `bootstrap_llm_host__proxy_port` | `"80"` | Port number for the reverse proxy. |
| `bootstrap_llm_host__proxy_type` | `traefik` | Type of reverse proxy to use (`nginx` or `traefik`). |
| `bootstrap_llm_host__server_name` | `{{ ansible_facts['fqdn'] \| d(ansible_facts['hostname']) \| d(ansible_host) }}` | Server name for the reverse proxy configuration. |
| `bootstrap_llm_host__traefik_entrypoint` | `web` | Traefik entry point to use. |
| `bootstrap_llm_host__traefik_config_path` | `"/etc/traefik/conf.d"` | Path to Traefik configuration files. |
| `bootstrap_llm_host__traefik_archive_url` | `"https://github.com/traefik/traefik/releases/download/v3.3.4/traefik_v3.3.4_linux_{{ 'amd64' if ansible_facts['architecture'] == 'x86_64' else 'arm64' }}.tar.gz"` | URL to download the Traefik binary. |
| `bootstrap_llm_host__nginx_conf_path` | `"{{ __bootstrap_llm_host__nginx_conf_path \| d(__bootstrap_llm_host__nginx_conf_path_default) }}"` | Path to Nginx configuration files. |
| `bootstrap_llm_host__nginx_enabled_path` | `"{{ __bootstrap_llm_host__nginx_enabled_path \| d(__bootstrap_llm_host__nginx_enabled_path_default) }}"` | Path to enabled Nginx sites. |
| `bootstrap_llm_host__ollama_user` | `ollama` | Username for the Ollama service. |
| `bootstrap_llm_host__webui_user` | `webui` | Username for the WebUI services. |
| `bootstrap_llm_host__ollama_home_dir` | `"/home/{{ bootstrap_llm_host__ollama_user }}"` | Home directory for the Ollama user. |
| `bootstrap_llm_host__webui_home_dir` | `"/home/{{ bootstrap_llm_host__webui_user }}"` | Home directory for the WebUI users. |
| `bootstrap_llm_host__ollama_port` | `"11434"` | Port number for Ollama API. |
| `bootstrap_llm_host__webui_port` | `"8080"` | Port number for WebUI services. |
| `bootstrap_llm_host__model_storage_dir` | `"{{ bootstrap_llm_host__ollama_home_dir }}/.ollama/models"` | Directory to store LLM models. |
| `bootstrap_llm_host__webui_venv_dir` | `"/home/{{ bootstrap_llm_host__webui_user }}/open-webui-venv"` | Virtual environment directory for Open WebUI. |
| `bootstrap_llm_host__webui_tmpdir` | `"/home/{{ bootstrap_llm_host__webui_user }}/tmp"` | Temporary directory for WebUI operations. |
| `bootstrap_llm_host__webui_secret_key` | `"{{ lookup('community.general.random_string', length=32) }}"` | Secret key for WebUI services. |
| `bootstrap_llm_host__model_download_timeout` | `3600` | Timeout in seconds for model downloads. |
| `bootstrap_llm_host__service_timeout` | `300` | Timeout in seconds for service readiness checks. |
| `bootstrap_llm_host__models` | `[]` | List of models to download and configure. |
| `bootstrap_llm_host__system_packages` | <pre>\[<br>  "curl",<br>  "wget",<br>  "git",<br>  "python3",<br>  "python3-pip",<br>  "python3-venv",<br>  "nodejs",<br>  "npm",<br>  "nginx"<br>\]</pre> | List of system packages to install. |
| `bootstrap_llm_host__nvidia_package_dist` | `"{{ ansible_facts['distribution'] \| lower }}{{ ansible_facts['distribution_version'] \| replace('.', '') }}"` | Distribution identifier for NVIDIA package installation. |
| `bootstrap_llm_host__nvidia_package_version` | `1.1-1` | Version of the NVIDIA package to install. |
| `bootstrap_llm_host__nvidia_package` | `"cuda-keyring_{{ bootstrap_llm_host__nvidia_package_version }}_all.deb"` | Filename of the NVIDIA package. |
| `bootstrap_llm_host__nvidia_package_url` | `"https://developer.download.nvidia.com/compute/cuda/repos/{{ bootstrap_llm_host__nvidia_package_dist }}/x86_64/{{ bootstrap_llm_host__nvidia_package }}"` | URL to download the NVIDIA package. |
| `bootstrap_llm_host__install_llama_cpp` | `false` | Whether to install llama.cpp, a C++ implementation of LLaMA. |
| `bootstrap_llm_host__llama_cpp_runtime` | `"{{ bootstrap_llm_host__ollama_runtime }}"` | Runtime environment for llama.cpp (defaults to Ollama runtime). |
| `bootstrap_llm_host__llama_cpp_container_name` | `"llama-cpp"` | Name of the Docker container for llama.cpp. |
| `bootstrap_llm_host__llama_cpp_service_name` | `"llama-cpp"` | Service name for llama.cpp in Docker Swarm. |
| `bootstrap_llm_host__llama_cpp_host_volume_path` | `"/home/container-user/docker/llama-cpp/models"` | Host path for llama.cpp data volume. |
| `bootstrap_llm_host__llama_cpp_port` | `"8081"` | Port number for llama.cpp API. |
| `bootstrap_llm_host__llama_cpp_models` | <pre>\[<br>  { repo: "unsloth/gemma-4-E2B-it-GGUF", filename: "gemma-4-E2B-it-Q5_K_M.gguf" },<br>  { repo: "unsloth/gemma-4-31B-it-GGUF", filename: "gemma-4-31B-it-Q5_K_M.gguf" }<br>\]</pre> | List of GGUF models to download for llama.cpp. |
| `bootstrap_llm_host__llama_cpp_ctx_size` | `32768` | Context size for llama.cpp. |
| `bootstrap_llm_host__llama_cpp_n_gpu_layers` | `99` | Number of GPU layers for llama.cpp. |
| `bootstrap_llm_host__llama_cpp_temp` | `0.7` | Temperature setting for llama.cpp. |
| `bootstrap_llm_host__llama_cpp_flash_attn` | `1` | Whether to enable flash attention in llama.cpp. |
| `bootstrap_llm_host__nemoclaw_version` | `"latest"` | Version of NemoClaw to install. |
| `bootstrap_llm_host__nemoclaw_user` | `"nemoclaw"` | Username for the NemoClaw service. |
| `bootstrap_llm_host__nemoclaw_home_dir` | `"/home/{{ bootstrap_llm_host__nemoclaw_user }}"` | Home directory for the NemoClaw user. |
| `bootstrap_llm_host__nemoclaw_port` | `"9000"` | Port number for NemoClaw API. |
| `bootstrap_llm_host__nemoclaw_workspace_dir` | `"{{ bootstrap_llm_host__nemoclaw_home_dir }}/workspace"` | Workspace directory for NemoClaw. |
| `bootstrap_llm_host__nemoclaw_sandbox_root` | `"/var/lib/nemoclaw/sandboxes"` | Root directory for NemoClaw sandboxes. |
| `bootstrap_llm_host__nemoclaw_orchestration_model` | `"deepseek-r1:14b"` | Orchestration model for NemoClaw. |

## Usage

To use the `bootstrap_llm_host` role, include it in your playbook and configure the variables as needed. Below is an example of how to include this role in a playbook:

```yaml
---
- name: Bootstrap LLM Host
  hosts: llm_servers
  become: true
  roles:
    - role: bootstrap_llm_host
      vars:
        bootstrap_llm_host__install_ollama_webui: true
        bootstrap_llm_host__models:
          - name: "gemma-4-E2B-it-GGUF"
            repo: "unsloth/gemma-4-E2B-it-GGUF"
            filename: "gemma-4-E2B-it-Q5_K_M.gguf"
```

## Dependencies

This role has the following dependencies:

- `bootstrap_linux_firewalld` (if configuring firewall rules)
- `community.general.random_string` (for generating secret keys)

Ensure these dependencies are available in your Ansible environment.

## Best Practices

1. **Backup Configuration Files**: Always back up existing configuration files before applying changes.
2. **Test in a Staging Environment**: Test the role in a staging environment to ensure it meets your requirements and does not cause any issues.
3. **Monitor Logs**: Monitor logs for any errors or warnings after running the playbook.
4. **Update Regularly**: Keep the role and its dependencies up-to-date with the latest versions.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_llm_host/defaults/main.yml)
- [tasks/dependencies.yml](../../roles/bootstrap_llm_host/tasks/dependencies.yml)
- [tasks/firewall.yml](../../roles/bootstrap_llm_host/tasks/firewall.yml)
- [tasks/llama_cpp.yml](../../roles/bootstrap_llm_host/tasks/llama_cpp.yml)
- [tasks/main.yml](../../roles/bootstrap_llm_host/tasks/main.yml)
- [tasks/models.yml](../../roles/bootstrap_llm_host/tasks/models.yml)
- [tasks/nemoclaw.yml](../../roles/bootstrap_llm_host/tasks/nemoclaw.yml)
- [tasks/ollama.yml](../../roles/bootstrap_llm_host/tasks/ollama.yml)
- [tasks/proxy.yml](../../roles/bootstrap_llm_host/tasks/proxy.yml)
- [tasks/webui.yml](../../roles/bootstrap_llm_host/tasks/webui.yml)
- [handlers/main.yml](../../roles/bootstrap_llm_host/handlers/main.yml)