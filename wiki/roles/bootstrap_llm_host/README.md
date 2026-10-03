---
title: Bootstrap LLM Host Role Documentation
original_path: roles/bootstrap_llm_host/README.md
category: Ansible Roles
tags: [LLM, Ansible, NVIDIA, Ollama, WebUI, Nginx, Traefik, UFW, GPU]
---

# Bootstrap LLM Host Role Documentation

## Summary

The `bootstrap_llm_host` role automates the setup of a Large Language Model (LLM) server. It installs and configures GPU drivers, Ollama API, LLaMA.cpp server, model downloads, WebUIs, reverse proxy, and firewall settings to ensure seamless operation of LLM services.

## Features

- Installs NVIDIA drivers/CUDA (via included role)
- Installs Ollama as a dedicated user
- Optional Open WebUI (recommended) or legacy Ollama-WebUI
- Nginx or Traefik reverse proxy (optional)
- UFW firewall configuration
- Management script: `/usr/local/bin/llm-server`
- Unified model handling: pull standard tags or create custom from GGUF + Modelfile
- Model storage configurable (defaults to large /home disk)
- NemoClaw setup (optional)

## Requirements

- Ubuntu 24.04+
- NVIDIA/AMD/Intel GPU (tested RTX 3090 24GB) (must be NVIDIA for NemoClaw)
- Ansible 2.14.0+
- Community collections: `community.general`, `ansible.posix`

## Variables

| Variable Name                                     | Default Value                                                                                                                                                          | Description                                                                                  |
|---------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| `bootstrap_llm_host__install_gpu_drivers`         | `true`                                                                                                                                                                 | Whether to install GPU drivers.                                                              |
| `bootstrap_llm_host__install_ollama`              | `true`                                                                                                                                                                 | Whether to install Ollama API.                                                               |
| `bootstrap_llm_host__install_ollama_webui`        | `false`                                                                                                                                                                | Whether to install Ollama WebUI.                                                             |
| `bootstrap_llm_host__install_open_webui`          | `true`                                                                                                                                                                 | Whether to install Open WebUI.                                                               |
| `bootstrap_llm_host__configure_firewall`          | `true`                                                                                                                                                                 | Whether to configure firewall settings.                                                      |
| `bootstrap_llm_host__download_models`             | `true`                                                                                                                                                                 | Whether to download models.                                                                  |
| `bootstrap_llm_host__configure_proxy`             | `true`                                                                                                                                                                 | Whether to configure a reverse proxy (Nginx or Traefik).                                     |
| `bootstrap_llm_host__ollama_runtime`              | `"native"`                                                                                                                                                             | Runtime for Ollama API (`native`, `docker`, `swarm`).                                        |
| `bootstrap_llm_host__ollama_container_name`       | `"ollama"`                                                                                                                                                             | Container name for Ollama API.                                                               |
| `bootstrap_llm_host__ollama_host_volume_path`     | `"/home/docker/ollama/data"`                                                                                                                                           | Host volume path for Ollama data.                                                            |
| `bootstrap_llm_host__docker_compose_project_name` | `"docker"`                                                                                                                                                             | Docker Compose project name.                                                                 |
| `bootstrap_llm_host__ollama_service_name`         | `"ollama"`                                                                                                                                                             | Service name for Ollama API in Docker Swarm mode.                                            |
| `bootstrap_llm_host__docker_stack_name`           | `"docker_stack"`                                                                                                                                                       | Docker stack name for Docker Swarm mode.                                                      |
| `bootstrap_llm_host__model_storage_path`          | `"/home/llm/models"`                                                                                                                                                   | Path to store LLM models.                                                                    |
| `bootstrap_llm_host__nemoclaw_enabled`            | `false`                                                                                                                                                                | Whether to enable NemoClaw setup.                                                           |

## Usage Examples

### Basic Usage
```yaml
- hosts: llm_servers
  roles:
    - bootstrap_llm_host
```

### Custom Configuration
```yaml
- hosts: llm_servers
  roles:
    - role: bootstrap_llm_host
      vars:
        bootstrap_llm_host__install_open_webui: false
        bootstrap_llm_host__install_ollama_webui: true
        bootstrap_llm_host__model_storage_path: "/mnt/ssd/llm/models"
```

## Backlinks

[Add links to related pages or documentation here]