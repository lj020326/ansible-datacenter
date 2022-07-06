
# vSphere ESXi 7.0 U3 VPXA configuration properties (87438)

## Details

In previous releases (before ESXi 7.0U3) you may be instructed by other KB article(s) to change some settings of ESXi service "vpxa" by directly editing its configuration file (/etc/vmware/vpxa/vpxa.cfg) manually and restarting the "vpxa" service.  
  
Since 7.0 U3 the service configuration settings are not stored in this file (/etc/vmware/vpxa/vpxa.xml), but in a special configuration store database.  
  
The settings in the database are accessible by a tool: **/bin/configstorecli**

## Solution

To make any changes for vpxa configuration, this can be performed on four steps:

1.  Export current vpxa database configuration on a json file.
2.  Make the changes needed on the json file.
3.  Import the changed from the json file to the VPXA database.
4.  Restart vpxa service.

**Steps to configure the settings :   
Note:** To run the below commands, please login to the ESXi Host (CLI) through SSH using root account. For more information, see [Using ESXi Shell in ESXi 5.x, 6.x and 7.x (2004746)](https://kb.vmware.com/s/article/2004746)

1.   To display the current settings in the configuration file.

```shell
# /bin/configstorecli config current get -c esx -g services -k vpxa
```

2.  To export the current settings on a json file (the file will be exported on the same directory you are running the command from).

```shell
# /bin/configstorecli config current get -c esx -g services -k vpxa -outfile tmp.json
```

3.  Navigate to the root directory.

4.  Backup the current configuration:

```shell
# cp tmp.json tmp.json.bak 
```

5.  Using text editor, apply the needed changes on the tmp.json file, save the changes and exit. For more information, see [Editing files on an ESXi host using vi (1020302)](https://kb.vmware.com/s/article/1020302)

6.  Run the command to apply the file to the database.

# /bin/configstorecli config current set -c esx -g services -k vpxa -infile tmp.json  
The output should look like the below:  
Set: completed successfully

7.  Restart vpxa service.

```shell
# /etc/init.d/vpxa restart
```

**Notes**:

-   To see all possible vpxa configuration properties, run the command:

```shell
# /bin/configstorecli schema get -c esx -g services -k vpxa 
```

-   An **update** can be applied on the vpxa database if a single property needs to be changed.

```shell
# /bin/configstorecli config current update -c esx -g services -k vpxa -infile tmp.json
```

tmp.json file can contain only the property needs to be modified on the vpxa configuration database.  
Example for a tmp.json file of single property:  

```json
 # cat tmp.json  
 {  
    "some\_sub\_object": {  
       "some\_property": "some\_value"  
    }  
 }
```

**The vpxa configuration database stores the default vpxa settings (on the ESXi Installation). These settings can be restored using the below steps:**  
 

1.  To display the **default** settings (vpxa state on ESXi installation) in the configuration file.

```shell
# /bin/configstorecli config default get -c esx -g services -k vpxa
```

2.  To export the **default** settings on a json file (the file will be exported on the same directory you are running the command from).

```shell
# /bin/configstorecli config default get -c esx -g services -k vpxa -outfile tmp.json
```

3.  Using text editor, apply the needed changes on the tmp.json file, save the changes and exit.  For more information, see [Editing files on an ESXi host using vi (1020302)](https://kb.vmware.com/s/article/1020302)
4.  Run the command below to apply the file configuration (**default**) on the database.

# /bin/configstorecli config current set -c esx -g services -k vpxa -infile tmp.json

5.  Restart vpxa service.


```shell
# /etc/init.d/vpxa restart

```

## Reference

* https://kb.vmware.com/s/article/87438
