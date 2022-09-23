
class FilterModule(object):
    def filters(self):
        return {
            'sortdictlist': self.sortdictlist
        }

    def sortdictlist(self, dictlist_to_sort, sorting_key):
        return sorted(dictlist_to_sort, key=lambda item: item.get(sorting_key))
        #return dictlist_to_sort.sort(key=lambda item: item.get(sorting_key))
        #return sorted(dictlist_to_sort, key=lambda x: x[1][sorting_key])
