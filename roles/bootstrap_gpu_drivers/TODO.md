
Enhance the "bootstrap_gpu_drivers" role to support installing nvidia, amd and intel gpu drivers on debian and redhat family linux distributions

1. Need to determine best method to derive the gpu driver type(s) to install:
   - inventory driven - by use of boolean gpu vendor options into role
     - `bootstrap_gpu_drivers__enable_nvidia`, `bootstrap_gpu_drivers__enable_amd`,  `bootstrap_gpu_drivers__enable_intel`
     - inventory maintainer places the host into the respective inventory groups to set the vendor enable booleans
   - `set_facts` runtime derived boolean variables to determine the gpu vendor(s)
   - handle use cases for machines with multiple gpu vendors 
     - e.g., `control02` has both amd (Radeon) and nvidia (RTX 4060) gpus

   Derived would be more preferable as long as the logic is reasonable

2. appropriate vendor gpu packages are installed based on the boolean vendor type options 

    We want to be able to install the correct gpu packages based on gpu vendor and platform OS
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
    
