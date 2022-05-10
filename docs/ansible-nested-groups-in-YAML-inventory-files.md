
# Managing "nested" group in Ansible YAML inventory files

I'm managing a number of clusters, and I wanted to consolidate multiple inventory files into a single inventory that looks effectively like this:

```
all:
  children:
    cluster_one:
      children:
        controller:
          hosts:
            host1:
            host2:
            host3:
        compute:
          hosts:
            host4:
            host5:
            host6:
    cluster_two:
      children:
        controller:
          hosts:
            host11:
            host12:
            host13:
```

I was expecting this to end up parsed like this:

```
[cluster_one]
host1
host2
host3
host4
host5
host6

[cluster_two]
host11
host12
host13

[controller]
host1
host2
host3
host11
host12
host13

[compute]
host4
host5
host6
```

With that structure, I would be able to ask for "controllers in cluster_one" with the host pattern `cluster_one:&controller`, or if I wanted all controllers across all clusters I could just ask for `controller`. Convenient!

Unfortunately, it's actually parsed like this:

```
[cluster_one]
host1
host2
host3
host4
host5
host6

[cluster_two]
host11
host12
host13

[controller]
host1
host2
host3
host11
host12
host13

[compute]
host4
host5
host6

[cluster_one:children]
controller
compute

[cluster_two:children]
controller
```

Note the two extra entries at the bottom that make the `controller` and `compute` groups children of their respecting "parents" in the YAML file, rather than making only their _hosts_ members of the parents.

So for example if I run `ansible -i example.yml --list-hosts cluster_one`, I get:

```
  hosts (9):
    host1
    host2
    host3
    host4
    host5
    host6
    host11
    host12
    host13
```

That was unexpected and made me sad. I can obviously restructure the inventory so that it works (e.g. by using the INI-format inventory shown here, or re-structuring the YAML for a similar structure), but those solutions involve listing each host multiple times, which means it's possible for things to get out of sync.

Is there a way to structure the inventory that gets me the grouping I want without having to explicitly list hosts in multiple groups?

## Solution

By using an inventory layout similar to what @Zeitounator suggested and making use of the `constructed` inventory plugin, I've been able to get what I want. I start with a static inventory in `inventory/static/clusters.yml` that looks like:

```
all:
  children:
    cluster_one:
      children:
        cluster_one_controller:
          vars:
            node_role: controller
          hosts:
            host1:
            host2:
            host3:
        cluster_one_compute:
          vars:
            node_role: compute
          hosts:
            host4:
            host5:
            host6:
    cluster_two:
      children:
        cluster_two_controller:
          vars:
            node_role: controller
          hosts:
            host11:
            host12:
            host13:
```

Then I mix in the following inventory from `inventory/dynamic/constructed.yml`:

```
plugin: constructed
strict: false
keyed_groups:
  - prefix: ""
    separator: ""
    key: node_role
```

And an `ansible.cfg` that looks like:

```
[defaults]
inventory = inventory/static,inventory/dynamic
```

(That ensures the `constructed` inventory loads _after_ the static inventory, without mucking about trying to manually order filenames).

___

With the above in place, I can run a task on just `cluster_one`:

```
ansible cluster_one ...
```

Or on all controllers:

```
ansible controller ...
```

Or just on controllers in `cluster_two`:

```
ansible 'cluster_two:&controller' ...
```

Etc.

(For that last example I can of course write `cluster_two_controller` instead of `cluster_two:&controller`, but I like the intersection syntax because it matches my mental map of what I'm trying to do.)


___

There is a possibility to DRY a bit more with the constructed plugin if you keep the same naming convention for cluster groups/subgroups, eliminating the need to introduce an additional variable in the groups.

Note that using convention for file names inside the inventory dir allows for natural loading order of the inventory sources as well without having to modify `ansible.cfg`

Given the following minimal `inventories/cluster/cluster.yml` static inventory source:

```
---
all:
  children:
    cluster_one:
      children:
        cluster_one_controller:
          hosts:
            host1:
            host2:
            host3:
        cluster_one_compute:
          hosts:
            host4:
            host5:
            host6:
    cluster_two:
      children:
        cluster_two_controller:
          hosts:
            host11:
            host12:
            host13:
```

And the corresponding `inventories/cluster/cluster_constructed.yml` dynamic inventory source based on existing group names detection:

```
---
plugin: constructed
strict: false
groups:
  controller: group_names | select('match', '^.*_controller$') | length > 0
  compute: group_names | select('match', '^.*_compute$') | length > 0
```

We get the expected result using our composite inventory directory

```
$ ansible-inventory -i inventories/cluster --list
{
    "_meta": {
        "hostvars": {}
    },
    "all": {
        "children": [
            "cluster_one",
            "cluster_two",
            "compute",
            "controller",
            "ungrouped"
        ]
    },
    "cluster_one": {
        "children": [
            "cluster_one_compute",
            "cluster_one_controller"
        ]
    },
    "cluster_one_compute": {
        "hosts": [
            "host4",
            "host5",
            "host6"
        ]
    },
    "cluster_one_controller": {
        "hosts": [
            "host1",
            "host2",
            "host3"
        ]
    },
    "cluster_two": {
        "children": [
            "cluster_two_controller"
        ]
    },
    "cluster_two_controller": {
        "hosts": [
            "host11",
            "host12",
            "host13"
        ]
    },
    "compute": {
        "hosts": [
            "host4",
            "host5",
            "host6"
        ]
    },
    "controller": {
        "hosts": [
            "host1",
            "host11",
            "host12",
            "host13",
            "host2",
            "host3"
        ]
    }
}
```

This will let you select any of the following patterns (non exhaustive list):

-   a full cluster e.g. `cluster_one`
-   all controllers of a cluster e.g `cluster_two_controller` or `cluster_two:&controller`
-   all compute nodes across clusters e.g. `compute`
-   ...


## References

* https://stackoverflow.com/questions/68746910/managing-nested-group-in-ansible-yaml-inventory-files
* 