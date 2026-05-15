
```yaml
host-info:
  - control02:
      processor: AMD Ryzen 9 7945HX with Radeon Graphics, 32 cores
      gpu-01: RTX 4060
      gpu-02:
        name: Radeon Graphics
        info: |
          lspci -nnk -s 04:00.0
            04:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Raphael [1002:164e] (rev d8)
            Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] Raphael [1002:164e]
            Kernel driver in use: amdgpu
            Kernel modules: amdgpu
      memory_desc: 2x48GB DDR5 SO-DIMM
      memory: 96GB
      memory_type: GDDR5
      storage:
        disk1:
          size: 1 TB
          type: M.2 2230 SSD
      pci: PCIe 5.0X16
      description: |
        MINISFORUM 795S7 Mini PC, 
        AMD Ryzen 9 7945HX(16 C/32 T),
        8GB GDDR6, 
        RTX 4060,
        2x48GB DDR5 SO-DIMM
        1TB SSD,
        PCIe 5.0X16, 
  - media01:
      processor: Intel(R) Core(TM) i7-8559U CPU @ 2.70GHz, 8 cores
      memory: 16GB
      memory_type: DDR4
      description: Intel NUC MINI PC NUC7i5BNK i5-7260U 2.2GHz 16GB DDR4
      storage:
        disk1:
          size: 1 TB
          type: M.2 2230 SSD
  - media02:
      processor: Intel(R) Core(TM) Ultra 9 185H, 22 cores
      memory_desc: 2x48GB DDR5 SO-DIMM
      memory: 32GB
      memory_type: GDDR5
      storage:
        disk1:
          size: 1 TB
          type: M.2 2230 SSD
      description: |
        ASUS NUC 14 PRO+ Intel Core Ultra 9 185H,
        32GB Ram and 1TB NVME
  - gpu01:
      processor: Cortex-X925 10 cores/A725 10 cores
      gpu-01: NVIDIA GB10
      memory: 128GB
      memory_type: LPDDR5x RAM
      storage:
        disk1:
          size: 4 TB
          type: M.2 CORSAIR 4TB MP700 NVME 2242
      description: |
        ASUS Ascent GX10 Personal
        AI Supercomputer with
        NVIDIA GB10 Superchip,
        128GB LPDDR5x RAM, 
        4TB NVMe 2242 SSD,
        PCIe G4x4, Wi-Fi 7 & BT5.4,
        DGX OS
  - gpu02:
      processor: AMD Ryzen 5 5600X 6-Core Processor, 12 cores
      gpu-01: NVIDIA RTX 3090
      memory: 64GB
      memory_type: DDR4-3200 RGB SDRAM
      storage:
        disk1:
          size: 256 GB
          type: M.2 256 GB PCIe NVMe SSD
        disk2:
          size: 2 TB
          type: SSD
      description: |
        HP OMEN 30L Gaming Desktop PC
        RTX 3090 Ryzen 5 5600x

```
