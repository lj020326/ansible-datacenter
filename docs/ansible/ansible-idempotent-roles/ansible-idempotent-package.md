
# Approach to maintaining machine state

## Additive/Incremental Approach

One common approach used to manage host machine state with ansible is to add the necessary configurations by the respective role/play.


### Example using package role

For this demonstration, it will be assumed that the linux package role performs a simple task to install linux packages using the [linux package module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/package_module.html) as follows.

Using the following inventory example.

./inventory/linux.ini:
```ini

[linux]
linuxhost001
linuxhost002
linuxhost003
...
linuxhost999

[webserver]
linuxhost023
linuxhost044
linuxhost080
linuxhost088

[nameserver]
linuxhost053


```



./roles/bootstrap-linux-package/tasks/main.yml:
```yml
---

- name: "Install packages"
  when: __bootstrap_linux_package_list|d([])|length>0
  package:
    name: "{{ __bootstrap_linux_package_list }}"
    state: "present"
    update_cache: "{{ bootstrap_linux_package_update_cache }}"

```

This works fine of the complete list is known at the time of running the play.

In most circumstances, packages are installed incrementally by other plays and/or roles.

