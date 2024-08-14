"""Module containing the tests for the default scenario."""

# Standard Python Libraries
import datetime
import os

# Third-Party Libraries
import pytest
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ["MOLECULE_INVENTORY_FILE"]
).get_hosts("all")


@pytest.mark.parametrize("pkg", ["aptitude"])
def test_apt_packages(host, pkg):
    """Test that appropriate packages were installed on apt-based systems."""
    if host.system_info.distribution in ["debian", "kali", "ubuntu"]:
        assert host.package(pkg).is_installed


def test_apt_updated(host):
    """Test that apt-based systems were updated."""
    if host.system_info.distribution in ["debian", "kali", "ubuntu"]:
        # Make sure that the instance was updated in the last 20
        # minutes.
        assert (
            datetime.datetime.now() - host.file("/var/lib/apt/lists").mtime
        ).total_seconds() <= 20 * 60


# This test can fail if there were no updates to install.
@pytest.mark.xfail
def test_dnf_updated_time(host):
    """Test that dnf-based instances were updated."""
    if host.system_info.distribution in ["amzn", "fedora"]:
        last_update = datetime.datetime.strptime(
            host.run(
                "yum --quiet history list | cut --delimiter='|' --fields=3-4 | grep --fixed-strings U | cut --delimiter='|' --fields=1 | head --lines=1"
            ).stdout.strip(),
            "%Y-%m-%d %H:%M",
        )
        # Make sure that the instance was updated in the last 20
        # minutes.
        assert (datetime.datetime.now() - last_update).total_seconds() <= 20 * 60


def test_dnf_updated_command_output(host):
    """Test that dnf-based instances were updated."""
    if host.system_info.distribution in ["amzn", "fedora"]:
        dnf_output = host.run("dnf update")
        # There should be nothing to update.
        assert "Nothing to do." in dnf_output.stdout
