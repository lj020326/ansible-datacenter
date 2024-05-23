
# How to recursively sort YAML (with anchors) using CommentedMap?

I'm facing issue with the recursive sort solution proposed [here](https://stackoverflow.com/questions/51386822/how-to-recursively-sort-yaml-using-commentedmap)

I cannot sort YAML file with anchor and sub-elements. The .pop method call is throwing a KeyError exception.

Ex:

```yaml
volvo:
  anchor_struct: &anchor_struct
    zzz:
      val: "bar"
    aaa:
      val: "foo"
  aaa: "Authorization"
  zzz: 341
  anchr_val: &anchor_val famous_val
  
lambo:
  <<: *anchor_struct
  mykey:
    myval:
      enabled: false
  anchor_struct:
    <<: *anchor_struct
    username: user
  anchor_val: *anchor_val
  zzz: zorglub
  www: web
```

```
  File <span class="hljs-string">"orderYaml.py"</span>, line <span class="hljs-number">36</span>, <span class="hljs-keyword">in</span> recursive_sort_mappings
    value = s.pop(key)
  File <span class="hljs-string">"/usr/local/lib/python3.6/dist-packages/ruamel/yaml/comments.py"</span>, line <span class="hljs-number">818</span>, <span class="hljs-keyword">in</span> __delitem__
    referer.update_key_value(key)
  File <span class="hljs-string">"/usr/local/lib/python3.6/dist-packages/ruamel/yaml/comments.py"</span>, line <span class="hljs-number">947</span>, <span class="hljs-keyword">in</span> update_key_value
    ordereddict.__delitem__(self, key)
KeyError: <span class="hljs-string">'aaa'</span>
```

This error goes when the YAML file contains extra elements in the anchors elements like here

```yaml
volvo:
  anchor_struct: &anchor_struct
    extra:
      zzz:
        val: "bar"
      aaa:
        val: "foo"
  aaa: "Authorization"
  zzz: 341
  anchr_val: &anchor_val famous_val
  
lambo:
  <<: *anchor_struct
  mykey:
    myval:
      enabled: false
  anchor_struct:
    <<: *anchor_struct
    username: user
  anchor_val: *anchor_val
  zzz: zorglub
  www: web
```

As cherry on the cake: is there a way to keep the anchor definition (&...) on the "volvo" element after the sort since I would like to manipulate the sort result to keep always the "volvo" element on top after the treatment.

My goal is to reach this file with the sort:

```yaml
lambo:
  <<: *anchor_struct
  anchor_struct:
    <<: *anchor_struct
  mykey:
    myval:
      enabled: false
    username: user
  anchor_val: *anchor_val
  www: web
  zzz: zorglub

volvo:
  aaa: "Authorization"
  anchor_struct: &anchor_struct
    aaa:
      val: "foo"
    zzz:
      val: "bar"
  anchr_val: &anchor_val famous_val
  zzz: 341
```

Do you see other solution to reach that ? My goal is to validate that alphabetical order is respected in all of our YAML files.

___

EDIT #1:

Here is another example of what I'm trying to reach.

-   I'm only expecting elements with attributes "&" in top element "\_world"
-   There will be at max 30 different values with attribute "&"
-   top element "_world" will be named explicitely with a prefix "_" to alway be on top
-   other root elements will use reference to the anchors (via "<<: \*")
-   The output must not add lines or attributes
-   The output must must not modify attributes
-   The output must sort all the elements and their subelements (except the arrays)

Here is an example of input/output expected:

Input

```yaml
_world:
  anchor_struct: &anchor_struct
    foo:
      val: "foo"
    bar:
      val: "foo"
  string: "string"
  newmsg: &newmsg
    msg: "msg"
    foo: "foo"
    new: "new"
  anchr_val: &anchor_val famous_val
  bool: True
elem2:
  myStruct:
    <<: *anchor_struct
  anchor_val: *anchor_val
  <<: *anchor_struct
  zzz: zorglub
  www: web
  anchor_struct:
    <<: *anchor_struct
    other_elem: "other_elem"
elem1:
  <<: *anchor_struct
  zzz: zorglub
  newmsg: 
    <<: *newmsg
    msg: "msg2"
  myStruct:
    <<: *anchor_struct
  anchor_struct:
    second_elem: "second_elem"
    <<: *anchor_struct
    other_elem: "other_elem"
  www: web
  anchor_val: *anchor_val
```

Expected output

```yaml
_world:
  anchor_struct: &anchor_struct
    bar:
      val: "foo"
    foo:
      val: "foo"
  anchr_val: &anchor_val famous_val
  bool: True
  newmsg: &newmsg
    foo: "foo"
    msg: "msg"
    new: "new"
  string: "string"
elem1:
  <<: *anchor_struct
  anchor_struct:
    <<: *anchor_struct
    other_elem: "other_elem"
    second_elem: "second_elem"
  anchor_val: *anchor_val
  myStruct:
    <<: *anchor_struct
  newmsg: 
    <<: *newmsg
    msg: "msg2"
  www: web
  zzz: zorglub
elem2:
  <<: *anchor_struct
  anchor_struct:
    <<: *anchor_struct
    other_elem: "other_elem"
  anchor_val: *anchor_val
  myStruct:
    <<: *anchor_struct
  www: web
  zzz: zorglub
```

## Solution

The approach I take with solving these kind of things, is first to add the expected and necessary imports, define the input and expected output as multiline strings, and add a useful `diff` method to the YAML instance.

String input is easier to work with than files while testing as everything is in one file (need to remove some trailing spaces?) and you cannot overwrite your input and start the next run with something different than the first.

```python
import sys
import difflib
import ruamel.yaml
from ruamel.yaml.comments import merge_attrib

yaml_in = """\
_world:
  anchor_struct: &anchor_struct
    foo:
      val: "foo"
    bar:
      val: "foo"
  string: "string"
  newmsg: &newmsg
    msg: "msg"
    foo: "foo"
    new: "new"
  anchr_val: &anchor_val famous_val
  bool: True
elem2:
  myStruct:
    <<: *anchor_struct
  anchor_val: *anchor_val
  <<: *anchor_struct
  zzz: zorglub
  www: web
  anchor_struct:
    <<: *anchor_struct
    other_elem: "other_elem"
elem1:
  <<: *anchor_struct
  zzz: zorglub
  newmsg: 
    <<: *newmsg
    msg: "msg2"
  myStruct:
    <<: *anchor_struct
  anchor_struct:
    second_elem: "second_elem"
    <<: *anchor_struct
    other_elem: "other_elem"
  www: web
  anchor_val: *anchor_val
"""

yaml_out = """\
_world:
  anchor_struct: &anchor_struct
    bar:
      val: "foo"
    foo:
      val: "foo"
  anchr_val: &anchor_val famous_val
  bool: True
  newmsg: &newmsg
    foo: "foo"
    msg: "msg"
    new: "new"
  string: "string"
elem1:
  <<: *anchor_struct
  anchor_struct:
    <<: *anchor_struct
    other_elem: "other_elem"
    second_elem: "second_elem"
  anchor_val: *anchor_val
  myStruct:
    <<: *anchor_struct
  newmsg: 
    <<: *newmsg
    msg: "msg2"
  www: web
  zzz: zorglub
elem2:
  <<: *anchor_struct
  anchor_struct:
    <<: *anchor_struct
    other_elem: "other_elem"
  anchor_val: *anchor_val
  myStruct:
    <<: *anchor_struct
  www: web
  zzz: zorglub
"""


def diff_yaml(self, data, s, fnin="in", fnout="out"):
    # dump data if necessary and compare with s
    inl = [l.rstrip() + '\n' for l in s.splitlines()]   # trailing space at end of line disregarded
    if not isinstance(data, str):
        buf = ruamel.yaml.compat.StringIO()
        self.dump(data, buf)
        outl = buf.getvalue().splitlines(True)
    else:
        outl = [l.rstrip() + '\n' for l in data.splitlines()]
    diff = difflib.unified_diff(inl, outl, fnin, fnout)
    result = True
    for line in diff:
        sys.stdout.write(line)
        result = False
    return result

ruamel.yaml.YAML.diff = diff_yaml

yaml = ruamel.yaml.YAML()
# yaml.indent(mapping=4, sequence=4, offset=2)
yaml.boolean_representation = ["False", "True"]

```

Then make sure your expected output is valid, and can be round-tripped:

```python
dout = yaml.load(yaml_out)
buf = ruamel.yaml.compat.StringIO()
yaml.dump(dout, buf)
assert yaml.diff(dout, yaml_out)
```

which should not give output nor an assertion error ( there is trailing whitespace in your expected output, as well as the not default `True` boolean). If the expected output cannot be round-tripped, ruamel.yaml might not be able dump your expected output.

If you are stuck can now inspect `dout` to determine what your parsed input should look like.

So now try the [`recursive_sort`](https://stackoverflow.com/a/51387713/1307905)

```python
def recursive_sort_mappings(s):
    if isinstance(s, list):
        for elem in s:
            recursive_sort_mappings(elem)
        return 
    if not isinstance(s, dict):
        return
    for key in sorted(s, reverse=True):
        value = s.pop(key)
        recursive_sort_mappings(value)
        s.insert(0, key, value)

din = yaml.load(yaml_in)
recursive_sort_mappings(din)
yaml.diff(din, yaml_out)
```

Which gives quite a bit of output, as the `recursive_sort_mappings` doesn't know about merges and runs over all the keys, tries to keep merge keys in their original position, and additionally when popping a key (before reinserting it in the first position), does some magic in case the popped value exists in a merged mapping:

```output
--- in
+++ out
@@ -1,8 +1,8 @@
 _world:
   anchor_struct: &anchor_struct
-    bar:
+    bar: &id001
       val: "foo"
-    foo:
+    foo: &id002
       val: "foo"
   anchr_val: &anchor_val famous_val
   bool: True
@@ -14,24 +14,38 @@
 elem1:
   <<: *anchor_struct
   anchor_struct:
+    bar: *id001
     <<: *anchor_struct
+    foo: *id002
     other_elem: "other_elem"
     second_elem: "second_elem"
   anchor_val: *anchor_val
+  bar: *id001
+  foo: *id002
   myStruct:
     <<: *anchor_struct
+    bar: *id001
+    foo: *id002
   newmsg:
     <<: *newmsg
+    foo: "foo"
     msg: "msg2"
+    new: "new"
   www: web
   zzz: zorglub
 elem2:
-  <<: *anchor_struct
   anchor_struct:
     <<: *anchor_struct
+    bar: *id001
+    foo: *id002
     other_elem: "other_elem"
   anchor_val: *anchor_val
+  <<: *anchor_struct
+  bar: *id001
+  foo: *id002
   myStruct:
     <<: *anchor_struct
+    bar: *id001
+    foo: *id002
   www: web
   zzz: zorglub

```

To solve this you need to do multiple things. First you need to abandon the .insert(), which emulation (for the Python3 built-in `OrderedDict`) the method defined C ordereddict package ruamel.ordereddict. This emulation recreates the OrderedDict and that leads to duplication. Python3 C implementation, has a less powerful (than `.insert()`), but in this case useful method `move_to_end` (Which could be be used in an update to the `.insert()` emulation in ruamel.yaml).

Second you need only to walk over the "real" keys, not those keys provided by merges, so you cannot use `for key in`.

Third you need the merge key to move to the top of mapping if it is somewhere else.

(The `level` argument was added for debugging purposes)

```python
from ruamel.yaml.comments import merge_attrib

def recursive_sort_mappings(s, level=0):
    if isinstance(s, list): 
        for elem in s:
            recursive_sort_mappings(elem, level=level+1)
        return 
    if not isinstance(s, dict):
        return
    merge = getattr(s, merge_attrib, [None])[0]
    if merge is not None and merge[0] != 0:  # << not in first position, move it
       setattr(s, merge_attrib, [(0, merge[1])])

    for key in sorted(s._ok): # _ok -> set of Own Keys, i.e. not merged in keys
        value = s[key]
        # print('v1', level, key, super(ruamel.yaml.comments.CommentedMap, s).keys())
        recursive_sort_mappings(value, level=level+1)
        # print('v2', level, key, super(ruamel.yaml.comments.CommentedMap, s).keys())
        s.move_to_end(key)


din = yaml.load(yaml_in)
recursive_sort_mappings(din)
assert yaml.diff(din, yaml_out)
```

And then the diff no longer gives output.

## Reference

- https://stackoverflow.com/questions/62953548/how-to-recursively-sort-yaml-with-anchors-using-commentedmap
- https://stackoverflow.com/questions/40226610/ruamel-yaml-equivalent-of-sort-keys#40227545
- https://stackoverflow.com/questions/49613901/sort-yaml-file-with-comments
- https://github.com/maxx27/pyyaml-sort/blob/main/comments_sort.py
- 
