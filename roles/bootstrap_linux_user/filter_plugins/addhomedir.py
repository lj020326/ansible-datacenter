
## ref: https://devops.stackexchange.com/questions/11481/doing-map-and-filter-of-a-list-of-dictionaries-in-ansible
## ref: https://stackoverflow.com/questions/4291236/edit-the-values-in-a-list-of-dictionaries
## ref: https://codereview.stackexchange.com/questions/24514/updating-list-of-dictionaries-from-other-such-list
class FilterModule:
    @staticmethod
    def add_home(_user_list):
        for user in _user_list:
            if 'home_dir' not in user:
                user['home_dir']='/home/{0}'.format(user['name'])

        return _user_list

    def filters(self):
        return {
            'add_home_dir': self.add_home
        }

