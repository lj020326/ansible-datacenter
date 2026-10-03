---
title: Enhance the "bootstrap_gpu_drivers" Role
harvested_date: '2026-08-07T18:07:09.228288+00:00'
original_path: roles/bootstrap_gpu_drivers/TODO.md
source_type: legacy_markdown
category: documentation
tags: [gpu, drivers, debian, redhat, nvidia, amd, intel]
---

# Enhance the "bootstrap_gpu_drivers" Role

This document outlines the plan to enhance the "bootstrap_gpu_drivers" role to support installing NVIDIA, AMD, and Intel GPU drivers on Debian and RedHat family Linux distributions.

## Objectives

1. Determine the best method to identify the GPU driver type(s) to install.
2. Ensure appropriate vendor GPU packages are installed based on the identified GPU vendor and platform OS.

## Method to Identify GPU Driver Type(s)

### Options

1. **Inventory-Driven Approach**
   - Use boolean GPU vendor options in the role:
     - `bootstrap_gpu_drivers__enable_nvidia`
     - `bootstrap_gpu_drivers__enable_amd`
     - `bootstrap_gpu_drivers__enable_intel`
   - Inventory maintainer places the host into the respective inventory groups to set the vendor enable booleans.

2. **Runtime-Derived Approach**
   - Use `set_facts` runtime-derived boolean variables to determine the GPU vendor(s).

3. **Handling Multiple GPU Vendors**
   - Consider use cases for machines with multiple GPU vendors, such as `control02` which has both AMD (Radeon) and NVIDIA (RTX 4060) GPUs.

### Preferred Approach

The runtime-derived approach is preferable as long as the logic is reasonable.

## Installing Appropriate Vendor GPU Packages

We need to be able to install the correct GPU packages based on the GPU vendor and platform OS. Below is an example of the current setup:

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

## Action Items

- [ ] Research and document the best method to identify GPU driver types.
- [ ] Implement the preferred approach for identifying GPU driver types.
- [ ] Test the implementation on different GPU vendors and OS platforms.
- [ ] Document the process for installing appropriate vendor GPU packages.
- [ ] Update the role with the new implementation.

## Responsibilities

- [ ] Assign a team member to research and document the best method to identify GPU driver types.
- [ ] Assign a team member to implement the preferred approach for identifying GPU driver types.
- [ ] Assign a team member to test the implementation on different GPU vendors and OS platforms.
- [ ] Assign a team member to document the process for installing appropriate vendor GPU packages.
- [ ] Assign a team member to update the role with the new implementation.

## Timeline

- [ ] Research and documentation: [Insert Date]
- [ ] Implementation: [Insert Date]
- [ ] Testing: [Insert Date]
- [ ] Documentation: [Insert Date]
- [ ] Role Update: [Insert Date]

## References

- [ ] Add references or additional resources that may be helpful.

## Conclusion

This document outlines the plan to enhance the "bootstrap_gpu_drivers" role. By following the outlined objectives, action items, and responsibilities, we can ensure that the role is enhanced to support installing NVIDIA, AMD, and Intel GPU drivers on Debian and RedHat family Linux distributions.