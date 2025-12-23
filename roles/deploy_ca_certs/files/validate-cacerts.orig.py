#!/usr/bin/env python3

# ref: https://stackoverflow.com/questions/1087227/validate-ssl-certificates-with-python
import pycurl
from sys import argv
import ssl

# Part A: Globals & Utils

MAXU16 = 65535  # maximum of u16

def error_out(message: str):
    print("\033[1;31mError occured\033[0m")
    print(message)
    exit(1)

def get_executable_name() -> str:
    from sys import executable
    from pathlib import Path
    return Path(executable).name

def get_script_name() -> str:
    from sys import argv
    return argv[0]

def usage():
    print(f"({scriptname}) is a very simple python curl based ssl validator.")
    print()
    print("\033[1mArguments:")
    print("[Long/Short]; Purpose; Example(s); Default")
    print("[--endpoint_host/-H]; SSL endpoint host; example.int, 192.168.1.8, etc; example.com")
    print("[--endpoint_port/-P]; SSL endpoint port; 443, 8443, etc; 443")
    print("[--ca_certs_file/-C]; CA Certs bundle file path; '/etc/service/bundle.pem'; None")
    print("\033[0m")
    print(f"Example: {execname} {scriptname} -H google.com --port 8443")
    print(f"Example: {execname} {scriptname} -H google.com --ca_certs_file /etc/service/bundle.pem")
    print("\033[0m")
    print(f"On Unix-like systems, this script can be ran via the Shebang: {scriptname} -H 10.0.1.10 -P 443")
    exit(1)


class SSLValidater:
    def __init__(self, endpoint_host="example.com", endpoint_port=443, ca_certs_file=None):
        self.endpoint_host = endpoint_host
        self.endpoint_port = endpoint_port
        self.endpoint_url = "https://%s:%s/" % (endpoint_host, endpoint_port)
        self.openssl_cafile = ssl.get_default_verify_paths().openssl_cafile
        self.curl = pycurl.Curl()

    def connect_to_endpoint(self):
        self.curl.setopt(pycurl.CAINFO, self.openssl_cafile)
        self.curl.setopt(pycurl.SSL_VERIFYPEER, 1)
        self.curl.setopt(pycurl.SSL_VERIFYHOST, 2)
        self.curl.setopt(pycurl.URL, self.endpoint_url)
        self.curl.perform()


if __name__ == "__main__":

    execname = get_executable_name()
    scriptname = get_script_name()
    argv = argv[1:]

    params = {
        "endpoint_host": ["--host", "-H"],
        "endpoint_port": ["--port", "-P"],
        "ca_certs_file": ["--ca_certs_file", "-C"]
    }
    
    if "--help" in argv or "-h" in argv:
        usage()

    args = {
        "endpoint_host": "example.com",
        "endpoint_port": "443",
        "ca_certs_file": None
    }

    all_params = sum(params.values(), [])
    skip = False
    for arg in argv:
        if skip:
            args[skip] = arg
            skip = False
            continue
        if arg in all_params:
            for k, v in params.items():
                if arg in v:
                    skip = k
        else:
            error_out(f"Illegal parameter: {arg}")

    endpoint_host = args["endpoint_host"]

    if not args["endpoint_port"].isdigit():
        error_out("endpoint_port must be digits")

    endpoint_port = int(args["endpoint_port"])
    if endpoint_port < 0 or endpoint_port > MAXU16:
        error_out("Port must be between 0 and 65535")

    ca_certs_file = args["ca_certs_file"]

    sslValidater = SSLValidater(endpoint_host=endpoint_host, endpoint_port=endpoint_port, ca_certs_file=ca_certs_file)
    sslValidater.connect_to_endpoint()
