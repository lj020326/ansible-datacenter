---
title: "bootstrap_llm_host Ansible Role"
role: bootstrap_llm_host
category: Infrastructure Automation
type: Ansible Role
---

## Summary

The `bootstrap_llm_host` Ansible role is designed to automate the setup of a Large Language Model (LLM) server. This includes configuring system dependencies, setting up firewall rules, installing GPU drivers, downloading models, and deploying various services such as Ollama, NemoClaw, and WebUIs. The role supports both native and containerized deployments and can be customized through a variety of configuration variables.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_llm_host__configure_firewall` | `true` | Whether to configure firewall rules for the LLM server. |
| `bootstrap_llm_host__configure_proxy` | `false` | Whether to configure a reverse proxy (Nginx or Traefik) for the LLM services. |
| `bootstrap_llm_host__download_models` | `true` | Whether to download and set up models on the host. |
| `bootstrap_llm_host__install_gpu_drivers` | `true` | Whether to install GPU drivers (specifically NVIDIA). |
| `bootstrap_llm_host__install_nemoclaw` | `false` | Whether to install NemoClaw, a secure application and sandboxing tool. |
| `bootstrap_llm_host__install_ollama` | `true` | Whether to install Ollama, an API for running LLMs locally. |
| `bootstrap_llm_host__install_ollama_webui` | `false` | Whether to install the Ollama WebUI. |
| `bootstrap_llm_host__install_open_webui` | `false` | Whether to install Open WebUI. |
| `bootstrap_llm_host__ollama_runtime` | `"native"` | Runtime environment for Ollama (`native`, `docker`, or `swarm`). |
| `bootstrap_llm_host__ollama_container_name` | `"ollama"` | Name of the Docker container for Ollama. |
| `bootstrap_llm_host__ollama_container_home_dir` | `"/ollama"` | Home directory inside the Ollama container. |
| `bootstrap_llm_host__ollama_host_volume_path` | `"/home/docker/ollama/data"` | Host volume path for Ollama data. |
| `bootstrap_llm_host__docker_compose_project_name` | `"docker"` | Name of the Docker Compose project. |
| `bootstrap_llm_host__ollama_service_name` | `"ollama"` | Service name for Ollama in Docker Swarm. |
| `bootstrap_llm_host__docker_stack_name` | `"docker_stack"` | Stack name for Docker Swarm. |
| `bootstrap_llm_host__proxy_port` | `"80"` | Port for the reverse proxy. |
| `bootstrap_llm_host__proxy_type` | `traefik` | Type of reverse proxy to use (`nginx` or `traefik`). |
| `bootstrap_llm_host__server_name` | `{{ ansible_facts['fqdn'] \| d(ansible_facts['hostname']) \| d(ansible_host) }}` | Server name for the LLM services. |
| `bootstrap_llm_host__traefik_entrypoint` | `web` | Entrypoint for Traefik. |
| `bootstrap_llm_host__traefik_config_path` | `"/etc/traefik/conf.d"` | Configuration path for Traefik. |
| `bootstrap_llm_host__traefik_archive_url` | `"https://github.com/traefik/traefik/releases/download/v3.3.4/traefik_v3.3.4_linux_{{ 'amd64' if ansible_facts['architecture'] == 'x86_64' else 'arm64' }}.tar.gz"` | URL for downloading Traefik binary. |
| `bootstrap_llm_host__nginx_conf_path` | `"{{ __bootstrap_llm_host__nginx_conf_path \| d(__bootstrap_llm_host__nginx_conf_path_default) }}"` | Configuration path for Nginx. |
| `bootstrap_llm_host__nginx_enabled_path` | `"{{ __bootstrap_llm_host__nginx_enabled_path \| d(__bootstrap_llm_host__nginx_enabled_path_default) }}"` | Enabled configuration path for Nginx (Debian/Ubuntu only). |
| `bootstrap_llm_host__ollama_user` | `ollama` | User for running Ollama. |
| `bootstrap_llm_host__webui_user` | `webui` | User for running WebUIs. |
| `bootstrap_llm_host__ollama_home_dir` | `"/home/{{ bootstrap_llm_host__ollama_user }}"` | Home directory for the Ollama user. |
| `bootstrap_llm_host__webui_home_dir` | `"/home/{{ bootstrap_llm_host__webui_user }}"` | Home directory for the WebUI user. |
| `bootstrap_llm_host__ollama_port` | `"11434"` | Port for Ollama API. |
| `bootstrap_llm_host__webui_port` | `"8080"` | Port for WebUI. |
| `bootstrap_llm_host__model_storage_dir` | `"{{ bootstrap_llm_host__ollama_home_dir }}/.ollama/models"` | Directory for storing models. |
| `bootstrap_llm_host__webui_venv_dir` | `"/home/{{ bootstrap_llm_host__webui_user }}/open-webui-venv"` | Virtual environment directory for Open WebUI. |
| `bootstrap_llm_host__webui_tmpdir` | `"/home/{{ bootstrap_llm_host__webui_user }}/tmp"` | Temporary directory for WebUI operations. |
| `bootstrap_llm_host__webui_secret_key` | `"{{ lookup('community.general.random_string', length=32) }}"` | Secret key for WebUI. |
| `bootstrap_llm_host__model_download_timeout` | `3600` | Timeout for model downloads in seconds. |
| `bootstrap_llm_host__service_timeout` | `300` | Timeout for service readiness checks in seconds. |
| `bootstrap_llm_host__models` | `[]` | List of models to download and configure. |
| `bootstrap_llm_host__system_packages` | <pre>\[<br>  "curl",<br>  "wget",<br>  "git",<br>  "python3",<br>  "python3-pip",<br>  "python3-venv",<br>  "nodejs",<br>  "npm",<br>  "nginx"<br>\]</pre> | List of system packages to install. |
| `bootstrap_llm_host__nvidia_package_dist` | `"{{ ansible_facts['distribution'] \| lower }}{{ ansible_facts['distribution_version'] \| replace('.', '') }}"` | Distribution string for NVIDIA package. |
| `bootstrap_llm_host__nvidia_package_version` | `1.1-1` | Version of the NVIDIA package. |
| `bootstrap_llm_host__nvidia_package` | `"cuda-keyring_{{ bootstrap_llm_host__nvidia_package_version }}_all.deb"` | Name of the NVIDIA package to install. |
| `bootstrap_llm_host__nvidia_package_url` | `"https://developer.download.nvidia.com/compute/cuda/repos/{{ bootstrap_llm_host__nvidia_package_dist }}/x86_64/{{ bootstrap_llm_host__nvidia_package }}"` | URL for downloading the NVIDIA package. |
| `bootstrap_llm_host__install_llama_cpp` | `false` | Whether to install llama.cpp, a C++ implementation of LLaMA models. |
| `bootstrap_llm_host__llama_runtime` | `"{{ bootstrap_llm_host__ollama_runtime }}"` | Runtime environment for llama.cpp (defaults to same as Ollama). |
| `bootstrap_llm_host__llama_container_name` | `"llama-cpp"` | Name of the Docker container for llama.cpp. |
| `bootstrap_llm_host__llama_service_name` | `"llama-cpp"` | Service name for llama.cpp in Docker Swarm. |
| `bootstrap_llm_host__llama_host_volume_path` | `"/home/container-user/docker/llama-cpp/models"` | Host volume path for llama.cpp models. |
| `bootstrap_llm_host__llama_port` | `"8081"` | Port for llama.cpp API. |
| `bootstrap_llm_host__llama_models` | <pre>\[<br>  { repo: "unsloth/gemma-4-E2B-it-GGUF", filename: "gemma-4-E2B-it-Q5_K_M.gguf" },<br>  { repo: "unsloth/gemma-4-31B-it-GGUF", filename: "gemma-4-31B-it-Q5_K_M.gguf" }<br>\]</pre> | List of llama.cpp models to download. |
| `bootstrap_llm_host__llama_ctx_size` | `32768` | Context size for llama.cpp. |
| `bootstrap_llm_host__llama_n_gpu_layers` | `99` | Number of GPU layers for llama.cpp. |
| `bootstrap_llm_host__llama_temp` | `0.7` | Temperature parameter for llama.cpp. |
| `bootstrap_llm_host__llama_flash_attn` | `1` | Whether to use flash attention in llama.cpp. |
| `bootstrap_llm_host__nemoclaw_version` | `"latest"` | Version of NemoClaw to install. |
| `bootstrap_llm_host__nemoclaw_user` | `"nemoclaw"` | User for running NemoClaw. |
| `bootstrap_llm_host__nemoclaw_home_dir` | `"/home/{{ bootstrap_llm_host__nemoclaw_user }}"` | Home directory for the NemoClaw user. |
| `bootstrap_llm_host__nemoclaw_port` | `"9000"` | Port for NemoClaw API. |
| `bootstrap_llm_host__nemoclaw_workspace_dir` | `"{{ bootstrap_llm_host__nemoclaw_home_dir }}/workspace"` | Workspace directory for NemoClaw. |
| `bootstrap_llm_host__nemoclaw_sandbox_root` | `"/var/lib/nemoclaw/sandboxes"` | Root directory for NemoClaw sandboxes. |
| `bootstrap_llm_host__nemoclaw_orchestration_model` | `"deepseek-r1:14b"` | Orchestration model for NemoClaw (optimized for tool execution loops). |

## Usage

To use the `bootstrap_llm_host` role, include it in your Ansible playbook and set any desired variables. Here is an example playbook:

```yaml
---
- name: Setup LLM Server
  hosts: llm_servers
  become: true
  roles:
    - role: bootstrap_llm_host
      vars:
        bootstrap_llm_host__install_ollama: true
        bootstrap_llm_host__install_open_webui: true
        bootstrap_llm_host__configure_proxy: true
```

## Dependencies

The `bootstrap_llm_host` role depends on the following:

- `ansible.builtin.apt` for package management (when using APT)
- `ansible.builtin.package` for generic package management
- `ansible.builtin.user` and `ansible.builtin.group` for user and group management
- `ansible.builtin.file` for file and directory operations
- `ansible.builtin.get_url` for downloading files
- `ansible.builtin.command` and `ansible.builtin.shell` for running shell commands
- `ansible.builtin.uri` for HTTP requests
- `ansible.builtin.template` for rendering configuration templates
- `ansible.posix.seboolean` (optional) for SELinux configuration

## Best Practices

1. **Backup Configuration Files**: Always back up existing configuration files before applying changes.
2. **Test in a Staging Environment**: Test the role in a staging environment to ensure it works as expected before deploying to production.
3. **Use Version Control**: Keep your Ansible playbooks and roles under version control (e.g., Git) for better collaboration and rollback capabilities.
4. **Secure Sensitive Data**: Use Ansible Vault or other secure methods to manage sensitive data such as API keys and passwords.

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