
# How to export all passwords from keychain to delimited ascii file (e.g., csv)


## Solution #1

This is just about [how](https://gist.github.com/rwest/1583781) I did it a many years ago, this is that script update for [Yosemite 10.11.5](https://gist.github.com/TaergLee/50934395f0dafbb7f7cb "here") - but I've not tested it.

1.  A script that saves each item in the Keychain to text:
    
    ```
    security dump-keychain -d login.keychain > keychain.txt
    ```
    
2.  A second AppleScript item that clicks on the "Allow" button that the 1st script triggers when reading the item out of the KeyChain.
    

\[Edit: July 2016\] This has been updated to 10.11.5 note as some have reported locking up their Mac with the 0.2 delay, I've limited the script to only process 200 results at a time, thus if you have 1050 keychain items, you'll need to run this script 6 time in the ScriptEditor, you'll also have to allow the ScriptEditor to be enabled in the Accessibility section in the security preferences in :

```
tell application "System Events"
    set maxAttemptsToClick to 200
    repeat while exists (processes where name is "SecurityAgent")
        if maxAttemptsToClick = 0 then exit repeat
        set maxAttemptsToClick to maxAttemptsToClick - 1
        tell process "SecurityAgent"
            try
                click button 2 of window 1
            on error
                keystroke " "
            end try
        end tell
        delay 0.2
    end repeat
end tell
```

Then the [link](https://gist.github.com/rwest/1583781)/[yosemite update](https://gist.github.com/TaergLee/50934395f0dafbb7f7cb "here") above also has a ruby conversion step from the text file to CSV, Good luck!

ShreevatsaR points out in the comments that this ruby conversion only covers "internet passwords" and not "application passwords". This is due to the aim of the script is to export the "internet passwords" into the application `1Password`.

And here's a [stack overflow](https://stackoverflow.com/questions/717095/is-there-a-quick-and-easy-way-to-dump-the-contents-of-a-macos-x-keychain) question and answer along the same lines

The System.keychain is here:

```
security dump-keychain -d /Library/Keychains/System.keychain > systemkeychain.txt
```

To enable AppleScript to interact with dialogue box the System Preferences -> Security & Privacy Preferences -> Privacy Tab, Accessibility Option must have "Script Editor.app" enabled.

![System Preferences -> Security & Privacy Preferences -> Privacy Tab, Accessibility Option highlighted](./img/sec-and-privacy-script-editor-app.png)


## Solution #2 - Python script

I wrote a python script that converts the keychain dump to an Excel file and thought I share it with you. I choose Excel over CSV or TSV because a lot of people have it installed and it just works by double clicking on the file. You may of course modify the script to print any other format. I did this on OS X 10.11 El Capitan, but should work on older OS' as well.

1.  Since I do not like storing my passwords plaintext on my hard drive, I created an encrypted container using the Disk Utility app. Simply open Disk Utility (press cmd+Space, type "disk"). In the app, press cmd+N for new image, change the name to SEC, change encryption to 256-Bit AES and save it under SEC in a directory of you choice. Then mount the volume by doubleclicking on the file (or using Disk Utility).
    
2.  Create a new file named keychain.py in the secure container and paste the code below.
    
3.  Now open Terminal.app and change directory to the mounted encrypted volume: `cd /Volumes/SEC`
    
4.  We need the python package manager for installing the Excel module (you will be prompted for your password): `sudo easy_install pip`
    
5.  We need to install the Python Excel module: `sudo pip install xlwt`
    
6.  Now export the passwords using one of the other answers to this question. I just did `security dump-keychain -d > keychain.txt` and spam clicked on the Allow button while holding the mouse with my other hand.
    
7.  The last step is to convert the txt file to a readable Excel sheet using the python script: `python keychain.py keychain.txt keychain.xls`
    

```python
#!/usr/bin/env python

import sys
import os
import re
import xlwt

# Regex to match both generic and internet passwords from a keychain dump
regex = re.compile(
    r"""
    keychain:\s"(?P<kchn>[^"]+)"\n                  # absolute path and file of keychain
    version:\s(\d\d\d)\n                            # version
    class:\s"(?P<clss>(genp|inet))"\n               # generic password or internet password
    attributes:\n
    (\s*?0x00000007\s<blob>=(?P<name>[^\n]+)\n)?    # name
    (\s*?0x00000008\s<blob>=(?P<hex8>[^\n]+)\n)?    # ? only used at certificates
    (\s*?"acct"<blob>=(?P<acct>[^\n]+)\n)?          # account
    (\s*?"atyp"<blob>=(?P<atyp>[^\n]+)\n)?          # account type ("form"), sometimes int
    (\s*?"cdat"<timedate>=[^"]*(?P<cdat>[^\n]+)\n)? # datetime created
    (\s*?"crtr"<uint32>=(?P<crtr>[^\n]+)\n)?        # vendor key with four chars like "aapl"
    (\s*?"cusi"<sint32>=(?P<cusi>[^\n]+)\n)?        # ? always null
    (\s*?"desc"<blob>=(?P<desc>[^\n]+)\n)?          # description
    (\s*?"gena"<blob>=(?P<gena>[^\n]+)\n)?          # ? always null except one rare cases
    (\s*?"icmt"<blob>=(?P<icmt>[^\n]+)\n)?          # ? some sort of description
    (\s*?"invi"<sint32>=(?P<invi>[^\n]+)\n)?        # ? always null
    (\s*?"mdat"<timedate>=[^"]*(?P<mdat>[^\n]+)\n)? # datetime last modified
    (\s*?"nega"<sint32>=(?P<nega>[^\n]+)\n)?        # ? always null
    (\s*?"path"<blob>=(?P<path>[^\n]+)\n)?          # path
    (\s*?"port"<uint32>=(?P<port>[^\n]+)\n)?        # port number in hex
    (\s*?"prot"<blob>=(?P<prot>[^\n]+)\n)?          # ? always null
    (\s*?"ptcl"<uint32>=(?P<ptcl>[^\n]+)\n)?        # protocol but is blob ("http", "https")
    (\s*?"scrp"<sint32>=(?P<scrp>[^\n]+)\n)?        # ? always null except one rare cases
    (\s*?"sdmn"<blob>=(?P<sdmn>[^\n]+)\n)?          # used for htaccess AuthName
    (\s*?"srvr"<blob>=(?P<srvr>[^\n]+)\n)?          # server
    (\s*?"svce"<blob>=(?P<svce>[^\n]+)\n)?          # ? some sort of description
    (\s*?"type"<uint32>=(?P<type>[^\n]+)\n)?        # some blob: "iprf", "note"
    data:\n
    "(?P<data>[^"]*)"                               # password
    """, re.MULTILINE | re.VERBOSE)

# Dictionary used by the clean function (Apple is not always right about the
# types of the field)
field2type = { 
    "name": "blob",
    "hex8": "blob",
    "acct": "blob",
    "atyp": "simple",
    "cdat": "timedate",
    "crtr": "uint32",
    "cusi": "sint32",
    "desc": "blob", 
    "gena": "blob",
    "icmt": "blob",
    "invi": "sint32",
    "mdat": "timedate",
    "nega": "sint32",
    "path": "blob",
    "port": "uint32",
    "prot": "blob",
    "ptcl": "blob",
    "scrp": "sint32",
    "sdmn": "blob",
    "srvr": "blob", 
    "svce": "blob",
    "type": "blob",
    "data": "simple",
    "kchn": "simple",
    "clss": "simple"
}

def clean(field, match):
    value = match.group(field)
    if not value or value == "<NULL>":
        # print null values as empty strings
        return ""
    if field2type[field] == "blob":
        # strip " at beginning and end
        return value[1:-1]
    elif field2type[field] == "timedate":
        # convert timedate to the iso standard
        value = value[1:-1]
        return value[0:4] + "-" + value[4:6] + "-" + value[6:8] + "T" + \
            value[8:10] + ":" + value[10:12] + ":" + value[12:14] + "Z" + value[16:19]
    elif field2type[field] == "uint32":
        # if it really is a hex int, convert it to decimal
        value = value.strip()
        if re.match("^0x[0-9a-fA-F]+$", value):
            return int(value, 16)
        else:
            return value
    else:
        # do nothing, just print it as it is
        return value

def print_help():
    print "Usage: python keychain.py INPUTFILE OUTPUTFILE"
    print "Example: python keychain.py keychain.txt keychain.xls"
    print "  where keychain.txt was created by `security dump-keychain -d > keychain.txt`"
    print "  When dumping the keychain, you have to click 'Allow' for each entry in your"
    print "  keychain. Position you mouse over the button and go clicking like crazy."




print "Keychain 0.1: convert an Apple Keychain dump to an Excel (XLS) spreadsheet."

# Check for correct parameters
if len(sys.argv) != 3:
    print_help()
    sys.exit(1)
elif len(sys.argv) == 3:
    if not os.path.isfile(sys.argv[1]):
        print "Error: no such file '{0}'".format(sys.argv[1])
        print_help()
        exit(1)

# Read keychain file
buffer = open(sys.argv[1], "r").read()
print "Read {0} bytes from '{1}'".format(len(buffer), sys.argv[1])

# Create excel workbook and header
wb = xlwt.Workbook()
ws = wb.add_sheet("Keychain")
ws.write(0, 0, "Name")
ws.write(0, 1, "Account")
ws.write(0, 2, "Password")
ws.write(0, 3, "Protocol")
ws.write(0, 4, "Server")
ws.write(0, 5, "Port")
ws.write(0, 6, "Path")
ws.write(0, 7, "Description")
ws.write(0, 8, "Created")
ws.write(0, 9, "Modified")
ws.write(0, 10, "AuthName")
ws.write(0, 11, "AccountType")
ws.write(0, 12, "Type")
ws.write(0, 13, "Keychain")

# Find passwords and add them to the excel spreadsheet
i = 1
for match in regex.finditer(buffer):
    ws.write(i, 0, clean("name", match))
    ws.write(i, 1, clean("acct", match))
    ws.write(i, 2, clean("data", match))
    ws.write(i, 3, clean("ptcl", match))
    ws.write(i, 4, clean("srvr", match))
    ws.write(i, 5, clean("port", match))
    ws.write(i, 6, clean("path", match))
    ws.write(i, 7, clean("desc", match))
    ws.write(i, 8, clean("cdat", match))
    ws.write(i, 9, clean("mdat", match))
    ws.write(i, 10, clean("sdmn", match))
    ws.write(i, 11, clean("atyp", match))
    ws.write(i, 12, clean("clss", match))
    ws.write(i, 13, clean("kchn", match))
    i += 1
wb.save(sys.argv[2])

print "Saved {0} passwords to '{1}'".format(i-1, sys.argv[2])
```

### Modified Python to export to csv using Pandas

And here is a modified version of the above python script to create a csv file for Firefox import. 
On MacOs it needs a `pip install pandas` before running.

```python
#!/usr/bin/env python

import sys
import os
import re
import csv

import pandas as pd
#from time
import datetime


# Regex to match both generic and internet passwords from a keychain dump
regex = re.compile(
    r"""
    keychain:\s"(?P<kchn>[^"]+)"\n                  # absolute path and file of keychain
    version:\s(\d\d\d)\n                            # version
    class:\s"(?P<clss>(genp|inet))"\n               # generic password or internet password
    attributes:\n
    (\s*?0x00000007\s<blob>=(?P<name>[^\n]+)\n)?    # name
    (\s*?0x00000008\s<blob>=(?P<hex8>[^\n]+)\n)?    # ? only used at certificates
    (\s*?"acct"<blob>=(?P<acct>[^\n]+)\n)?          # account
    (\s*?"atyp"<blob>=(?P<atyp>[^\n]+)\n)?          # account type ("form"), sometimes int
    (\s*?"cdat"<timedate>=[^"]*(?P<cdat>[^\n]+)\n)? # datetime created
    (\s*?"crtr"<uint32>=(?P<crtr>[^\n]+)\n)?        # vendor key with four chars like "aapl"
    (\s*?"cusi"<sint32>=(?P<cusi>[^\n]+)\n)?        # ? always null
    (\s*?"desc"<blob>=(?P<desc>[^\n]+)\n)?          # description
    (\s*?"gena"<blob>=(?P<gena>[^\n]+)\n)?          # ? always null except one rare cases
    (\s*?"icmt"<blob>=(?P<icmt>[^\n]+)\n)?          # ? some sort of description
    (\s*?"invi"<sint32>=(?P<invi>[^\n]+)\n)?        # ? always null
    (\s*?"mdat"<timedate>=[^"]*(?P<mdat>[^\n]+)\n)? # datetime last modified
    (\s*?"nega"<sint32>=(?P<nega>[^\n]+)\n)?        # ? always null
    (\s*?"path"<blob>=(?P<path>[^\n]+)\n)?          # path
    (\s*?"port"<uint32>=(?P<port>[^\n]+)\n)?        # port number in hex
    (\s*?"prot"<blob>=(?P<prot>[^\n]+)\n)?          # ? always null
    (\s*?"ptcl"<uint32>=(?P<ptcl>[^\n]+)\n)?        # protocol but is blob ("http", "https")
    (\s*?"scrp"<sint32>=(?P<scrp>[^\n]+)\n)?        # ? always null except one rare cases
    (\s*?"sdmn"<blob>=(?P<sdmn>[^\n]+)\n)?          # used for htaccess AuthName
    (\s*?"srvr"<blob>=(?P<srvr>[^\n]+)\n)?          # server
    (\s*?"svce"<blob>=(?P<svce>[^\n]+)\n)?          # ? some sort of description
    (\s*?"type"<uint32>=(?P<type>[^\n]+)\n)?        # some blob: "iprf", "note"
    data:\n
    "(?P<data>.*)"                               # password
    """, re.MULTILINE | re.VERBOSE)

# Dictionary used by the clean function (Apple is not always right about the
# types of the field)
field2type = { 
    "name": "blob",
    "hex8": "blob",
    "acct": "blob",
    "atyp": "simple",
    "cdat": "timedate",
    "crtr": "uint32",
    "cusi": "sint32",
    "desc": "blob", 
    "gena": "blob",
    "icmt": "blob",
    "invi": "sint32",
    "mdat": "timedate",
    "nega": "sint32",
    "path": "blob",
    "port": "uint32",
    "prot": "blob",
    "ptcl": "blob",
    "scrp": "sint32",
    "sdmn": "blob",
    "srvr": "blob", 
    "svce": "blob",
    "type": "blob",
    "data": "simple",
    "kchn": "simple",
    "clss": "simple"
}

def clean(field, match):
    value = match.group(field)
    if not value or value == "<NULL>":
        # print null values as empty strings
        return ""
    if field2type[field] == "blob":
        # strip " at beginning and end
        return value[1:-1]
    elif field2type[field] == "timedate":
        # convert timedate to the iso standard
        value = value[1:-1]
        return value[0:4] + "-" + value[4:6] + "-" + value[6:8] + "T" + \
            value[8:10] + ":" + value[10:12] + ":" + value[12:14] + "Z" + value[16:19]
    elif field2type[field] == "uint32":
        # if it really is a hex int, convert it to decimal
        value = value.strip()
        if re.match("^0x[0-9a-fA-F]+$", value):
            return int(value, 16)
        else:
            return value
    else:
        # do nothing, just print it as it is
        return value

def print_help():
    print "Usage: python keychain4ff.py INPUTFILE OUTPUTFILE"
    print "Example: python keychain.py keychain.txt keychain.xls"
    print "  where keychain.txt was created by `security dump-keychain -d > keychain.txt`"
    print "  When dumping the keychain, you have to click 'Allow' for each entry in your"
    print "  keychain. Position you mouse over the button and go clicking like crazy."



print "Keychain 0.1: convert an Apple Keychain dump to a .csv for Firefox import ."

# Check for correct parameters
if len(sys.argv) != 3:
    print_help()
    sys.exit(1)
elif len(sys.argv) == 3:
    if not os.path.isfile(sys.argv[1]):
        print "Error: no such file '{0}'".format(sys.argv[1])
        print_help()
        exit(1)

# Read keychain file
buffer = open(sys.argv[1], "r").read()
print "Read {0} bytes from '{1}'".format(len(buffer), sys.argv[1])


df = pd.DataFrame( columns = ["url", "username", "password", "httpRealm", "formActionOrigin", "guid", "timeCreated", "timeLastUsed", "timePasswordChanged", ])

# Find passwords and add them to the Data Frame
i = 0
for match in regex.finditer(buffer):
    url = clean("ptcl", match)
    if len(url):
        if url == 'htps':
            url = 'https'
        elif url == 'http':
            pass
        else:
            continue
            
        datstr = clean("cdat", match)
        mo = re.match(r"(\d\d\d\d)-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)Z000", datstr)
        if mo:
            dstr = mo.group(1)+" "+mo.group(2)+" "+mo.group(3)+" "+mo.group(4)+" "+mo.group(5)+" "+mo.group(6)
            epoch = int( (datetime.datetime(int(mo.group(1)), int(mo.group(2)), int(mo.group(3)), int(mo.group(4)), int(mo.group(5)), int(mo.group(6))) - datetime.datetime(1970,1,1) ).total_seconds())
            
        record = {"url": url + "://"+ clean("srvr", match),
                  "username" : clean("acct", match),
                  "password" : clean("data", match),
                  "httpRealm": "",
                  "formActionOrigin": url + "://"+ clean("srvr", match), 
                  "guid": "",
                  "timeCreated":         epoch,
                  "timeLastUsed":        epoch,
                  "timePasswordChanged": epoch,
        }
        df = df.append(record, ignore_index=True)
        i += 1
df.to_csv(sys.argv[2], index=False, quotechar='"', quoting=csv.QUOTE_ALL, escapechar="\\")

print "Saved {0} passwords to '{1}'".format(i-1, sys.argv[2])
```

## Solution #3

I wrote a python script that converts the keychain dump to an Excel file and thought I share it with you. I choose Excel over CSV or TSV because a lot of people have it installed and it just works by double clicking on the file. You may of course modify the script to print any other format. I did this on OS X 10.11 El Capitan, but should work on older OS' as well.

1.  Since I do not like storing my passwords plaintext on my hard drive, I created an encrypted container using the Disk Utility app. Simply open Disk Utility (press cmd+Space, type "disk"). In the app, press cmd+N for new image, change the name to SEC, change encryption to 256-Bit AES and save it under SEC in a directory of you choice. Then mount the volume by doubleclicking on the file (or using Disk Utility).
    
2.  Create a new file named keychain.py in the secure container and paste the code below.
    
3.  Now open Terminal.app and change directory to the mounted encrypted volume: `cd /Volumes/SEC`
    
4.  We need the python package manager for installing the Excel module (you will be prompted for your password): `sudo easy_install pip`
    
5.  We need to install the Python Excel module: `sudo pip install xlwt`
    
6.  Now export the passwords using one of the other answers to this question. I just did `security dump-keychain -d > keychain.txt` and spam clicked on the Allow button while holding the mouse with my other hand.
    
7.  The last step is to convert the txt file to a readable Excel sheet using the python script: `python keychain.py keychain.txt keychain.xls`
    

.

```
#!/usr/bin/env python

import sys
import os
import re
import xlwt

# Regex to match both generic and internet passwords from a keychain dump
regex = re.compile(
    r"""
    keychain:\s"(?P<kchn>[^"]+)"\n                  # absolute path and file of keychain
    version:\s(\d\d\d)\n                            # version
    class:\s"(?P<clss>(genp|inet))"\n               # generic password or internet password
    attributes:\n
    (\s*?0x00000007\s<blob>=(?P<name>[^\n]+)\n)?    # name
    (\s*?0x00000008\s<blob>=(?P<hex8>[^\n]+)\n)?    # ? only used at certificates
    (\s*?"acct"<blob>=(?P<acct>[^\n]+)\n)?          # account
    (\s*?"atyp"<blob>=(?P<atyp>[^\n]+)\n)?          # account type ("form"), sometimes int
    (\s*?"cdat"<timedate>=[^"]*(?P<cdat>[^\n]+)\n)? # datetime created
    (\s*?"crtr"<uint32>=(?P<crtr>[^\n]+)\n)?        # vendor key with four chars like "aapl"
    (\s*?"cusi"<sint32>=(?P<cusi>[^\n]+)\n)?        # ? always null
    (\s*?"desc"<blob>=(?P<desc>[^\n]+)\n)?          # description
    (\s*?"gena"<blob>=(?P<gena>[^\n]+)\n)?          # ? always null except one rare cases
    (\s*?"icmt"<blob>=(?P<icmt>[^\n]+)\n)?          # ? some sort of description
    (\s*?"invi"<sint32>=(?P<invi>[^\n]+)\n)?        # ? always null
    (\s*?"mdat"<timedate>=[^"]*(?P<mdat>[^\n]+)\n)? # datetime last modified
    (\s*?"nega"<sint32>=(?P<nega>[^\n]+)\n)?        # ? always null
    (\s*?"path"<blob>=(?P<path>[^\n]+)\n)?          # path
    (\s*?"port"<uint32>=(?P<port>[^\n]+)\n)?        # port number in hex
    (\s*?"prot"<blob>=(?P<prot>[^\n]+)\n)?          # ? always null
    (\s*?"ptcl"<uint32>=(?P<ptcl>[^\n]+)\n)?        # protocol but is blob ("http", "https")
    (\s*?"scrp"<sint32>=(?P<scrp>[^\n]+)\n)?        # ? always null except one rare cases
    (\s*?"sdmn"<blob>=(?P<sdmn>[^\n]+)\n)?          # used for htaccess AuthName
    (\s*?"srvr"<blob>=(?P<srvr>[^\n]+)\n)?          # server
    (\s*?"svce"<blob>=(?P<svce>[^\n]+)\n)?          # ? some sort of description
    (\s*?"type"<uint32>=(?P<type>[^\n]+)\n)?        # some blob: "iprf", "note"
    data:\n
    "(?P<data>[^"]*)"                               # password
    """, re.MULTILINE | re.VERBOSE)

# Dictionary used by the clean function (Apple is not always right about the
# types of the field)
field2type = { 
    "name": "blob",
    "hex8": "blob",
    "acct": "blob",
    "atyp": "simple",
    "cdat": "timedate",
    "crtr": "uint32",
    "cusi": "sint32",
    "desc": "blob", 
    "gena": "blob",
    "icmt": "blob",
    "invi": "sint32",
    "mdat": "timedate",
    "nega": "sint32",
    "path": "blob",
    "port": "uint32",
    "prot": "blob",
    "ptcl": "blob",
    "scrp": "sint32",
    "sdmn": "blob",
    "srvr": "blob", 
    "svce": "blob",
    "type": "blob",
    "data": "simple",
    "kchn": "simple",
    "clss": "simple"
}

def clean(field, match):
    value = match.group(field)
    if not value or value == "<NULL>":
        # print null values as empty strings
        return ""
    if field2type[field] == "blob":
        # strip " at beginning and end
        return value[1:-1]
    elif field2type[field] == "timedate":
        # convert timedate to the iso standard
        value = value[1:-1]
        return value[0:4] + "-" + value[4:6] + "-" + value[6:8] + "T" + \
            value[8:10] + ":" + value[10:12] + ":" + value[12:14] + "Z" + value[16:19]
    elif field2type[field] == "uint32":
        # if it really is a hex int, convert it to decimal
        value = value.strip()
        if re.match("^0x[0-9a-fA-F]+$", value):
            return int(value, 16)
        else:
            return value
    else:
        # do nothing, just print it as it is
        return value

def print_help():
    print "Usage: python keychain.py INPUTFILE OUTPUTFILE"
    print "Example: python keychain.py keychain.txt keychain.xls"
    print "  where keychain.txt was created by `security dump-keychain -d > keychain.txt`"
    print "  When dumping the keychain, you have to click 'Allow' for each entry in your"
    print "  keychain. Position you mouse over the button and go clicking like crazy."




print "Keychain 0.1: convert an Apple Keychain dump to an Excel (XLS) spreadsheet."

# Check for correct parameters
if len(sys.argv) != 3:
    print_help()
    sys.exit(1)
elif len(sys.argv) == 3:
    if not os.path.isfile(sys.argv[1]):
        print "Error: no such file '{0}'".format(sys.argv[1])
        print_help()
        exit(1)

# Read keychain file
buffer = open(sys.argv[1], "r").read()
print "Read {0} bytes from '{1}'".format(len(buffer), sys.argv[1])

# Create excel workbook and header
wb = xlwt.Workbook()
ws = wb.add_sheet("Keychain")
ws.write(0, 0, "Name")
ws.write(0, 1, "Account")
ws.write(0, 2, "Password")
ws.write(0, 3, "Protocol")
ws.write(0, 4, "Server")
ws.write(0, 5, "Port")
ws.write(0, 6, "Path")
ws.write(0, 7, "Description")
ws.write(0, 8, "Created")
ws.write(0, 9, "Modified")
ws.write(0, 10, "AuthName")
ws.write(0, 11, "AccountType")
ws.write(0, 12, "Type")
ws.write(0, 13, "Keychain")

# Find passwords and add them to the excel spreadsheet
i = 1
for match in regex.finditer(buffer):
    ws.write(i, 0, clean("name", match))
    ws.write(i, 1, clean("acct", match))
    ws.write(i, 2, clean("data", match))
    ws.write(i, 3, clean("ptcl", match))
    ws.write(i, 4, clean("srvr", match))
    ws.write(i, 5, clean("port", match))
    ws.write(i, 6, clean("path", match))
    ws.write(i, 7, clean("desc", match))
    ws.write(i, 8, clean("cdat", match))
    ws.write(i, 9, clean("mdat", match))
    ws.write(i, 10, clean("sdmn", match))
    ws.write(i, 11, clean("atyp", match))
    ws.write(i, 12, clean("clss", match))
    ws.write(i, 13, clean("kchn", match))
    i += 1
wb.save(sys.argv[2])

print "Saved {0} passwords to '{1}'".format(i-1, sys.argv[2])
```

### Autoaccept method

As of OSX 10.10.3 there is a new way do auto-accept (I ran into issues during an upgrade path)

Bash functions (added to either `.profile` or `.bash_rc` files)

```
## At the terminal when you start getting the prompts, type `Accepts` and press enter
function Accepts () {
osascript <<EOF
  tell application "System Events"
    repeat while exists (processes where name is "SecurityAgent")
      tell process "SecurityAgent" to click button "Allow" of window 1
      delay 0.2
    end repeat
  end tell
EOF
}

## At the terminal when you start getting the prompts, type `Accepts YourUsername YourPassword` and press enter
function AcceptWithCreds () {
username="$1"
password="$2"

[ -z "${password}" ] && return 1

osascript 2>/dev/null <<EOF
    set appName to "${username}"
    set appPass to "${password}"
    tell application "System Events"
        repeat while exists (processes where name is "SecurityAgent")
            tell process "SecurityAgent"
                if exists (text field 1 of window 1) then
                    set value of text field 1 of window 1 to appName
                    set value of text field 2 of window 1 to appPass
                end if
            end tell
      tell process "SecurityAgent" to click button "Allow" of window 1
            delay 0.2
        end repeat
    end tell
EOF
echo 'Finished...'
}
```

And use this script to dump your keyring (`sudo ./dump.sh`)

```
#!/bin/bash
# Run above script in another window

security dump-keychain -d login.keychain > keychain-login.txt
security dump-keychain -d /Library/Keychains/System.keychain > keychain-system.txt
```


## Reference

- https://apple.stackexchange.com/questions/137250/export-keychains
