from __future__ import absolute_import, division, print_function
__metaclass__ = type


class GitConfiguration:

    def __init__(self, module, git_config=None):
        self.module = module
        self.git_config = git_config

    def user_config(self):
        """
        Config git local user.name and user.email.

        args:
            * module:
                type: dict()
                descrition: Ansible basic module utilities and module arguments.
        return:
            * result:
                type: dict()
                desription: updated changed status.
        """
        PARAMETERS = ['name', 'email']
        result = dict()
        path = self.module.params.get('path')

        for parameter in PARAMETERS:
            if self.git_config[parameter]:
                config_parameter = self.git_config[parameter]
            else:
                config_parameter = self.module.params.get('user_{0}'.format(parameter))

            if config_parameter:
                command = ['git', 'config', '--local', 'user.{0}'.format(parameter)]
                _rc, output, _error = self.module.run_command(command, cwd=path)

                if output != config_parameter:
                    command.append(config_parameter)
                    _rc, output, _error = self.module.run_command(command, cwd=path)

                    result.update({parameter: output, "changed": True})

        return result
