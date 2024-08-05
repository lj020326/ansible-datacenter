## source: https://github.com/freeipa/ansible-freeipa

from __future__ import (absolute_import, division, print_function)

__metaclass__ = type

ANSIBLE_METADATA = {
    "metadata_version": "1.0",
    "supported_by": "community",
    "status": ["preview"],
}


DOCUMENTATION = '''
---
module: ipaautomountlocation
author:
  - Chris Procter (@chr15p)
  - Thomas Woerner (@t-woerner)
short_description: Manage FreeIPA autommount locations
description:
- Add and delete an IPA automount location
extends_documentation_fragment:
  - ipamodule_base_docs
options:
  name:
    description: The automount location to be managed
    required: true
    type: list
    elements: str
    aliases: ["cn","location"]
  state:
    description: State to ensure
    required: false
    type: str
    default: present
    choices: ["present", "absent"]
'''

EXAMPLES = '''
- name: ensure a automount location named DMZ exists
  ipaautomountlocation:
    ipaadmin_password: SomeADMINpassword
    name: DMZ
    state: present

- name: ensure a automount location named DMZ is absent
  ipaautomountlocation:
    ipaadmin_password: SomeADMINpassword
    name: DMZ
    state: absent
'''

RETURN = '''
'''

from ansible.module_utils.ansible_freeipa_module import (
    IPAAnsibleModule, ipalib_errors
)


class AutomountLocation(IPAAnsibleModule):

    def __init__(self, *args, **kwargs):
        # pylint: disable=super-with-arguments
        super(AutomountLocation, self).__init__(*args, **kwargs)
        self.commands = []

    def get_location(self, location):
        try:
            response = self.ipa_command(
                "automountlocation_show", location, {}
            )
        except ipalib_errors.NotFound:
            return None
        return response.get("result", None)

    def check_ipa_params(self):
        if len(self.params_get("name")) == 0:
            self.fail_json(msg="At least one location must be provided.")

    def define_ipa_commands(self):
        state = self.params_get("state")

        for location_name in self.params_get("name"):
            location = self.get_location(location_name)

            if not location and state == "present":
                # does not exist and is wanted
                self.commands.append(
                    (location_name, "automountlocation_add", {}))
            elif location and state == "absent":
                # exists and is not wanted
                self.commands.append(
                    (location_name, "automountlocation_del", {}))


def main():
    ipa_module = AutomountLocation(
        argument_spec=dict(
            state=dict(type='str',
                       default='present',
                       choices=['present', 'absent']
                       ),
            name=dict(type="list", elements="str",
                      aliases=["cn", "location"],
                      required=True
                      ),
        ),
    )
    ipaapi_context = ipa_module.params_get("ipaapi_context")
    with ipa_module.ipa_connect(context=ipaapi_context):
        ipa_module.check_ipa_params()
        ipa_module.define_ipa_commands()
        changed = ipa_module.execute_ipa_commands(ipa_module.commands)
    ipa_module.exit_json(changed=changed)


if __name__ == "__main__":
    main()
