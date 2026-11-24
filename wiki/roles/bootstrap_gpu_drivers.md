---
title: "Bootstrap GPU Drivers Role - Automate GPU Driver Installation and Configuration"
role: "bootstrap_gpu_drivers"
category: "System"
type: "Role"
summary: |
  The `bootstrap_gpu_drivers` role is designed to automate the installation and configuration of GPU drivers for NVIDIA, AMD, and Intel GPUs on various Linux distributions, including Ubuntu, RHEL, and Debian. This role detects the presence of GPUs, installs the appropriate drivers, and configures system settings to ensure optimal performance and compatibility.

variables: |
  | Variable Name | Default Value | Description |
  |---------------|---------------|-------------|
  | `bootstrap_gpu_drivers__package_state` | `present` | The state of the GPU driver packages to be installed. |
  | `bootstrap_gpu_drivers__package_version` | `""` | The specific version of the GPU drivers to install. |
  | `bootstrap_gpu_drivers__persistence_mode_on` | `true` | Whether to enable persistence mode for NVIDIA drivers. |
  | `bootstrap_gpu_drivers__skip_reboot` | `true` | Whether to skip rebooting after driver installation. |
  | `bootstrap_gpu_drivers__auto_detect` | `true` | Whether to automatically detect GPU vendors. |
  | `bootstrap_gpu_drivers__install_gpu_monitoring` | `true` | Whether to install GPU monitoring tools. |
  | `bootstrap_gpu_drivers__power_limit_enabled` | `false` | Whether to enable power limit settings for NVIDIA GPUs. |
  | `bootstrap_gpu_drivers__power_limit_watts` | `null` | The power limit in watts for NVIDIA GPUs. |
  | `bootstrap_gpu_drivers__epel_package` | `https://dl.fedoraproject.org/pub/epel/epel-release-latest-{{ ansible_facts['distribution_major_version'] }}.noarch.rpm` | URL for the EPEL package. |
  | `bootstrap_gpu_drivers__epel_repo_key` | `https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-{{ ansible_facts['distribution_major_version'] }}` | URL for the EPEL repository GPG key. |
  | `bootstrap_gpu_drivers__nvidia_module_file` | `/etc/modprobe.d/nvidia.conf` | Path to the NVIDIA module configuration file. |
  | `bootstrap_gpu_drivers__nvidia_module_params` | `""` | Parameters for the NVIDIA module. |
  | `bootstrap_gpu_drivers__nvidia_add_repos` | `true` | Whether to add NVIDIA repositories. |
  | `bootstrap_gpu_drivers__nvidia_package_branch_default` | `"550"` | Default branch for NVIDIA packages. |
  | `bootstrap_gpu_drivers__nvidia_ubuntu_packages_suffix` | `-open` | Suffix for NVIDIA packages on Ubuntu. |
  | `bootstrap_gpu_drivers__nvidia_ubuntu_install_from_cuda_repo` | `false` | Whether to install NVIDIA drivers from the CUDA repository on Ubuntu. |
  | `bootstrap_gpu_drivers__nvidia_install_container_toolkit` | `false` | Whether to install the NVIDIA container toolkit. |
  | `bootstrap_gpu_drivers__nvidia_container_toolkit_version` | `""` | The specific version of the NVIDIA container toolkit to install. |
  | `bootstrap_gpu_drivers__nvidia_rhel_cuda_repo_baseurl` | `https://developer.download.nvidia.com/compute/cuda/repos/{{ _rhel_repo_dir }}/` | Base URL for the NVIDIA CUDA repository on RHEL. |
  | `bootstrap_gpu_drivers__nvidia_rhel_cuda_repo_gpgkey` | `https://developer.download.nvidia.com/compute/cuda/repos/{{ _rhel_repo_dir }}/D42D0685.pub` | GPG key for the NVIDIA CUDA repository on RHEL. |
  | `bootstrap_gpu_drivers__nvidia_rhel_branch` | `{{ bootstrap_gpu_drivers__nvidia_package_branch | d(bootstrap_gpu_drivers__nvidia_package_branch_default) }}` | Branch for NVIDIA packages on RHEL. |
  | `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_repo_gpgkey_id_old` | `7fa2af80` | Old GPG key ID for the NVIDIA CUDA repository on Ubuntu. |
  | `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_repo_baseurl` | `https://developer.download.nvidia.com/compute/cuda/repos/{{ _ubuntu_repo_dir }}` | Base URL for the NVIDIA CUDA repository on Ubuntu. |
  | `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_keyring_package` | `cuda-keyring_1.0-1_all.deb` | CUDA keyring package for Ubuntu. |
  | `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_keyring_url` | `{{ bootstrap_gpu_drivers__nvidia_ubuntu_cuda_repo_baseurl }}/{{ bootstrap_gpu_drivers__nvidia_ubuntu_cuda_keyring_package }}` | URL for the CUDA keyring package on Ubuntu. |
  | `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_package` | `cuda-drivers-{{ bootstrap_gpu_drivers__nvidia_ubuntu_branch }}` | CUDA package for Ubuntu. |
  | `bootstrap_gpu_drivers__amd_use_case` | `"graphics,rocm"` | Use case for AMD GPUs (graphics, ROCm, or both). |
  | `bootstrap_gpu_drivers__amd_deb_package_base_url` | `https://repo.radeon.com/amdgpu-install/latest/ubuntu/{{ ansible_facts['distribution_release'] | lower }}` | Base URL for AMD packages on Debian/Ubuntu. |
  | `bootstrap_gpu_drivers__amd_rhel_package_base_url` | `https://repo.radeon.com/amdgpu-install/latest/rhel/{{ ansible_facts['distribution_major_version'] }}` | Base URL for AMD packages on RHEL. |
  | `bootstrap_gpu_drivers__restart_docker` | `false` | Whether to restart Docker after installing the NVIDIA container toolkit. |
  | `bootstrap_gpu_drivers__intel_install_compute` | `false` | Whether to install Intel compute runtime. |
  | `_ubuntu_repo_dir` | `{{ ansible_facts['distribution'] | lower }}{{ ansible_facts['distribution_version'] | replace('.', '') }}/{{ ansible_facts['architecture'] }}` | Directory for Ubuntu repositories. |
  | `_rhel_repo_dir` | `rhel{{ ansible_facts['distribution_major_version'] }}/{{ ansible_facts['architecture'] }}` | Directory for RHEL repositories. |
  | `_debian_codename` | `{{ ansible_facts['distribution_release'] | lower | default('bookworm') }}` | Codename for Debian distributions. |

usage: |
  To use the `bootstrap_gpu_drivers` role, include it in your playbook and set the desired variables. The role will automatically detect the presence of GPUs and install the appropriate drivers. You can override default values by setting variables in your playbook or inventory.

  Example playbook:
  ```yaml
  ---
  - hosts: gpu_servers
    roles:
      - role: bootstrap_gpu_drivers
        vars:
          bootstrap_gpu_drivers__package_state: present
          bootstrap_gpu_drivers__package_version: "515.65.01"
          bootstrap_gpu_drivers__persistence_mode_on: true
          bootstrap_gpu_drivers__skip_reboot: false
          bootstrap_gpu_drivers__auto_detect: true
          bootstrap_gpu_drivers__install_gpu_monitoring: true
          bootstrap_gpu_drivers__power_limit_enabled: false
          bootstrap_gpu_drivers__power_limit_watts: null
  ```

dependencies: |
  The `bootstrap_gpu_drivers` role does not have any specific dependencies, but it requires the following modules to be available on the target system:
  - `community.general.modprobe` (version 3.0.0 or later)
  - `community.general.kernel_blacklist` (version 3.0.0 or later)

best_practices: |
  - Always test the role on a staging environment before deploying it to production.
  - Ensure that the target system has the necessary kernel headers and development tools installed.
  - Check for compatibility with existing drivers before installing new ones.
  - Monitor the system after installing the drivers to ensure that they are working correctly.
  - Consider setting up a reboot schedule to apply driver updates without disrupting services.

troubleshooting: |
  - If the role fails to detect GPUs, ensure that the system has the necessary hardware and that it is properly connected.
  - If the role fails to install drivers, check that the repositories are accessible and that the system has internet access.
  - If the role fails to configure the system, check that the necessary modules are available and that the system has the necessary permissions.

backlinks: |
  - [.inclusivity.yml](../../.inclusivity.yml)
  - [site.yml](../../site.yml)
  - [.wiki-config.yml](../../.wiki-config.yml)
  - [gpu_host_rtx_24gb.yml](../../inventory/PROD/group_vars/gpu_host_rtx_24gb.yml)
  - [docker_gpu_nvidia.yml](../../inventory/PROD/group_vars/docker_gpu_nvidia.yml)
  - [docker_stack_llm.yml](../../inventory/PROD/group_vars/docker_stack_llm.yml)
  - [gpu_host_rtx_8gb.yml](../../inventory/PROD/group_vars/gpu_host_rtx_8gb.yml)
  - [gpu_host_gb10_128gb.yml](../../inventory/PROD/group_vars/gpu_host_gb10_128gb.yml)
  - [gpu_host_rtx_24gb.yml](../../inventory/group_vars/gpu_host_rtx_24gb.yml)
  - [docker_gpu_nvidia.yml](../../inventory/group_vars/docker_gpu_nvidia.yml)