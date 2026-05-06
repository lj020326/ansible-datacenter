---
title: Bootstrap GPU Drivers Role Documentation
role: bootstrap_gpu_drivers
category: Ansible Roles
type: Configuration Management
tags: gpu, nvidia, amd, drivers, ansible

## Summary
The `bootstrap_gpu_drivers` role is designed to automate the installation and configuration of NVIDIA and AMD GPU drivers on various Linux distributions. It supports both Ubuntu and Red Hat-based systems, handling driver installations from official repositories or CUDA repositories as specified by the user. The role also manages persistence mode for NVIDIA GPUs and optionally installs the NVIDIA Container Toolkit.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_gpu_drivers__package_state` | `present` | Desired state of the GPU driver packages (`present` or `absent`). |
| `bootstrap_gpu_drivers__package_version` | `""` | Specific version of the GPU drivers to install. If left empty, it installs the latest available version. |
| `bootstrap_gpu_drivers__persistence_mode_on` | `true` | Enables persistence mode for NVIDIA GPUs to improve performance by keeping the driver loaded. |
| `bootstrap_gpu_drivers__skip_reboot` | `true` | Skips rebooting the system after installing GPU drivers if set to `true`. |
| `bootstrap_gpu_drivers__nvidia_module_file` | `/etc/modprobe.d/nvidia.conf` | Path to the modprobe configuration file for NVIDIA modules. |
| `bootstrap_gpu_drivers__nvidia_module_params` | `""` | Parameters to be passed to NVIDIA kernel modules, if any. |
| `bootstrap_gpu_drivers__nvidia_add_repos` | `true` | Adds NVIDIA repositories to the system package manager. |
| `bootstrap_gpu_drivers__nvidia_package_branch_default` | `"550"` | Default branch of NVIDIA drivers to install if no specific version is provided. |
| `bootstrap_gpu_drivers__restart_docker` | `false` | Restarts Docker service after installing NVIDIA Container Toolkit if set to `true`. |
| `bootstrap_gpu_drivers__epel_package` | `https://dl.fedoraproject.org/pub/epel/epel-release-latest-\{\{ ansible_facts['distribution_major_version'] \}\}.noarch.rpm` | URL for the EPEL repository package. |
| `bootstrap_gpu_drivers__epel_repo_key` | `https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-\{\{ ansible_facts['distribution_major_version'] \}\}` | URL for the GPG key of the EPEL repository. |
| `bootstrap_gpu_drivers__nvidia_rhel_cuda_repo_baseurl` | `https://developer.download.nvidia.com/compute/cuda/repos/\{\{ _rhel_repo_dir \}\}/` | Base URL for NVIDIA CUDA repositories on RHEL/CentOS. |
| `bootstrap_gpu_drivers__nvidia_rhel_cuda_repo_gpgkey` | `https://developer.download.nvidia.com/compute/cuda/repos/\{\{ _rhel_repo_dir \}\}/D42D0685.pub` | URL for the GPG key of NVIDIA CUDA repositories on RHEL/CentOS. |
| `bootstrap_gpu_drivers__nvidia_rhel_branch` | `\{\{ bootstrap_gpu_drivers__nvidia_package_branch \| d(bootstrap_gpu_drivers__nvidia_package_branch_default) \}\}` | Branch of NVIDIA drivers for RHEL/CentOS installations. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_install_from_cuda_repo` | `false` | Installs NVIDIA drivers from the CUDA repository on Ubuntu if set to `true`. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_packages_suffix` | `-open` | Suffix for NVIDIA driver packages on Ubuntu. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_repo_gpgkey_id_old` | `7fa2af80` | ID of the old GPG key used by NVIDIA CUDA repositories on Ubuntu. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_repo_baseurl` | `https://developer.download.nvidia.com/compute/cuda/repos/\{\{ _ubuntu_repo_dir \}\}` | Base URL for NVIDIA CUDA repositories on Ubuntu. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_keyring_package` | `cuda-keyring_1.0-1_all.deb` | Name of the CUDA keyring package for Ubuntu. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_keyring_url` | `\{\{ bootstrap_gpu_drivers__nvidia_ubuntu_cuda_repo_baseurl \}\}/\{\{ bootstrap_gpu_drivers__nvidia_ubuntu_cuda_keyring_package \}\}` | URL for the CUDA keyring package on Ubuntu. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_package` | `cuda-drivers-\{\{ bootstrap_gpu_drivers__nvidia_ubuntu_branch \}\}` | Name of the NVIDIA driver package on Ubuntu. |
| `_ubuntu_repo_dir` | `\{\{ ansible_facts['distribution'] \| lower \}\}\{\{ ansible_facts['distribution_version'] \| replace('.', '') \}\}/\{\{ ansible_facts['architecture'] \}\}` | Internal variable for constructing repository directory paths on Ubuntu. |
| `_rhel_repo_dir` | `rhel\{\{ ansible_facts['distribution_major_version'] \}\}/\{\{ ansible_facts['architecture'] \}\}` | Internal variable for constructing repository directory paths on RHEL/CentOS. |
| `bootstrap_gpu_drivers__amd_deb_package_base_url` | `https://repo.radeon.com/amdgpu-install/latest/ubuntu/\{\{ ansible_facts['distribution_release'] \| lower \}\}` | Base URL for AMD GPU installation packages on Ubuntu. |
| `bootstrap_gpu_drivers__nvidia_install_container_toolkit` | `false` | Installs NVIDIA Container Toolkit if set to `true`. |
| `bootstrap_gpu_drivers__nvidia_container_toolkit_version` | `""` | Specific version of the NVIDIA Container Toolkit to install, if any. |

## Usage
To use this role, include it in your playbook and optionally override default variables as needed. Here is an example playbook:

```yaml
---
- name: Install GPU Drivers
  hosts: all
  roles:
    - role: bootstrap_gpu_drivers
      vars:
        bootstrap_gpu_drivers__package_state: present
        bootstrap_gpu_drivers__persistence_mode_on: true
        bootstrap_gpu_drivers__nvidia_add_repos: true
```

## Dependencies
- `community.general` Ansible collection for `modprobe` and `kernel_blacklist` modules.
- `ansible.builtin` core modules.

Ensure the required collections are installed using:
```bash
ansible-galaxy collection install community.general
```

## Tags
This role uses tags to allow selective execution of tasks. The following tags are available:

| Tag | Description |
|-----|-------------|
| `nvidia` | Tasks related to NVIDIA GPU drivers. |
| `amd` | Tasks related to AMD GPU drivers. |
| `container_toolkit` | Tasks related to the NVIDIA Container Toolkit. |

Example usage with tags:
```bash
ansible-playbook -i inventory playbook.yml --tags=nvidia,container_toolkit
```

## Best Practices
- Always specify a version for critical packages like GPU drivers and container toolkits to avoid unexpected changes.
- Ensure Secure Boot is disabled on systems where NVIDIA drivers are installed unless the drivers are signed.
- Use tags to control which parts of the role are executed based on your specific requirements.

## Molecule Tests
This role includes Molecule tests to verify its functionality. To run the tests, ensure you have Molecule and Ansible installed, then execute:

```bash
molecule test
```

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_gpu_drivers/defaults/main.yml)
- [tasks/install-amd.yml](../../roles/bootstrap_gpu_drivers/tasks/install-amd.yml)
- [tasks/install-nvidia.yml](../../roles/bootstrap_gpu_drivers/tasks/install-nvidia.yml)
- [tasks/main.yml](../../roles/bootstrap_gpu_drivers/tasks/main.yml)
- [tasks/install-container-toolkit.yml](../../roles/bootstrap_gpu_drivers/tasks/install-container-toolkit.yml)
- [tasks/install-redhat.yml](../../roles/bootstrap_gpu_drivers/tasks/install-redhat.yml)
- [tasks/install-ubuntu-cuda-repo.yml](../../roles/bootstrap_gpu_drivers/tasks/install-ubuntu-cuda-repo.yml)
- [tasks/install-ubuntu.yml](../../roles/bootstrap_gpu_drivers/tasks/install-ubuntu.yml)
- [handlers/main.yml](../../roles/bootstrap_gpu_drivers/handlers/main.yml)