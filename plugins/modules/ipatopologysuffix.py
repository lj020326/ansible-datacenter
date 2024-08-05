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
module: ipatopologysuffix
short_description: Verify FreeIPA topology suffix
description: Verify FreeIPA topology suffix
extends_documentation_fragment:
  - ipamodule_base_docs
options:
  suffix:
    description: Topology suffix
    type: str
    required: true
    choices: ["domain", "ca"]
  state:
    description: State to ensure
    type: str
    default: verified
    choices: ["verified"]
author:
  - Thomas Woerner (@t-woerner)
"""

EXAMPLES = """
- ipatopologysuffix:
    ipaadmin_password: SomeADMINpassword
    suffix: domain
    state: verified
"""

RETURN = """
"""

from ansible.module_utils.ansible_freeipa_module import IPAAnsibleModule


def main():
    ansible_module = IPAAnsibleModule(
        argument_spec=dict(
            suffix=dict(type="str", choices=["domain", "ca"], required=True),
            state=dict(type="str", default="verified",
                       choices=["verified"]),
        ),
        supports_check_mode=True,
    )

    ansible_module._ansible_debug = True

    # Get parameters

    suffix = ansible_module.params_get("suffix")
    state = ansible_module.params_get("state")

    # Check parameters

    # Init

    # Create command

    if state not in ["verified"]:
        ansible_module.fail_json(msg="Unkown state '%s'" % state)

    # Execute command

    with ansible_module.ipa_connect():
        # Execute command
        ansible_module.ipa_command("topologysuffix_verify", suffix, {})

    # Done

    ansible_module.exit_json(changed=True)


if __name__ == "__main__":
    main()
