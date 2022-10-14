
# Standard Operating Procedures for IaC

To be developed and synchronized with the related [ALSAC confluence site page](https://alsacwiki.stjude.org/pages/viewpage.action?spaceKey=TECH&title=Infrastructure+as+Code).

The SOPs are based on different scopes and/or patterns based on the requirements/circumstance.

The configurations, testing and other requirements depend on the scope/pattern.

In some case, multiple sets of use case SOPs may be required depending on the type/complexity of the specific circumstance needs.

## Patterns and Scopes requiring specific SOPs

### 1: SW Deployments involving Large Disjoint Sub-Groups Requiring Inventory Configuration State (e.g., Client / Server) 

This SOP is related to whenever the need exists to set up a set and disjoint set of sub-group configurations required for any playbook and corresponding roles (e.g., client/server configurations).

Basically / put simply, whenever there is the following conditions: 

1) a large group A, and 
2) a very small/finite subset group B within A, and 
3) the need exists to have a 3rd group C which is the difference of A - B = C, and 
4) the need to maintain the configuration state for group C in group_vars/groupC.yml format

Many use cases require servers, fixtures, or assets to be setup to serve or enable clients within a larger defined group.

Some example use cases involving 'servers' within a group serving a subset of machines within a defined group ('network', etc):

- router/gateways/firewalls
- dns servers
- ntp servers
- ldap servers
- postfix servers
- nfs servers
- archive servers (apache archiva, jfrog artifactory, sonatype nexus, etc)
- source code repo (bitbucket, gitlab, gitea, etc)
- etc (many other similar software network/client domain use cases)

#### Simple Example for a derived group

Currently, functionality exists in ansible playbook to sufficiently limit hosts to an implied "subset" set of machines using the [patterns supported by the limit feature](https://docs.ansible.com/ansible/latest/user_guide/intro_patterns.html).  For example, to specify all hosts in webservers except those in atlanta:

```shell
ansible-playbook site.yml --limit 'webservers:!atlanta' 
```

Now consider the following inventory use case.
![Derived Groups](./img/iac-derived-groups.png)

In the aforementioned diagram/example, to limit the targeted hosts to only clients:
```shell
ansible-playbook site.yml --limit 'network_a:!network_a_servers' 
```

However, if there are any configurations that the client group requires, then this method is insufficient.

Ideally, the YAML-based inventory could support derived groupings with operators similar to the limit directive.

For example, if the YAML-based inventory supported the following feature then the solution mentioned [here](https://github.com/lj020326/ansible-inventory-file-examples/tree/develop-lj/tests/ansible-multiple-yaml-inventories/example6) would not be necessary:

```yaml
all:
  children:
    network_a_clients: 
      hosts: network_a:!network_a_servers
      vars:
        network_server_list: "{{ groups['network_a_servers'] }}"
      
    network_a:
      hosts:
        admin01: {}
        admin02: {}
        admin03: {}
        machine10: {}
        machine11: {}
        machine12: {}
        ...
        ...
        ...
        machine99: {}
    
    network_a_servers:
      hosts:
        admin01: {}
        admin02: {}
        admin03: {}


```

But alas, the YAML-based ansible inventory does not support this feature, at least not at present.

#### Generalized Case

Say the following parameters are given:

* A 'network' (parent) group has 100, 1000, or lets say __N machines__ and 
* A subset 'network_server' group only has a far less _finite number_ of instances, say 2, 4, or __M machines__
* A derived 'network_client' defined as the parent group of __N machines__ minus the server group of __M machines__.

So given an inventory with a 'network' group of 1000 machines, and a 'network_server' group of 4 machines, then the 'network_client' group would have 996 machines. 

Maintaining a 'network_client' group for multiple use-cases would have to re-define the child group of __(N - M) machines__. 

This can present risks since then each 'network_client' group is almost the same size as the parent 'network_server' group and exposes risks of maintaining synchronization of the group.

Multiply this by the number of use cases having the same/similar pattern.

Ideally, we do not want to explicitly define and maintain a 'network_client' group since it can be simply derived from the obtaining the difference of the 'network' and 'network_server' groups.

The ansible inventory solution [here](https://github.com/lj020326/ansible-inventory-file-examples/tree/develop-lj/tests/ansible-multiple-yaml-inventories/example6) details a working solution to the challenge of deriving the 'network_client' child group.  Specifically, the example illustrates how to derive an 'ntp_client_internal' group from explicitly defined ntp_network and ntp_server groups.

#### Use Case involving an actual Client-Server Example

For this example, we consider the steps necessary to deploy a client/server role, specifically, the ntp role [bootstrap_ntp](https://bitbucket.alsac.stjude.org:8443/projects/AT/repos/linux_middleware_playbooks/browse/roles/bootstrap_ntp?at=feature/DCC-14482-create-chronyd-server-role-which-can-install-and-modify-chronyd-for-ntp-servers).

For context, the related JIRA request tickets are:
- [Create NTP Server Role](https://alsacjira.stjude.org/browse/DCC-10698)
- [Create chronyd server role which can install and modify chronyd for ntp servers](https://alsacjira.stjude.org/browse/DCC-14482)



More to follow....


### 2: DCC Shared Role and/or Module Deployments (TBC)

This section remains to be completed (TBC).

This section will seek to document the processes, procedures, and/or steps required whenever changes and/or enhancements are made to any [dcc_common](https://bitbucket.alsac.stjude.org:8443/projects/AT/repos/dcc_common/browse) related collections playbooks, roles and/or modules.


### 3: Linux Inventory, Playbook, Role Deployments (TBC)

This section remains to be completed (TBC).

This section will seek to document the process/procedures/steps required whenever changes/enhancements are made to any [linux_middleware_playbooks](https://bitbucket.alsac.stjude.org:8443/projects/AT/repos/linux_middleware_playbooks/browse) related inventory, playbooks, and/or roles.


### 4: Windows Inventory, Playbook, Role Deployments (TBC)

This section remains to be completed (TBC).

This section will seek to document the process/procedures/steps required whenever changes/enhancements are made to any [windows_compute_playbooks](https://bitbucket.alsac.stjude.org:8443/projects/AT/repos/windows_compute_playbooks/browse) related inventory, playbooks, roles, and/or modules.


### 5: Database Inventory, Playbook, Role Deployments (TBC)

This section remains to be completed (TBC).

This section will seek to document the process/procedures/steps required whenever changes/enhancements are made to any database related inventory, playbooks, roles, and/or modules.
The DevOps/Infrastructure database related repos:

* [db_ops_playbooks](https://bitbucket.alsac.stjude.org:8443/projects/AT/repos/db_ops_playbooks/browse) 
* [dbops_config_data](https://bitbucket.alsac.stjude.org:8443/projects/AT/repos/dbops_config_data/browse)
* [dbops_dbschema](https://bitbucket.alsac.stjude.org:8443/projects/AT/repos/dbops_dbschema/browse)

### 6: Network Inventory, Playbook, Role Deployments (TBC)
This section remains to be completed (TBC).

This section will seek to document the process/procedures/steps required whenever changes/enhancements are made to any network related inventory, playbooks, roles, and/or modules.
The DevOps/Infrastructure network related repos:

* [network_playbooks](https://bitbucket.alsac.stjude.org:8443/projects/AT/repos/network_playbooks/browse) 
* [network_lb](https://bitbucket.alsac.stjude.org:8443/projects/AT/repos/network_lb/browse)
* [network_firewall](https://bitbucket.alsac.stjude.org:8443/projects/AT/repos/network_firewall/browse)
* [network_meraki](https://bitbucket.alsac.stjude.org:8443/projects/AT/repos/network_meraki/browse)

### 7: Middleware Inventory, Playbook, Role Deployments (TBC)
This section remains to be completed (TBC).

This section will seek to document the process/procedures/steps required whenever changes/enhancements are made to any [midwa_playbooks](https://bitbucket.alsac.stjude.org:8443/projects/AT/repos/midwa_playbooks/browse) related inventory, playbooks, roles, and/or modules.


### 8: Ansible Automation Management Role and/or Module Deployments (TBC)

This section remains to be completed (TBC).

This section will seek to document the processes, procedures, and/or steps required whenever changes and/or enhancements are made to any [tower-management](https://bitbucket.alsac.stjude.org:8443/projects/AT/repos/tower-management/browse) related inventory, playbooks, roles and/or modules.


### 9: Ansible Inventory Change/Enhancement Deployments (TBC)

This section remains to be completed (TBC).

This section will seek to document the processes, procedures, and/or steps required whenever changes and/or enhancements are made to any [tower-inventory](https://bitbucket.alsac.stjude.org:8443/projects/AT/repos/tower-inventory/browse) related inventory.

