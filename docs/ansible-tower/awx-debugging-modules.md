
# Debugging modules on AWX Platform

## Debugging modules on AWX control node

Log onto the tower control node 

```shell
## log into tower
## sandbox => tower.example.int
ssh username@tower.example.int
sudo su
```

Launch the play from AWX.

When the bubble wraps are available, save copy for debugging:
```shell
mkdir -p /tmp/save
cp -npr /tmp/bwrap_* /tmp/save/
cd /tmp/save/bwrap_35484_fq1l84h_/awx_35484_ioxopt89/project/collections/ansible_collections/dettonville/utils/tests/integration/targets
```

Run the test manually

```shell
cd /tmp/save/bwrap_35484_fq1l84h_/awx_35484_ioxopt89/project/collections/ansible_collections/dettonville/utils/tests/integration/targets
./runme.sh -vvv
```

At point of failure, run the module in debug mode
```shell
cd /var/lib/awx/.ansible/tmp/ansible-tmp-1663850363.83-19341-84313376690859
./AnsiballZ_git_acp.py explode
Module expanded into:
/var/lib/awx/.ansible/tmp/ansible-tmp-1663850363.83-19341-84313376690859/debug_dir

```

Save formatted args

```shell
cat debug_dir/args | python -m json.tool > debug_dir/args.json
cp -p debug_dir/args.json debug_dir/args.orig.json
cp -p debug_dir/args.json debug_dir/args
## if necessary edit any module args in debug_dir/args
```

Run the Module

```shell
export ANSIBLE_DEBUG=1
./AnsiballZ_git_acp.py execute | python -m json.tool

```

Edit module if necessary and test

```shell
nano debug_dir/ansible_collections/dettonville/utils/plugins/module_utils/git_actions.py
./AnsiballZ_git_acp.py execute | python -m json.tool

```


## Debugging module references

* https://docs.ansible.com/ansible/latest/dev_guide/debugging.html
* https://yaobinwen.github.io/2021/01/29/Ansible-how-to-debug-a-problematic-module.html
