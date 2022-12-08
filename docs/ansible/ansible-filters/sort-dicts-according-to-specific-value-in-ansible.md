
# Sort dict according to specific value in Ansible

I have the following dictionary set as a variable in Ansible:

```
my_users:
  name1:
    value: some_value1
    id: 99
    type: some_type1
  name2:
    value: some_value2
    id: 55
    type: some_type2
  name3:
    value: some_value3
    id: 101
    type: some_type3
```

I would like to sort it according to the `id` field and print it again. I have tried using `dictsort` and chosing the by value option but I couldn't find a way to specify a specific value on which to sort.

```
  tasks:
    - debug:
        msg: "{{ item }}"
      with_items: "{{ my_users | dictsort(false, 'value') }}"
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

    def sortbysubkey(self, dict_to_sort, sorting_key):
        return sorted(dict_to_sort.items(), key=lambda x: x[1][sorting_key])
```

Then use the custom filter to sort the dicts:
```yaml
  tasks:
    - debug:
        msg: "{{ my_users | sortbysubkey('id') }}"
```

## References

* https://stackoverflow.com/questions/51864288/sort-dict-according-to-specific-value-in-ansible
* 