
# Images Templates

The following diagram presents an overview of the image creation process relating to both virtual machines and container images:

```mermaid
graph TD;
    A[[Packer Build Spec]] --> B{Virtual Machine}
    B -->|yes| C[["Install OS (Centos/Ubuntu/Debian)"]]
    B -->|no| D[[Container Build]]
    C --> E[[Post OS Install - VM Base VM Template Image]]
    D --> F[[Post OS Install - OS Base Container Image]]
    E --> G[["Ansible Provision Role + Harden Security Profile"]]
    F --> G[["Ansible Provision Role + Harden Security Profile"]]
    G --> H[["Ansible Post OS Install - Software Install"]]
    H --> I[[Ansible Application Deploy]]
    I --> J[[Ansible Maintenance]]
```

## Bootstrapping Virtual Machine Templates

The [bootstrap_vm_template.yml](./../bootstrap_vm_template.yml) playbook is used by [vm-templates repo](https://github.com/lj020326/vm-templates) to build VMware Ubuntu, Debian, and Centos templates. 

The 'ansible' and 'vm template build' pipelines are both automated using the [pipeline-automation-lib](https://github.com/lj020326/pipeline-automation-lib/) jenkins library.
