#!/usr/bin/env python3

import os
import sys
import argparse
import logging

# ref: https://stackoverflow.com/questions/1087227/validate-ssl-certificates-with-python
import pycurl
import ssl

# Part A: Globals & Utils

_LOGLEVEL_DEFAULT = "INFO"

__scriptName__ = sys.argv[0]

# ref: https://stackoverflow.com/questions/458550/standard-way-to-embed-version-into-python-package
__version__ = '2025.5.16'
__updated__ = '16 May 2025'

progname = __scriptName__.split(".")[0]

logging.basicConfig(
    level=_LOGLEVEL_DEFAULT,
    format='%(asctime)s [%(levelname)s]: %(message)s'
)
log = logging.getLogger()
#log = logging.getLogger(progname)

def get_executable_name() -> str:
    from sys import executable
    from pathlib import Path
    return Path(executable).name

def path_type(path):
    if os.path.isfile(path):
        return path
    elif os.path.isdir(path):
        return path
    else:
        raise argparse.ArgumentTypeError(f"Invalid path: {path}")


class SSLValidater:
    def __init__(self, endpoint_url="https://example.com", ca_certs_file=None):
        self.endpoint_url = endpoint_url
        self.openssl_cafile = ssl.get_default_verify_paths().openssl_cafile
        self.ca_certs_file = ca_certs_file
        self.curl = pycurl.Curl()

    def connect_to_endpoint(self):
        # log.debug("log.level ==> %s" % log.level)
        # log.debug("logging.INFO ==> %s" % logging.INFO)
        # log.debug("logging.DEBUG ==> %s" % logging.DEBUG)
        if log.level <= logging.DEBUG:
            self.curl.setopt(pycurl.VERBOSE, True)

        if self.ca_certs_file:
            self.curl.setopt(pycurl.CAINFO, self.ca_certs_file)
        else:
            self.curl.setopt(pycurl.CAINFO, self.openssl_cafile)

        self.curl.setopt(pycurl.SSL_VERIFYPEER, 1)
        self.curl.setopt(pycurl.SSL_VERIFYHOST, 2)
        self.curl.setopt(pycurl.URL, self.endpoint_url)
        try:
            self.curl.perform()
        except pycurl.error as e:
            log.error(f"Connection failed: {e}")


if __name__ == "__main__":

    execname = get_executable_name()

    prog_usage = '''
    ({1}) is a simple python ssl connection validator using pycurl.

    Examples of use:

        {0} {1} https://example.com/health
        {0} {1} -L DEBUG https://example.int:8443/health
        {0} {1} --ca_certs_file /etc/service/bundle.pem google.com
    
    On Unix-like systems, this script can be ran via the Shebang:

        {1} https://10.0.1.10:8443
        {1} -C /etc/service/bundle.pem https://google.com

    '''.format(execname, progname)

    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description="Validate SSL connection / certificate using pycurl",
                                     epilog=prog_usage)

    parser.add_argument('url',
                        type=str,
                        help="SSL endpoint URL.  E.g., https://example.int/health, https://192.168.1.8:8443, etc")

    parser.add_argument('-V', '--version',
                        action='version',
                        version='%(prog)s {version}'.format(version=__version__),
                        help='show version')

    parser.add_argument("-L", "--loglevel",
                        default=_LOGLEVEL_DEFAULT,
                        choices=['DEBUG', 'INFO', 'WARN', 'ERROR'],
                        help="log level")

    parser.add_argument("-C", '--ca_certs_file',
                        type=path_type,
                        help="CA Certs bundle file path.  E.g., '/etc/service/bundle.pem'")

    args, additional_args = parser.parse_known_args()

    log.setLevel(args.loglevel)
    log.debug("loglevel ==> [%s]" % logging.getLevelName(log.level))

    log.debug("started")

    if additional_args:
        log.debug("additional args=%s" % additional_args)

    log.debug("args.url [%s]" % args.url)
    log.debug("args.ca_certs_file [%s]" % args.ca_certs_file)

    sslValidater = SSLValidater(
        endpoint_url=args.url,
        ca_certs_file=args.ca_certs_file)
    sslValidater.connect_to_endpoint()
