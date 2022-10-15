#!/usr/bin/env python3

from collections import OrderedDict
import sys
import yaml
import ast
import re
import six
from ansible.module_utils.common.text.converters import to_text
from collections import defaultdict

try:
    import ConfigParser
except ImportError:
    import configparser as ConfigParser

class literal_unicode(six.text_type):
    pass

def literal_unicode_representer(dumper, data):
    return dumper.represent_scalar(u'tag:yaml.org,2002:str', data, style='|')

yaml.add_representer(literal_unicode, literal_unicode_representer)

config = ConfigParser.RawConfigParser(allow_no_value = True)
config.optionxform = str
# config.readfp(sys.stdin)
config_reader = config.read_file
config_reader(sys.stdin)

inventory = {}

varRegex = re.compile("[\t ]*([a-zA-Z][a-zA-Z0-9_]+)=('[^']+'|\"[^\"]+\"|[^ ]+)")
noQuotesNeededRegex = re.compile("^([-.0-9a-zA-Z]+|'[^']+'|\"[^\"]+\")$")

# Parse host variable and return corresponding YAML object
def parse_value(v):
  '''
  Attempt to transform the string value from an ini file into a basic python object
  (int, dict, list, unicode string, etc).
  '''
  try:
    v = ast.literal_eval(v)
  # Using explicit exceptions.
  # Likely a string that literal_eval does not like. We wil then just set it.
  except ValueError:
    # For some reason this was thought to be malformed.
    pass
  except SyntaxError:
    # Is this a hash with an equals at the end?
    pass
  return to_text(v, nonstring='passthru', errors='surrogate_or_strict')


for section in config.sections():
  group = section.split(':')
  # print("group=", group)
  if len(group) == 1:  # section contains host group
    for name, value in config.items(section):
      # print("name=", name)
      # print("value=", value)

      if value:
        value = name + '=' + value
        # value = name + ':' + value
      else:
        value = name
      # print("value=", value)

      host = re.split(' |\t', value, 1)
      # print("host=", host)
      hostname = host[0].replace('=', ':')
      # print("hostname=", hostname)
      hostvars = host[1] if len(host) > 1 else ''
      # print("hostvars[0]=", hostvars)
      hostvars = varRegex.findall(hostvars)
      # print("hostvars=", hostvars)

      inventory.setdefault('all', {}).setdefault('children', {}).setdefault(group[0], {}).setdefault('hosts', {})[hostname] = {}
      for hostvar in hostvars:
        value = parse_value(hostvar[1])
        inventory.setdefault('all', {}).setdefault('children', {}).setdefault(group[0], {}).setdefault('hosts', {})[hostname][hostvar[0]] = value
  elif group[1] == 'vars':  # section contains group vars
    for name, value in config.items(section):
      value = parse_value(value)
      inventory.setdefault('all', {}).setdefault('children', {}).setdefault(group[0], {}).setdefault('vars', {})[name] = value
  elif group[1] == 'children':  # section contains group of groups
    for name, value in config.items(section):
      inventory.setdefault('all', {}).setdefault('children', {}).setdefault(group[0], {}).setdefault('children', {})[name] = {}


print(yaml.dump(inventory, default_flow_style=False, width=float("inf")))
