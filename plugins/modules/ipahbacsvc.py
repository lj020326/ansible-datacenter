## source: https://github.com/freeipa/ansible-freeipa

from __future__ import (absolute_import, division, print_function)

__metaclass__ = type

ANSIBLE_METADATA = {
    "metadata_version": "1.0",
    "supported_by": "community",
    "status": ["preview"],
}

DOCUMENTATION = """
---
module: ipahbacsvc
short_description: Manage FreeIPA HBAC Services
description: Manage FreeIPA HBAC Services
extends_documentation_fragment:
  - ipamodule_base_docs
options:
  name:
    description: The group name
    type: list
    elements: str
    required: true
    aliases: ["cn", "service"]
  description:
    description: The HBAC Service description
    type: str
    required: false
  state:
    description: State to ensure
    type: str
    default: present
    choices: ["present", "absent"]
author:
  - Thomas Woerner (@t-woerner)
"""

EXAMPLES = """
# Ensure HBAC Service for http is present
- ipahbacsvc:
    ipaadmin_password: SomeADMINpassword
    name: http
    description: Web service

# Ensure HBAC Service for tftp is absent
- ipahbacsvc:
    ipaadmin_password: SomeADMINpassword
    name: tftp
    state: absent
"""

RETURN = """
"""

from ansible.module_utils.ansible_freeipa_module import \
    IPAAnsibleModule, compare_args_ipa


def find_hbacsvc(module, name):
    _args = {
        "all": True,
        "cn": name,
    }

    _result = module.ipa_command("hbacsvc_find", name, _args)

    if len(_result["result"]) > 1:
        module.fail_json(
            msg="There is more than one hbacsvc '%s'" % (name))
    elif len(_result["result"]) == 1:
        return _result["result"][0]

    return None


def gen_args(description):
    _args = {}
    if description is not None:
        _args["description"] = description

    return _args


def main():
    ansible_module = IPAAnsibleModule(
        argument_spec=dict(
            # general
            name=dict(type="list", elements="str", aliases=["cn", "service"],
                      required=True),
            # present

            description=dict(type="str", default=None),

            # state
            state=dict(type="str", default="present",
                       choices=["present", "absent"]),
        ),
        supports_check_mode=True,
    )

    ansible_module._ansible_debug = True

    # Get parameters

    # general
    names = ansible_module.params_get("name")

    # present
    description = ansible_module.params_get("description")

    # state
    state = ansible_module.params_get("state")

    # Check parameters

    invalid = []
    if state == "present":
        if len(names) != 1:
            ansible_module.fail_json(
                msg="Only one hbacsvc can be set at a time.")

    if state == "absent":
        if len(names) < 1:
            ansible_module.fail_json(
                msg="No name given.")
        invalid = ["description"]

    ansible_module.params_fail_used_invalid(invalid, state)

    # Init

    changed = False
    exit_args = {}

    # Connect to IPA API
    with ansible_module.ipa_connect():

        commands = []

        for name in names:
            # Try to find hbacsvc
            res_find = find_hbacsvc(ansible_module, name)

            # Create command
            if state == "present":
                # Generate args
                args = gen_args(description)

                # Found the hbacsvc
                if res_find is not None:
                    # For all settings is args, check if there are
                    # different settings in the find result.
                    # If yes: modify
                    if not compare_args_ipa(ansible_module, args,
                                            res_find):
                        commands.append([name, "hbacsvc_mod", args])
                else:
                    commands.append([name, "hbacsvc_add", args])

            elif state == "absent":
                if res_find is not None:
                    commands.append([name, "hbacsvc_del", {}])

            else:
                ansible_module.fail_json(msg="Unkown state '%s'" % state)

        # Execute commands

        changed = ansible_module.execute_ipa_commands(commands)

    # Done

    ansible_module.exit_json(changed=changed, **exit_args)


if __name__ == "__main__":
    main()
