This should be a simple task. I have already created the answer file for an unattended installation, copied it to a virtual floppy image, and obtained a windows installation ISO. [VMware’s Ansible modules](https://docs.ansible.com/ansible/latest/modules/list_of_cloud_modules.html#vmware) look promising, so you would think you could use vsphere\_copy to transfer the .iso and .flp to a datastore, use vsphere\_guest to create the VM, and sit back and wait for WinRM to start responding.

Unfortunately, VMware’s modules have some coverage gaps that prevent this from working. The vsphere\_copy module does not work with standalone hosts. In my greenfield deployment scenario, I am building the domain controller before I deploy vCenter, so vCenter is not available yet. But even if it was, the vmware\_guest module can’t create a virtual floppy drive. That feature was in the deprecated vsphere\_guest module it replaced, but was somehow lost along the way.

To overcome these limitations I had to take a different approach. I realized that I could use the vsphere\_host module to enable SSH in ESXi, and then treat it like a linux host and use some of the available shell commands to copy bits and edit files. It is not the most elegant solution, but until the VMware modules mature it will have to do.

You can find the complete playbook on the [lj020326 github](https://github.com/lj020326/ansible-datacenter/playbooks), but here are some of the highlights:

Putting the ESX login variables in an anchor:

```yml
vars:
  esxi_login: &esxi_login
    hostname: '{{ esxi_address }}'
    username: '{{ esxi_username }}'
    password: '{{ esxi_password }}'  
    validate_certs: no 
```

Enabling SSH (starting the TSM-SSH and TSM services):

```yml
- name: Enable ESX SSH (TSM-SSH)
  vmware_host_service_manager:
    <<: *esxi_login
    esxi_hostname: '{{ esxi_address }}'
    service_name: TSM-SSH
    state: present
  delegate_to: localhost
- name: Enable ESX Shell (TSM)
  vmware_host_service_manager:
    <<: *esxi_login
    esxi_hostname: '{{ esxi_address }}'
    service_name: TSM
    state: present
  delegate_to: localhost
```

And telling ESXi to go download the bits. I could have used the Ansible copy module to copy over the floppy image, but the ISO is too large to transfer this way. The copy module copies files to the target system’s temp volume first. Filling the temp space on an ESXi host doesn’t end well, and the ISO never makes it to the destination.

```yml
- name: Download the Windows Server ISO
  shell: 'wget -P /vmfs/volumes/{{ esxi_datastore }} {{ windows_iso_url }}'
  args:
    creates: '/vmfs/volumes/{{ esxi_datastore }}/{{ windows_iso }}'
  delegate_to: '{{ esxi_address }}'
- name: Download the autounattend floppy .flp
  shell: 'wget -P /vmfs/volumes/{{ esxi_datastore }} {{ windows_flp_url }}'
  args:
    creates: '/vmfs/volumes/{{ esxi_datastore }}/{{ windows_flp }}'
  delegate_to: '{{ esxi_address }}'
```

Now I can create the VM:

```yml
- name: Create a new Server 2016 VM
  vmware_guest:
    <<: *esxi_login
    folder: /
    name: '{{ vm_name }}'
    state: present
    guest_id: windows9Server64Guest
    cdrom:
      type: iso
      iso_path: '[{{ esxi_datastore }}] {{ windows_iso }}'
    disk:
    - size_gb: '{{ vm_disk_gb }}'
      type: thin
      datastore: '{{ esxi_datastore }}'
    hardware:
      memory_mb: '{{ vm_memory_mb }}'
      num_cpus: '{{ vm_num_cpus }}'
      scsi: lsilogicsas
    networks:
    - name: '{{ vm_network }}'
      device_type: e1000
    wait_for_ip_address: no
  delegate_to: localhost
  register: deploy_vm
```

Notice how there is no floppy drive. Since I can’t create it with the vmware\_guest module, I’ll have to edit the vmx file. It’s a little gruesome, but it works. I should be able to clean this up with customvalues in the vsphere\_guest module, but it doesn’t currently work on a standalone host.

```yml
- name: Adding VMX Entry - floppy0.fileType
  lineinfile:
    path: '/vmfs/volumes/{{ esxi_datastore }}/{{ vm_name }}/{{ vm_name }}.vmx'
    line: 'floppy0.fileType = "file"'
  delegate_to: '{{ esxi_address }}'
- name: Adding VMX Entry - floppy0.fileName
  lineinfile:
    path: '/vmfs/volumes/{{ esxi_datastore }}/{{ vm_name }}/{{ vm_name }}.vmx'
    line: 'floppy0.fileName = "/vmfs/volumes/{{ esxi_datastore }}/{{ windows_flp }}"'
  delegate_to: '{{ esxi_address }}'
- name: Removing VMX Entry - floppy0.present = "FALSE"
  lineinfile:
    path: '/vmfs/volumes/{{ esxi_datastore }}/{{ vm_name }}/{{ vm_name }}.vmx'
    line: 'floppy0.present = "FALSE"'
    state: absent
  delegate_to: '{{ esxi_address }}'
```

One last thing before I can power it on. The default boot sequence won’t work. This one will:

```yml
- name: Change virtual machine's boot order and related parameters
  vmware_guest_boot_manager:
    <<: *esxi_login 
    name: '{{ vm_name }}'
    boot_delay: 1000
    enter_bios_setup: False
    boot_retry_enabled: True
    boot_retry_delay: 20000
    boot_firmware: bios
    secure_boot_enabled: False
    boot_order:
      - cdrom
      - disk
      - ethernet
      - floppy
  delegate_to: localhost
  register: vm_boot_order
```

Now I can power it on, and wait. Once the VMware tools are responding, I can use the vmware\_vm\_shell module to run commands inside the guest OS to assign a new hostname, set the IP address, etc. In the playbook this is part of a second play called “Customize Guest”.

```yml
- name: Set password via vmware_vm_shell
  local_action:
    module: vmware_vm_shell
    <<: *esxi_login
    vm_username: Administrator
    vm_password: '{{ vm_password_old }}'
    vm_id: '{{ vm_name }}'
    vm_shell: 'c:\windows\system32\windowspowershell\v1.0\powershell.exe'
    vm_shell_args: '-command "(net user Administrator {{ vm_password_new }})"'
    wait_for_process: true
  ignore_errors: yes
- name: Configure IP address via vmware_vm_shell
  local_action:
    module: vmware_vm_shell
    <<: *esxi_login
    vm_username: Administrator
    vm_password: '{{ vm_password_new }}'
    vm_id: '{{ vm_name }}'
    vm_shell: 'c:\windows\system32\windowspowershell\v1.0\powershell.exe'
    vm_shell_args: '-command "(new-netipaddress -InterfaceAlias Ethernet0 -IPAddress {{ vm_address }} -prefixlength {{vm_netmask_cidr}} -defaultgateway {{ vm_gateway }})"'
    wait_for_process: true
- name: Configure DNS via vmware_vm_shell
  local_action:
    module: vmware_vm_shell
    <<: *esxi_login
    vm_username: Administrator
    vm_password: '{{ vm_password_new }}'
    vm_id: '{{ vm_name }}'
    vm_shell: 'c:\windows\system32\windowspowershell\v1.0\powershell.exe'
    vm_shell_args: '-command "(Set-DnsClientServerAddress -InterfaceAlias Ethernet0 -ServerAddresses {{ vm_dns_server }})"'
    wait_for_process: true
- name: Rename Computer via vmware_vm_shell
  local_action:
    module: vmware_vm_shell
    <<: *esxi_login
    vm_username: Administrator
    vm_password: '{{ vm_password_new }}'
    vm_id: '{{ vm_name }}'
    vm_shell: 'c:\windows\system32\windowspowershell\v1.0\powershell.exe'
    vm_shell_args: '-command "(Rename-Computer -NewName {{ vm_name }})"'
    wait_for_process: true
```

One more reboot and the VM is ready for advanced configuration by another playbook. In the [complete playbook](https://github.com/lj020326/ansible-datacenter/playbooks/blob/main/deploy-windows-vm.yml) and the corresponding [example vars file](https://github.com/lj020326/ansible-datacenter/playbooks/vars/blob/main/deploy-windows-vm.yml), there are a few extra steps I take to capture and later restore the state of the TSM & TSM-SSH services since most people don’t leave those enabled.
