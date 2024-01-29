#!/usr/bin/env python3

import yaml
import os
import sys
import logging
import pprint
from collections import OrderedDict
from collections import Counter

import argparse
from argparse import RawTextHelpFormatter

_LOGLEVEL_DEFAULT = "INFO"

__scriptName__ = sys.argv[0]

# ref: https://stackoverflow.com/questions/458550/standard-way-to-embed-version-into-python-package
__version__ = '0.1'
__updated__ = '5 Jan 2024'

progname = __scriptName__.split(".")[0]

loglevel = _LOGLEVEL_DEFAULT

logging.basicConfig(
    level=loglevel
)
log = logging.getLogger()
# log = logging.getLogger(__scriptName__)

def setLogLevel(args):
    if args.loglevel:
        loglevel = args.loglevel
        log.setLevel(loglevel)
        log.debug("set loglevel to [%s]" % loglevel)

# ref: https://dave.dkjones.org/posts/2013/pretty-print-log-python/
# ref: https://realpython.com/python-pretty-print/
class PrettyLog:
    def __init__(self, obj):
        self.obj = obj

    def __repr__(self):
        # ref: https://stackoverflow.com/questions/21420243/pretty-printing-ordereddicts-using-pprint
        # ref: https://stackoverflow.com/questions/4301069/any-way-to-properly-pretty-print-ordereddict
        if isinstance(object, OrderedDict):
            return pprint.pformat(dict(self.obj))
        return pprint.pformat(self.obj)

def find_key_value(input_dict: dict, key):
    if key in input_dict: return input_dict[key]
    for k, v in input_dict.items():
        if isinstance(v,dict):
            item = find_key_value(v, key)
            if item is not None:
                return item

# ref: https://www.geeksforgeeks.org/python-extract-selective-keys-values-including-nested-keys/#
def search_key_values(input_dict: dict, key: str):
    # print("input_dict=%s" % PrettyLog(input_dict))
    for i, j in input_dict.items():
        if key in input_dict:
            yield j
        if isinstance(j, dict):
            yield from search_key_values(j, key)

# ref: https://www.geeksforgeeks.org/python-extract-selective-keys-values-including-nested-keys/#
def get_all_subkeys(input_dict: dict, key_list: list, parent_key: str = None):
    # print("input_dict=%s" % PrettyLog(input_dict))
    for i, j in input_dict.items():
        if parent_key and parent_key in key_list:
            yield i
        if isinstance(j, dict):
            yield from get_all_subkeys(j, key_list, i)

def validate_children_groups_in_groups_file(log,
                                        groups_file_path: str = "xenv_groups.yml",
                                        hosts_file_path: str = "SANDBOX/hosts.yml") -> int:
    log_prefix = "validate_groups_in_xenv_groups():"
    num_errors = 0

    if not os.path.exists(hosts_file_path):
        log.error('%s file does not exist at hosts_file_path=%s' %
                  (log_prefix, hosts_file_path))

    with open(hosts_file_path) as file:
        # hosts_dict = yaml.safe_load(file)
        hosts_dict = yaml.load(file, Loader=yaml.FullLoader)

    log.debug("%s hosts_dict=%s" % (log_prefix, PrettyLog(hosts_dict)))

    children_groups = list(get_all_subkeys(hosts_dict, ["children"]))

    log.debug("%s children_groups=%s" % (log_prefix, PrettyLog(children_groups)))

    if not os.path.exists(groups_file_path):
        log.error('%s file does not exist at groups_file_path=%s' %
                   (log_prefix, groups_file_path))

    with open(groups_file_path) as file:
        # groups = yaml.safe_load(file)
        groups = yaml.load(file, Loader=yaml.FullLoader)

    for child_group in children_groups:
        log.debug("==> child_group=%s" % child_group)
        # key_value = find_key_value(groups, child_group)
        # log.debug("==> key_value=%s" % key_value)
        # if key_value or key_value == {}:
        #     continue

        key_value_list = list(search_key_values(groups, child_group))

        log.debug("==> key_value_list=%s" % key_value_list)

        if key_value_list:
            continue

        log.error("%s child_group=[%s] in %s not found in %s"
                  % (log_prefix, child_group, hosts_file_path, groups_file_path))
        num_errors += 1

    if num_errors > 0:
        log.error('%s exception count found in %s = [%s]' %
                   (log_prefix, hosts_file_path, num_errors))
    else:
        log.info('%s validations SUCCESSFUL - no exceptions found!' % log_prefix)

    return num_errors


def validate_groups_unique(log, file_path: str = "xenv_groups.yml") -> int:
    log_prefix = "validate_groups_unique():"
    num_errors = 0

    if not os.path.exists(file_path):
        log.error('%s file does not exist at file_path=%s' %
                  (log_prefix, file_path))

    with open(file_path) as file:
        # hosts_dict = yaml.safe_load(file)
        file_dict = yaml.load(file, Loader=yaml.FullLoader)

    log.debug("%s file_dict=%s" % (log_prefix, PrettyLog(file_dict)))

    children_groups = list(get_all_subkeys(file_dict, ["children"]))

    log.info("%s children_groups=%s" % (log_prefix, PrettyLog(children_groups)))

    # ref: https://stackoverflow.com/questions/11236006/identify-duplicate-values-in-a-list-in-python
    duplicate_groups = [k for k, v in Counter(children_groups).items() if v > 1]
    log.info("%s duplicate_groups=%s" % (log_prefix, PrettyLog(duplicate_groups)))
    num_errors = len(duplicate_groups)

    if num_errors:
        log.error('%s duplicate groups found in %s = [%s]' % (log_prefix, file_path, num_errors))
    else:
        log.info('%s validations SUCCESSFUL - no duplicate groups found!' % log_prefix)

    return num_errors


def main(argv):
    # ref: https://stackoverflow.com/questions/4152963/get-name-of-current-script-in-python#4152986
    log_prefix = "%s:" % os.path.basename(__file__)

    prog_usage ='''
Examples of use:

{0} hosts_file.yml
{0} SANDBOX/hosts.yml
{0} -G xenv_groups.yml SANDBOX/hosts.yml
{0} -l DEBUG DEV/hosts.yml
{0} -d xenv_groups.yml

'''.format(__scriptName__)

    # create the top-level parser
    parser = argparse.ArgumentParser(prog=__scriptName__,
                                     formatter_class=RawTextHelpFormatter,
                                     description="Use this script to verify inventory host groups exist in groups file",
                                     epilog=prog_usage)

    # ref: https://stackoverflow.com/questions/17909294/python-argparse-mutual-exclusive-group
    group = parser.add_mutually_exclusive_group()
    # group.add_argument("-v", "--verbosity", action="count", default=0)
    # group.add_argument("-q", "--quiet", action="store_true")
    group.add_argument("-l", "--loglevel", choices=['DEBUG', 'INFO', 'WARN', 'ERROR'], help="log level")

    # ref: https://stackoverflow.com/questions/15405636/pythons-argparse-to-show-programs-version-with-prog-and-version-string-formatt#15406624
    parser.add_argument('-V', '--version',
                        action='version',
                        version='%(prog)s {version}'.format(version=__version__),
                        help='show version')

    parser.add_argument("-d",
                        "--verifyduplicategroups",
                        action="store_true",
                        help="verify if duplicate groups exist")

    parser.add_argument("-G", "--groupsfile",
                        default='xenv_groups.yml',
                        help="groups yaml file - e.g., 'groups.yml', 'xenv_groups.yml', etc")

    parser.add_argument("hostsfile",
                        help="hosts yaml file - e.g., 'hosts.yml', 'SANDBOX/hosts.yml', etc")

    # parser.add_argument('args', nargs=argparse.REMAINDER)
    # parser.add_argument('args', nargs='?')
    # parser.parse_args()

    args, additional_args = parser.parse_known_args()

    setLogLevel(args)

    log.info("started")

    if additional_args:
        log.debug("additional args=%s" % additional_args)

    groups_file_path = args.groupsfile
    hosts_file_path = args.hostsfile

    exception_count = 0
    if args.verifyduplicategroups:
        exception_count = validate_groups_unique(log, hosts_file_path)
    else:
        exception_count = validate_children_groups_in_groups_file(log, groups_file_path, hosts_file_path)

    # ref: https://stackoverflow.com/questions/18231415/best-way-to-return-a-value-from-a-python-script
    sys.exit(exception_count)

if __name__ == '__main__':
    main(sys.argv)
