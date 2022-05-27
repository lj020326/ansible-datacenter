
Using multiple Ansible YAML-based Inventories  
===

The following sections will explore use cases when using multiple YAML-based inventory files:

* [Example 1: Playbook using multiple YAML inventories](#Example-01)

* [Example 2: Playbook using multiple YAML inventories with non-overlapping parent groups - works but doesn't](#Example-02)

* [Example 3: Playbook using multiple YAML inventories with group requirement sufficiency](#Example-03)

The purpose here is to fully understand how to leverage child group vars especially with respect to deriving the expected behavior for variable merging. 

The ansible environment used to perform the examples:

```output
$ git clone https://github.com/lj020326/ansible-inventory-file-examples.git
$ cd ansible-inventory-file-examples
$ git switch develop-lj
$ cd tests/ansible-multiple-yaml-inventories
$ ansible --version
ansible [core 2.12.3]
  config file = None
  configured module search path = ['/Users/ljohnson/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /Users/ljohnson/.pyenv/versions/3.10.2/lib/python3.10/site-packages/ansible
  ansible collection location = /Users/ljohnson/.ansible/collections:/usr/share/ansible/collections
  executable location = /Users/ljohnson/.pyenv/versions/3.10.2/bin/ansible
  python version = 3.10.2 (main, Feb 21 2022, 15:35:10) [Clang 13.0.0 (clang-1300.0.29.30)]
  jinja version = 3.1.0
  libyaml = True
```



## <a id="Example-01"></a>Example 1: Playbook using multiple YAML inventories with overlapping parent groups

See the details for this example [here](./example1/README.md)

## <a id="Example-02"></a>Example 2: Playbook using multiple YAML inventories with non-overlapping parent groups

See the details for this example [here](./example2/README.md)

## <a id="Example-03"></a>Example 3: Playbook using multiple YAML inventories meeting group requirement sufficiency

See the details for this example [here](./example3/README.md)
