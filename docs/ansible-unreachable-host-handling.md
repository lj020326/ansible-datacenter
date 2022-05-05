
Ansible: Getting list of failed hosts and using in a subsequent play
===

Handling the ansible inventory can have some frustrating characteristics – one of which is the difficulty in capturing lists of hosts which have failed and carrying out remedial operations.

##### First Attempt

For quite a while I’ve resorted to doing what I assume most people do, which is to capture the output log and grep for failures, successes, write them into individual files and deal with them later.   After that I tried experimenting with using ‘block’ and ‘rescue’, however this doesn’t prevent the host from being removed from subsequent plays;  resetting the meta vars can get around this but its messy and hard to follow whats going on when reading the code.

##### Second Attempt

So, my second attempt at resolving this (first proper attempt) involved carrying out checks on the hosts (such as running the ‘ping’ or ‘setup’ modules) and setting a fact afterwards.   If the check passed, then the fact would get set and that would indicate the task worked.   Here’s an example –

```yml
- name: Check ssh connection works with a basic command
   raw: whoami
   register: connect_test
   changed_when: false
 
 - name: Set passed host connection fact
   set_fact:
     passed_connection: true
   when: connect_test.rc == 0
```

Here, I check you can ssh onto the server using ‘raw’ (in case it’s a server without Python installed).    The next step sets a fact called ‘passed\_connection’ as true.    There’s a when condition here checking if the return code of the raw command was zero, but it’s not actually needed – if the raw command fails the playbook won’t move onto this step for the failed host, it’ll just move onto the next host in the list.

This approach also worked when delegating to another host – so doing an nslookup of the inventory host from the host the playbook is running from – 

```yml
- name: Check DNS name resolves for inventory hostname
  shell: "nslookup {{ inventory_hostname }}"
  ignore_errors: true
  register: dns_lookup
  delegate_to: localhost
 
- name: Set dns_resolves fact
  set_fact:
    dns_resolves: true
  when: dns_lookup.rc == 0 
```

This example is slightly different to the first in that ‘ignore\_errors’ is set to true – this means that even if it fails it will still move onto the next task, which sets the dns\_resolves fact to true; however if it has failed, this fact won’t be set because the when condition \*is\* used this time around.

  
Once the facts are set for our successful hosts, we then need to make use of them.   My idea was to have a play that ran at the end of all my other tasks that read the facts and used them to create lists of the status of each host.    I accomplished this using a combination of jinja2 and set\_fact like this –

```yml
- set_fact:
    unreachable_hosts: "{% set unreachable_hosts = [] %}{% for host in ansible_play_hosts_all %}{% if hostvars[host]['passed_connection'] is undefined %}{{ unreachable_hosts.append(host) }}{% endif %}{% endfor %}{{ unreachable_hosts }}"
    no_facts_hosts: "{% set no_facts_hosts = [] %}{% for host in ansible_play_hosts_all %}{% if hostvars[host]['passed_fact_gathering'] is undefined %}{{ no_facts_hosts.append(host) }}{% endif %}{% endfor %}{{ no_facts_hosts }}"
    no_ssh_hosts: "{% set ssh_port_not_avail_hosts = [] %}{% for host in ansible_play_hosts_all %}{% if hostvars[host]['ssh_port_available'] is undefined %}{{ ssh_port_not_avail_hosts.append(host) }}{% endif %}{% endfor %}{{ ssh_port_not_avail_hosts }}"
    no_dns_hosts: "{% set no_dns_hosts = [] %}{% for host in ansible_play_hosts_all %}{% if hostvars[host]['dns_resolves'] is undefined %}{{ no_dns_hosts.append(host) }}{% endif %}{% endfor %}{{ no_dns_hosts }}"
   delegate_facts: true
   delegate_to: localhost
   run_once: true
 
- set_fact:
     unsuccessful_hosts: "{{ ansible_play_hosts_all|difference(ansible_play_hosts)}}"
   delegate_facts: true
   delegate_to: localhost
   run_once: true
 
- set_fact:
     failed_hosts: "{{ hostvars['localhost']['unsuccessful_hosts']|difference(hostvars['localhost']['unreachable_hosts'])}}"
   delegate_facts: true
   delegate_to: localhost
   run_once: true
```

Not particularly elegant at all – the first set\_fact involves looping through all the hosts in the inventory, looking at whether they have certain facts set and if so using jinja2 to add them to lists, which are in turn set as a fact on localhost using a combination of delegate\_to, delegate\_facts and run\_once.   

The second set\_fact attempts to determine what hosts failed by looking at the difference between which hosts are left in the play\_hosts group and how many were originally in the play (ansible\_play\_hosts\_all) – this list includes all hosts that failed to connect and those that failed to complete some operation during the playbook run.

The final set\_fact operation works out which hosts were reachable, but still failed.  This information was then written to a report for later analysis.   

All this is ok, but its a lot of complex, hard to follow code that doesn’t really accomplish what I wanted to.

##### Third Attempt

So this brings me to today, my third attempt to resolve this, and it’s much cleaner.  I discovered the ‘add\_host’ module and it’s opened up a whole new world of possibilities. It lets you add a host to an inventory group in memory (including one that doesn’t yet exist, creating it), to allow you to use it in a later play. The only downside is that you can’t use it in the conventional sense – I expected to do something like this –

```yml
name: check ssh
ping:
register: ping_check
ignore_errors: true
 
add_host:
  host: "{{ inventory_hostname }}"
  groups: "failed_ping"
when: ping_check.failed == True
```

but no… turns out ‘add\_host’ will only ever run once per play, like having ‘run\_once: true’ hardcoded into it. It took me ages to work out why I was only ever getting one host added to my group, when I had an inventory of around 200 all calling that task in turn.

It’s not a dealbreaker though as you can use ‘with\_items’ to pass in more hosts. I found using a separate play works well like this –

```yml
- hosts: localhost
  gather_facts: no
  become: false
  tasks:
   - add_host:
       hostname: "{{ item }}"
       groups: "resolve_check_{{ hostvars[item]['resolve_check_status'] }}"
     with_items: "{{ groups['all'] }}"
```

So here, I’ve got a play running only against localhost, with one ‘add\_host’ task, which loops through the entire ‘groups\[‘all’\]’ list – all the hosts in our inventory. In an earlier play I’ve set a fact called resolve\_check\_status (setting it to passed or failed depending on the results of the task before it), and use that to determine what group each host goes into. At the end of this play, I’ll have two groups, one called ‘resolve\_check\_passed’ containing all the hosts that passed my dns check, and one called ‘resolve\_check\_failed’ containing all the ones that didn’t.

Here’s the playbook in full –

```yml
---
# Creates groups resolve_check_passed and resolve_check_failed
- hosts: all
  gather_facts: no
  become: false
  tasks:
   - set_fact:
       connection: "{% if inventory_hostname == \"localhost\" -%}local{% else -%}ssh{%- endif %}"
 
   - name: Check hostname resolves
     shell: "nslookup {{ inventory_hostname }}"
     delegate_to: localhost
     connection: "{{ connection }}"
     become: false
     ignore_errors: true
     register: resolve_check
 
   - name: set_success_fact
     set_fact:
       resolve_check_status: passed
     when: resolve_check.failed != true
 
   - name: set_failure_fact
     set_fact:
       resolve_check_status: failed
     when: resolve_check.failed == true
 
- hosts: localhost
  gather_facts: no
  become: false
  tasks:
   - add_host:
       hostname: "{{ item }}"
       groups: "resolve_check_{{ hostvars[item]['resolve_check_status'] }}"
     with_items: "{{ groups['all'] }}"
 
- hosts: localhost
  gather_facts: no
  become: false
  connection: local
  tasks:
   - name: total hosts
     debug:
       msg: "{{ groups['all'] }}"
   - name: number of hosts passed dns
     debug:
       msg: "{{ groups['resolve_check_passed'] }}"
 
   - name: number of hosts failed dns
     debug:
       msg: "{{ groups['resolve_check_failed'] }}"
```

At the bottom is just a quick debug to print out the contents of each list. My plan here would be to create these groups for each task I need to check and use them to determine what subsequent plays to run on the hosts.

## Reference

* https://iautomatelinux.wordpress.com/2019/03/27/ansible-getting-list-of-failed-hosts-and-using-in-a-subsequent-play/
