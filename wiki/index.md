# Ansible Datacenter Wiki

Documentation for all roles, playbooks, and infrastructure automation

This markdown is automatically generated and maintained by the [LLM-powered wiki pipeline](https://github.com/lj020326/jenkins-docker-agent/tree/main/image/wiki-pipeline).
It provides professional, GitHub-native documentation for the ansible-datacenter repository.


## Priority Roles

- **[apply_common_groups](roles/apply_common_groups.md)** — Core role
- **[apply_ping_test](roles/apply_ping_test.md)** — Core role
- **[bootstrap_ansible_controller](roles/bootstrap_ansible_controller.md)** — Core role
- **[bootstrap_docker](roles/bootstrap_docker.md)** — Core role
- **[bootstrap_docker_stack](roles/bootstrap_docker_stack.md)** — Core role
- **[bootstrap_gpu_drivers](roles/bootstrap_gpu_drivers.md)** — Core role
- **[bootstrap_jenkins_agent](roles/bootstrap_jenkins_agent.md)** — Core role
- **[bootstrap_kubernetes](roles/bootstrap_kubernetes.md)** — Core role
- **[bootstrap_linux](roles/bootstrap_linux.md)** — Core role
- **[bootstrap_linux_core](roles/bootstrap_linux_core.md)** — Core role
- **[bootstrap_linux_systemd](roles/bootstrap_linux_systemd.md)** — Core role
- **[bootstrap_llm_host](roles/bootstrap_llm_host.md)** — Core role
- **[bootstrap_netplan](roles/bootstrap_netplan.md)** — Core role
- **[bootstrap_pki](roles/bootstrap_pki.md)** — Core role
- **[deploy_pki_certs](roles/deploy_pki_certs.md)** — Core role
- **[deploy_vm](roles/deploy_vm.md)** — Core role

## All Roles by Category

### Audit & Information
*Roles run to audit and/or information gathering across inventory*

- [fetch_linux_os_configs](roles/fetch_linux_os_configs.md)
- [report_inventory_facts](roles/report_inventory_facts.md)

### Bootstrap & Foundation Roles
*Core OS and infrastructure setup*

- [bootstrap_aibrix](roles/bootstrap_aibrix.md)
- [bootstrap_ansible](roles/bootstrap_ansible.md)
- [bootstrap_ansible_controller](roles/bootstrap_ansible_controller.md)
- [bootstrap_ansible_user](roles/bootstrap_ansible_user.md)
- [bootstrap_awstats](roles/bootstrap_awstats.md)
- [bootstrap_awx](roles/bootstrap_awx.md)
- [bootstrap_awx_config](roles/bootstrap_awx_config.md)
- [bootstrap_awx_docker](roles/bootstrap_awx_docker.md)
- [bootstrap_awx_resources](roles/bootstrap_awx_resources.md)
- [bootstrap_bind](roles/bootstrap_bind.md)
- [bootstrap_ca_certs](roles/bootstrap_ca_certs.md)
- [bootstrap_caddy2](roles/bootstrap_caddy2.md)
- [bootstrap_certs](roles/bootstrap_certs.md)
- [bootstrap_cfssl](roles/bootstrap_cfssl.md)
- [bootstrap_chronyclient](roles/bootstrap_chronyclient.md)
- [bootstrap_chronyserver](roles/bootstrap_chronyserver.md)
- [bootstrap_cloud_init](roles/bootstrap_cloud_init.md)
- [bootstrap_cni](roles/bootstrap_cni.md)
- [bootstrap_dell_opscenter](roles/bootstrap_dell_opscenter.md)
- [bootstrap_dell_racadm_host](roles/bootstrap_dell_racadm_host.md)
- [bootstrap_dhcp](roles/bootstrap_dhcp.md)
- [bootstrap_docker](roles/bootstrap_docker.md)
- [bootstrap_docker_stack](roles/bootstrap_docker_stack.md)
- [bootstrap_epel_repo](roles/bootstrap_epel_repo.md)
- [bootstrap_etcd](roles/bootstrap_etcd.md)
- [bootstrap_fog](roles/bootstrap_fog.md)
- [bootstrap_git](roles/bootstrap_git.md)
- [bootstrap_gitea_runner](roles/bootstrap_gitea_runner.md)
- [bootstrap_govc](roles/bootstrap_govc.md)
- [bootstrap_gpu_drivers](roles/bootstrap_gpu_drivers.md)
- [bootstrap_hddtemp](roles/bootstrap_hddtemp.md)
- [bootstrap_inspec](roles/bootstrap_inspec.md)
- [bootstrap_ipa_client](roles/bootstrap_ipa_client.md)
- [bootstrap_ipa_config](roles/bootstrap_ipa_config.md)
- [bootstrap_ipa_krb5](roles/bootstrap_ipa_krb5.md)
- [bootstrap_ipa_replica](roles/bootstrap_ipa_replica.md)
- [bootstrap_ipa_server](roles/bootstrap_ipa_server.md)
- [bootstrap_ipa_sssd](roles/bootstrap_ipa_sssd.md)
- [bootstrap_iscsi_client](roles/bootstrap_iscsi_client.md)
- [bootstrap_java](roles/bootstrap_java.md)
- [bootstrap_jenkins](roles/bootstrap_jenkins.md)
- [bootstrap_jenkins_agent](roles/bootstrap_jenkins_agent.md)
- [bootstrap_jenkins_swarm_agent](roles/bootstrap_jenkins_swarm_agent.md)
- [bootstrap_kubernetes](roles/bootstrap_kubernetes.md)
- [bootstrap_kubernetes_ca](roles/bootstrap_kubernetes_ca.md)
- [bootstrap_kubernetes_controller](roles/bootstrap_kubernetes_controller.md)
- [bootstrap_kubernetes_worker](roles/bootstrap_kubernetes_worker.md)
- [bootstrap_kvm](roles/bootstrap_kvm.md)
- [bootstrap_kvm_infra](roles/bootstrap_kvm_infra.md)
- [bootstrap_ldap_client](roles/bootstrap_ldap_client.md)
- [bootstrap_linux](roles/bootstrap_linux.md)
- [bootstrap_linux_core](roles/bootstrap_linux_core.md)
- [bootstrap_linux_cron](roles/bootstrap_linux_cron.md)
- [bootstrap_linux_firewalld](roles/bootstrap_linux_firewalld.md)
- [bootstrap_linux_locale](roles/bootstrap_linux_locale.md)
- [bootstrap_linux_mount](roles/bootstrap_linux_mount.md)
- [bootstrap_linux_networking](roles/bootstrap_linux_networking.md)
- [bootstrap_linux_package](roles/bootstrap_linux_package.md)
- [bootstrap_linux_systemd](roles/bootstrap_linux_systemd.md)
- [bootstrap_linux_systemd_mount](roles/bootstrap_linux_systemd_mount.md)
- [bootstrap_linux_upgrade](roles/bootstrap_linux_upgrade.md)
- [bootstrap_linux_user](roles/bootstrap_linux_user.md)
- [bootstrap_llm_host](roles/bootstrap_llm_host.md)
- [bootstrap_logrotate](roles/bootstrap_logrotate.md)
- [bootstrap_lxc](roles/bootstrap_lxc.md)
- [bootstrap_maven](roles/bootstrap_maven.md)
- [bootstrap_mergerfs](roles/bootstrap_mergerfs.md)
- [bootstrap_nfs](roles/bootstrap_nfs.md)
- [bootstrap_nfs_service](roles/bootstrap_nfs_service.md)
- [bootstrap_nginx_service](roles/bootstrap_nginx_service.md)
- [bootstrap_nodejs](roles/bootstrap_nodejs.md)
- [bootstrap_ntp](roles/bootstrap_ntp.md)
- [bootstrap_openstack](roles/bootstrap_openstack.md)
- [bootstrap_openstack_cloud](roles/bootstrap_openstack_cloud.md)
- [bootstrap_os_network](roles/bootstrap_os_network.md)
- [bootstrap_osclient](roles/bootstrap_osclient.md)
- [bootstrap_osclient_config](roles/bootstrap_osclient_config.md)
- [bootstrap_ovftool](roles/bootstrap_ovftool.md)
- [bootstrap_packer](roles/bootstrap_packer.md)
- [bootstrap_pdc](roles/bootstrap_pdc.md)
- [bootstrap_pip](roles/bootstrap_pip.md)
- [bootstrap_pip_libs](roles/bootstrap_pip_libs.md)
- [bootstrap_pki](roles/bootstrap_pki.md)
- [bootstrap_plexupdate](roles/bootstrap_plexupdate.md)
- [bootstrap_postfix](roles/bootstrap_postfix.md)
- [bootstrap_proxmox](roles/bootstrap_proxmox.md)
- [bootstrap_pyenv](roles/bootstrap_pyenv.md)
- [bootstrap_python3](roles/bootstrap_python3.md)
- [bootstrap_rsyncd](roles/bootstrap_rsyncd.md)
- [bootstrap_sanoid](roles/bootstrap_sanoid.md)
- [bootstrap_snapraid](roles/bootstrap_snapraid.md)
- [bootstrap_solr_cloud](roles/bootstrap_solr_cloud.md)
- [bootstrap_sshd](roles/bootstrap_sshd.md)
- [bootstrap_stepca](roles/bootstrap_stepca.md)
- [bootstrap_systemd_service](roles/bootstrap_systemd_service.md)
- [bootstrap_telegraf](roles/bootstrap_telegraf.md)
- [bootstrap_veeam_agent](roles/bootstrap_veeam_agent.md)
- [bootstrap_veeam_agent_config](roles/bootstrap_veeam_agent_config.md)
- [bootstrap_vmware_datastores](roles/bootstrap_vmware_datastores.md)
- [bootstrap_vmware_esxi](roles/bootstrap_vmware_esxi.md)
- [bootstrap_vmware_esxi_hostconf](roles/bootstrap_vmware_esxi_hostconf.md)
- [bootstrap_vmware_esxi_hostconfig](roles/bootstrap_vmware_esxi_hostconfig.md)
- [bootstrap_vmware_tools](roles/bootstrap_vmware_tools.md)
- [bootstrap_vsphere](roles/bootstrap_vsphere.md)
- [bootstrap_webmin](roles/bootstrap_webmin.md)
- [bootstrap_windows](roles/bootstrap_windows.md)
- [bootstrap_windows_firewall](roles/bootstrap_windows_firewall.md)
- [bootstrap_windows_openssh](roles/bootstrap_windows_openssh.md)
- [bootstrap_yq](roles/bootstrap_yq.md)
- [bootstrap_zookeeper](roles/bootstrap_zookeeper.md)
- [run_terraform](roles/run_terraform.md)

### Deployment & Provisioning
*VM, container, and application deployment*

- [deploy_authorized_keys](roles/deploy_authorized_keys.md)
- [deploy_ca_certs](roles/deploy_ca_certs.md)
- [deploy_pki_certs](roles/deploy_pki_certs.md)
- [deploy_vm](roles/deploy_vm.md)

### Monitoring & Observability
*Telemetry, logging, and alerting*

- [bootstrap_postfix](roles/bootstrap_postfix.md)
- [bootstrap_telegraf](roles/bootstrap_telegraf.md)
- [run_inspec](roles/run_inspec.md)

### Networking & Security
*Network configuration and hardening*

- [apply_ping_test](roles/apply_ping_test.md)
- [bootstrap_linux_firewalld](roles/bootstrap_linux_firewalld.md)
- [bootstrap_linux_networking](roles/bootstrap_linux_networking.md)
- [bootstrap_netplan](roles/bootstrap_netplan.md)
- [bootstrap_network_interfaces](roles/bootstrap_network_interfaces.md)
- [bootstrap_os_network](roles/bootstrap_os_network.md)
- [bootstrap_sshd](roles/bootstrap_sshd.md)
- [harden_os_linux](roles/harden_os_linux.md)

### Operational
*Roles run to operational plays (startup, shutdown, etc)*

- [run_inspec](roles/run_inspec.md)
- [run_terraform](roles/run_terraform.md)
- [vmware_remount_datastores](roles/vmware_remount_datastores.md)
- [vmware_upgrade_esxi](roles/vmware_upgrade_esxi.md)

### Other Roles

- [bootstrap_cloudstack](roles/bootstrap_cloudstack.md)
- [bootstrap_cloudstack_controller](roles/bootstrap_cloudstack_controller.md)
- [bootstrap_cobbler](roles/bootstrap_cobbler.md)
- [bootstrap_cobbler_resources](roles/bootstrap_cobbler_resources.md)
- [bootstrap_netbootxyz](roles/bootstrap_netbootxyz.md)
- [bootstrap_samba_client](roles/bootstrap_samba_client.md)
- [remove_cloudstack_setup](roles/remove_cloudstack_setup.md)

### Utility
*Roles run to perform and/or apply common tasks*

- [apply_common_groups](roles/apply_common_groups.md)
- [apply_ping_test](roles/apply_ping_test.md)
- [fetch_os_images](roles/fetch_os_images.md)


## 📊 System Visuals & Charts
