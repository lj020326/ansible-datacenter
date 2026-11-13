---
title: "Bootstrap LLM Host Role"
role: bootstrap_llm_host
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_llm_host]
---

# Bootstrap LLM Host Role

The `bootstrap_llm_host` role is designed to set up and configure a host machine for running large language models (LLMs). This role handles the installation and configuration of various components required for LLM deployment, including model management, web UI interfaces, reverse proxies, and firewall settings.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_llm_host__configure_firewall` | `true` | Whether to configure the firewall. |
| `bootstrap_llm_host__configure_proxy` | `false` | Whether to configure a reverse proxy. |
| `bootstrap_llm_host__ensure_ollama_models` | `true` | Whether to ensure Ollama models are installed. |
| `bootstrap_llm_host__ensure_llama_models` | `false` | Whether to ensure llama.cpp models are installed. |
| `bootstrap_llm_host__ensure_vllm_models` | `false` | Whether to ensure vLLM models are installed. |
| `bootstrap_llm_host__install_force` | `false` | Whether to force installation of components. |
| `bootstrap_llm_host__install_gpu_drivers` | `true` | Whether to install GPU drivers. |
| `bootstrap_llm_host__install_nemoclaw` | `false` | Whether to install the NemoClaw agent stack. |
| `bootstrap_llm_host__install_ollama` | `true` | Whether to install Ollama. |
| `bootstrap_llm_host__install_ollama_webui` | `false` | Whether to install the Ollama Web UI. |
| `bootstrap_llm_host__install_open_webui` | `false` | Whether to install the Open Web UI. |
| `bootstrap_llm_host__hugging_face_token` | `""` | Hugging Face API token. |
| `bootstrap_llm_host__container_user` | `"container-user"` | User for container operations. |
| `bootstrap_llm_host__model_runtime` | `"native"` | Runtime environment for models (native, docker, swarm). |
| `bootstrap_llm_host__model_user` | `"{{
  bootstrap_llm_host__container_user
  if bootstrap_llm_host__model_runtime in ['docker', 'swarm']
  else 'model-user' }}"` | User for model operations. |
| `bootstrap_llm_host__service_timeout` | `300` | Service timeout in seconds. |
| `bootstrap_llm_host__proxy_port` | `"80"` | Port for the reverse proxy. |
| `bootstrap_llm_host__proxy_type` | `"traefik"` | Type of reverse proxy to use (nginx, traefik). |
| `bootstrap_llm_host__server_name` | `"{{ ansible_facts['fqdn'] | d(ansible_facts['hostname']) | d(ansible_host) }}"` | Server name for the host. |
| `bootstrap_llm_host__traefik_entrypoint` | `"web"` | Traefik entrypoint. |
| `bootstrap_llm_host__traefik_config_path` | `"/etc/traefik/conf.d"` | Path to Traefik configuration files. |
| `bootstrap_llm_host__traefik_archive_url` | `"https://github.com/traefik/traefik/releases/download/v3.3.4/traefik_v3.3.4_linux_{{
  'amd64' if ansible_facts['architecture'] == 'x86_64' else 'arm64' }}.tar.gz"` | URL to download Traefik archive. |
| `bootstrap_llm_host__nginx_conf_path` | `"/etc/nginx/sites-available"` | Path to Nginx configuration files. |
| `bootstrap_llm_host__nginx_enabled_path` | `"/etc/nginx/sites-enabled"` | Path to enabled Nginx configuration files. |
| `bootstrap_llm_host__docker_compose_project_name` | `"docker"` | Docker Compose project name. |
| `bootstrap_llm_host__docker_stack_name` | `"docker_stack"` | Docker stack name. |
| `bootstrap_llm_host__webui_user` | `"webui"` | User for Web UI operations. |
| `bootstrap_llm_host__webui_home_dir` | `"/home/{{ bootstrap_llm_host__webui_user }}"` | Home directory for Web UI user. |
| `bootstrap_llm_host__webui_port` | `"8080"` | Port for Web UI. |

## Usage

To use the `bootstrap_llm_host` role, include it in your playbook and set the desired variables:

```yaml
- hosts: llm_hosts
  roles:
    - role: bootstrap_llm_host
      vars:
        bootstrap_llm_host__configure_firewall: true
        bootstrap_llm_host__install_ollama: true
        bootstrap_llm_host__ensure_ollama_models: true
        bootstrap_llm_host__model_runtime: "docker"
```

## Dependencies

This role depends on the following roles and modules:

- `bootstrap_linux_firewalld` role for firewall configuration.
- `dettonville.llm.hf_download` module for downloading models from Hugging Face.
- `dettonville.llm.llama_api` module for interacting with the llama.cpp API.
- `dettonville.llm.ollama_api` module for interacting with the Ollama API.
- `dettonville.llm.vllm_api` module for interacting with the vLLM API.

## Best Practices

- Ensure that the host machine has sufficient resources (CPU, GPU, memory) for running LLMs.
- Use a dedicated user for model operations to enhance security.
- Regularly update the models and dependencies to benefit from the latest improvements and security patches.
- Monitor the services and logs to ensure smooth operation.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_llm_host/defaults/main.yml)
- [tasks/firewall.yml](../../roles/bootstrap_llm_host/tasks/firewall.yml)
- [tasks/main.yml](../../roles/bootstrap_llm_host/tasks/main.yml)
- [tasks/models_llama.yml](../../roles/bootstrap_llm_host/tasks/models_llama.yml)
- [tasks/models_ollama.yml](../../roles/bootstrap_llm_host/tasks/models_ollama.yml)
- [tasks/models_vllm.yml](../../roles/bootstrap_llm_host/tasks/models_vllm.yml)
- [tasks/nemoclaw.yml](../../roles/bootstrap_llm_host/tasks/nemoclaw.yml)
- [tasks/ollama.yml](../../roles/bootstrap_llm_host/tasks/ollama.yml)
- [tasks/proxy.yml](../../roles/bootstrap_llm_host/tasks/proxy.yml)
- [tasks/webui.yml](../../roles/bootstrap_llm_host/tasks/webui.yml)
- [handlers/main.yml](../../roles/bootstrap_llm_host/handlers/main.yml)