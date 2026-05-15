```markdown
---
title: Enhance GPU Driver Installation in bootstrap_gpu_drivers Role
original_path: roles/bootstrap_gpu_drivers/TODO.md
category: Documentation
tags: [ansible, gpu-drivers, nvidia, amd, intel, debian, redhat]
---

# Enhance the "bootstrap_gpu_drivers" Role

## Objective

Enhance the `bootstrap_gpu_drivers` role to support installing NVIDIA, AMD, and Intel GPU drivers on Debian and RedHat family Linux distributions.

## Requirements

1. **Determine GPU Driver Type(s) to Install:**

   - **Inventory Driven:**
     - Use boolean variables in the role to specify GPU vendors:
       - `bootstrap_gpu_drivers__enable_nvidia`
       - `bootstrap_gpu_drivers__enable_amd`
       - `bootstrap_gpu_drivers__enable_intel`
     - Inventory maintainers place hosts into respective inventory groups to set these vendor enable booleans.
   
   - **Runtime Derived:**
     - Use `set_facts` to determine GPU vendors dynamically based on system information.
     - Handle cases where machines have multiple GPU vendors, e.g., a host with both AMD (Radeon) and NVIDIA (RTX 4060) GPUs.

   - Preference is given to the runtime derived method if the logic is reasonable.

2. **Install Appropriate Vendor GPU Packages:**

   Install correct GPU packages based on the detected GPU vendor and platform OS.

   ```shell
   root@control02:[docker]$ nvidia-smi
   Wed May 13 10:24:49 2026       
   +-----------------------------------------------------------------------------------------+
   | NVIDIA-SMI 580.142                Driver Version: 580.142        CUDA Version: 13.0     |
   +-----------------------------------------+------------------------+----------------------+
   | GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
   | Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
   |                                         |                        |               MIG M. |
   |=========================================+========================+======================|
   |   0  NVIDIA GeForce RTX 4060        On  |   00000000:01:00.0 Off |                  N/A |
   | 30%   43C    P8            N/A  /  115W |       2MiB /   8188MiB |      0%      Default |
   |                                         |                        |                  N/A |
   +-----------------------------------------+------------------------+----------------------+
   
   +-----------------------------------------------------------------------------------------+
   | Processes:                                                                              |
   |  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
   |        ID   ID                                                               Usage      |
   |=========================================================================================|
   |  No running processes found                                                             |
   +-----------------------------------------------------------------------------------------+

   root@control02:[docker]$ lspci | grep -E 'VGA|Display|3D'
   01:00.0 VGA compatible controller: NVIDIA Corporation AD107 [GeForce RTX 4060] (rev a1)
   04:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Raphael (rev d8)

   root@control02:[docker]$ lspci -nnk -s 04:00.0
   04:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Raphael [1002:164e] (rev d8)
       Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] Raphael [1002:164e]
       Kernel driver in use: amdgpu
       Kernel modules: amdgpu

   root@control02:[docker]$ glxinfo -B | grep -E "OpenGL|Device|Vendor"
   Command 'glxinfo' not found, but can be installed with:
   apt install mesa-utils
   ```

## Backlinks

- [Ansible Roles Documentation](/roles)
```

This improved Markdown document maintains the original information while adhering to clean and professional standards suitable for GitHub rendering.