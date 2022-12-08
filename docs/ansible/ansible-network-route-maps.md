
# Getting started with Route Maps Resource Modules

Red Hat Ansible Engine v2.9 [introduced the first set of Resource Modules](https://www.ansible.com/blog/network-features-coming-soon-in-ansible-engine-2.9) that make network automation easier and more consistent, especially in multi-vendor environments. These network resource specific and opinionated Ansible modules help us avoid creating overly complex Jinja2 templates to render and push network configurations, thereby easing the adoption of network automation both in green and brownfield environments. The resource modules, along with the tools provided in [ansible.utils](https://cloud.redhat.com/ansible/automation-hub/repo/published/ansible/utils), are highly focused on allowing the end user to manipulate network configuration as “structured data” and not have to worry about network platform specific details.

In the past, we have gone through resource modules that facilitate managing [BGP](https://www.ansible.com/blog/getting-started-with-bgp-global-resource-modules), [OSPFv2](https://www.ansible.com/blog/getting-started-with-ospfv2-resource-modules), [ACLs](https://www.ansible.com/blog/deep-dive-acl-configuration-management-using-ansible-network-automation-resource-modules) and [VLANS](https://www.ansible.com/blog/deep-dive-on-vlans-resource-modules-for-network-automation) configurations on network devices. In this blog post, we’ll cover the newly added route maps resource modules using cisco.nxos.nxos\_route\_maps as an example.

Route maps are used to define which routes from a source routing protocol are to be distributed to a target routing protocol. It also allows filtering routes that are sent or received between BGP peers. Every route map can have multiple entries, with each entry having a sequence number and an action (the “permit” or “deny” clause) associated with it. Each of these contain an ordered set of match criterias (the “match” clause) that are successively evaluated. Route maps are similar to access lists (ACLs), but are more powerful and flexible than them and can be used to match routes based on conditions that ACLs cannot verify. In fact, route maps have the ability to leverage an existing ACL as a match criteria within it. They can also modify information associated with a route while redistributing it into the target protocol using the “set” clause. 

Route maps are an extremely powerful feature in the networking landscape, and with all its bells and whistles, it can be difficult to manually manage them, especially in a production environment where the margin of error is very small. This is where the route maps resource modules can step in! Let us walk through several examples on how to leverage and make the best use of them in real world scenarios. 

## The Certified Ansible Content Collection

The route maps resource module is available for the following Ansible-maintained platforms on both Automation Hub (supported) and Ansible Galaxy (community):

<table><tbody><tr><td><p>Platform</p></td><td><p>Full Collection Path</p></td><td><p>Automation Hub Link<br>(requires subscription)</p></td><td><p>Ansible Galaxy Link</p></td></tr><tr><td><p><span>Arista EOS</span></p></td><td><p><span>arista.eos.eos_route_maps</span></p></td><td><p><a href="https://cloud.redhat.com/ansible/automation-hub/repo/published/arista/eos/content/module/eos_route_maps"><span>Hub</span></a></p></td><td><p><a href="https://galaxy.ansible.com/arista/eos" rel="noopener"><span>Galaxy</span></a></p></td></tr><tr><td><p><span>Cisco IOS</span></p></td><td><p><span>cisco.ios.ios_route_maps</span></p></td><td><p><a href="https://cloud.redhat.com/ansible/automation-hub/repo/published/cisco/ios/content/module/ios_route_maps"><span>Hub</span></a></p></td><td><p><a href="https://galaxy.ansible.com/cisco/ios"><span>Galaxy</span></a></p></td></tr><tr><td><p><span>Cisco NX-OS</span></p></td><td><p><span>cisco.nxos.nxos_route_maps</span></p></td><td><p><a href="https://cloud.redhat.com/ansible/automation-hub/repo/published/cisco/nxos/content/module/nxos_route_maps"><span>Hub</span></a></p></td><td><p><a href="https://galaxy.ansible.com/cisco/nxos"><span>Galaxy</span></a></p></td></tr><tr><td><p><span>Juniper JunOS</span></p></td><td><p><span>junipernetwork.junos.junos_routing_instances</span></p></td><td><p><a href="https://cloud.redhat.com/ansible/automation-hub/repo/published/junipernetworks/junos/content/module/junos_routing_instances"><span>Hub</span></a></p></td><td><p><a href="https://galaxy.ansible.com/junipernetworks/junos"><span>Galaxy</span></a></p></td></tr><tr><td><p><span>VyOS</span></p></td><td><p><span>vyos.vyos.vyos_route_maps</span></p></td><td><p><a href="https://cloud.redhat.com/ansible/automation-hub/repo/published/vyos/vyos"><span>Hub</span></a></p></td><td><p><a href="https://galaxy.ansible.com/vyos/vyos"><span>Galaxy</span></a></p></td></tr></tbody></table>

  
**Note:** For Cisco IOS-XR, it is suggested to use the [cisco.iosxr.iosxr\_config](https://cloud.redhat.com/ansible/automation-hub/repo/published/cisco/iosxr/content/module/iosxr_config) module and the platform’s Route Policy Language(RPL) to configure route maps.

This blog uses the nxos\_route\_maps module from the cisco.nxos Collection and a Cisco Nexus 9000v running NX-OS 9.3.6 as reference for all the configuration management operations in the examples.

For more information on Ansible Content Collections, please refer to the following documentation: [https://docs.ansible.com/ansible/latest/user\_guide/collections\_using.html](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html).

## Getting started - Managing Route Maps configuration with Ansible

The route maps resource module provides the same level of functionality that a user can achieve when configuring manually on a device running Cisco NX-OS. But combined with the power of Ansible’s fact gathering capabilities and resource module approach, this is more closely aligned with how network professionals work day to day. Like all supported resource modules, the route\_maps module also supports the following seven states: 

-   merged
-   replaced
-   overridden
-   deleted
-   gathered
-   rendered
-   parsed 

Let us take a look at them one by one.

Below is the existing state of route map configurations on our target device.

```
nxos9k# show running-config  | section “^route-map”
route-map rmap1 permit 10
  description rmap1-10-permit
  match as-number 65564
  match as-path Allow40
  match ip address acl_1
route-map rmap1 deny 20
  description rmap1-20-deny
  match ip address prefix-list AllowPrefix1 AllowPrefix2
  match community BGPCommunity1 BGPCommunity2
  set dampening 30 1500 10000 120
route-map rmap2 permit 10
```

## Using state gathered - Building an Ansible inventory

Resource modules have the ability to convert the network platform specific configuration into ''structured data'' as per the module’s argument specifications by using state: gathered. This is equivalent to gathering Ansible facts for any network resource. In the following example, we will use state: gathered in a task to read the route-maps configuration as structured data and write it to host\_vars. If you are new to the concept of Ansible inventory and want to learn more about group\_vars and host\_vars, please refer to the Ansible User Guide: Inventory.

### Ansible Playbook Example

```
---
- name: Gather route-maps configuration as structured data
  hosts: nxos
  gather_facts: no
  vars:
    destination: "{{ inventory_dir }}/host_vars/{{ inventory_hostname }}"
  
  tasks:
  - name: Use Route Maps resource module to gather existing configuration
    cisco.nxos.nxos_route_maps:
      state: gathered
    register: route_maps

  - name: Create inventory directory
    ansible.builtin.file:
      path: "{{ destination }}"
      state: directory

  - name: Write the Route Maps configuration to a file
    ansible.builtin.copy:
      content: "{{ {'route_maps': route_maps['gathered']} | to_nice_yaml }}"
      dest: "{{ destination }}/route_maps.yaml"
```

(Gist source available [here](https://gist.github.com/NilashishC/a777029f0927c0ada682e26465c47054))

Execute the above playbook with the following command:

```
$ ansible-playbook example.yaml
```

Now let’s take a look at the contents of the file that was created. We should see the existing device configuration as structured data in it. Getting started with this module in a brownfield environment is as simple as this!

```
$ cat ./ansible_inventory/host_vars/nxos-9k/route_maps.yaml
route_maps:
-   entries:
    -   action: permit
        description: rmap1-10-permit
        match:
            as_number:
                asn:
                - '65564'
            as_path:
            - Allow40
            ip:
                address:
                    access_list: acl_1
        sequence: 10
    -   action: deny
        description: rmap1-20-deny
        match:
            community:
                community_list:
                - BGPCommunity1
                - BGPCommunity2
            ip:
                address:
                    prefix_lists:
                    - AllowPrefix1
                    - AllowPrefix2
        sequence: 20
        set:
            dampening:
                half_life: 30
                max_suppress_time: 120
                start_reuse_route: 1500
                start_suppress_route: 10000
    route_map: rmap1
-   entries:
    -   action: permit
        sequence: 10
    route_map: rmap2
```

(Gist source available [here](https://gist.github.com/NilashishC/d309c2a6035fb828bb5da4784fc0fc2b))

## Using state merged - Pushing configuration changes

The state: merged is used to merge the task input with the existing on-box configuration. This does not affect configurations that are not specified in the task. Let’s take a look at how we can use this.

### Modify stored route-maps data

In the previous example, we saw how we can gather existing information from the target device as structured data and store it as a flat file. Now, let us update that data and push it back to the device with state: merged. Notice how we can immediately start using the gathered facts as a source of truth for a network resource.

We make the following updates:

1.  Append “BGPCommunity3” to the community-list in match->community->community\_list in sequence 20 of route-map rmap1.
2.  Update sequence 10 of route-map rmap2 with “match” and “set” clauses.
3.  Add new sequence 40 with action “deny” and “match” clauses.

The updated flat-file should now look like this:

```
route_maps:
-   entries:
    -   action: permit
        description: rmap1-10-permit
        match:
            as_number:
                asn:
                - '65564'
            as_path:
            - Allow40
            ip:
                address:
                    access_list: acl_1
        sequence: 10
    -   action: deny
        description: rmap1-20-deny
        match:
            community:
                community_list:
                - BGPCommunity1
                - BGPCommunity2
                - BGPCommunity3
            ip:
                address:
                    prefix_lists:
                    - AllowPrefix1
                    - AllowPrefix2
        sequence: 20
        set:
            dampening:
                half_life: 30
                max_suppress_time: 120
                start_reuse_route: 1500
                start_suppress_route: 10000
    route_map: rmap1

-   entries:
    -   action: permit
        sequence: 10
        continue_sequence: 40
        match:
            ipv6:
                address:
                    prefix_lists: 
                    - AllowIPv6Prefix
            interfaces: Ethernet1/1
        set:
            as_path:
                prepend:
                    as_number:
                    - “65563”
                    - “65568”
                    - “65569”
            extcomm_list: BGPExtCommunity
    -   sequence: 40
        action: deny
        description: rmap2-40-deny
        match:
            route_types:
            - level-1
            - level-2
            tags: 
            - 2
            ip:
              multicast:
                rp:
                  prefix: 192.0.2.0/24
                  rp_type: ASM
                source: 203.0.113.0/24
                group_range:
                  first: 239.0.0.1
                  last: 239.255.255.255
    route_map: rmap2
```

(Gist source available [here](https://gist.github.com/NilashishC/7b4492ecaafd20974d3c7367bcdfdd49))

We are ready to push this data back to the device with the following task:

```
- name: Merge with the existing on-box running configuration
  cisco.nxos.nxos_route_maps:
    config: "{{ route_maps }}"
    state: merged
```

But hold on; wouldn’t it be even better if we could verify that our route-map’s  source of truth is indeed in sync with the actual device configuration after we send out the updates? We can do this by re-running the same merged task and asserting that the second one did not make any changes.

The final merged playbook should look like this:

```
- name: Merge with the existing on-box running configuration
  cisco.nxos.nxos_route_maps: 
    config: "{{ route_maps }}"
    state: merged

- name: Merge with the existing on-box configuration (IDEMPOTENT)
  cisco.nxos.nxos_route_maps:
    config: "{{ route_maps }}"
    state: merged
  register: merged

- name: Asset that the source of truth is in sync with device config
  assert:
    that:
    - merged.changed == False
    - merged.commands == []
```

Once the playbook run is complete, we can verify the updated configuration on the network device. As evident, all the intended updates have been correctly pushed.

```
nxos9k# show running-config | section ^route-map
route-map rmap1 permit 10
  description rmap1-10-permit
  match ip address acl_1
  match as-path Allow40
  match as-number 65564
route-map rmap1 deny 20
  description rmap1-20-deny
  match ip address prefix-list AllowPrefix1 AllowPrefix2
  match community BGPCommunity1 BGPCommunity2 BGPCommunity3
  set dampening 30 1500 10000 120
route-map rmap2 permit 10
  match ipv6 address prefix-list AllowIPv6Prefix
  match interface Ethernet1/1
  continue 40
  set as-path prepend 65563 65568 65569
  set extcomm-list BGPExtCommunity  delete
route-map rmap2 deny 40
  description rmap2-40-deny
  match tag 2
  match route-type level-1 level-2
  match ip multicast source 203.0.113.0/24 group-range 239.0.0.1 to 239.255.255.255 rp 192.0.2.0/24 rp-type ASM
```

Note: Cisco NX-OS allows executing route-map command without the action clause and a sequence number. For example, “route-map rmap1” by itself is a valid command. Once executed, this shows up in running-config as “route-map rmap1 permit 10”. As such, the nxos\_route\_maps resource module also allows the user to do the same. However, such a task will **NOT** be idempotent or function properly.

## Using state replaced - Pushing configuration changes

The state: replaced replaces the on-box configuration subsection with the provided configuration subsection in the task. This is how a user can expect this state to behave for the route\_maps modules:

1.  For listed route maps:

1.  all entries (identified by the sequence number) that are in running-config but not in the task, will be negated
2.  superfluous attributes within existing entries will also be negated

3.  The following items will be “merged” with the existing on-box configuration:

1.  new route-maps
2.  new entries within an existing route map
3.  new attributes in existing entries

5.  existing route maps that are not specified in the task will remain unaffected

Alright, now it’s time to see this in action. For this scenario, let’s make the following changes to the source of truth:

1.  Remove the entry with sequence number 10 from route-map rmap1.
2.  Remove “BGPCommunity1” and ”BGPCommunity2” from match->community->community\_list in sequence 20 of route-map rmap1.
3.  Add “acl\_1” to ip->address->access\_list in sequence 20 of route-map rmap1.
4.  Update match->ip->multicast to use a single multicast group prefix “239.0.0.0/24” instead of a range, in sequence 40 of rmap2.
5.  Add a new entry with sequence 30 in rmap1.
6.  Add a new route-map rmap3.

The updated flat file should look like this:

```
route_maps:
-   entries:
    -   action: deny
        description: rmap1-20-deny
        match:
            community:
                community_list:
                - BGPCommunity2
            ip:
                address:
                    prefix_lists:
                    - AllowPrefix1
                    - AllowPrefix2
                    access_list: acl_1
        sequence: 20
        set:
            dampening:
                half_life: 30
                max_suppress_time: 120
                start_reuse_route: 1500
                start_suppress_route: 10000
    route_map: rmap1

-   entries:
    -   action: permit
        sequence: 10
        continue_sequence: 40
        match:
            ipv6:
                address:
                    prefix_lists: 
                    - AllowIPv6Prefix
            interfaces: 
            - Ethernet1/1
        set:
            as_path:
                prepend:
                    as_number:
                    - "65563"
                    - "65568"
                    - "65569"
            extcomm_list: BGPExtCommunity

    -   sequence:  30
        action: permit
        description: rmap2-30-permit
        match:
            ipv6:
                address:
                    prefix_lists:
                    - AllowIPv6Prefix2

    -   sequence: 40
        action: deny
        description: rmap2-40-deny
        match:
            route_types:
            - level-1
            - level-2
            tags: 
            - 2
            ip:
              multicast:
                rp:
                  prefix: 192.0.2.0/24
                  rp_type: ASM
                source: 203.0.113.0/24
                group:
                  prefix: 239.0.0.0/24
    route_map: rmap2
    
-   entries:
    -   action: deny
        description: rmap3-20-deny
        sequence: 20
    route_map: rmap3
```

(Gist source available [here](https://gist.github.com/NilashishC/c5dc207aea85c1242b91aab85eaa02cd))

We now push this structured configuration data to the target device and verify its correctness with the following set of tasks. Notice that these are identical to the previous “merged” tasks, except the value “state” parameter, which is now “replaced”.

```
- name: Replace provided route-maps with given configuration
  cisco.nxos.nxos_route_maps:
    config: "{{ route_maps }}"
    state: replaced

- name: Replace provided route-maps with given configuration
 (IDEMPOTENT)
  cisco.nxos.nxos_route_maps:
    config: "{{ route_maps }}"
    state: replaced
  register: replaced

- name: Asset that the source of truth is in sync with device config
  assert:
    that:
    - replaced.changed == False
    - replaced.commands == []
```

Inspecting the updated configuration on the device after the playbook was run, we can see that all extraneous configurations have been removed and updates have been applied.

```
nxos9k# show running-config | section “^route-map”
route-map rmap1 deny 20
  description rmap1-20-deny
  match ip address acl_1
  match ip address prefix-list AllowPrefix1 AllowPrefix2
  match community BGPCommunity2
  set dampening 30 1500 10000 120
route-map rmap2 permit 10
  match ipv6 address prefix-list AllowIPv6Prefix
  match interface Ethernet1/1
  continue 40
  set as-path prepend 65563 65568 65569
  set extcomm-list BGPExtCommunity  delete
route-map rmap2 permit 30
  description rmap2-30-permit
  match ipv6 address prefix-list AllowIPv6Prefix2
route-map rmap2 deny 40
  description rmap2-40-deny
  match tag 2
  match route-type level-1 level-2
  match ip multicast source 203.0.113.0/24 group 239.0.0.0/24 rp 192.0.2.0/24 rp-type ASM
route-map rmap3 deny 20
  description rmap3-20-deny
```

## Using state overridden - Pushing configuration changes

With state: overridden, Ansible overrides all the on-device configuration of a particular resource with the provided configuration in the task.

Let’s assume some unwanted route map configuration got pushed to our target device. As a result, the device started behaving erroneously. Now instead of manually inspecting and reverting these changes, we can push the existing structured data in our flat-file with state: overridden, thereby enforcing the source-of-truth and removing all unwanted configuration lines.

This state behaves similar to state: replaced, except that overridden affects all the route maps on the device, which means, route maps that are in running-config but not in the task input will be removed.

For this example, let us consider the following to be the route map configuration on the target device after the unwanted changes were pushed:

```
nxos9k# show running-config | section “^route-map”
route-map rmap1 deny 20
  description rmap1-20-deny
  match ip address acl_1
  match ip address prefix-list AllowPrefix1 AllowPrefix2
  match community BGPCommunity1
  set dampening 30 1500 10000 120
route-map rmap2 permit 10
  match ipv6 address prefix-list AllowIPv6Prefix
  match interface Ethernet1/1
  continue 40
  set as-path prepend 65563 65568 65569
  set extcomm-list BGPExtCommunity  delete
route-map rmap2 permit 30
  description rmap2-30-permit
  match ipv6 address prefix-list AllowIPv6Prefix1
route-map rmap2 deny 40
  description rmap2-40-deny
  match tag 2
  match route-type level-1 level-2
  match ip multicast source 198.51.100.0/24 group 239.0.0.0/24 rp 192.0.2.0/24 rp-type ASM
route-map rmap3 deny 20
  description rmap3-20-deny
route-map rmap4 deny 10
   description rmap4-10-deny
   match route-type level-2
```

Before we remediate the changes and align the on-box route-map configuration with its source of truth, let us find out how the current (running) config has deviated from the intended config. To do that, we will leverage the very useful fact\_diff and to\_paths plugins from the ansible.utils Collection.

```
- name: Gather current route-map configuration from the device
  cisco.nxos.nxos_route_maps:
    state: gathered
  register: result

- name: Find out diff between intended and current configuration
  ansible.utils.fact_diff:
    before: "{{ route_maps|ansible.utils.to_paths }}"
    after: "{{ result['gathered']|ansible.utils.to_paths }}"
```

(Gist source available [here](https://gist.github.com/NilashishC/3e9806344ca3bd3aead63234bf5e360d))

In the above tasks, we first gather the existing route-map configuration from the target device as structured data and then compare it with the source of truth in the flat-file. Running this playbook renders the deviation in a dot delimited format which can also be saved in a file for auditing purposes in the future.

![route maps blog 1](https://www.ansible.com/hs-fs/hubfs/route%20maps%20blog%201.png?width=1550&name=route%20maps%20blog%201.png)

(Gist source available [here](https://gist.github.com/NilashishC/127144ce409d5468e2a6b5222f7e09ea))

Okay, so now that we know what changed, let’s restore the route map configuration to it’s correct state with the following:

```
- name: Override all route-maps config with given configuration
  cisco.nxos.nxos_route_maps:
    config: "{{ route_maps }}"
    state: overridden

- name: Override all route-maps config with given configuration
 (IDEMPOTENT)
  cisco.nxos.nxos_route_maps:
    config: "{{ route_maps }}"
    state: overridden
  register: overridden

- name: Asset that the source of truth is in sync with device config
  assert:
    that:
    - overridden.changed == False
    - overridden.commands == []
```

Once this playbook completes the execution, we can verify by inspecting the device that the route map configurations have been reverted to their correct state:

```
nxos9k# show running-config | section “^route-map”
route-map rmap1 deny 20
  description rmap1-20-deny
  match ip address acl_1
  match ip address prefix-list AllowPrefix1 AllowPrefix2
  match community BGPCommunity2
  set dampening 30 1500 10000 120
route-map rmap2 permit 10
  match ipv6 address prefix-list AllowIPv6Prefix
  match interface Ethernet1/1
  continue 40
  set as-path prepend 65563 65568 65569
  set extcomm-list BGPExtCommunity  delete
route-map rmap2 permit 30
  description rmap2-30-permit
  match ipv6 address prefix-list AllowIPv6Prefix2
route-map rmap2 deny 40
  description rmap2-40-deny
  match tag 2
  match route-type level-1 level-2
  match ip multicast source 203.0.113.0/24 group 239.0.0.0/24 rp 192.0.2.0/24 rp-type ASM
route-map rmap3 deny 20
  description rmap3-20-deny
```

## Using state deleted - Deleting configuration changes

Now that we have seen how to configure and modify route maps, let’s take a look at how to delete them with state: deleted. 

### Deleting specified route map(s)

We have the ability to delete individual route maps from the device with state: deleted. For example, the following task will remove route map rmap2 (with both its entries) from the target device.

```
- name: Delete rmap2 from target device
  cisco.nxos.nxos_route_maps:
    config:
    - route_map: rmap2
    state: deleted
```

However, running such a task would mean that we have to manually update the flat-file (a.k.a, source of truth) so that it is in sync with the device configuration. For deleting hand picked route maps or sequences, it is recommended to first delete them from the source of truth and then use state: overridden on it.

### Deleting all route maps from the device

When no route maps are specified in the task, state: deleted would remove all the route maps from running-config.

```
- name: Delete all route-maps from target device
  cisco.nxos.nxos_route_maps:
    state: deleted
```

Running the above on our target device would delete all three route maps - rmap1, rmap2 and rmap3.

```
nxos9k# show running-config | section “^route-map”
nxos9k#
```

## Using state rendered - Development and working offline

The state: rendered transforms the task input into platform specific CLI commands without requiring a connection to the end device. When run with this state, the module does not make any changes to the target and always assumes that there are no existing configurations to compare against.

Let’s reuse the route maps configuration from the  state: merged example and pass it to the nxos\_route\_maps module setting state: rendered.

```
- name: Render platform specific configuration lines (offline)
  cisco.nxos.nxos_route_maps:
    config: "{{ route_maps }}"
    state: rendered
```

Running this task gives us the following output:

```
"rendered": [
        "route-map rmap1 permit 10",
        "match as-number 65564",
        "match as-path Allow40",
        "match ip address acl_1",
        "description rmap1-10-permit",
        "route-map rmap1 deny 20",
        "match community BGPCommunity1 BGPCommunity2 BGPCommunity3",
        "match ip address prefix-list AllowPrefix1 AllowPrefix2",
        "description rmap1-20-deny",
        "set dampening 30 1500 10000 120",
        "route-map rmap2 permit 10",
        "match interface Ethernet1/1",
        "match ipv6 address prefix-list AllowIPv6Prefix",
        "set as-path prepend “65563” “65568” “65569”",
        "continue 40",
        "set extcomm-list BGPExtCommunity delete",
        "route-map rmap2 deny 40",
        "match ip multicast source 203.0.113.0/24 group-range 239.0.0.1 to 239.255.255.255 rp 192.0.2.0/24 rp-type ASM",
        "match route-type level-1 level-2",
        "match tag 2",
        "description rmap2-40-deny"
    ]
```

## Using state parsed - Development and working offline

This state reads the configuration from the running\_config option and transforms it into structured data as per the module’s argspec. Like state: rendered, this state also doesn’t require a connection to the target device. This is very helpful for experimenting, troubleshooting or creating offline sources of truth for network resources. 

```
- name: Parse externally provided route-maps configuration
  cisco.nxos.nxos_route_maps:
    running_config: |
      route-map rmap1 permit 10
        match as-number 65564
        match as-path Allow40
        match ip address acl_1
        description rmap1-10-permit
      route-map rmap1 deny 20
        match community BGPCommunity1 BGPCommunity2
        match ip address prefix-list AllowPrefix1 AllowPrefix2
        description rmap1-20-deny
        set dampening 30 1500 10000 120
    state: parsed
```

(Gist source available [here](https://gist.github.com/NilashishC/4292a36534bf0b1a144434bee6ff0d8d))

Running this task renders the specified platform specific route map configuration lines as malleable structured data:

```
"parsed": [
        {
            "entries": [
                {
                    "action": "permit",
                    "description": "rmap1-10-permit",
                    "match": {
                        "as_number": {
                            "asn": [
                                "65564"
                            ]
                        },
                        "as_path": [
                            "Allow40"
                        ],
                        "ip": {
                            "address": {
                                "access_list": "acl_1"
                            }
                        }
                    },
                    "sequence": 10
                },
                {
                    "action": "deny",
                    "description": "rmap1-20-deny",
                    "match": {
                        "community": {
                            "community_list": [
                                "BGPCommunity1",
                                "BGPCommunity2"
                            ]
                        },
                        "ip": {
                            "address": {
                                "prefix_lists": [
                                    "AllowPrefix1",
                                    "AllowPrefix2"
                                ]
                            }
                        }
                    },
                    "sequence": 20,
                    "set": {
                        "dampening": {
                            "half_life": 30,
                            "max_suppress_time": 120,
                            "start_reuse_route": 1500,
                            "start_suppress_route": 10000
                        }
                    }
                }
            ],
            "route_map": "rmap1"
        }
]
```

(Gist source available [here](https://gist.github.com/NilashishC/7e36a3952e4282dc8bbccf69a2583c90))

## Takeaways & Next Steps

As shown above, with the help of the resource modules for route maps, automation can be simplified. Users don't need to create complicated Jinja2 templates or bother much about implementation details for each platform. Engineers can just enter the important data into a simple data model broken out into each resource module. By using the merged, replaced and overridden parameters, we allow much more flexibility for network engineers to adopt automation in incremental steps. The other operations like gathered, rendered and parsed allow a better, user friendly handling of the facts (structured data) and the data managed within these tasks.

If you want to learn more about the Red Hat Ansible Automation Platform and network automation, you can check out these resources:

-   [Network E-Book - Part 1 - Network automation for everyone](https://www.redhat.com/en/resources/network-automation-everyone-ebook?sc_cid=7013a0000026PBJAA2&gclid=EAIaIQobChMI653Lz5uz8AIVk4jICh04jQvlEAAYAyAAEgI5avD_BwE&gclsrc=aw.ds)
-   [Network E-Book - Part 2 - Automate your network with Red Hat](https://www.redhat.com/en/engage/network-automation-ebook-s-202104291219)
-   [Get a trial of the Red Hat Ansible Automation Platform](http://red.ht/try_ansible)
-   [Subscribe to us on YouTube](https://youtube.com/ansibleautomation)

#### [Nilashish Chakraborty](https://www.ansible.com/blog/author/nilashish-chakraborty)

![](https://www.ansible.com/hubfs/DSC06544.png)

Nilashish is a Senior Software Engineer for the Red Hat Ansible Automation Platform where he is focused on building solutions for network automation.