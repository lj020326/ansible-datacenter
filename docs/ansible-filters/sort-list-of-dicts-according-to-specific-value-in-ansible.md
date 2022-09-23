
# Sort dict according to specific value in Ansible

I have the following dictionary set as a variable in Ansible:

```
my_users:
- Name: Jeremy
  Age: 25
  Favorite Color: Blue
- Name: Jasmine
  Age: 29
  Favorite Color: Aqua
- Name: Ally
  Age: 41
  Favorite Color: Magenta

```

I would like to sort it according to the 'age' field and print it again using a method similar to the following. 

```
  tasks:
    - debug:
        msg: "{{ item }}"
      with_items: "{{ my_users | somefiltertosortthelist('age') }}"
```

## Solution 1

[Jinja2 `dictsort`](http://jinja.pocoo.org/docs/2.10/templates/#dictsort) works on dictionaries (flat) and allows for either sorting by a key or value (that's the meaning of `'value'` argument ― it is a switch, not a name of a key in a nested dictionary).

You can write a simple filter plugin in Python:

```python
#!/usr/bin/python
class FilterModule(object):
    def filters(self):
        return {
            'sortbysubkey': self.sortbysubkey,
        }

    def sortbysubkey(self, dictlist_to_sort, sorting_key):
        return sorted(dictlist_to_sort, key=lambda item: item.get(sorting_key))
        #return dictlist_to_sort.sort(key=lambda item: item.get(sorting_key))
        #return sorted(dictlist_to_sort, key=lambda x: x[1][sorting_key])
```

Then use the custom filter to sort the list of dicts:
```yaml
  tasks:
    - debug:
        msg: "{{ my_users | sortbysubkey('id') }}"
```


## References

* https://therenegadecoder.com/code/how-to-sort-a-list-of-dictionaries-in-python/
* https://stackoverflow.com/questions/51864288/sort-dict-according-to-specific-value-in-ansible
* 