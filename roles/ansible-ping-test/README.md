
# Role ansible-ping-test

The role will place target node into node_offline if the ping test fails for the specified hosts.

Example usage:
```shell
- name: "Pre-check | Perform connectivity (ping) tests to determine nodes to add to group 'node_offline'"
  hosts: all,!local,!node_offline
  tags: always
  ## https://issues.jenkins-ci.org/browse/JENKINS-54557
  ignore_unreachable: yes
  gather_facts: no
  vars_files:
    - vars/vault.yml
  roles:
    - role: ansible-ping-test
      when:
        - not ping_exclude|d(False)|bool
        - inventory_hostname in ansible_play_hosts

```

