
# ruamel.yaml: Preserve comments and blank lines when dumping a class that was previously loaded from yaml

I have a class that I wish to load/modify/dump from and to yaml while preserving comments and general formating using `ruamel.yaml` (0.17.21).

My issue is that after a yaml --> python --> yaml roundtrip, some comments disappear, some inline comment get put on their own line, and some bank lines (which are comments in ruamel.yaml I believe) are missing. I'm not sure if I'm doing something wrong, or if this is a bug report.

Here's a minimal working example:

```python
import sys
from ruamel.yaml import YAML, yaml_object

yaml = YAML()

@yaml_object(yaml)
class ExampleClass():
    def __init__(self, subentries):
        if not 'subentry_0' in subentries:
            raise AssertionError
        for k,v in subentries.items():
            setattr(self, k, v)
    # Here I can also define a `__setstate__` method that calls the init for me
    # But it doesn't change much

source = """
# top-level comment
entry: !ExampleClass # entry inline comment
    subentry_0: 0
    subentry_1: 1 # subentry inline comment

    # separation comment
    subentry_2: 2


entry 2: |
    This is a long
    text
    entry
"""
a = yaml.load(source)
yaml.dump(a, sys.stdout)

```

Outputs:

```yaml
# top-level comment
entry: !ExampleClass
                     # entry inline comment
  subentry_0: 0
  subentry_1: 1
  subentry_2: 2
entry 2: |
  This is a long
  text
  entry
```

Where some funky stuff happened to the comments and blank spaces.

If I initialize my class via `a['entry'].__init__(a['entry'].__dict__)`, I also lose most comments and blank lines, but it looks better:

```yaml
# top-level comment
entry: !ExampleClass
  subentry_0: 0
  subentry_1: 1
  subentry_2: 2
entry 2: |
  This is a long
  text
  entry

```

For blank lines, it'd be acceptable to me to just strip them all and then insert blank lines back between top-level entries.

## Solution

There are two issues here. One is that when you want to round-trip, you should not register tags for your own objects. `ruamel.yaml` can round-trip tagged collections (mapping, sequence) and most scalars (most notably it cannot round-trip a tagged `null`/`~`). This gives you subclasses of standard python types that mostly behave as you would expect and preserve all of the comments as well as any tags.

The second issue is that comments between keys and their values have issues, and tags interfere with comments (i.e. are not properly covered by enough testcases because of lazyness of the `ruamel.yaml` author). IIRC comments between a key and a tagged value get complete lost. The easiest solution for this second issue (for now) is probably to post-process the output.

```python
import sys
import ruamel.yaml

yaml_str = """\
# top-level comment
entry: !ExampleClass # entry inline comment
    subentry_0: 0
    subentry_1: 1 # subentry inline comment

    # separation comment
    subentry_2: 2


entry 2: |
    This is a long
    text
    entry
"""
    
yaml = ruamel.yaml.YAML()
yaml.indent(mapping=4)
yaml.preserve_quotes = True
data = yaml.load(yaml_str)
# print(data['entry'].tag.value)

def correct_comment_after_tag(s):
    # if a previous line ends in a tag and this line has enough spaces
    # at the start, append the end of the line to the previous one
    res = []
    prev_line = -1 # -1 if previous line didn't end in tag, else length of previous line
    for line in s.splitlines():
        linesplit = line.split()
        if linesplit and linesplit[-1].startswith('!'):
            prev_line = len(line)
        else:
            if prev_line > 0:
                if line.lstrip().startswith('#') and line.find('#') > prev_line:
                    res[-1] += line[prev_line:]
                    prev_line = -1
                    continue
            prev_line = -1
        res.append(line)
    return '\n'.join(res)

yaml.dump(data, sys.stdout, transform=correct_comment_after_tag)
```

which gives:

```yaml
# top-level comment
entry: !ExampleClass # entry inline comment
    subentry_0: 0
    subentry_1: 1 # subentry inline comment

    # separation comment
    subentry_2: 2


entry 2: |
    This is a long
    text
    entry
```

To get the `ExampleClass` behaviour I would probably duck-type a `__getattr__` on `ruamel.yaml.comments.CommentedMap` that checks for `subentry_0` and returns the value for key. If usually know up-front that I am going to round-trip or not and use `yamlrt = YAML()` if I do and `yamls = YAML(typ='safe')` with classes registered in `yamls` if I don't).

If you need to do (extra) checks on tagged nodes, it is IMO easiest to recursively walk over the data structure, testing dict, list and possible items for their `.tag` attribute and do the appropriate check when the tag matches.

Alternatively, you probably get a Python datastructure that preserves comments on round-trip when you make `ExampleClass` a subclass of `CommentedMap`, but I am not sure.

## Reference

- https://stackoverflow.com/questions/74049751/ruamel-yaml-preserve-comments-and-blank-lines-when-dumping-a-class-that-was-pre
- https://towardsdatascience.com/writing-yaml-files-with-python-a6a7fc6ed6c3

