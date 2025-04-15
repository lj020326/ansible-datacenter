#!/usr/bin/env python3

# import time
import os
import subprocess
import shlex
from typing import List, Any

import yaml
import sys
import argparse
from argparse import RawTextHelpFormatter
import logging
import logging.handlers
# from StringIO import StringIO
from subprocess import Popen, PIPE, STDOUT

# __scriptName__ = sys.argv[0]
__scriptName__ = os.path.basename(sys.argv[0])

__version__ = '2025.4.15'
__updated__ = '15 Apr 2025'

progname = __scriptName__.split(".")[0]

# loglevel - logging.DEBUG
loglevel = logging.INFO

log = logging.getLogger(__scriptName__)
log.setLevel(loglevel)

## create console handler
handler = logging.StreamHandler()
# handler.setLevel(logging.DEBUG)
log.addHandler(handler)

# configDir = "/opt/scripts"
configDir = os.path.dirname(os.path.realpath(__file__))
configFile = os.path.join(configDir, 'backups.yml')


## ref: https://www.geeksforgeeks.org/python-merging-two-dictionaries/
def mergeDicts(dict1, dict2):
    res = {**dict1, **dict2}
    return res


def setLogLevel(args):
    if args.loglevel:
        loglevel = args.loglevel
        log.setLevel(loglevel)
        log.debug("set loglevel to [%s]" % loglevel)


class Backups(object):
    def __init__(self, config):

        self.config = config
        self.loglevel = config['loglevel'] if 'loglevel' in config else "INFO"
        # logging.getLogger().setLevel(self.loglevel)
        self.log = logging.getLogger()
        self.log.setLevel(self.loglevel)

        ## create console handler
        handler = logging.StreamHandler()
        # handler.setLevel(logging.DEBUG)
        self.log.addHandler(handler)

    def run(self, type):

        # self.log.info("config =>%s" % yaml.dump(self.config))

        # backupGroupConfig = self.config.groups[type]
        backupGroupConfig = self.config['groups'][type]
        # self.log.info("backupGroupConfig =>%s" % yaml.dump(backupGroupConfig))

        # for key, value in self.config.items():
        #     if key != 'groups':
        #         self.log.info("key=%s, value=%s" % (key, value))

        ## ref: https://thispointer.com/different-ways-to-remove-a-key-from-dictionary-in-python/
        backupGroupConfig = mergeDicts({key: value for key, value in self.config.items() if key != 'groups'},
                                       backupGroupConfig)
        backupGroupConfig['scriptPath'] = os.path.join(backupGroupConfig['scriptDir'],
                                                       backupGroupConfig['backupScript'])

        # log.info("backupGroupConfig = %s" % pformat(backupGroupConfig))
        # self.log.info("backupGroupConfig =>")
        # self.log.info(yaml.dump(backupGroupConfig))

        for target in backupGroupConfig['targets']:
            self.log.info("target =>%s" % yaml.dump(target))

            targetConfig = mergeDicts({key: value for key, value in backupGroupConfig.items() if key != 'targets'},
                                      target)
            self.log.info("targetConfig =>")
            self.log.info(yaml.dump(targetConfig))

            shell_command_array: list[str | Any] = ["bash"]

            # if self.loglevel=="DEBUG":
            #     shell_command_array.append("-x")

            shell_command_array.append(targetConfig['scriptPath'])

            if 'loglevel' in targetConfig:
                shell_command_array.append("-L %s" % targetConfig['loglevel'])

            shell_command_array.append("-b %s" % targetConfig['backupLabel'])
            shell_command_array.append("-s %s" % targetConfig['srcDir'])
            shell_command_array.append("-d %s" % targetConfig['destDir'])

            if 'configPath' in targetConfig:
                shell_command_array.append("-c %s" % targetConfig['configPath'])
            if 'emailFrom' in targetConfig:
                shell_command_array.append("-f %s" % targetConfig['emailFrom'])
            if 'emailTo' in targetConfig:
                shell_command_array.append("-t %s" % targetConfig['emailTo'])
            if 'logDir' in targetConfig:
                shell_command_array.append("-l %s" % targetConfig['logDir'])

            shell_command = ' '.join(shell_command_array)
            self.log.info("shell_command=[%s]" % shell_command)
            self.run_shell_command(shell_command)
            self.log.info("Finished backup from %s to %s" % (target['srcDir'], target['destDir']))
            self.log.info("===================")
            self.log.info("===================")

        return 0

    def log_subprocess_output(self, pipe):
        for line in iter(pipe.readline, b''):  # b'\n'-separated lines
            # self.log.info('got line from subprocess: %r', line)
            self.log.info('subprocess: %r', line)

    ## ref: https://stackoverflow.com/questions/21953835/run-subprocess-and-print-output-to-logging
    def run_shell_command(self, command_line):
        command_line_args = shlex.split(command_line)

        self.log.info('Subprocess: "' + command_line + '"')

        try:
            command_line_process = subprocess.Popen(
                command_line_args,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
            )

            with command_line_process.stdout:
                self.log_subprocess_output(command_line_process.stdout)
            exitcode = command_line_process.wait()
            self.log.info("Subprocess exitcode [%s]" % exitcode)

            # process_output, _ =  command_line_process.communicate()
            #
            # # process_output is now a string, not a file,
            # # you may want to do:
            # # process_output = StringIO(process_output)
            # log_subprocess_output(process_output)

        except (OSError, ChildProcessError) as exception:
            self.log.info('Exception occurred: ' + str(exception))
            self.log.info('Subprocess failed')
            return False
        else:
            # no exception was raised
            self.log.info('Subprocess finished')

        return True


# ------------------------------------------------------
# Name: main()
# Role: parse CLI args and call function to add/update/remove/list tomcat datasources
# ------------------------------------------------------

def main(argv):
    # Create a folder for dst if one does not already exist
    if not os.path.exists(configDir):
        os.makedirs(configDir)

    # Copy only if there is not a file at the destination location
    if not os.path.exists(configFile):
        log.error("config file [%s] not found" % configFile)
        return

    prog_usage = '''
Examples of use:

{0} daily
{0} monthly

'''.format(__scriptName__)

    parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter,
                                     description="Use this script to run backups",
                                     epilog=prog_usage)

    group = parser.add_mutually_exclusive_group()
    # group.add_argument("-v", "--verbosity", action="count", default=0)
    # group.add_argument("-q", "--quiet", action="store_true")
    group.add_argument("-l", "--loglevel", choices=['DEBUG', 'INFO', 'WARN', 'ERROR'], help="log level")
    # group.add_argument("-b", "--backuptype", choices=['daily', 'monthly'], help="backup type")

    parser.add_argument('type',
                        help="Backup config type defined under root 'groups' node in config yaml file - e.g., 'daily', 'monthly', etc")

    # parser.add_argument('args', nargs=argparse.REMAINDER)
    # parser.add_argument('args', nargs='?')
    # parser.parse_args()

    args, additional_args = parser.parse_known_args()

    setLogLevel(args)

    log.debug("started")

    if additional_args:
        log.debug("additional args=%s" % additional_args)

    ## ref: https://www.discoverbits.in/892/yamlloadwarning-calling-yaml-load-without-loader-deprecated
    # config = yaml.load(open(configFile))
    config = yaml.load(open(configFile), Loader=yaml.FullLoader)

    if "scriptDir" not in config:
        config['scriptDir'] = configDir

    backups = Backups(config)
    backups.run(args.type)

    log.debug("finished")


# ------------------------------------------
# Code Execution begins
# ------------------------------------------
if (__name__ == '__main__') or (__name__ == 'main'):
    # main(sys.argv[1:])
    main(sys.argv)
else:
    log.error("This script should be executed, not imported.")
