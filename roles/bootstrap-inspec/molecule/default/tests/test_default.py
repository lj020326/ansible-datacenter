import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


PACKAGE = 'inspec'
PACKAGE_BINARY = '/usr/bin/inspec'


def test_bootstrap_inspec__package_installed(host):
    """
    Tests if inspec packages is installed.
    """
    assert host.package(PACKAGE).is_installed


def test_bootstrap_inspec__binary_exists(host):
    """
    Tests if inspec binary exists.
    """
    assert host.file(PACKAGE_BINARY).exists


def test_bootstrap_inspec__binary_file(host):
    """
    Tests if inspec binary is a file type.
    """
    assert host.file(PACKAGE_BINARY).is_file


def test_bootstrap_inspec__binary_which(host):
    """
    Tests the output to confirm inspec's binary location.
    """
    assert host.check_output('which inspec') == PACKAGE_BINARY
