---
title: "Bootstrap GPU Drivers Role"
role: roles/bootstrap_gpu_drivers
category: System
type: ansible-role
tags: [ansible, role, bootstrap_gpu_drivers]
---

```yaml
---
title: "Bootstrap GPU Drivers Role"
role: "bootstrap_gpu_drivers"
category: "System"
type: "Role"

summary: |
  The `bootstrap_gpu_drivers` role is designed to automate the installation and configuration of GPU drivers for NVIDIA, AMD, and Intel GPUs on various Linux distributions. This role handles the detection of GPU hardware, installs the appropriate drivers, and configures persistence mode and container toolkit support as needed. It also includes tasks for installing GPU monitoring tools and handling special cases like DGX systems.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_gpu_drivers__package_state` | `present` | The state of the GPU driver packages (present or absent). |
| `bootstrap_gpu_drivers__package_version` | `""` | The specific version of the GPU driver to install. |
| `bootstrap_gpu_drivers__persistence_mode_on` | `true` | Whether to enable persistence mode for NVIDIA drivers. |
| `bootstrap_gpu_drivers__skip_reboot` | `true` | Whether to skip rebooting the system after driver installation. |
| `bootstrap_gpu_drivers__auto_detect` | `true` | Whether to automatically detect GPU hardware. |
| `bootstrap_gpu_drivers__install_gpu_monitoring` | `true` | Whether to install GPU monitoring tools. |
| `__bootstrap_gpu_drivers__is_dgx` | `{{ (ansible_facts.product_name \| default('', true) \| regex_search('(?i)DGX|Ascent|Grace|Blackwell|gx10')) is not none or ('dgx' in (ansible_facts.os_family \| default('', true) \| lower)) or (ansible_facts.machine == 'aarch64' and 'nvidia' in (ansible_facts.product_version \| default('', true) \| lower)) }}` | Internal variable to detect if the system is a DGX system. |
| `bootstrap_gpu_drivers__skip_driver_install_on_dgx` | `true` | Whether to skip driver installation on DGX systems. |
| `bootstrap_gpu_drivers__install_container_toolkit_on_dgx` | `true` | Whether to install the NVIDIA container toolkit on DGX systems. |
| `bootstrap_gpu_drivers__epel_package` | `https://dl.fedoraproject.org/pub/epel/epel-release-latest-{{ ansible_facts['distribution_major_version'] }}.noarch.rpm` | URL for the EPEL package. |
| `bootstrap_gpu_drivers__epel_repo_key` | `https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-{{ ansible_facts['distribution_major_version'] }}` | URL for the EPEL repository key. |
| `bootstrap_gpu_drivers__nvidia_module_file` | `/etc/modprobe.d/nvidia.conf` | Path to the NVIDIA module configuration file. |
| `bootstrap_gpu_drivers__nvidia_module_params` | `""` | Parameters for the NVIDIA module. |
| `bootstrap_gpu_drivers__nvidia_add_repos` | `true` | Whether to add NVIDIA repositories. |
| `bootstrap_gpu_drivers__nvidia_package_branch_default` | `"550"` | Default branch for NVIDIA packages. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_packages_suffix` | `-open` | Suffix for NVIDIA packages on Ubuntu. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_install_from_cuda_repo` | `false` | Whether to install NVIDIA packages from the CUDA repository on Ubuntu. |
| `bootstrap_gpu_drivers__nvidia_install_container_toolkit` | `false` | Whether to install the NVIDIA container toolkit. |
| `bootstrap_gpu_drivers__nvidia_container_toolkit_version` | `""` | Specific version of the NVIDIA container toolkit to install. |
| `bootstrap_gpu_drivers__nvidia_rhel_cuda_repo_baseurl` | `https://developer.download.nvidia.com/compute/cuda/repos/{{ _rhel_repo_dir }}/` | Base URL for the NVIDIA CUDA repository on RHEL. |
| `bootstrap_gpu_drivers__nvidia_rhel_cuda_repo_gpgkey` | `https://developer.download.nvidia.com/compute/cuda/repos/{{ _rhel_repo_dir }}/D42D0685.pub` | URL for the NVIDIA CUDA repository GPG key on RHEL. |
| `bootstrap_gpu_drivers__nvidia_rhel_branch` | `{{ bootstrap_gpu_drivers__nvidia_package_branch \| d(bootstrap_gpu_drivers__nvidia_package_branch_default) }}` | Branch for NVIDIA packages on RHEL. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_repo_gpgkey_id_old` | `7fa2af80` | Old GPG key ID for the NVIDIA CUDA repository on Ubuntu. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_repo_baseurl` | `https://developer.download.nvidia.com/compute/cuda/repos/{{ _ubuntu_repo_dir }}` | Base URL for the NVIDIA CUDA repository on Ubuntu. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_keyring_package` | `cuda-keyring_1.0-1_all.deb` | CUDA keyring package for Ubuntu. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_keyring_url` | `{{ bootstrap_gpu_drivers__nvidia_ubuntu_cuda_repo_baseurl }}/{{ bootstrap_gpu_drivers__nvidia_ubuntu_cuda_keyring_package }}` | URL for the CUDA keyring package on Ubuntu. |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_package` | `cuda-drivers-{{ bootstrap_gpu_drivers__nvidia_ubuntu_branch }}` | CUDA package for Ubuntu. |
| `bootstrap_gpu_drivers__amd_use_case` | `"graphics,rocm"` | Use case for AMD GPU drivers (graphics, rocm, or graphics only). |
| `bootstrap_gpu_drivers__amd_deb_package_base_url` | `https://repo.radeon.com/amdgpu-install/latest/ubuntu/{{ ansible_facts['distribution_release'] | lower }}` | Base URL for AMD DEB packages. |
| `bootstrap_gpu_drivers__amd_rhel_package_base_url` | `https://repo.radeon.com/amdgpu-install/latest/rhel/{{ ansible_facts['distribution_major_version'] }}` | Base URL for AMD RHEL packages. |
| `bootstrap_gpu_drivers__restart_docker` | `false` | Whether to restart Docker after installing the NVIDIA container toolkit. |
| `bootstrap_gpu_drivers__intel_install_compute` | `false` | Whether to install Intel compute runtime. |
| `_ubuntu_repo_dir` | `{{ ansible_facts['distribution'] | lower }}{{ ansible_facts['distribution_version'] \| replace('.', '') }}/{{ ansible_facts['architecture'] }}` | Directory for Ubuntu repositories. |
| `_rhel_repo_dir` | `rhel{{ ansible_facts['distribution_major_version'] }}/{{ ansible_facts['architecture'] }}` | Directory for RHEL repositories. |
| `_debian_codename` | `{{ ansible_facts['distribution_release'] | lower | default('bookworm') }}` | Codename for Debian distributions. |

## Usage

To use the `bootstrap_gpu_drivers` role, include it in your playbook and configure the variables as needed:

```yaml
- hosts: gpu_servers
  roles:
    - role: bootstrap_gpu_drivers
      vars:
        bootstrap_gpu_drivers__package_state: present
        bootstrap_gpu_drivers__package_version: "515"
        bootstrap_gpu_drivers__persistence_mode_on: true
        bootstrap_gpu_drivers__skip_reboot: false
        bootstrap_gpu_drivers__auto_detect: true
        bootstrap_gpu_drivers__install_gpu_monitoring: true
        bootstrap_gpu_drivers__amd_use_case: "graphics,rocm"
        bootstrap_gpu_drivers__intel_install_compute: false
```

## Dependencies

This role requires the following dependencies:

- `community.general` collection for kernel blacklisting tasks.

## Best Practices

- Ensure that the system has internet access to download the necessary packages and repositories.
- Test the role on a staging environment before deploying it to production.
- Monitor the system after driver installation to ensure that the drivers are working correctly.
- Regularly update the role to include the latest GPU drivers and dependencies.
- Verify that the appropriate GPU drivers are installed for your specific hardware configuration.
- Check for any specific requirements or dependencies for your Linux distribution.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_gpu_drivers/defaults/main.yml)
- [tasks/install-amd.yml](../../roles/bootstrap_gpu_drivers/tasks/install-amd.yml)
- [tasks/install-gpu-monitoring.yml](../../roles/bootstrap_gpu_drivers/tasks/install-gpu-monitoring.yml)
- [tasks/install-intel.yml](../../roles/bootstrap_gpu_drivers/tasks/install-intel.yml)
- [tasks/install-nvidia.yml](../../roles/bootstrap_gpu_drivers/tasks/install-nvidia.yml)
- [tasks/main.yml](../../roles/bootstrap_gpu_drivers/tasks/main.yml)
- [tasks/install-container-toolkit.yml](../../roles/bootstrap_gpu_drivers/tasks/install-container-toolkit.yml)
- [tasks/install-debian.yml](../../roles/bootstrap_gpu_drivers/tasks/install-debian.yml)
- [tasks/install-redhat.yml](../../roles/bootstrap_gpu_drivers/tasks/install-redhat.yml)
- [tasks/install-ubuntu-cuda-repo.yml](../../roles/bootstrap_gpu_drivers/tasks/install-ubuntu-cuda-repo.yml)
- [tasks/install-ubuntu.yml](../../roles/bootstrap_gpu_drivers/tasks/install-ubuntu.yml)
- [handlers/main.yml](../../roles/bootstrap_gpu_drivers/handlers/main.yml)