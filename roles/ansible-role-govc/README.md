# ansible-role-govc

Install and manage govc, a statically linked cli tool for operations on VMware vCenter server

source: https://github.com/vmware-archive/ansible-role-govc

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
    - role: ansible-role-govc

    # install govc v0.12.1 in /tmp,
    # and import a photon ova into an esx or vcenter server

    - role: ansible-role-govc
      vars:
        govc_path: /tmp
        govc_version: "0.12.1"

        # esx or vcenter host and credentials
        govc_host: esx-a.home.local
        govc_username: administrator@home.local
        govc_password: password

        # alternativly, use govc_url
        # govc_url:  https://user:pass@host/sdk

        govc_ova_imports:
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
    

## License

Copyright © 2017 VMware, Inc. All Rights Reserved.

SPDX-License-Identifier: MIT OR GPL-3.0-only

## Author Information

Tom Scanlan
tscanlan@vmware.com
tompscanlan@gmail.com
