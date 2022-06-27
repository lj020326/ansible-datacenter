from __future__ import absolute_import, division, print_function
__metaclass__ = type

import os
import stat
import re
import shutil
import tempfile
from distutils.version import LooseVersion


try:
    from module_utils.messages import FailingMessage
except ImportError:
    from ansible.module_utils.messages import FailingMessage

try:
    from module_utils.six import b
except ImportError:
    from ansible.module_utils.six import b

try:
    from module_utils._text import to_native, to_text
except ImportError:
    from ansible.module_utils._text import to_native, to_text


class Git:

    def __init__(self, module, inventory_repo_dir):
        self.module = module
        self.inventory_repo_dir = inventory_repo_dir

        self.git_path = self.module.params.get('executable') or self.module.get_bin_path('git', True)

        self.inventory_repo_url = self.module.params.get('inventory_repo_url')
        self.inventory_repo_scheme = self.module.params.get('inventory_repo_scheme')
        self.inventory_repo_branch = self.module.params.get('inventory_repo_branch')

        print('self.inventory_repo_url={0}'.format(self.inventory_repo_url))

        self.remote = self.module.params.get('remote') or 'origin'
        self.push_option = self.module.params.get('push_option')
        self.user = self.module.params.get('user')
        self.token = self.module.params.get('token')

        self.ssh_key_file = None
        self.ssh_opts = None
        self.ssh_accept_hostkey = False

        ssh_params = self.module.params['ssh_params'] or None

        if ssh_params:

            self.ssh_key_file = ssh_params['key_file'] if 'key_file' in ssh_params else None
            self.ssh_opts = ssh_params['ssh_opts'] if 'ssh_opts' in ssh_params else None
            self.ssh_accept_hostkey = ssh_params['accept_hostkey'] if 'accept_hostkey' in ssh_params else False

            if self.ssh_accept_hostkey:
                if self.ssh_opts is not None:
                    if "-o StrictHostKeyChecking=no" not in self.ssh_opts:
                        self.ssh_opts += " -o StrictHostKeyChecking=no"
                else:
                    self.ssh_opts = "-o StrictHostKeyChecking=no"

        self.ssh_wrapper = self.write_ssh_wrapper(self.module.tmpdir)
        self.set_git_ssh(self.ssh_wrapper, self.ssh_key_file, self.ssh_opts)
        self.module.add_cleanup_file(path=self.ssh_wrapper)

        # We screenscrape a huge amount of git commands so use C
        # locale anytime we call run_command()
        self.module.run_command_environ_update = dict(LANG='C', LC_ALL='C', LC_MESSAGES='C', LC_CTYPE='C')

        if self.inventory_repo_scheme == 'local':
            if self.inventory_repo_url.startswith(('https://', 'git', 'ssh://git')):
                self.module.fail_json(msg='SSH or HTTPS scheme selected but repo is "local')

            if ssh_params:
                self.module.warn('SSH Parameters will be ignored as scheme "local"')

        elif self.inventory_repo_scheme == 'https':
            if not self.inventory_repo_url.startswith('https://'):
                self.module.fail_json(msg='HTTPS scheme selected but url (' +
                                          self.inventory_repo_url + ') not starting with "https"')
            if ssh_params:
                self.module.warn('SSH Parameters will be ignored as scheme "https"')

        elif self.inventory_repo_scheme == 'ssh':
            if not self.inventory_repo_url.startswith(('git', 'ssh://git')):
                self.module.fail_json('SSH scheme selected but url (' +
                                      self.inventory_repo_url + ') not starting with "git" or "ssh://git"')

            if self.inventory_repo_url.startswith('ssh://git@github.com'):
                self.module.fail_json('GitHub does not support "ssh://" URL. Please remove it from url')

    def write_ssh_wrapper(self, module_tmpdir):
        try:
            # make sure we have full permission to the module_dir, which
            # may not be the case if we're sudo'ing to a non-root user
            if os.access(module_tmpdir, os.W_OK | os.R_OK | os.X_OK):
                fd, wrapper_path = tempfile.mkstemp(prefix=module_tmpdir + '/')
            else:
                raise OSError
        except (IOError, OSError):
            fd, wrapper_path = tempfile.mkstemp()

        fh = os.fdopen(fd, 'w+b')
        template = b("""#!/bin/sh
if [ -z "$GIT_SSH_OPTS" ]; then
    BASEOPTS=""
else
    BASEOPTS=$GIT_SSH_OPTS
fi

# Let ssh fail rather than prompt
BASEOPTS="$BASEOPTS -o BatchMode=yes"

if [ -z "$GIT_KEY" ]; then
    ssh $BASEOPTS "$@"
else
    ssh -i "$GIT_KEY" -o IdentitiesOnly=yes $BASEOPTS "$@"
fi
""")
        fh.write(template)
        fh.close()
        st = os.stat(wrapper_path)
        os.chmod(wrapper_path, st.st_mode | stat.S_IEXEC)
        return wrapper_path

    def set_git_ssh(self, ssh_wrapper, key_file, ssh_opts):

        if os.environ.get("GIT_SSH"):
            del os.environ["GIT_SSH"]
        os.environ["GIT_SSH"] = ssh_wrapper

        if os.environ.get("GIT_KEY"):
            del os.environ["GIT_KEY"]

        if key_file:
            os.environ["GIT_KEY"] = key_file

        if os.environ.get("GIT_SSH_OPTS"):
            del os.environ["GIT_SSH_OPTS"]

        if ssh_opts:
            os.environ["GIT_SSH_OPTS"] = ssh_opts

    def get_branches(self, dest):
        branches = []
        cmd = '%s branch --no-color -a' % (self.git_path,)
        (rc, out, err) = self.module.run_command(cmd, cwd=dest)
        if rc != 0:
            self.module.fail_json(msg="Could not determine branch data - received %s" % out, stdout=out, stderr=err)
        for line in out.split('\n'):
            if line.strip():
                branches.append(line.strip())
        return branches

    def git_version(self):
        """return the installed version of git"""
        cmd = "%s --version" % self.git_path
        (rc, out, err) = self.module.run_command(cmd)
        if rc != 0:
            # one could fail_json here, but the version info is not that important,
            # so let's try to fail only on actual git commands
            return None
        rematch = re.search('git version (.*)$', to_native(out))
        if not rematch:
            return None
        return LooseVersion(rematch.groups()[0])

    def get_annotated_tags(self, dest):
        tags = []
        cmd = [self.git_path, 'for-each-ref', 'refs/tags/', '--format', '%(objecttype):%(refname:short)']
        (rc, out, err) = self.module.run_command(cmd, cwd=dest)
        if rc != 0:
            self.module.fail_json(msg="Could not determine tag data - received %s" % out, stdout=out, stderr=err)
        for line in to_native(out).split('\n'):
            if line.strip():
                tagtype, tagname = line.strip().split(':')
                if tagtype == 'tag':
                    tags.append(tagname)
        return tags

    def clone(self, bare=False, reference=None, refspec=None):
        ''' makes a new git repo if it does not already exist '''

        try:
            os.makedirs(os.path.dirname(self.inventory_repo_dir))
        except OSError:
            pass
        cmd = [self.git_path, 'clone']

        if bare:
            cmd.append('--bare')
        else:
            cmd.extend(['--origin', self.remote])

        if reference:
            cmd.extend(['--reference', str(reference)])

        cmd.extend([self.inventory_repo_url, self.inventory_repo_dir])
        self.module.run_command(cmd, check_rc=True, cwd=self.inventory_repo_dir)

        if bare and remote != 'origin':
            self.module.run_command([self.git_path, 'remote', 'add', remote, self.inventory_repo_url],
                                    check_rc=True, cwd=self.inventory_repo_dir)

        if refspec:
            cmd = [self.git_path, 'fetch']
            cmd.extend([remote, refspec])
            self.module.run_command(cmd, check_rc=True, cwd=self.inventory_repo_dir)

    def add(self, add_files=['.']):
        """
        Run git add and stage changed files.

        args:
            * module:
                type: dict()
                descrition: Ansible basic module utilities and module arguments.

        return: null
        """

        command = [self.git_path, 'add', '--']

        command.extend(add_files)

        rc, output, error = self.module.run_command(command, cwd=self.inventory_repo_dir)

        if rc == 0:
            return

        FailingMessage(self.module, rc, command, output, error)

    def status(self):
        """
        Run git status and check if repo has changes.

        args:
            * module:
                type: dict()
                descrition: Ansible basic module utilities and module arguments.
        return:
            * data:
                type: set()
                description: list of files changed in repo.
        """
        data = set()
        command = [self.git_path, 'status', '--porcelain']

        rc, output, error = self.module.run_command(command, cwd=self.inventory_repo_dir)

        if rc == 0:
            for line in output.split('\n'):
                file_name = line.split(' ')[-1].strip()
                if file_name:
                    data.add(file_name)
            return data

        else:
            FailingMessage(self.module, rc, command, output, error)

    def commit(self, comment='ansible update'):
        """
        Run git commit and commit files in repo.

        args:
            * module:
                type: dict()
                descrition: Ansible basic module utilities and module arguments.
        return:
            * result:
                type: dict()
                desription: returned output from git commit command and changed status
        """
        result = dict()
        command = [self.git_path, 'commit', '-m', comment]

        rc, output, error = self.module.run_command(command, cwd=self.inventory_repo_dir)

        if rc == 0:
            if output:
                result.update({"git_commit": output, "changed": True})
                return result
        else:
            FailingMessage(self.module, rc, command, output, error)

    def push(self):
        """
        Set URL and remote if required. Push changes to remote repo.

        args:
            * module:
                type: dict()
                descrition: Ansible basic module utilities and module arguments.
        return:
            * result:
                type: dict()
                desription: returned output from git push command and updated changed status.
        """

        command = [self.git_path, 'push', self.remote, self.inventory_repo_branch]

        def set_url():
            """
            Set URL and remote if required.

            args:
                * module:
                    type: dict()
                    descrition: Ansible basic module utilities and module arguments.
            return: null
            """
            command = [self.git_path, 'remote', 'get-url', '--all', self.remote]

            rc, _output, _error = self.module.run_command(command, cwd=self.inventory_repo_dir)

            if rc == 0:
                return

            if rc == 128:
                if self.inventory_repo_scheme == 'https':
                    if self.inventory_repo_url.startswith('https://'):
                        command = [
                            self.git_path,
                            'remote',
                            'add',
                            self.remote,
                            'https://{0}:{1}@{2}'.format(self.user, self.token, self.inventory_repo_url[8:])
                        ]
                    else:
                        self.module.fail_json(msg='HTTPS scheme selected but not HTTPS URL provided')
                else:
                    command = [self.git_path, 'remote', 'add', self.remote, self.inventory_repo_url]

                rc, output, error = self.module.run_command(command, cwd=self.inventory_repo_dir)

                if rc == 0:
                    return
                else:
                    FailingMessage(self.module, rc, command, output, error)

        def push_cmd():
            """
            Set URL and remote if required. Push changes to remote repo.

            args:
                * path:
                    type: path
                    descrition: git repo local path.
                * cmd_push:
                    type: list()
                    descrition: list of commands to perform git push operation.
            return:
                * result:
                    type: dict()
                    desription: returned output from git push command and updated changed status.
            """
            result = dict()

            rc, output, error = self.module.run_command(command, cwd=self.inventory_repo_dir)

            if rc == 0:
                result.update({"git_push": str(error) + str(output), "changed": True})
                return result
            else:
                FailingMessage(self.module, rc, command, output, error)

        if self.push_option:
            command.insert(3, '--push-option={0} '.format(self.push_option))

        set_url()

        return push_cmd()
