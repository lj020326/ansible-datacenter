# bootstrap-govc

Install and manage govc, a statically linked cli tool for operations on VMware vCenter server

source: https://github.com/vmware-archive/bootstrap-govc

## Requirements

- gunzip

## Role Variables

To set the specific version of the binary to install
- govc\_version: "0.12.1"

Path to install the binary.  Can be used to install to user local path, or system wide path.
- govc\_path: /usr/bin

## Dependencies

Not a true dependency, but you'll probably want to install [ansible-role-assets](../ansible-role-assets)
to pull a set of OVAs.


## Example Playbook

```yaml
---
- hosts: adminServers
  roles:

    # Just install govc in standard path
    - role: bootstrap-govc
```

```yaml
---
- hosts: adminServers
  roles:
    # install govc v0.12.1 in /tmp,
    # and import a photon ova into an esx or vcenter server
    - role: bootstrap-govc
      vars:
        bootstrap_govc__path: /tmp
        bootstrap_govc__version: "0.12.1"

        # esx or vcenter host and credentials
        bootstrap_govc__host: esx-a.home.local
        bootstrap_govc__username: administrator@home.local
        bootstrap_govc__password: password

        # alternativly, use bootstrap_govc__url
        # bootstrap_govc__url:  https://user:pass@host/sdk

        bootstrap_govc__ova_imports:
          - name: photon01
            ova: /tmp/photon.ova
          - name: photon02
            ova: /tmp/photon.ova
          - name: vcsa
            spec: /tmp/vcsa.json
            ova: /tmp/vcsa.ova


```

## Testing

Update tests/group_vars to suit your test environment.  Make your own set of 
vault.yml files, or replace them with un-encrypted versions for your own passwords.

Then run the tests:

    pip install molecule docker-py
    ./tests/test.sh
    
## Reference

- https://github.com/vmware-archive/ansible-role-govc
- 
