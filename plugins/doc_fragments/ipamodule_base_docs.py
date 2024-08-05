## source: https://github.com/freeipa/ansible-freeipa

from __future__ import (absolute_import, division, print_function)

__metaclass__ = type


class ModuleDocFragment(object):  # pylint: disable=R0205,R0903
    DOCUMENTATION = r"""
options:
  ipaadmin_principal:
    description: The admin principal.
    default: admin
    type: str
  ipaadmin_password:
    description: The admin password.
    required: false
    type: str
  ipaapi_context:
    description: |
      The context in which the module will execute. Executing in a
      server context is preferred. If not provided context will be
      determined by the execution environment.
    choices: ["server", "client"]
    type: str
    required: false
  ipaapi_ldap_cache:
    description: Use LDAP cache for IPA connection.
    type: bool
    default: true
"""

    DELETE_CONTINUE = r"""
options:
  delete_continue:
    description: |
      Continuous mode. Don't stop on errors. Valid only if `state` is `absent`.
    aliases: ["continue"]
    type: bool
    default: true
"""
