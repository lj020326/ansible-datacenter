# Overview & Purpose

Use this role to create and/or remove ansible-tower resources including:

* organizations
  * credentials
  * inventories
  * projects
    * job templates
  * teams
    * roles



# Role Objectives

Define each tower resource under the configuration root node 'tower_resources':

* Create a list of one or more organization(s) under the node 'tower_resources.organizations'. 
* Each organization can define the following lists:
  * credentials - list of credential maps containing the [credential definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/credential_module.html#ansible-collections-awx-awx-credential-module). 
  * inventories - list of inventory maps containing the [inventory definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/inventory_module.html#ansible-collections-awx-awx-inventory-module). 
  * projects - list of project maps containing the [project definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/project_module.html#ansible-collections-awx-awx-project-module). 
    * job_templates - list of job_template maps containing the [job_template definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/job_template_module.html#ansible-collections-awx-awx-job-template-module). 
  * teams - list of team maps containing the [team definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/team_module.html#ansible-collections-awx-awx-team-module). 
      When defining an organization team, specify the team_role ('member','admin',etc) and organization_role ('execute','read', etc) 
    * roles - list of role maps containing the [role definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/role_module.html#ansible-collections-awx-awx-role-module).

The following conditional actions are observed upon execution of the role:

* If any object with same 'name' already exists in the tower runtime environment with the same details defined in the 'tower_resources' map, no changes will be made to the object. 
* If any object with same 'name' already exists in the tower runtime environment and the details in the 'tower_resources' map are different, the respective object(s) will be updated/changed accordingly. 
* If any object exists in the tower runtime environment and is not defined by 'name' in the 'tower_resources' map, the object will not be changed or removed. 
* Upon setting the tower_resource_state to 'absent', any object with same 'name' that already exists in the tower runtime environment will be removed.  <b>Be judicious/careful when utilizing tower object removal.</b>

## Example 1 - 2 organizations

In the following example, the yaml definition will create 2 organizations.

For the second organization 'New Org2', an inventory 'New Inventory', a project 'New Project' and job template 'Job Template to Launch' will be with details as defined below.

```yml
tower_resources:
    organizations:
      - name: "New Org1"
        description: "test org"
        state: present
    
      - name: "New Org2"
        description: "test org"
        state: present
    
        inventories:
          - name: "New Inventory"
            description: "test inv"
            state: present
    
        projects:
          - name: "New Project"
            scm_type: git
            scm_url: https://github.com/ansible/test-playbooks.git
            job_templates:
              - name: "Job Template to Launch"
                project: "New Project"
                inventory: "New Inventory"
                playbook: debug.yml
    

```

## Example 2 - 2 organizations, with elaboration for team roles

In the next example, the definition for the second organization 'New Org2' is elaborated to include team roles as defined.

```yml
tower_resources:
    organizations:
      - name: "TEST - New Org111"
        description: "test org"
        state: present
    
      - name: "TEST - New Org222"
        description: "test org"
        state: present
    
        credentials:
          - name: 'TEST - Example password'
            credential_type: Vault
            inputs:
              vault_password: 'new_password'
          - name: "TEST - SCM Credential"
            state: present
            credential_type: Source Control
            inputs:
              username: joe
              password: secret
    
        inventories:
          - name: "TEST - New Inventory"
            description: "test inv"
            state: present
    
        projects:
          - name: "TEST - New Project"
            scm_type: git
            scm_url: https://github.com/ansible/test-playbooks.git
            job_templates:
              - name: "TEST - Job Template to Launch"
                inventory: "TEST - New Inventory"
                playbook: debug.yml
    
        teams:
          - name: "TEST - Test Team 1"
            description: "test team"
            team_role: 'member'
            organization_role: 'execute'
            state: present
            roles:
              - role: use
                inventories:
                - "TEST - New Inventory"
              - role: use
                projects:
                - "TEST - New Project"
              - role: use
                credentials:
                - "TEST - Example password"
                - "TEST - SCM Credential"
              - role: execute
                job_templates:
                - "TEST - Job Template to Launch"
    
#              ## if using ansible.tower - it may not support lists - change to singletons
#              - role: use
#                inventory: "TEST - New Inventory"
#              - role: use
#                project: "TEST - New Project"
#              - role: use
#                credential: "TEST - Example password"
#              - role: use
#                credential: "TEST - SCM Credential"
#              - role: execute
#                job_template: "TEST - Job Template to Launch"

```


Role Variables
--------------

**tower_config_state: "(present|absent)"
Default: "present"


tower_resources: (map of maps)
**Default:** {} - empty map \

* credentials - list of credential maps containing the [credential definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/credential_module.html#ansible-collections-awx-awx-credential-module). 
* inventories - list of inventory maps containing the [inventory definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/inventory_module.html#ansible-collections-awx-awx-inventory-module). 
* projects - list of project maps containing the [project definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/project_module.html#ansible-collections-awx-awx-project-module). 
  * job_templates - list of job_template maps containing the [job_template definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/job_template_module.html#ansible-collections-awx-awx-job-template-module). 
* teams - list of team maps containing the [team definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/team_module.html#ansible-collections-awx-awx-team-module). 
  * roles - list of role maps containing the [role definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/role_module.html#ansible-collections-awx-awx-role-module).
* organizations:
    * credentials - list of credential maps containing the [credential definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/credential_module.html#ansible-collections-awx-awx-credential-module). 
    * inventories - list of inventory maps containing the [inventory definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/inventory_module.html#ansible-collections-awx-awx-inventory-module). 
    * projects - list of project maps containing the [project definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/project_module.html#ansible-collections-awx-awx-project-module). 
      * job_templates - list of job_template maps containing the [job_template definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/job_template_module.html#ansible-collections-awx-awx-job-template-module). 
    * teams - list of team maps containing the [team definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/team_module.html#ansible-collections-awx-awx-team-module). 
      * roles - list of role maps containing the [role definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/role_module.html#ansible-collections-awx-awx-role-module).




Example Playbook
----------------

The following playbook creates 2 organizations and all defined resources.

```yaml
---

- name: Playbook to bootstrap tower resources
  hosts: localhost
  gather_facts: false
  tags:
    - bootstrap-tower-resources

  tasks:
    - name: Setup tower resources
      include_role:
        name: ansible-tower-resources
      vars:
        tower_resources:
          organizations:
              - name: "TEST - New Org111"
                description: "test org"
                state: present
        
              - name: "TEST - New Org222"
                description: "test org"
                state: present
        
                inventories:
                  - name: "TEST - New Inventory"
                    description: "test inv"
                    state: present
        
                projects:
                  - name: "TEST - New Project"
                    scm_type: git
                    scm_url: https://github.com/ansible/test-playbooks.git
                    job_templates:
                      - name: "TEST - Job Template to Launch"
                        inventory: "TEST - New Inventory"
                        playbook: debug.yml
        
                credentials:
                  - name: 'TEST - Example password'
                    credential_type: Vault
                    inputs:
                      vault_password: 'new_password'
                  - name: "TEST - SCM Credential"
                    state: present
                    credential_type: Source Control
                    inputs:
                      username: joe
                      password: secret
        
                teams:
                  - name: "TEST - Test Team 1"
                    description: "test team"
                    state: present
                    roles:
                      - role: use
                        inventory: "TEST - New Inventory"
                      - role: use
                        project: "TEST - New Project"
                      - role: use
                        credential: "TEST - Example password"
                      - role: use
                        credential: "TEST - SCM Credential"
                      - role: execute
                        job_template: "TEST - Job Template to Launch"

```


The following playbook remove 2 organizations and all defined resources.

```yaml
---

- name: Playbook to remove tower resources
  hosts: localhost
  gather_facts: false
  collections:
    - ansible.tower
  environment:
    TOWER_OAUTH_TOKEN: "{% if new_tower_host is defined %}{{ new_tower_oauth_token }}{% else %}{{ tower_oauth_token }}{% endif %}"
  tags:
    - remove-tower-resources

  roles:
    - role: ansible-tower-resources
      vars:
        tower_resource_state: absent
    
        tower_resources:
          organizations:
              - name: "TEST - New Org111"
                description: "test org"
                state: present
        
              - name: "TEST - New Org222"
                description: "test org"
                state: present
        
                inventories:
                  - name: "TEST - New Inventory"
                    description: "test inv"
                    state: present
        
                projects:
                  - name: "TEST - New Project"
                    scm_type: git
                    scm_url: https://github.com/ansible/test-playbooks.git
                    job_templates:
                      - name: "TEST - Job Template to Launch"
                        inventory: "TEST - New Inventory"
                        playbook: debug.yml
        
                credentials:
                  - name: 'TEST - Example password'
                    credential_type: Vault
                    inputs:
                      vault_password: 'new_password'
                  - name: "TEST - SCM Credential"
                    state: present
                    credential_type: Source Control
                    inputs:
                      username: joe
                      password: secret
        
                teams:
                  - name: "TEST - Test Team 1"
                    description: "test team"
                    state: present
                    roles:
                      - role: use
                        inventory: "TEST - New Inventory"
                      - role: use
                        project: "TEST - New Project"
                      - role: use
                        credential: "TEST - Example password"
                      - role: use
                        credential: "TEST - SCM Credential"
                      - role: execute
                        job_template: "TEST - Job Template to Launch"

```


## Todo

Comments and findings are welcome.
