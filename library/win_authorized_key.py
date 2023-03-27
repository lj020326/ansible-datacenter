#!/usr/bin/python
# -*- coding: utf-8 -*-

# This is a windows documentation stub.  Actual code lives in the .ps1
# file of the same name.

# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type


ANSIBLE_METADATA = {'metadata_version': '1.0',
                    'status': ['preview'],
                    'supported_by': 'community'}


DOCUMENTATION = r'''
---
module: win_authorized_key
short_description: Adds or removes an SSH authorized key
description:
  - Ansible module to add or to remove SSH authorized keys for particular user accounts on Windows-based systems.
requirements:
  - Win32 OpenSSH
options:
  user:
    description:
      - The username on the remote host whose authorized_keys file will be modified
    required: true
    type: str
  key:
    description:
      - The SSH public key(s), as a string or (since 1.9) url U(https://github.com/username.keys)
    required: true
    type: str
  path:
    description:
      - Alternate path to the authorized_keys file
    default: "(homedir)+/.ssh/authorized_keys"
    type: str
  manage_dir:
    description:
      - Whether this module should manage the directory of the authorized key file.
      - If set, the module will create the directory, as well as set the owner and permissions
        of an existing directory.
      - Be sure to set I(manage_dir)=C(no) if you are using an alternate directory for
        authorized_keys, as set with C(path), since you could lock yourself out of
        SSH access. See the example below.
    type: bool
    default: 'yes'
  state:
    description:
      - Whether the given key (with the given key_options) should or should not be in the file
    choices: [ "present", "absent" ]
    default: "present"
    type: str
  key_options:
    description:
      - A string of ssh key options to be prepended to the key in the authorized_keys file
    type: str
  exclusive:
    description:
      - Whether to remove all other non-specified keys from the authorized_keys file. Multiple keys
        can be specified in a single I(key) string value by separating them by newlines.
      - This option is not loop aware, so if you use C(with_) , it will be exclusive per iteration
        of the loop, if you want multiple keys in the file you need to pass them all to C(key) in a
        single batch as mentioned above.
    type: bool
    default: 'no'
  validate_certs:
    description:
      - This only applies if using a https url as the source of the keys.
      - If set to C(no), the SSL certificates will not be validated.
      - This should only set to C(no) used on personally controlled sites using self-signed certificates as it avoids verifying the source site.
    type: bool
    default: yes
  comment:
    description:
      - Change the comment on the public key. Rewriting the comment is useful in cases such as fetching it from GitHub or GitLab.
      - If no comment is specified, the existing comment will be kept.
    type: str
  follow:
    description:
      - Follow path symlink instead of replacing it
    type: bool
    default: 'no'
author:
  - Stéphane Bilqué (@sbilque) - Translation in PowerShell
  - Brad Olson (brado@movedbylight.com) - Initial work in Python
'''

EXAMPLES = r'''
---
roles:
  - win_authorized_key

tasks:

  - name: Set authorized key taken from file
    win_authorized_key:
      user: charlie
      state: present
      key: "{{ lookup('file', 'c:/users/charlie/.ssh/id_rsa.pub') }}"

  - name: Set authorized keys taken from url
    win_authorized_key:
      user: charlie
      state: present
      key: https://github.com/charlie.keys

  - name: Set authorized key in alternate location
    win_authorized_key:
      user: charlie
      state: present
      key: "{{ lookup('file', 'c:/users/charlie/.ssh/id_rsa.pub') }}"
      path: c:/ProgramData/ssh/administrators_authorized_key
      manage_dir: False

  - name: Set up multiple authorized keys
    win_authorized_key:
      user: deploy
      state: present
      key: '{{ item }}'
    with_file:
      - public_keys/doe-jane
      - public_keys/doe-john

  - name: Set authorized key defining key options
    win_authorized_key:
      user: charlie
      state: present
      key: "{{ lookup('file', 'c:/users/charlie/.ssh/id_rsa.pub') }}"
      key_options: 'no-port-forwarding,from="10.0.1.1"'

  - name: Set authorized key without validating the TLS/SSL certificates
    win_authorized_key:
      user: charlie
      state: present
      key: https://github.com/user.keys
      validate_certs: False

  - name: Set authorized key, removing all the authorized keys already set
    win_authorized_key:
      user: administrator
      key: '{{ item }}'
      state: present
      exclusive: True
    with_file:
      - public_keys/doe-jane
'''

RETURN = r'''
exclusive:
    description: If the key has been forced to be exclusive or not.
    returned: success
    type: boolean
    sample: False
key:
    description: The key that the module was running against.
    returned: success
    type: string
    sample: U(https://github.com/user.keys)
key_option:
    description: Key options related to the key.
    returned: success
    type: string
    sample: null
keyfile:
    description: Path for authorized key file.
    returned: success
    type: string
    sample: C:/users/charlie/.ssh/authorized_keys
manage_dir:
    description: Whether this module managed the directory of the authorized key file.
    returned: success
    type: boolean
    sample: True
path:
    description: Alternate path to the authorized_keys file.
    returned: success
    type: string
    sample: null
state:
    description: Whether the given key (with the given key_options) should or should not be in the file.
    returned: success
    type: string
    sample: present
unique:
    description: Whether the key is unique.
    returned: success
    type: boolean
    sample: false
user:
    description: The username on the remote host whose authorized_keys file will be modified.
    returned: success
    type: string
    sample: user
validate_certs:
    description: This only applies if using a https url as the source of the keys. If set to C(no), the SSL certificates will not be validated.
    returned: success
    type: bool
    sample: true
'''
