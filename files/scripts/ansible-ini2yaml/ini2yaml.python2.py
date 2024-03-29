#! /usr/bin/env python

from collections import OrderedDict
import sys
#import ConfigParser
import configparser
import yaml
import ast
import re
from collections import defaultdict

class literal_unicode(unicode): pass

def literal_unicode_representer(dumper, data):
    return dumper.represent_scalar(u'tag:yaml.org,2002:str', data, style='|')

yaml.add_representer(literal_unicode, literal_unicode_representer)

# config = ConfigParser.RawConfigParser(allow_no_value = True)
config = configparser.RawConfigParser(allow_no_value=True)
config.optionxform = str
config.readfp(sys.stdin)

inventory = {}

varRegex = re.compile("[\t ]*([a-zA-Z][a-zA-Z0-9_]+)=('[^']+'|\"[^\"]+\"|[^ ]+)")
noQuotesNeededRegex = re.compile("^([-.0-9a-zA-Z]+|'[^']+'|\"[^\"]+\")$")

# Parse host variable and return corresponding YAML object
def parse_value(value):
  if noQuotesNeededRegex.match(value):  # Integers, booleans and quoted strings strings must not be quoted
    result = yaml.load('value: ' + value)['value']
  else:
    result = yaml.load('value: "' + value + '"')['value']
  if isinstance(result, basestring):
    if '\\n' in result:  # Use YAML block literal for multi-line strings
      return literal_unicode(result.replace('\\n', '\n'))
    else:
      try:  # Unwrap nested YAML structures
        new_result = yaml.load('value: ' + result)['value']
        if isinstance(new_result, list) or isinstance(new_result, dict):
          result = new_result
      except:
        pass

  return result


for section in config.sections():
  group = section.split(':')
  if len(group) == 1:  # section contains host group
    for name, value in config.items(section):
      if value:
        value = name + '=' + value
      else:
        value = name
      host = re.split(' |\t', value, 1)
      hostname = host[0]
      hostvars = host[1] if len(host) > 1 else ''
      hostvars = varRegex.findall(hostvars)

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
