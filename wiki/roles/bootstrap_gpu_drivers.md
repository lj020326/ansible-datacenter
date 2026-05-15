---
title: "bootstrap_gpu_drivers Role"
role: bootstrap_gpu_drivers
category: Ansible Roles
type: Documentation
tags: ansible, gpu, drivers, nvidia, amd, intel

---

## Summary

The `bootstrap_gpu_drivers` role is designed to automate the installation and configuration of GPU drivers for NVIDIA, AMD, and Intel GPUs across various Linux distributions. It supports automatic detection of GPU vendors and provides options to customize driver installations based on specific requirements such as persistence mode, package versions, and container toolkit integration.

## Variables

| Variable Name                                      | Default Value                                                                                         | Description                                                                                                                                                                                                 |
|----------------------------------------------------|-------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_gpu_drivers__package_state`             | `present`                                                                                             | Desired state of the GPU driver packages (`present`, `absent`).                                                                                                                                             |
| `bootstrap_gpu_drivers__package_version`           | `""`                                                                                                  | Specific version of the GPU driver package to install. Leave empty for latest version.                                                                                                                    |
| `bootstrap_gpu_drivers__persistence_mode_on`       | `true`                                                                                                | Enable or disable NVIDIA persistence mode.                                                                                                                                                                    |
| `bootstrap_gpu_drivers__skip_reboot`               | `true`                                                                                                | Skip rebooting the system after driver installation if set to `true`.                                                                                                                                         |
| `bootstrap_gpu_drivers__auto_detect`               | `true`                                                                                                | Automatically detect GPU vendors using lspci. If no GPUs are detected, manual enabling is required.                                                                                                          |
| `bootstrap_gpu_drivers__skip_driver_install_on_dgx`| `true`                                                                                                | Skip NVIDIA driver installation on DGX systems as they come pre-installed with the necessary drivers.                                                                                                      |
| `bootstrap_gpu_drivers__install_container_toolkit_on_dgx` | `true`                                                                                             | Install NVIDIA Container Toolkit on DGX systems.                                                                                                                                                              |
| `bootstrap_gpu_drivers__epel_package`              | `https://dl.fedoraproject.org/pub/epel/epel-release-latest-{{ ansible_facts['distribution_major_version'] }}.noarch.rpm` | URL to the EPEL repository package for RedHat-based distributions.                                                                                                                                          |
| `bootstrap_gpu_drivers__epel_repo_key`             | `https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-{{ ansible_facts['distribution_major_version'] }}`  | URL to the GPG key for EPEL repository.                                                                                                                                                                     |
| `bootstrap_gpu_drivers__nvidia_module_file`        | `/etc/modprobe.d/nvidia.conf`                                                                         | Path to the modprobe configuration file for NVIDIA drivers.                                                                                                                                                 |
| `bootstrap_gpu_drivers__nvidia_module_params`      | `""`                                                                                                  | Parameters to pass to the NVIDIA kernel module.                                                                                                                                                             |
| `bootstrap_gpu_drivers__nvidia_add_repos`          | `true`                                                                                                | Add NVIDIA CUDA repository during installation.                                                                                                                                                               |
| `bootstrap_gpu_drivers__nvidia_package_branch_default` | `"550"`                                                                                            | Default branch of the NVIDIA driver package to install if not specified otherwise.                                                                                                                          |
| `bootstrap_gpu_drivers__nvidia_ubuntu_packages_suffix` | `-open`                                                                                            | Suffix for Ubuntu NVIDIA packages (e.g., `-open`).                                                                                                                                                          |
| `bootstrap_gpu_drivers__nvidia_ubuntu_install_from_cuda_repo` | `false`                                                                                         | Install NVIDIA drivers from the CUDA repository on Ubuntu.                                                                                                                                                |
| `bootstrap_gpu_drivers__nvidia_install_container_toolkit` | `false`                                                                                           | Install NVIDIA Container Toolkit alongside GPU drivers.                                                                                                                                                     |
| `bootstrap_gpu_drivers__nvidia_container_toolkit_version` | `""`                                                                                              | Specific version of the NVIDIA Container Toolkit to install. Leave empty for latest version.                                                                                                              |
| `bootstrap_gpu_drivers__nvidia_rhel_cuda_repo_baseurl` | `https://developer.download.nvidia.com/compute/cuda/repos/{{ _rhel_repo_dir }}/`                 | Base URL for the NVIDIA CUDA repository on RedHat-based distributions.                                                                                                                                    |
| `bootstrap_gpu_drivers__nvidia_rhel_cuda_repo_gpgkey` | `https://developer.download.nvidia.com/compute/cuda/repos/{{ _rhel_repo_dir }}/D42D0685.pub`      | URL to the GPG key for NVIDIA CUDA repository on RedHat-based distributions.                                                                                                                              |
| `bootstrap_gpu_drivers__nvidia_rhel_branch`        | `"{{ bootstrap_gpu_drivers__nvidia_package_branch \| d(bootstrap_gpu_drivers__nvidia_package_branch_default) }}"` | Branch of the NVIDIA driver package to install on RedHat-based distributions.                                                                                                                               |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_repo_gpgkey_id_old` | `7fa2af80`                                                                                    | ID of the old GPG key for Ubuntu CUDA repository.                                                                                                                                                           |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_repo_baseurl` | `https://developer.download.nvidia.com/compute/cuda/repos/{{ _ubuntu_repo_dir }}`             | Base URL for the NVIDIA CUDA repository on Ubuntu.                                                                                                                                                          |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_keyring_package` | `cuda-keyring_1.0-1_all.deb`                                                                      | Name of the CUDA keyring package for Ubuntu.                                                                                                                                                                |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_keyring_url` | `"{{ bootstrap_gpu_drivers__nvidia_ubuntu_cuda_repo_baseurl }}/{{ bootstrap_gpu_drivers__nvidia_ubuntu_cuda_keyring_package }}"`              | URL to the CUDA keyring package for Ubuntu.                                                                                                                                                                 |
| `bootstrap_gpu_drivers__nvidia_ubuntu_cuda_package` | `cuda-drivers-{{ bootstrap_gpu_drivers__nvidia_ubuntu_branch }}"`                                      | Name of the NVIDIA driver package for Ubuntu.                                                                                                                                                               |
| `bootstrap_gpu_drivers__amd_use_case`              | `"graphics,rocm"`                                                                                     | Use case for AMD GPU installation (e.g., `graphics`, `rocm`).                                                                                                                                             |
| `bootstrap_gpu_drivers__amd_deb_package_base_url`  | `"https://repo.radeon.com/amdgpu-install/latest/ubuntu/{{ ansible_facts['distribution_release'] \| lower }}"` | Base URL for the AMD GPU installer package on Debian/Ubuntu.                                                                                                                                              |
| `bootstrap_gpu_drivers__amd_rhel_package_base_url` | `"https://repo.radeon.com/amdgpu-install/latest/rhel/{{ ansible_facts['distribution_major_version'] }}"`  | Base URL for the AMD GPU installer package on RedHat-based distributions.                                                                                                                                   |
| `bootstrap_gpu_drivers__restart_docker`            | `false`                                                                                               | Restart Docker service after installing NVIDIA Container Toolkit if set to `true`.                                                                                                                        |
| `bootstrap_gpu_drivers__intel_install_compute`     | `false`                                                                                               | Install Intel GPU compute runtime (e.g., oneAPI, Level Zero) if set to `true`.                                                                                                                            |

## Usage

To use the `bootstrap_gpu_drivers` role, include it in your playbook and customize variables as needed. Here is an example playbook:

```yaml
---
- name: Bootstrap GPU Drivers on Target Hosts
  hosts: all
  become: yes
  roles:
    - role: bootstrap_gpu_drivers
      vars:
        bootstrap_gpu_drivers__package_state: present
        bootstrap_gpu_drivers__persistence_mode_on: true
        bootstrap_gpu_drivers__install_container_toolkit_on_dgx: false
```

## Dependencies

- `community.general.modprobe`
- `ansible.builtin.package`
- `ansible.builtin.apt`
- `ansible.builtin.dnf`
- `ansible.builtin.yum_repository`
- `ansible.builtin.rpm_key`
- `ansible.builtin.get_url`
- `ansible.builtin.stat`
- `ansible.builtin.shell`
- `ansible.builtin.command`
- `community.general.kernel_blacklist`

## Best Practices

1. **Backup Configuration**: Always back up existing configurations before applying changes.
2. **Test in Staging**: Test the role in a staging environment to ensure it meets your requirements and does not cause any issues.
3. **Use Specific Versions**: Specify package versions for stability and compatibility.
4. **Monitor Logs**: Monitor system logs after installation to verify that drivers are loaded correctly.

## Molecule Tests

This role includes Molecule tests to validate its functionality across different operating systems. To run the tests, ensure you have Molecule installed and execute:

```bash
molecule test
```

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