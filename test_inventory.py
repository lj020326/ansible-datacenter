
import os
from os.path import join, dirname, abspath

import pytest
import subprocess

# ref: https://pytest-with-eric.com/introduction/pytest-run-single-test/
# ref: https://medium.com/swlh/build-your-first-automated-test-integration-with-pytest-jenkins-and-docker-ec738ec43955
# ref: https://www.linkedin.com/pulse/how-use-jenkins-run-automated-python-tests-antonio-quarta/

# ref: https://pypi.org/project/pytest-shell-utilities/
# ref: https://pytest-shell-utilities.readthedocs.io/en/latest/index.html
# ref: https://github.com/saltstack/pytest-shell-utilities
# ref: https://github.com/saltstack/pytest-shell-utilities/blob/main/tests/functional/shell/test_script_subprocess.py
# ref: https://github.com/saltstack/pytest-shell-utilities/blob/main/tests/unit/utils/processes/test_processresult.py

# ref: https://docs.pytest.org/en/7.1.x/how-to/fixtures.html
@pytest.fixture
def request_path(request):
    return request.path

@pytest.fixture
def script_path():
    cwd = os.getcwd()
    script_path = join(cwd, "run-inventory-tests.sh")
    # script_path = "%s/run-inventory-tests.sh" % cwd
    return script_path

# ref: https://stackoverflow.com/questions/49132728/python-subprocess-return-output-into-a-list
def bash_command(cmd):
    sp = subprocess.Popen(['/bin/bash', '-c', cmd], stdout=subprocess.PIPE)
    return sp.stdout.read().splitlines()

def get_test_cases():
    # ref: https://stackoverflow.com/questions/39475849/how-to-get-pytest-fixture-data-dynamically
    cwd = os.getcwd()
    script_file = join(cwd, "run-inventory-tests.sh")
    test_case_list = bash_command("%s -l" % script_file)
    print("test_case_list=%s" % test_case_list)
    return test_case_list

test_case_list = get_test_cases()

# ref: https://docs.pytest.org/en/latest/reference/reference.html#request
# ref: https://stackoverflow.com/questions/63210834/run-pytest-for-each-file-in-directory
@pytest.mark.parametrize("test_case", test_case_list)
def test_inventory(shell, script_path, test_case):
    ret = shell.run(script_path, test_case)
    assert ret.returncode == 0
