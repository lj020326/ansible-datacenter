---
title: Bootstrap LLM Host Role Documentation
role: bootstrap_llm_host
category: Ansible Roles
type: Configuration Management
tags: ansible, llm, ollama, llama_cpp, webui, proxy, firewall

---

## Summary

The `bootstrap_llm_host` role is designed to automate the setup of a Large Language Model (LLM) server. It handles the installation and configuration of GPU drivers, Ollama API, LLaMA.cpp server, model downloads, WebUIs (Open WebUI or Ollama WebUI), reverse proxy (Nginx or Traefik), and firewall settings. This role ensures that all necessary components are installed and configured to enable seamless operation of the LLM services.

## Variables

| Variable Name                                      | Default Value                                                                                       | Description                                                                                                                                                                                                 |
|----------------------------------------------------|-----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_llm_host__install_gpu_drivers`        | `true`                                                                                                | Whether to install GPU drivers.                                                                                                                                                                             |
| `bootstrap_llm_host__install_ollama`             | `true`                                                                                                | Whether to install Ollama API.                                                                                                                                                                              |
| `bootstrap_llm_host__install_ollama_webui`       | `false`                                                                                               | Whether to install Ollama WebUI.                                                                                                                                                                            |
| `bootstrap_llm_host__install_open_webui`         | `true`                                                                                                | Whether to install Open WebUI.                                                                                                                                                                              |
| `bootstrap_llm_host__configure_firewall`         | `true`                                                                                                | Whether to configure firewall settings.                                                                                                                                                                     |
| `bootstrap_llm_host__download_models`            | `true`                                                                                                | Whether to download models.                                                                                                                                                                                 |
| `bootstrap_llm_host__configure_proxy`            | `true`                                                                                                | Whether to configure a reverse proxy (Nginx or Traefik).                                                                                                                                                    |
| `bootstrap_llm_host__ollama_runtime`             | `"native"`                                                                                            | Runtime for Ollama API (`native`, `docker`, `swarm`).                                                                                                                                                       |
| `bootstrap_llm_host__ollama_container_name`      | `"ollama"`                                                                                            | Container name for Ollama API.                                                                                                                                                                              |
| `bootstrap_llm_host__ollama_host_volume_path`    | `"/home/docker/ollama/data"`                                                                          | Host volume path for Ollama data.                                                                                                                                                                           |
| `bootstrap_llm_host__docker_compose_project_name`| `"docker"`                                                                                            | Docker Compose project name.                                                                                                                                                                                |
| `bootstrap_llm_host__ollama_service_name`        | `"ollama"`                                                                                            | Service name for Ollama API in Docker Swarm mode.                                                                                                                                                           |
| `bootstrap_llm_host__docker_stack_name`          | `"docker_stack"`                                                                                      | Docker stack name for Docker Swarm mode.                                                                                                                                                                    |
| `bootstrap_llm_host__proxy_port`                 | `"80"`                                                                                                | Port for the reverse proxy.                                                                                                                                                                                 |
| `bootstrap_llm_host__proxy_type`                 | `traefik`                                                                                             | Type of reverse proxy (`nginx`, `traefik`).                                                                                                                                                                 |
| `bootstrap_llm_host__server_name`                | `{{ ansible_facts['fqdn'] \| d(ansible_facts['hostname']) \| d(ansible_host) }}`                       | Server name for the reverse proxy configuration.                                                                                                                                                            |
| `bootstrap_llm_host__traefik_entrypoint`         | `web`                                                                                                 | Traefik entry point.                                                                                                                                                                                        |
| `bootstrap_llm_host__traefik_config_path`        | `"/etc/traefik/conf.d"`                                                                               | Path for Traefik configuration files.                                                                                                                                                                       |
| `bootstrap_llm_host__traefik_archive_url`        | `"https://github.com/traefik/traefik/releases/download/v3.3.4/traefik_v3.3.4_linux_{{ 'amd64' if ansible_facts['architecture'] == 'x86_64' else 'arm64' }}.tar.gz"` | URL for downloading Traefik binary.                                                                                                                                                                       |
| `bootstrap_llm_host__ollama_user`                | `ollama`                                                                                              | User for Ollama API.                                                                                                                                                                                        |
| `bootstrap_llm_host__webui_user`                 | `webui`                                                                                               | User for WebUIs.                                                                                                                                                                                            |
| `bootstrap_llm_host__ollama_home_dir`            | `"/home/{{ bootstrap_llm_host__ollama_user }}"`                                                         | Home directory for Ollama user.                                                                                                                                                                             |
| `bootstrap_llm_host__webui_home_dir`             | `"/home/{{ bootstrap_llm_host__webui_user }}"`                                                          | Home directory for WebUI user.                                                                                                                                                                              |
| `bootstrap_llm_host__ollama_port`                | `"11434"`                                                                                             | Port for Ollama API.                                                                                                                                                                                        |
| `bootstrap_llm_host__webui_port`                 | `"8080"`                                                                                              | Port for WebUIs.                                                                                                                                                                                            |
| `bootstrap_llm_host__model_storage_dir`          | `"{{ bootstrap_llm_host__ollama_home_dir }}/.ollama/models"`                                          | Directory for storing models.                                                                                                                                                                               |
| `bootstrap_llm_host__webui_venv_dir`             | `"/home/{{ bootstrap_llm_host__webui_user }}/open-webui-venv"`                                       | Virtual environment directory for Open WebUI.                                                                                                                                                               |
| `bootstrap_llm_host__webui_tmpdir`               | `"/home/{{ bootstrap_llm_host__webui_user }}/tmp"`                                                     | Temporary directory for WebUIs.                                                                                                                                                                             |
| `bootstrap_llm_host__webui_secret_key`           | `"{{ lookup('community.general.random_string', length=32) }}"`                                         | Secret key for Open WebUI.                                                                                                                                                                                  |
| `bootstrap_llm_host__model_download_timeout`     | `3600`                                                                                                | Timeout for model downloads (in seconds).                                                                                                                                                                   |
| `bootstrap_llm_host__service_timeout`            | `300`                                                                                                 | Timeout for services to start (in seconds).                                                                                                                                                                 |
| `bootstrap_llm_host__models`                     | `[]`                                                                                                  | List of models to download and configure.                                                                                                                                                                   |
| `bootstrap_llm_host__system_packages`            | `['curl', 'wget', 'git', 'python3', 'python3-pip', 'python3-venv', 'nodejs', 'npm', 'nginx']`         | System packages to install.                                                                                                                                                                                 |
| `bootstrap_llm_host__nvidia_package_dist`        | `"{{ ansible_facts['distribution'] \| lower }}{{ ansible_facts['distribution_version'] \| replace('.', '') }}"` | Distribution string for NVIDIA package URL.                                                                                                                                                                 |
| `bootstrap_llm_host__nvidia_package_version`     | `1.1-1`                                                                                               | Version of NVIDIA package to install.                                                                                                                                                                       |
| `bootstrap_llm_host__nvidia_package`             | `"cuda-keyring_{{ bootstrap_llm_host__nvidia_package_version }}_all.deb"`                              | Name of the NVIDIA package to download.                                                                                                                                                                     |
| `bootstrap_llm_host__nvidia_package_url`         | `"https://developer.download.nvidia.com/compute/cuda/repos/{{ bootstrap_llm_host__nvidia_package_dist }}/x86_64/{{ bootstrap_llm_host__nvidia_package }}"` | URL for downloading NVIDIA package.                                                                                                                                                                         |
| `bootstrap_llm_host__install_llama_cpp`          | `false`                                                                                               | Whether to install LLaMA.cpp server.                                                                                                                                                                        |
| `bootstrap_llm_host__llama_cpp_runtime`          | `"{{ bootstrap_llm_host__ollama_runtime }}"`                                                            | Runtime for LLaMA.cpp (`native`, `docker`, `swarm`). Defaults to the same as Ollama runtime.                                                                                                            |
| `bootstrap_llm_host__llama_cpp_container_name`   | `"llama-cpp"`                                                                                         | Container name for LLaMA.cpp server.                                                                                                                                                                        |
| `bootstrap_llm_host__llama_cpp_service_name`     | `"llama-cpp"`                                                                                         | Service name for LLaMA.cpp in Docker Swarm mode.                                                                                                                                                            |
| `bootstrap_llm_host__llama_cpp_host_volume_path` | `"/home/container-user/docker/llama-cpp/models"`                                                      | Host volume path for LLaMA.cpp models.                                                                                                                                                                      |
| `bootstrap_llm_host__llama_cpp_port`             | `"8081"`                                                                                              | Port for LLaMA.cpp OpenAI-compatible API.                                                                                                                                                                   |
| `bootstrap_llm_host__llama_cpp_models`           | `[ { repo: 'unsloth/gemma-4-E2B-it-GGUF', filename: 'gemma-4-E2B-it-Q5_K_M.gguf' }, { repo: 'unsloth/gemma-4-31B-it-GGUF', filename: 'gemma-4-31B-it-Q5_K_M.gguf' } ]` | List of LLaMA.cpp models to download.                                                                                                                                                                       |
| `bootstrap_llm_host__llama_cpp_ctx_size`         | `32768`                                                                                               | Context size for LLaMA.cpp.                                                                                                                                                                                 |
| `bootstrap_llm_host__llama_cpp_n_gpu_layers`     | `99`                                                                                                  | Number of GPU layers for LLaMA.cpp.                                                                                                                                                                         |
| `bootstrap_llm_host__llama_cpp_temp`             | `0.7`                                                                                                 | Temperature setting for LLaMA.cpp.                                                                                                                                                                          |
| `bootstrap_llm_host__llama_cpp_flash_attn`       | `1`                                                                                                   | Flash attention flag for LLaMA.cpp.                                                                                                                                                                         |

## Usage

To use the `bootstrap_llm_host` role, include it in your playbook and configure the necessary variables as needed. Here is an example playbook:

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
        bootstrap_llm_host__configure_proxy: true
        bootstrap_llm_host__proxy_type: traefik
        bootstrap_llm_host__models:
          - name: "gemma-4-E2B-it-GGUF"
            type: pull
```

## Dependencies

The `bootstrap_llm_host` role depends on the following:

- `ansible.builtin`
- `community.general.random_string`
- `community.general.npm`

Ensure these dependencies are available in your Ansible environment.

## Tags

The following tags can be used to selectively run parts of this role:

- `dependencies`: Install required system packages.
- `firewall`: Configure firewall settings.
- `llama_cpp`: Manage LLaMA.cpp server installation and configuration.
- `models`: Download and configure models.
- `ollama`: Manage Ollama API installation and configuration.
- `proxy`: Configure reverse proxy (Nginx or Traefik).
- `webui`: Install and configure WebUIs (Open WebUI or Ollama WebUI).

Example of using tags:

```bash
ansible-playbook -i inventory playbook.yml --tags "ollama,webui"
```

## Best Practices

- **Backup Configuration Files**: Always back up existing configuration files before running the role to prevent data loss.
- **Test in a Staging Environment**: Test the role in a staging environment before deploying it to production to ensure everything works as expected.
- **Monitor Logs**: Monitor logs for any issues during and after the setup process. Use `journalctl` to check service logs.

## Molecule Tests

This role does not include Molecule tests at this time. However, it is recommended to write and run Molecule tests to validate the role's functionality in different environments.

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