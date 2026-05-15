```markdown
---
title: Bootstrap Linux Role TODO List
original_path: roles/bootstrap_linux/TODO.md
category: Documentation
tags: [bootstrap, linux, gpu, cuda, llm, docker, kubernetes, security, monitoring]
---

# Bootstrap Linux Role TODO List

## GPU / CUDA Verification Role (bootstrap_gpu_drivers)
- Add support for DGX OS.

## Common LLM Tools Installation Roles
### Baremetal Use Cases
- **bootstrap_llm_host**: For baremetal use cases (not common).

### Docker Stack Use Cases
- **bootstrap_docker_stack**: For docker stack use cases (most common).

### Kubernetes Pod Setup
- **bootstrap_k8s_pod** (TBD): For setup of LLM mesh on kubernetes (need to setup new role).
  - This role depends on the `bootstrap_kubernetes` role to set up Kubernetes.

## Docker + NVIDIA Container Toolkit Configuration
- **bootstrap_gpu_drivers**: To set up GPU drivers and NVIDIA Container Toolkit for NVIDIA GPUs.
- **bootstrap_docker**: To install and configure Docker and Docker Swarm.

## Security Hardening
- Implement security hardening measures such as fail2ban, key-only SSH, UFW, etc.

## Monitoring
- Set up monitoring tools like node_exporter, etc.

## Directory Layout and User Conventions
- Define any specific directory layout or user conventions required for the roles.

# Backlinks
- [Main Documentation](README.md)
```

This Markdown document is now structured with clear headings, proper formatting, and includes a YAML frontmatter with relevant metadata. The "Backlinks" section provides a way to navigate back to the main documentation page.