```markdown
---
title: Bootstrap GPU Drivers Role Documentation
original_path: roles/bootstrap_gpu_drivers/README.md
category: Ansible Roles
tags: [gpu-drivers, nvidia, amd, ansible]
---

# Bootstrap GPU Drivers Role Documentation

## Summary

The `bootstrap_gpu_drivers` role is designed to automate the installation and configuration of NVIDIA and AMD GPU drivers on various Linux distributions. It supports both Ubuntu and Red Hat-based systems, handling driver installations from official repositories or CUDA repositories as specified by the user. The role also manages persistence mode for NVIDIA GPUs and optionally installs the NVIDIA Container Toolkit.

## Variables

| Variable Name                                                  | Default Value                                                                                                                                                 | Description                                                                                              |
|----------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| `bootstrap_gpu_drivers__package_state`                         | `present`                                                                                                                                                     | Desired state of the GPU driver packages (`present` or `absent`).                                        |
| `bootstrap_gpu_drivers__package_version`                       | `""`                                                                                                                                                          | Specific version of the GPU drivers to install. If left empty, it installs the latest available version. |
| `bootstrap_gpu_drivers__persistence_mode_on`                   | `true`                                                                                                                                                        | Enables persistence mode for NVIDIA GPUs to improve performance by keeping the driver loaded.            |
| `bootstrap_gpu_drivers__skip_reboot`                           | `true`                                                                                                                                                        | Skips rebooting the system after installing GPU drivers if set to `true`.                                |
| `bootstrap_gpu_drivers__nvidia_module_file`                    | `/etc/modprobe.d/nvidia.conf`                                                                                                                                 | Path to the modprobe configuration file for NVIDIA modules.                                              |
| `bootstrap_gpu_drivers__nvidia_module_params`                  | `""`                                                                                                                                                          | Parameters to be passed to NVIDIA kernel modules, if any.                                                |
| `bootstrap_gpu_drivers__nvidia_add_repos`                      | `true`                                                                                                                                                        | Adds NVIDIA repositories to the system package manager.                                                  |
| `bootstrap_gpu_drivers__nvidia_package_branch_default`         | `"550"`                                                                                                                                                       | Default branch of NVIDIA drivers to install if no specific version is provided.                          |
| `bootstrap_gpu_drivers__restart_docker`                        | `false`                                                                                                                                                       | Restarts Docker service after installing NVIDIA Container Toolkit if set to `true`.                      |
| `bootstrap_gpu_drivers__epel_package`                          | `https://dl.fedoraproject.org/pub/epel/epel-release-latest-\{\{ ansible_facts['distribution_major_version'] \}\}.noarch.rpm`                                  | URL for the EPEL repository package.                                                                     |
| `bootstrap_gpu_drivers__epel_repo_key`                         | `https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-\{\{ ansible_facts['distribution_major_version'] \}\}`                                                | URL for the GPG key of the EPEL repository.                                                              |
| `bootstrap_gpu_drivers__nvidia_rhel_cuda_repo_baseurl`         | `https://developer.download.nvidia.com/compute/cuda/repos/\{\{ _rhel_repo_dir \}\}/`                                                                          | Base URL for NVIDIA CUDA repositories on RHEL/CentOS.                                                    |
| `bootstrap_gpu_drivers__nvidia_rhel_cuda_repo_gpgkey`          | `https://developer.download.nvidia.com/compute/cuda/repos/\{\{ _rhel_repo_dir \}\}/D42D0685.pub`                                                              | URL for the GPG key of NVIDIA CUDA repositories on RHEL/CentOS.                                          |
| `bootstrap_gpu_drivers__nvidia_rhel_branch`                    | `\{\{ bootstrap_gpu_drivers__nvidia_package_branch \| d(bootstrap_gpu_drivers__nvidia_package_branch_default) \}\}`                                           | Branch of NVIDIA drivers for RHEL/CentOS installations.                                                  |

## Backlinks

- [Ansible Roles Documentation](/docs/ansible-roles)
```

This improved Markdown document includes a standardized YAML frontmatter with additional metadata such as `title`, `category`, and `tags`. The structure is clear, and headings are properly formatted. A "Backlinks" section has been added to provide context for where this documentation might fit within a larger knowledge base or documentation set.