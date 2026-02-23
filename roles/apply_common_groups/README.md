
# Role apply_common_groups

The role will derive common groups to be used by subsequent ansible plays.

Some of the most commonly used 'common' groups include:
  - common_groups__network_group
  - common_groups__oc_family
  - common_groups__oc_distribution
  - common_groups__oc_distribution_version
  - common_groups__oc_machine_type


Example usage:
```shell
- name: "Gather facts for all hosts to apply common group vars"
  tags: always
  hosts: all,!local,!node_offline
  gather_facts: yes
  roles:
    - role: apply_common_groups

- name: "Display common group information"
  debug:
    msg:
      ## dynamically derived common_groups__oc_* groups
      - "common_groups__network_group={{ common_groups__network_group }}"
      - "common_groups__oc_family={{ common_groups__oc_family }}"
      - "common_groups__oc_distribution={{ common_groups__oc_distribution }}"
      - "common_groups__oc_distribution_version={{ common_groups__oc_distribution_version }}"
      - "common_groups__oc_machine_type={{ common_groups__oc_machine_type }}"

## Should see the hosts added to the common groups in group_names in this task
- name: "Display group_names"
  debug:
    var: group_names | d('')

```

Example play output:
```output
TASK [Display common group information] ***
ok: [app-d1.example.int] => {
    "msg": [
        "common_groups__oc_family=common_groups__oc_linux", 
        "common_groups__oc_distribution=common_groups__oc_redhat", 
        "common_groups__oc_distribution_version=common_groups__oc_redhat_7", 
        "common_groups__oc_machine_type=common_groups__oc_machine_type_baremetal"
    ]
}

TASK [Display group_names] ***
ok: [app-d1.example.int] => {
    "group_names": [
        "appweb",
        "dev",
        "dmz",
        "dmz_dev",
        "foreman_content_view_rhel7_composite",
        "foreman_lifecycle_environment_dev",
        "foreman_location_mem",
        "foreman_organization_example",
        "linux",
        "lnx_all",
        "lnx_dev",
        "lnx_mem",
        "mem",
        "common_groups__oc_linux",
        "common_groups__oc_redhat",
        "common_groups__oc_redhat_7",
        "common_groups__oc_machine_type_baremetal",
        "wl_app",
        "wl_app_dev_neo",
        "wl_dev",
        "wl_hosts"
    ]
}
```

