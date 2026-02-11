#!/usr/bin/env python3

import yaml
import os
import sys
import logging
import pprint
import re
import argparse
from collections import Counter, OrderedDict
from argparse import RawTextHelpFormatter

_LOGLEVEL_DEFAULT = "INFO"
__version__ = '2026.1.30'
__updated__ = '2026-01-30'

logging.basicConfig(level=_LOGLEVEL_DEFAULT)
log = logging.getLogger()

mutually_exclusive_group_patterns_default = [
    # r"docker_stack_.*_(admin|dev|prod|qa)$",
    r"docker_stack_env_(admin|dev|prod|qa)$",
    r"ca_domain_.*_(int_dettonville|int_johnson)$"
]


class PrettyLog:
    def __init__(self, obj):
        self.obj = obj

    def __repr__(self):
        if isinstance(self.obj, OrderedDict):
            return pprint.pformat(dict(self.obj))
        return pprint.pformat(self.obj)


def get_all_subkeys(input_dict: dict, key_list: list, parent_key: str = None):
    """Recursively finds all keys that are children of the specified parent keys."""
    if not isinstance(input_dict, dict):
        return
    for i, j in input_dict.items():
        if parent_key and parent_key in key_list:
            yield i
        if isinstance(j, dict):
            yield from get_all_subkeys(j, key_list, i)


def search_key_values(input_dict: dict, key: str):
    """Searches for a specific key in a nested dictionary and yields its values."""
    if not isinstance(input_dict, dict):
        return
    for i, j in input_dict.items():
        if i == key:
            yield j
        if isinstance(j, dict):
            yield from search_key_values(j, key)


def validate_children_groups_in_groups_file(log, groups_file_path, hosts_file_path):
    """
    Validation #2: Verifies that all groups referenced in the inventory hosts.yml
    are present in the 'global' cross-environment file (xenv_groups.yml).
    """
    log_prefix = "validate_children_groups_in_groups_file():"
    num_errors = 0

    with open(hosts_file_path) as f:
        hosts_dict = yaml.load(f, Loader=yaml.FullLoader)
    with open(groups_file_path) as f:
        groups_dict = yaml.load(f, Loader=yaml.FullLoader)

    # Find every group mentioned under a 'children' key in the hosts file
    children_groups = list(get_all_subkeys(hosts_dict, ["children"]))

    for child_group in children_groups:
        # Check if this group exists anywhere in the global groups file
        key_value_list = list(search_key_values(groups_dict, child_group))
        if not key_value_list:
            log.error("%s group [%s] found in %s is missing from %s"
                      % (log_prefix, child_group, hosts_file_path, groups_file_path))
            num_errors += 1

    if num_errors == 0:
        log.info('%s validations SUCCESSFUL!' % log_prefix)
    return num_errors


def validate_groups_unique(log, file_path):
    """
    Validation #1: Verifies that all groups are uniquely defined in the hosts.yml.
    """
    log_prefix = "validate_groups_unique():"
    with open(file_path) as f:
        file_dict = yaml.load(f, Loader=yaml.FullLoader)

    children_groups = list(get_all_subkeys(file_dict, ["children"]))
    duplicate_groups = [k for k, v in Counter(children_groups).items() if v > 1]

    if duplicate_groups:
        log.error('%s duplicates found: %s' % (log_prefix, duplicate_groups))
        return len(duplicate_groups)

    log.info('%s SUCCESSFUL - no duplicates.' % log_prefix)
    return 0


def resolve_group_ancestry(hierarchy_dict):
    """
    Builds a child -> set(parents) map by walking the xenv_groups.yml structure.
    """
    ancestry = {}

    def walk(current_dict, parents):
        if not isinstance(current_dict, dict):
            return
        children = current_dict.get('children', {})
        if not children:
            return
        for child_name, child_content in children.items():
            if child_name not in ancestry:
                ancestry[child_name] = set()
            ancestry[child_name].update(parents)
            walk(child_content, parents + [child_name])

    all_content = hierarchy_dict.get('all', {})
    walk(all_content, ['all'])
    return ancestry


def validate_host_mutual_exclusive_group_labels(log, hosts_file_path, groups_file_path, patterns):
    """
    Validation #3: Ensures each host is present in only 1 mutually exclusive group label pattern,
    accounting for group hierarchy/ancestry inheritance.
    """
    log_prefix = "validate_host_mutual_exclusive_group_labels():"
    num_errors = 0

    with open(hosts_file_path) as f:
        hosts_inventory = yaml.load(f, Loader=yaml.FullLoader)
    with open(groups_file_path) as f:
        global_groups = yaml.load(f, Loader=yaml.FullLoader)

    group_ancestry = resolve_group_ancestry(global_groups)
    host_to_full_groups = {}

    # Resolve every host to its full set of groups (direct + inherited)
    inventory_groups = hosts_inventory.get('all', {}).get('children', {})
    for group_name, group_content in inventory_groups.items():
        content = group_content if group_content else {}
        hosts_in_group = content.get('hosts', {})
        if hosts_in_group is None: hosts_in_group = {}

        for host in hosts_in_group.keys():
            if host not in host_to_full_groups:
                host_to_full_groups[host] = set()
            host_to_full_groups[host].add(group_name)
            if group_name in group_ancestry:
                host_to_full_groups[host].update(group_ancestry[group_name])

    host_group_label_mapping = {}
    regex_list = [re.compile(p) for p in patterns]

    for host, resolved_groups in host_to_full_groups.items():
        for group_name in resolved_groups:
            for regex in regex_list:
                match = regex.match(group_name)
                if match:
                    group_label = match.group(1) if match.groups() else match.group(0)
                    if host not in host_group_label_mapping:
                        host_group_label_mapping[host] = {}
                    if group_label not in host_group_label_mapping[host]:
                        host_group_label_mapping[host][group_label] = set()
                    host_group_label_mapping[host][group_label].add(group_name)

    # Now check for hosts associated with multiple unique group labels
    for host, envs in host_group_label_mapping.items():
        if len(envs) > 1:
            details = ", ".join(["%s %s" % (label, list(gs)) for label, gs in envs.items()])
            log.error("%s Host [%s] spans multiple mutually exclusive group labels: %s" % (log_prefix, host, details))
            num_errors += 1

    if num_errors == 0:
        log.info("%s SUCCESSFUL - all hosts exclusive to one label group hierarchy." % log_prefix)
    return num_errors


def main(argv):
    parser = argparse.ArgumentParser(prog="run-inventory-checks.py",
                                     formatter_class=RawTextHelpFormatter,
                                     description="Ansible Inventory Validation Toolkit")

    parser.add_argument("-l", "--loglevel", choices=['DEBUG', 'INFO', 'WARN', 'ERROR'], default='INFO')
    parser.add_argument("-d", "--verifyduplicategroups", action="store_true", help="Run unique group check")
    parser.add_argument("-e", "--verifyenvexclusivity", action="store_true",
                        help="Run host environment exclusivity check")
    parser.add_argument("-P", "--patterns", nargs='+', default=mutually_exclusive_group_patterns_default, help="Regex for mutually exclusive groups")
    parser.add_argument("-G", "--groupsfile", default='xenv_groups.yml', help="Global groups file")
    parser.add_argument("hostsfile", help="Inventory hosts file")

    args = parser.parse_args(argv[1:])
    log.setLevel(args.loglevel)

    total_errors = 0
    if args.verifyduplicategroups:
        total_errors = validate_groups_unique(log, args.hostsfile)
    elif args.verifyenvexclusivity:
        total_errors = validate_host_mutual_exclusive_group_labels(log, args.hostsfile, args.groupsfile, args.patterns)
    else:
        # Default behavior: Validate children groups exist in the global file
        total_errors = validate_children_groups_in_groups_file(log, args.groupsfile, args.hostsfile)

    sys.exit(total_errors)


if __name__ == '__main__':
    main(sys.argv)
