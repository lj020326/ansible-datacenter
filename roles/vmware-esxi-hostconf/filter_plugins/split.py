from ansible import errors
import re

# https://github.com/timraasveld/ansible-string-split-filter/blob/master/split.py

def split_string(string, separator=None, maxsplit=-1):
    try:
        return string.split(separator, maxsplit)
    except Exception as e:
        raise errors.AnsibleFilterError('split plugin error: %s, provided string: "%s"' % (str(e),str(string)) )

def split_regex(string, separator_pattern='\s+'):
    try:
        return re.split(separator_pattern, string)
    except Exception as e:
        raise errors.AnsibleFilterError('split plugin error: %s, provided string: "%s"' % (str(e),str(string)) )

class FilterModule(object):
    ''' A filter to split a string into a list. '''
    def filters(self):
        return {
            'split' : split_string,
            'split_regex' : split_regex,
        }
