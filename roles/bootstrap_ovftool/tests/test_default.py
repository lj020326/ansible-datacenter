
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    '.molecule/ansible_inventory').get_hosts('all')


def test_hosts_file(File):
    f = File('/usr/bin/ovftool')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
