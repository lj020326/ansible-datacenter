
```shell
ansible --version
ansible -i ./inventory --list-hosts all
ansible -i ./inventory --list-hosts ntp
ansible -i ./inventory --list-hosts ntp_client
ansible -i ./inventory -m debug -a var="group_trace_var,ntp_servers|d('')" ntp
ansible -i ./inventory -m debug -a var="group_trace_var,ntp_servers|d('')" ntp_client,\!ntp_server
ansible -i ./inventory -m debug -a var="group_trace_var,ntp_servers|d('')" ntp_client,\&ntp_server
ansible -i ./inventory -m debug -a var="group_trace_var,ntp_servers|d('')" ntp_server
ansible -i ./inventory -m debug -a var="group_trace_var,ntp_servers|d('')" ntp_server,\!ntp_server
ansible -i ./inventory -m debug -a var=ntp_servers ntp_server
ansible -i ./inventory/ -m debug -a var="ntp_servers|d('')" ntp
ansible -i ./inventory/ -m debug -a var="group_trace_var,ntp_servers|d('')" ntp
ansible -i ./inventory/ -m debug -a var=group_names,ntp_server ntp_server
ansible -i ./inventory/ -m debug -a var=group_trace_var,gateway_ip ntp_server,\&network_internal
ansible -i ./inventory/ -m debug -a var=group_trace_var,gateway_ipv4 ntp_server
ansible -i ./inventory/ -m debug -a var=group_trace_var,gateway_ipv4 ntp_server,\&network_internal
ansible -i ./inventory/ -m debug -a var=group_trace_var,gateway_ipv4,ntp_peers ntp_server
ansible -i ./inventory/ -m debug -a var=ntp_server ntp_client,\!ntp_server
ansible -i ./inventory/ -m debug -a var=ntp_servers ntp_client,\!ntp_server
ansible -i ./inventory/ -m debug -a var=ntp_servers ntp_server
ansible -i ./inventory/ -m debug -a var=ntp_servers ntp_server,\&network_internal
ansible -i ./inventory/ -m debug -a var=trace_var location_site1,\&dmz
ansible -i ./inventory/ -m debug -a var=trace_var location_site1,\&network_dmz
ansible -i ./inventory/ -m debug -a var=trace_var,group_names location_site1
ansible -i ./inventory/ -m debug -a var=trace_var,group_names location_site2,\&ntp_server
ansible -i ./inventory/ -m debug -a var=trace_var,group_names network_internal
ansible -i ./inventory/ -m debug -a var=trace_var,group_names ntp_client -l web-*
ansible -i ./inventory/ -m debug -a var=trace_var,group_names ntp_server -l admin01.qa.site1.example.dmz
ansible -i ./inventory/ -m debug -a var=trace_var,group_names ntp_server,\&location_site2
ansible -i ./inventory/ -m debug -a var=trace_var,group_names ntp_server,\&network_dmz
ansible -i ./inventory/ -m debug -a var=trace_var,group_names ntp_server,\&network_internal
ansible -i ./inventory/ \!ntp_server -m debug -a var=trace_var
ansible -i ./inventory/ dmz -m debug -a var=trace_var
ansible -i ./inventory/ network1 -m debug -a var=trace_var
ansible -i ./inventory/ ntp_client -m debug -a var=trace_var
ansible -i ./inventory/ ntp_client -m debug -a var=trace_var
ansible -i ./inventory/ ntp_client -m debug -a var=trace_var,group_names
ansible -i ./inventory/ ntp_client,\!ntp_server -m debug -a var=trace_var
ansible -i ./inventory/ ntp_client,\!ntp_server -m debug -a var=trace_var,group_names
ansible -i ./inventory/ ntp_client,\&\!ntp_server -m debug -a var=trace_var
ansible -i ./inventory/ ntp_client\&\!ntp_server -m debug -a var=trace_var
ansible -i ./inventory/ ntp_server -m debug -a var=trace_var
ansible -i ./inventory/ ntp_server -m debug -a var=trace_var
ansible -i ./inventory/ ntp_server -m debug -a var=trace_var,group_names
ansible -i ./inventory/dmz --list
ansible -i ./inventory/dmz --list-hosts
ansible -i ./inventory/dmz --list-hosts all
ansible -i ./inventory/dmz --list-hosts-all
ansible -i ./inventory/dmz -m debug -a var="ntp_servers|d(''),group_trace_var,group_names" ntp
ansible -i ./inventory/dmz -m debug -a var="group_trace_var,ntp_servers|d('')" ntp
ansible -i ./inventory/dmz -m debug -a var=ntp_servers ntp
ansible -i ./inventory/dmz -m debug -a var=ntp_servers ntp
ansible -i ./inventory/dmz -m debug -a var=ntp_servers ntp_server
ansible -i ./inventory/dmz -m debug -a var=ntp_servers ntp_server,\&network_internal
ansible -i ./inventory/internal -m debug -a var="ntp_servers" ntp
ansible -i ./inventory/internal -m debug -a var="groups[ntp_server],ntp_servers|d('')" ntp
ansible -i ./inventory/internal -m debug -a var="groups[ntp_servers],ntp_servers|d('')" ntp
ansible -i ./inventory/internal -m debug -a var="ntp_allow_networks|d('')" ntp
ansible -i ./inventory/internal -m debug -a var="ntp_allow_networks|d(''),ntp_servers" ntp
ansible -i ./inventory/internal -m debug -a var="ntp_allow_networks|d(''),ntp_servers|d('')" ntp
ansible -i ./inventory/internal -m debug -a var="ntp_allow_networks|d(''),ntp_servers|d([])" ntp
ansible -i ./inventory/internal -m debug -a var="ntp_servers|d('')" ntp
ansible -i ./inventory/internal -m debug -a var="ntp_servers|d(''),group_trace_var" ntp
ansible -i ./inventory/internal -m debug -a var="ntp_servers|d(''),group_trace_var" ntp_server
ansible -i ./inventory/internal -m debug -a var="ntp_servers|d(''),group_trace_var,group_names" ntp
ansible -i ./inventory/internal -m debug -a var="ntp_servers|d(''),group_trace_var,group_names" ntp_server
ansible -i ./inventory/internal -m debug -a var=ntp_allow_networks,ntp_servers ntp
ansible -i ./inventory/internal -m debug -a var=ntp_allow_networks|d(""),ntp_servers ntp
ansible -i ./inventory/internal -m debug -a var=ntp_allow_networks|d(''),ntp_servers ntp
ansible -i ./inventory/internal -m debug -a var=ntp_servers ntp
ansible-inventory --graph output -i inventory/
ansible-inventory --graph output -i inventory/ ntp
ansible-inventory --graph output -i inventory/ ntp_server
ansible-inventory --graph output -i inventory/internal/
ansible-inventory --graph output -i inventory/internal/ ntp
ansible-inventory -i inventory/ --graph ntp
ansible-inventory -i inventory/internal/ --graph ntp
ansible-inventory -i inventory/internal/ --graph output
ansible-inventory -i inventory/internal/ --graph output group
ansible-inventory -i inventory/internal/ --graph output ntp
ansible-inventory -i inventory/internal/ --list ntp
ansible-inventory -i inventory/internal/ntp.yml --graph output
ansible-inventory -i inventory/internal/site1.yml --graph output
ansible-playbook -i ./inventory display-ntp-servers.yml 
ansible-playbook -i ./inventory/ display-ntp-servers.yml
ansible-playbook -i ./inventory/ playbook.yml
ansible-playbook -i ./inventory/dmz display-ntp-servers.yml 
ansible-playbook -i ./inventory/internal display-ntp-servers.yml
ansible-playbook -i ./inventory/internal display-ntp-servers.yml 


```
