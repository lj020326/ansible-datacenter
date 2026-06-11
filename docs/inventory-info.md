
```yaml
all:
  hosts:
    esx00:
      description: |
        Supermicro E200-8D Xeon D-1528 w/ 128GB RAM & 1TB M2 SSD
      groups:
        - machine_baremetal
        - os_baremetal
        - vmware_cluster
        - vmware_cluster_management
        - vmware_esx_host
        - vmware_physical_esx_host
        - vmware_vsphere        
    esx01:
      description: |
        Supermicro E200-8D Xeon D-1528 w/ 128GB RAM & 1TB M2 SSD
      groups:
        - machine_baremetal
        - os_baremetal
        - vmware_cluster
        - vmware_cluster_management
        - vmware_esx_host
        - vmware_physical_esx_host
        - vmware_vsphere        
    esx02:
      description: |
        Supermicro E200-8D Xeon D-1528 w/ 128GB RAM & 1TB M2 SSD
      groups:
        - machine_baremetal
        - os_baremetal
        - vmware_cluster
        - vmware_cluster_management
        - vmware_esx_host
        - vmware_physical_esx_host
        - vmware_vsphere        
    syse3018s01:
      description: |
        Supermicro SYS-E301-8D Xeon D-1528 128GB RAM 2TB SSD NVIDIA P1000 10Gbe Server
      acquired_date: Dec 09, 2022
      notes: possible setup as kubernetes controller machine
      groups:
        - unassigned
    control02:
      description: |
        MINISFORUM 795S7 Mini PC, 
        AMD Ryzen 9 7945HX(16 C/32 T),
        8GB GDDR6, 
        RTX 4060,
        2x48GB DDR5 SO-DIMM
        1TB SSD,
        PCIe 5.0X16, 
      processor: AMD Ryzen 9 7945HX with Radeon Graphics, 32 cores
      gpu-01:
        name: RTX 4060
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
      groups:
        - ansible_controller
        - backup_server
        - ca_domain
        - ca_domain_int_johnson
        - ca_keystore
        - cert_host
        - common_groups
        - common_groups_os
        - common_groups_os_linux
        - control_host
        - docker
        - docker_awx
        - docker_gpu
        - docker_gpu_nvidia
        - docker_stack
        - docker_stack_archiva
        - docker_stack_auth
        - docker_stack_control
        - docker_stack_domain
        - docker_stack_domain_johnson
        - docker_stack_env
        - docker_stack_env_admin
        - docker_stack_gitea
        - docker_stack_jenkins
        - docker_stack_jenkins_jcac
        - docker_stack_jenkins_jcac_admin
        - docker_stack_keycloak
        - docker_stack_llm
        - docker_stack_openbao
        - docker_stack_openldap
        - docker_stack_registry_passthru
        - docker_stack_samba
        - docker_stack_vault
        - docker_swarm
        - docker_swarm_control
        - docker_swarm_leader
        - docker_swarm_leader_control
        - docker_swarm_llm
        - firewall_zone
        - firewall_zone_docker
        - firewall_zone_internal
        - gpu_host
        - gpu_host_prod
        - jenkins_agent
        - ldap_network
        - ldap_server
        - ldap_server_prod
        - linux_ip_static
        - llm_host
        - llm_host_prod
        - machine_baremetal
        - nfs_network
        - nfs_server
        - nfs_server_control
        - nfs_server_control_prod
        - ntp_network
        - os_baremetal
        - os_baremetal_linux
        - os_baremetal_linux_prod
        - os_linux
        - postfix_network
        - postfix_server
        - postfix_server_admin
        - step_ca_network
    vcontrol01:
      description: |
        vmware vm: 2 CPUs with 2 cores per socket
        Memory 16 GB
        Hard disk: 150 GB | Thick Provision Lazy Zeroed
      processor: Intel(R) Xeon(R) CPU D-1528 @ 1.90GHz, 2 cores
      storage:
        disk1:
          size: 150 GB
      groups:
        - ansible_controller
        - ca_domain
        - ca_domain_int_dettonville
        - cert_host
        - common_groups
        - common_groups_os
        - common_groups_os_linux
        - control_host
        - docker
        - docker_awx
        - docker_stack
        - docker_stack_admin
        - docker_stack_admin_prod
        - docker_stack_archiva
        - docker_stack_auth
        - docker_stack_domain
        - docker_stack_domain_dettonville
        - docker_stack_env
        - docker_stack_env_prod
        - docker_stack_gitea
        - docker_stack_jenkins
        - docker_stack_jenkins_controller
        - docker_stack_jenkins_controller_prod
        - docker_stack_keycloak
        - docker_stack_openbao
        - docker_stack_openldap
        - docker_stack_plane
        - docker_stack_registry_passthru
        - docker_stack_samba
        - docker_stack_vault
        - docker_stack_wekan
        - firewall_zone
        - firewall_zone_docker
        - firewall_zone_internal
        - iscsi_client
        - jenkins_agent
        - ldap_network
        - ldap_server
        - ldap_server_prod
        - machine_vm
        - nfs_network
        - nfs_server
        - nfs_server_control
        - nfs_server_control_prod
        - ntp_network
        - os_linux
        - postfix_network
        - step_ca_network
        - vmware_image_linux
        - vmware_image_ubuntu
        - vmware_image_ubuntu_24
        - vmware_vm
        - vmware_vm_linux
    media01:
      description: Intel NUC MINI PC NUC7i5BNK i5-7260U 2.2GHz 16GB DDR4
      processor: Intel(R) Core(TM) i7-8559U CPU @ 2.70GHz, 8 cores
      memory: 16GB
      memory_type: DDR4
      storage:
        disk1:
          size: 1 TB
          type: M.2 2230 SSD
      groups:
        - ca_domain
        - ca_domain_int_johnson
        - cert_host
        - common_groups
        - common_groups_os
        - common_groups_os_linux
        - docker
        - docker_registry
        - docker_stack
        - docker_stack_domain
        - docker_stack_domain_johnson
        - docker_stack_openldap
        - docker_stack_plex
        - docker_stack_samba
        - firewall_zone
        - firewall_zone_docker
        - firewall_zone_internal
        - ldap_network
        - linux_ip_static
        - machine_baremetal
        - nfs_network
        - nfs_server
        - nfs_server_media
        - nfs_server_media_prod
        - ntp_network
        - os_baremetal
        - os_baremetal_linux
        - os_baremetal_linux_prod
        - os_linux
        - plex
        - plex_prod
        - postfix_network
        - step_ca_network
    media02:
      description: |
        ASUS NUC 14 PRO+ Intel Core Ultra 9 185H,
        32GB Ram and 1TB NVME
      processor: Intel(R) Core(TM) Ultra 9 185H, 22 cores
      memory_desc: 2x48GB DDR5 SO-DIMM
      memory: 32GB
      memory_type: GDDR5
      storage:
        disk1:
          size: 1 TB
          type: M.2 2230 SSD
      groups:
        - ca_domain
        - ca_domain_int_johnson
        - cert_host
        - common_groups
        - common_groups_os
        - common_groups_os_linux
        - docker
        - docker_registry
        - docker_stack
        - docker_stack_domain
        - docker_stack_domain_johnson
        - docker_stack_media
        - docker_stack_openldap
        - docker_stack_registry
        - docker_stack_samba
        - firewall_zone
        - firewall_zone_docker
        - firewall_zone_internal
        - ldap_network
        - machine_baremetal
        - nfs_network
        - nfs_server
        - nfs_server_media
        - nfs_server_media_prod
        - ntp_network
        - os_baremetal
        - os_baremetal_linux
        - os_baremetal_linux_prod
        - os_linux
        - postfix_network
        - step_ca_network
    gpu01:
      description: |
        ASUS Ascent GX10 Personal
        AI Supercomputer with
        NVIDIA GB10 Superchip,
        128GB LPDDR5x RAM, 
        4TB NVMe 2242 SSD,
        PCIe G4x4, Wi-Fi 7 & BT5.4,
        DGX OS
      processor: Cortex-X925 10 cores/A725 10 cores
      gpu-01:
        name: NVIDIA GB10
      memory: 128GB
      memory_type: LPDDR5x RAM
      storage:
        disk1:
          size: 4 TB
          type: M.2 CORSAIR 4TB MP700 NVME 2242
      groups:
        - aibrix
        - aibrix_prod
        - baremetal_dhcp
        - baremetal_linux_ip_dhcp
        - ca_domain
        - ca_domain_int_johnson
        - cert_host
        - common_groups
        - common_groups_os
        - common_groups_os_linux
        - docker
        - docker_gpu
        - docker_gpu_nvidia
        - docker_stack
        - docker_stack_domain
        - docker_stack_domain_johnson
        - docker_stack_llama_cppserver
        - docker_stack_llm
        - docker_stack_llm_prod
        - etcd
        - etcd_prod
        - firewall_zone
        - firewall_zone_docker
        - firewall_zone_internal
        - gpu_host
        - gpu_host_prod
        - kubernetes
        - kubernetes_controller
        - kubernetes_controller_prod
        - kubernetes_etcd
        - kubernetes_etcd_prod
        - ldap_network
        - linux_ip_dhcp
        - llm_host
        - llm_host_prod
        - machine_baremetal
        - nfs_network
        - ntp_network
        - os_baremetal
        - os_baremetal_linux
        - os_baremetal_linux_prod
        - os_linux
        - postfix_network
        - step_ca_network
    gpu02:
      description: |
        HP OMEN 30L Gaming Desktop PC
        RTX 3090 Ryzen 5 5600x
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
      groups:
        - aibrix
        - aibrix_prod
        - baremetal_dhcp
        - baremetal_linux_ip_dhcp
        - ca_domain
        - ca_domain_int_johnson
        - cert_host
        - common_groups
        - common_groups_os
        - common_groups_os_linux
        - docker
        - docker_gpu
        - docker_gpu_nvidia
        - docker_stack
        - docker_stack_domain
        - docker_stack_domain_johnson
        - docker_stack_llama_cppserver
        - docker_stack_llm
        - docker_stack_llm_prod
        - etcd
        - etcd_prod
        - firewall_zone
        - firewall_zone_docker
        - firewall_zone_internal
        - gpu_host
        - gpu_host_prod
        - kubernetes
        - kubernetes_controller
        - kubernetes_controller_prod
        - kubernetes_etcd
        - kubernetes_etcd_prod
        - ldap_network
        - linux_ip_dhcp
        - llm_host
        - llm_host_prod
        - machine_baremetal
        - nfs_network
        - ntp_network
        - os_baremetal
        - os_baremetal_linux
        - os_baremetal_linux_prod
        - os_linux
        - postfix_network
        - step_ca_network
```
