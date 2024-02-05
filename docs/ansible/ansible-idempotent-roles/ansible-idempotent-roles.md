
# Idempotent Roles - Example idempotent role maintaining Firewall (FW) State

## Additive/Incremental Approach

One common approach used to manage firewalls with ansible is to add the necessary port/service/rule needed by a role/play just applied.

For this demonstration, it will be assumed that the firewall role performs a simple task to open ports using the [firewalld module](https://docs.ansible.com/ansible/latest/collections/ansible/posix/firewalld_module.html) as follows.

Using the following inventory example.

./inventory/linux.ini:
```ini

[linux]
linuxhost001
linuxhost002
linuxhost003
...
linuxhost999


[veeam-agent:children]
linux

[webserver]
linuxhost023
linuxhost044
linuxhost080
linuxhost088

[nameserver]
linuxhost053


```



./roles/bootstrap-linux-firewalld/tasks/main.yml:
```yml
---

- name: Allow ports through the firewall
  ansible.posix.firewalld:
    port: "{{ item }}"
    zone: "internal"
    permanent: true
    state: enabled
    immediate: yes
  with_items: "{{ firewalld_ports }}"
  notify:
    - reload firewalld

```

The following playbook example then specifies the ports to be added to the firewall by the firewalld role after each prior app role is applied.

./playbooks/bootstrap-linux.yml:
```yaml
---

- name: "Setup postfix"
  hosts: linux
  become: true
  tags: bootstrap-postfix
  vars:
    postfix_firewalld_ports:
      - "25/tcp"
    firewalld_ports: "{{ postfix_firewalld_ports }}"
  roles:
    - role: ansible-role-postfix
    - role: bootstrap-linux-firewalld

- name: "Setup veeam-agent"
  hosts: linux
  become: true
  tags: bootstrap-veeam
  vars:
    veeam_firewalld_ports:
      - "10006/tcp"
    firewalld_ports: "{{ veeam_firewalld_ports }}"
  roles:
    - role: bootstrap-veeam-agent
    - role: bootstrap-linux-firewalld
      tags: [ 'firewall-config-veeamagent' ]

- name: "Setup web"
  hosts: webserver
  become: true
  tags: bootstrap-httpd
  vars:
    httpd_firewalld_ports:
      - "80/tcp"
      - "443/tcp"
    firewalld_ports: "{{ httpd_firewalld_ports }}"
  roles:
    - role: ansible-role-httpd
    - role: bootstrap-linux-firewalld

- name: "Setup nameservers"
  hosts: nameserver
  become: true
  tags: bootstrap-bind
  vars:
    bind_sshd_ports:
      - "53/udp"
      - "53/tcp"
      - "953/udp"
      - "953/tcp"
    firewalld_ports: "{{ bind_firewalld_ports }}"
  roles:
    - role: ansible-role-bind
    - role: bootstrap-linux-firewalld



```

As can be seen, this approach is additive in nature.  At any time, ports can be added to the existing configuration.  This makes it easy to add to any playbook for any respective role with firewall dependencies.  To put another way, the upside to this approach is that the role implementor does not need to know anything about the firewall state in order to add ports.

### Downside/Challenges with Additive Approach

The downside to this approach is that for any given inventory host, there is no way to arrive at the current state of the firewall without running all the plays that have been used. 

Another downside is that if the plays used to arrive at the final FW state are time-consuming or costly in terms of the tasks needed to be done, it can become untenable to have to re-run all the plays to apply a simple set of firewall changes/updates. 

E.g., From my experiences, I have playbooks that can take up to 60 minutes to run through in some cases.  It would become unacceptable to run the entire playbook just to add a port for one of the applications defined in the set of plays.  

### Idempotent Firewall Role Requirement

In a more ideal/stringent setting, the complete state of the firewall must be arrived at by  running an idempotent firewall role such that it will resolve all necessary groupvar/hostvar variables and arrive at the defined FW state without having to replay all the plays with FW requirements.

## Alternative Approach using variable naming convention

The [varnames lookup plugin](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/varnames_lookup.html) can be used to derive all variables matching a pattern (e.g., 'firewalld_ports__*') to derive all the firewall variable port allowed specifications for an inventory host.

The variables will need to exist in the inventory as group vars or host vars for the variable lookup plugin approach to work.

So we create group var files for each of the respective target host groups defined in the playbook.

In this case, we create a 'linux', 'webserver', and 'nameserver' group var file to add the respective firewall_port__* variables with the necessary port config settings.

./inventory/group_vars/linux.yml:
```yml
---

firewalld_ports__postfix:
  - "25/tcp"
 
firewalld_ports__httpd:
  - "80/tcp"
  - "443/tcp"
 
firewalld_ports__veeam:
  - "10006/tcp"

```

./inventory/group_vars/webserver.yml:
```yml
---
 
firewalld_ports__httpd:
  - "80/tcp"
  - "443/tcp"

```

./inventory/group_vars/nameserver.yml:
```yaml
---

firewalld_ports__bind:
  - "53/udp"
  - "53/tcp"
  - "953/udp"
  - "953/tcp"
```


./playbooks/bootstrap-linux.yml:
```yaml
---

- name: "Setup postfix"
  hosts: linux
  become: true
  tags: bootstrap-postfix
  roles:
    - role: ansible-role-postfix
    - role: bootstrap-linux-firewalld

- name: "Setup web"
  hosts: webserver
  become: true
  tags: bootstrap-httpd
  roles:
    - role: ansible-role-httpd
    - role: bootstrap-linux-firewalld

- name: "Setup veeam-agent"
  hosts: linux
  become: true
  tags: bootstrap-veeam
  roles:
    - role: bootstrap-veeam-agent
    - role: bootstrap-linux-firewalld
      tags: [ 'firewall-config-veeamagent' ]

- name: "Setup nameservers"
  hosts: nameserver
  become: true
  tags: bootstrap-bind
  roles:
    - role: ansible-role-bind
    - role: bootstrap-linux-firewalld

```

./roles/bootstrap-linux-firewalld/tasks/main.yml:
```yml
---

- name: Combine firewalld_ports__* ports into merged list
  set_fact:
    firewalld_ports: "{{ firewalld_ports|d([]) + lookup('vars', item)|d([]) }}"
  loop: "{{ lookup('varnames','^firewalld_ports__') }}"
  
- name: "Display firewalld_ports"
  debug:
    var: firewalld_ports

- name: Allow ports through the firewall
  ansible.posix.firewalld:
    port: "{{ item }}"
    zone: "internal"
    permanent: true
    state: enabled
    immediate: yes
  with_items: "{{ firewalld_ports }}"
  notify:
    - reload firewalld
```


That is to say that the role can be used by role implementors in an additive way, but also upon execution, the role will resolve all firewall defined variables such that at any run, the same firewall state will be arrived at in an idempotent manner.

The overall concept is that plays and roles pair up with groups.
Once that framework is used consistently, everything starts to make sense. 

For example, for the 'postfix' play and role there would be a 'postfix' group.
For a 'veeam-agent' play and role there would be a 'veeam-agent' group.
For a 'webserver' play and role there would be an 'webserver' group
For a 'nameserver' play/role there would be 'nameserver' group.
For a 'badwolf' play/role there would be 'badwolf' group.

The idea is that application roles have groups defined as a sort of header space used by the inventory to declare whatever is needed for the respective role such that other utility/helper roles can re-use the same definitions when and if necessary.

It becomes not hard at all, in fact very easy, to patrol / enforce once the framework naming convention is done methodically/consistently.

## windows mssql example

Another example FW usage for mssql.

We assume that there is an ansible-win-firewall role to support updating the firewall for windows machines.

./roles/ansible-win-firewall/tasks/main.yml
```yml
---

- name: Combine firewall_win_ports__* ports into merged list
  set_fact:
    firewall_win_ports: "{{ firewall_win_ports|d([]) + lookup('vars', item)|d([]) }}"
  loop: "{{ lookup('varnames','^firewall_win_ports__$') }}"
  
- name: "Display firewall_win_ports"
  debug:
    var: firewall_win_ports

## See allow port requests example here
## ref: https://runebook.dev/en/docs/ansible/collections/community/windows/win_firewall_rule_module
- name: Firewall | allow port requests
  win_firewall_rule:
    name: "{{ win_fw_prefix }}-allow-incoming-{{ item.program }}-{{ item.port }}-{{ item.protocol }}"
    enable: yes
    state: present
    localport: "{{ item.port }}"
    protocol: "{{ item.protocol }}"
    action: allow
    direction: in
  with_items: "{{ firewall_win_ports }}"
  notify:
    - reload firewall_win

```

Take an example windows host inventory as follows.

./inventory/windows.ini:
```ini

[windows]
windows001
windows002
windows003
...
windows999

[windows:children]
mssql

[mssql]
mssql_host[01:23]

```


Using the variable lookup approach, you can do this:

./inventory/group_vars/mssql.yml:
```yaml
firewall_win_ports__mssql: 
  - port: "11433"
    protocol: "udp"
    program: "mssql"
  - port: "11433"
    protocol: "tcp"
    program: "mssql"

```

Then the mssql playbook.

./playbooks/bootstrap-mssql.yml:
```yaml
---

- name: "Setup mssql"
  hosts: mssql
  become: true
  tags: bootstrap-mssql
  roles:
    - role: ansible-role-mssql
    - role: ansible-win-firewall

```

## Next Steps / Taking this approach further

While the examples above have been limited in nature to one Firewall use case, of allowing a port, the same variable lookup method can be used to define all the firewall rules for any given application as a list of dictionaries and each of the application lists can be merged using the same variable lookup method.

For example, a full set of firewall rules for an application can be specified in a list of dictionaries similar to the following.

./inventory/group_vars/mssql.yml:
```yaml
firewall_win_rules__mssql: 
  - localport: "11433"
    remoteport: any
    protocol: "udp"
    program: "mssql"
    action: "allow"
    direction: "in"
    profile: "private"
  - localport: "11433"
    remoteport: any
    protocol: "tcp"
    program: "mssql"
    action: "allow"
    direction: "in"
    profile: Public

```


./roles/ansible-win-firewall/tasks/main.yml:
```yml
---

- name: Combine firewall_win_rules__* ports into merged list
  set_fact:
    firewall_win_rules: "{{ firewall_win_rules|d([]) + lookup('vars', item)|d([]) }}"
  loop: "{{ lookup('varnames','^firewall_win_rules__') }}"
  
- name: "Display firewall_win_rules"
  debug:
    var: firewall_win_rules

  win_firewall_rule:
    name: "{{ win_fw_prefix }}-{{ item.action }}-{{ item.direction }}-{{ item.program | win_basename }}"
    program: "{{ item.program }}"
    enable: yes
    state: present
    localport: "{{ item.localport | d(omit) }}"
    remoteport: "{{ item.remoteport | d(omit) }}"
    action: "{{ item.action | d(omit) }}"
    direction: "{{ item.direction | d(omit) }}"
    protocol: "{{ item.protocol | d(omit) }}"
    profile: "{{ item.profile | d(omit) }}"
  with_items: "{{ firewall_win_rules }}"
  notify:
    - reload firewall_win

```


## Working example roles from this repository

For examples, see the group_var files in the [example repo here](https://github.com/lj020326/ansible-datacenter) for the following groups/examples:

group var file|var names used
---|---
[dc_os_linux.yml](https://github.com/lj020326/ansible-datacenter/tree/main/inventory/group_vars/dc_os_linux.yml)|firewalld_services__linux
[postfix_server.yml](https://github.com/lj020326/ansible-datacenter/tree/main/inventory/group_vars/postfix_server.yml)|firewalld_ports__postfix
[nameserver.yml](https://github.com/lj020326/ansible-datacenter/tree/main/inventory/group_vars/nameserver.yml)|firewalld_ports__bind
[veeam_agent.yml](https://github.com/lj020326/ansible-datacenter/tree/main/inventory/group_vars/veeam_agent.yml)|firewalld_ports__veeam

## Firewall Role execution from another role

If there is the need to invoke the firewall role from another role, see the example nfs-service role invoking the firewall role below.

[roles/bootstrap-nfs-service/tasks/main.yml](https://github.com/lj020326/ansible-datacenter/blob/main/roles/bootstrap-nfs-service/tasks/main.yml#L56-L64):
```yaml
- name: Setup and run nfs
  include_role:
    name: geerlingguy.nfs
 
- name: Allow nfs traffic through the firewall
  when: firewalld_enabled | bool
  tags: [ firewall-config-nfs ]
  include_role:
    name: bootstrap-linux-firewalld
  vars:
    firewalld_action: configure
    firewalld_services: "{{ nfs_firewalld_services | d([]) }}"
    firewalld_ports: "{{ nfs_firewalld_ports | d([]) }}"
```

