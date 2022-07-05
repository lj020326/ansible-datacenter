from __future__ import absolute_import, division, print_function
__metaclass__ = type


try:
    from ansible_collections.dettonville.inventory.plugins.module_utils.inventory_repo_actions import InventoryRepo
except ImportError:
    # noinspection PyUnresolvedReferences
    from ansible_collections.dettonville.inventory.plugins.module_utils.inventory_repo_actions_pyyaml \
        import InventoryRepoPyYaml as InventoryRepo

# noinspection PyUnresolvedReferences
from ansible_collections.dettonville.inventory.plugins.module_utils.inventory_repo_actions_pyyaml \
    import InventoryRepoPyYaml

# ref: https://medium.com/design-patterns-in-python/factory-pattern-in-python-2f7e1ca45d3e
class InventoryRepoFactory:

    @staticmethod
    def get_repo_updater(yaml_lib_mode, module, inventory_file_path):
        "A static method to get a concrete inventory repo updater"
        if yaml_lib_mode == 'pyyaml':
            return InventoryRepoPyYaml(module, inventory_file_path)
        if yaml_lib_mode == 'ruamel':
            return InventoryRepo(module, inventory_file_path)
        return None
