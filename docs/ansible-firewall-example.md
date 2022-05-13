

## Additive Approach to maintaining Firewall (FW) State

One common approach used to manage firewalls with ansible is to add the necessary port needed by that role just applied.

For this demonstration, it will be assumed that the firewall role performs a simple task to open ports using the [firewalld module](https://docs.ansible.com/ansible/latest/collections/ansible/posix/firewalld_module.html) as follows.

./roles/ansible-firewalld/tasks/main.yml:
```yml
---

- name: Allow ports through the firewall
  ansible.posix.firewalld:
    port: "{{ item }}"
    zone: "internal"
    permanent: true
    state: enabled
    immediate: yes
  with_items:
    "{{ firewalld_ports }}"
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
    firewalld_ports: [ "{{ postfix_firewalld_ports }}" ]
  roles:
    - role: ansible-role-postfix
    - role: ansible-firewalld

- name: "Setup web"
  hosts: linux
  become: true
  tags: bootstrap-httpd
  vars:
    httpd_firewalld_ports:
      - "80/tcp"
      - "443/tcp"
    firewalld_ports: [ "{{ httpd_firewalld_ports }}" ]
  roles:
    - role: ansible-role-httpd
    - role: ansible-firewalld

- name: "Setup veeam-agent"
  hosts: linux
  become: true
  tags: bootstrap-veeam
  vars:
    veeam_firewalld_ports:
      - "10006/tcp"
    firewalld_ports: [ "{{ veeam_firewalld_ports }}" ]
  roles:
    - role: ansible.veeam-agent
    - role: ansible-firewalld
      tags: [ 'firewall-config-veeamagent' ]

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
    firewalld_ports: [ "{{ bind_firewalld_ports }}" ]
  roles:
    - role: ansible-role-bind
    - role: ansible-firewalld



```

As can be seen, this approach is additive in nature.  At any time, ports can be added to the existing configuration.  This makes it easy to add to any playbook for any respective role with firewall dependencies.  To put another way, the upside to this approach is that the role implementor does not need to know anything about the firewall state in order to add ports.

### Downside/Challenges with Additive Approach

The downside to this approach is that for any given inventory host, there is no way to arrive at the current state of the firewall without running all the plays that have been used. 

### Idempotent Firewall Role Requirement

In a more ideal/stringent setting, the complete state of the firewall must be arrived at by  running an idempotent firewalld role such that it will resolve all necessary groupvar/hostvar variables and arrive at the defined FW state without having to replay all the plays with FW requirements.

## Alternative Approach using variable naming convention

The [varnames lookup plugin](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/varnames_lookup.html) can be used to derive all variables matching a pattern (e.g., 'firewall_ports__*') to derive all the firewall variable port definitions/specifications for an inventory host.

First, the variables will need to exist in the inventory as group vars or host vars for the variable lookup plugin approach to work.
From the prior playbook, with the exception of the bind role, all of the target hosts are linux hosts. 
So we create a 'linux' group to add them and a 'nameserver' group var file for the nameserver port config settings.

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
    - role: ansible-firewalld

- name: "Setup web"
  hosts: linux
  become: true
  tags: bootstrap-httpd
  roles:
    - role: ansible-role-httpd
    - role: ansible-firewalld

- name: "Setup veeam-agent"
  hosts: linux
  become: true
  tags: bootstrap-veeam
  roles:
    - role: ansible.veeam-agent
    - role: ansible-firewalld
      tags: [ 'firewall-config-veeamagent' ]

- name: "Setup nameservers"
  hosts: nameserver
  become: true
  tags: bootstrap-bind
  roles:
    - role: ansible-role-bind
    - role: ansible-firewalld

```

./roles/ansible-firewalld/tasks/main.yml
```yml
---

- name: Combine firewalld_ports__* ports into merged list
  set_fact:
    firewalld_ports: "{{ firewalld_ports|d([]) + lookup('vars', item)|d([]) }}"
  loop: "{{ lookup('varnames','^firewalld_ports__*$') }}"
  
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
  with_items:
    "{{ firewalld_ports }}"
  notify:
    - reload firewalld
```


That is to say that the role can be used by role implementors in an additive way, but also upon execution, the role will resolve all firewall defined variables such that at any run, the same firewall state will be arrived at in an idempotent manner.




