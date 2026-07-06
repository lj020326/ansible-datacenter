---
title: Bootstrap GPU Drivers Role Documentation
role: bootstrap_gpu_drivers
category: Ansible Roles
type: Technical Documentation
tags: ansible, gpu, drivers, nvidia, amd, intel

## Summary

The `bootstrap_gpu_drivers` role is designed to automate the installation and configuration of GPU drivers for NVIDIA, AMD, and Intel GPUs across various Linux distributions. It supports automatic detection of GPU hardware, manages driver installations from official repositories, and configures necessary system settings such as persistence mode for NVIDIA GPUs. The role also includes optional features like installing container toolkits and handling specific cases for DGX systems.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_gpu_drivers__package_state` | `"present"` | Desired state of the GPU driver packages (`present`, `absent`). |
| `bootstrap_gpu_drivers__package_version` | `""` | Specific version of the GPU driver to install. Leave empty for latest. |
| `bootstrap_gpu_drivers__persistence_mode_on` | `true` | Enable NVIDIA persistence mode to reduce latency in GPU access. |
| `bootstrap_gpu_drivers__skip_reboot` | `true` | Skip automatic reboot after driver installation if set to `true`. |
| `bootstrap_gpu_drivers__auto_detect` | `true` | Automatically detect GPUs and install corresponding drivers. Set to `false` for manual configuration. |
| `bootstrap_gpu_drivers__skip_driver_install_on_dgx` | `true` | Skip NVIDIA driver installation on DGX systems as they come pre-installed with the necessary drivers. |
| `bootstrap_gpu_drivers__install_container_toolkit_on_dgx` | `true` | Install NVIDIA Container Toolkit on DGX systems. |
| `bootstrap_gpu_drivers__epel_package` | `https://dl.fedoraproject.org/pub/epel/epel-release-latest-{{ ansible_facts['distribution_major_version'] }}.noarch.rpm` | URL for the EPEL repository package. |
| `bootstrap_gpu_drivers__epel_repo_key` | `https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-{{ ansible_facts['distribution_major_version'] }}` | URL for the EPEL repository GPG key. |
| `bootstrap_gpu_drivers__nvidia_module_file` | `/etc/modprobe.d/nvidia.conf` | Path to the NVIDIA module configuration file. |
| `bootstrap_gpu_drivers__nvidia_module_params` | `""` | Parameters to pass to the NVIDIA kernel module. |
| `bootstrap_gpu_drivers__nvidia_add_repos` | `true` | Add NVIDIA repositories for driver installation. |
| `bootstrap_gpu_drivers__nvidia_package_branch_default` | `"550"` | Default branch of the NVIDIA driver package to install. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_packages_suffix` | `-open` | Suffix for Ubuntu NVIDIA packages (e.g., `-open`). |
| `bootstrap_gpu_drivers__nvidia_ubuntu_install_from_cuda_repo` | `false` | Install NVIDIA drivers from the CUDA repository on Ubuntu. |
| `bootstrap_gpu_drivers__nvidia_install_container_toolkit` | `false` | Install NVIDIA Container Toolkit. |
| `bootstrap_gpu_drivers__nvidia_container_toolkit_version` | `""` | Specific version of the NVIDIA Container Toolkit to install. Leave empty for latest. |
| `bootstrap_gpu_drivers__nvidia_rhel_cuda_repo_baseurl` | `https://developer.download.nvidia.com/compute/cuda/repos/{{ _rhel_repo_dir }}/` | Base URL for NVIDIA CUDA repository on RHEL/CentOS. |
| `bootstrap_gpu_drivers__nvidia_rhel_cuda_repo_gpgkey` | `https://developer.download.nvidia.com/compute/cuda/repos/{{ _rhel_repo_dir }}/D42D0685.pub` | GPG key URL for NVIDIA CUDA repository on RHEL/CentOS. |
| `bootstrap_gpu_drivers__nvidia_rhel_branch` | `"{{ bootstrap_gpu_drivers__nvidia_package_branch \| d(bootstrap_gpu_drivers__nvidia_package_branch_default) }}"` | Branch of the NVIDIA driver package to install on RHEL/CentOS. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_repo_gpgkey_id_old` | `7fa2af80` | Old GPG key ID for Ubuntu CUDA repository. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_repo_baseurl` | `https://developer.download.nvidia.com/compute/cuda/repos/{{ _ubuntu_repo_dir }}` | Base URL for NVIDIA CUDA repository on Ubuntu. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_keyring_package` | `cuda-keyring_1.0-1_all.deb` | Name of the CUDA keyring package for Ubuntu. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_keyring_url` | `"{{ bootstrap_gpu_drivers__nvidia_ubuntu_cuda_repo_baseurl }}/{{ bootstrap_gpu_drivers__nvidia_ubuntu_cuda_keyring_package }}"` | URL for the CUDA keyring package on Ubuntu. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_package` | `cuda-drivers-{{ bootstrap_gpu_drivers__nvidia_ubuntu_branch }}` | Name of the NVIDIA driver package for Ubuntu. |
| `bootstrap_gpu_drivers__amd_use_case` | `"graphics,rocm"` | AMD GPU use case (e.g., `graphics`, `rocm`). |
| `bootstrap_gpu_drivers__amd_deb_package_base_url` | `"https://repo.radeon.com/amdgpu-install/latest/ubuntu/{{ ansible_facts['distribution_release'] \| lower }}"` | Base URL for AMD GPU installer on Debian/Ubuntu. |
| `bootstrap_gpu_drivers__amd_rhel_package_base_url` | `"https://repo.radeon.com/amdgpu-install/latest/rhel/{{ ansible_facts['distribution_major_version'] }}"` | Base URL for AMD GPU installer on RHEL/CentOS. |
| `bootstrap_gpu_drivers__restart_docker` | `false` | Restart Docker service after installing NVIDIA Container Toolkit if set to `true`. |
| `bootstrap_gpu_drivers__intel_install_compute` | `false` | Install Intel GPU compute runtime (oneAPI / Level Zero). |

## Usage

To use the `bootstrap_gpu_drivers` role, include it in your playbook and optionally override any of the default variables as needed. Here is an example:

```yaml
- hosts: all
  roles:
    - role: bootstrap_gpu_drivers
      vars:
        bootstrap_gpu_drivers__package_state: present
        bootstrap_gpu_drivers__persistence_mode_on: true
        bootstrap_gpu_drivers__install_container_toolkit_on_dgx: false
```

## Dependencies

The `bootstrap_gpu_drivers` role depends on the following Ansible collections:

- `community.general`
- `ansible.builtin`

Ensure these collections are installed in your environment before running the role.

```bash
ansible-galaxy collection install community.general
```

## Best Practices

1. **Backup Configuration**: Before applying this role, ensure you have backups of critical system configurations to prevent data loss.
2. **Test Environment**: Test the role in a non-production environment to verify its behavior and make any necessary adjustments.
3. **Reboot Handling**: If `bootstrap_gpu_drivers__skip_reboot` is set to `false`, be aware that the system will reboot after driver installation to apply changes.
4. **Secure Boot**: On systems with Secure Boot enabled, ensure that drivers are signed or disable Secure Boot in BIOS if necessary.

## Molecule Tests

This role includes Molecule tests to verify its functionality across different operating systems and configurations. To run the tests:

```bash
molecule test
```

Ensure you have Molecule installed along with the required dependencies before running the tests.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_gpu_drivers/defaults/main.yml)
- [tasks/install-amd.yml](../../roles/bootstrap_gpu_drivers/tasks/install-amd.yml)
- [tasks/install-intel.yml](../../roles/bootstrap_gpu_drivers/tasks/install-intel.yml)
- [tasks/install-nvidia.yml](../../roles/bootstrap_gpu_drivers/tasks/install-nvidia.yml)
- [tasks/main.yml](../../roles/bootstrap_gpu_drivers/tasks/main.yml)
- [tasks/install-container-toolkit.yml](../../roles/bootstrap_gpu_drivers/tasks/install-container-toolkit.yml)
- [tasks/install-debian.yml](../../roles/bootstrap_gpu_drivers/tasks/install-debian.yml)
- [tasks/install-redhat.yml](../../roles/bootstrap_gpu_drivers/tasks/install-redhat.yml)
- [tasks/install-ubuntu-cuda-repo.yml](../../roles/bootstrap_gpu_drivers/tasks/install-ubuntu-cuda-repo.yml)
- [tasks/install-ubuntu.yml](../../roles/bootstrap_gpu_drivers/tasks/install-ubuntu.yml)
- [handlers/main.yml](../../roles/bootstrap_gpu_drivers/handlers/main.yml)