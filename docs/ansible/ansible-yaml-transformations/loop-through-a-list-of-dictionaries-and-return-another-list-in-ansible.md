
# Loop through a list of dictionaries and return another list in ansible

Let's say I have this list:

```
myList
- name: Bob
  age: 25
- name: Alice
  age: 18
- name: Bryan
  age: 20
```

All I want is to loop through **myList** and get a list of names and set it to a variable **nameList**:

```
nameList
- name: Bob
- name: Alice
- name: Bryan
```

Is there a short syntax for this in ansible?

## Solution

If you need a list of dictionaries with single `name` key (as in your example, then:

```
{{ myList | map('json_query','{name:name}') | list }}
```

This results in:

```
[
  { "name": "Bob" },
  { "name": "Alice" },
  { "name": "Bryan" }
]
```

If you need plain list of names:

```
{{ myList | map(attribute='name') | list }}
```

This results in:

```
[ "Bob", "Alice", "Bryan" ]
```

## Reference

* https://stackoverflow.com/questions/49747576/loop-through-a-list-of-dictionaries-and-return-another-list-in-ansible
* 