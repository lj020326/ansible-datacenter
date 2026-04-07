# bootstrap_llm_host Ansible Role

Sets up a local LLM inference server using Ollama on Ubuntu 24.04+ with NVIDIA GPU support.

## Features

- Installs NVIDIA drivers/CUDA (via included role)
- Installs Ollama as dedicated user
- Optional Open WebUI (recommended) or legacy Ollama-WebUI
- Nginx reverse proxy (optional)
- UFW firewall configuration
- Management script: `/usr/local/bin/llm-server`
- Unified model handling: pull standard tags or create custom from GGUF + Modelfile
- Model storage configurable (defaults to large /home disk)

## Requirements

- Ubuntu 24.04+
- NVIDIA GPU (tested RTX 3090 24GB)
- Ansible 2.14+
- Community collections: `community.general`, `ansible.posix`

## Role Variables

See `defaults/main.yml` for all vars. Key ones:

```yaml
bootstrap_llm_host__models: []               # List of dicts - see examples below
bootstrap_llm_host__model_storage_dir: "/home/ollama/.ollama/models"
bootstrap_llm_host__install_open_webui: true
bootstrap_llm_host__configure_proxy: true    # Recommended with WebUI
```

Example model config (in playbook vars):
```yaml
bootstrap_llm_host__models:
  - type: pull
    name: qwen3.5:27b           # Official Ollama tag, ~17GB VRAM Q4
  - type: pull
    name: deepseek-coder:6.7b
  - type: custom
    id: qwen-custom-32k
    gguf_url: https://huggingface.co/unsloth/Qwen3.5-27B-GGUF/resolve/main/Qwen3.5-27B-Q4_K_M.gguf
    num_ctx: 32768
    temperature: 0.7
```

## Usage

```yaml
- hosts: gpu_servers
  roles:
    - role: bootstrap_llm_host
      vars:
        bootstrap_llm_host__models:
          - type: pull
            name: qwen3.5:27b
```

After run:

- Access Open WebUI: http://<host>:80 (if nginx enabled)
- Ollama API: http://localhost:11434
- Manage: llm-server list-models, llm-server pull-model qwen3.5:14b, etc.

## Next Steps / Integration

- Use Continue.dev in VSCode/IntelliJ → provider "ollama", model "qwen3.5:27b", base "http://localhost:11434"
- Clone Gitea repos locally → open in IDE for AI-assisted debugging/coding

## License

MIT
