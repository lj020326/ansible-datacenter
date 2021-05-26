# VDC-API-examples-Python

Example Python programs for basic interaction with the [Interoute Virtual Data Centre](https://cloudstore.interoute.com/what_is_vdc) API. These all make use of the class 'VDCApiCall' which is defined in [vdc_api_call.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/vdc_api_call.py).

For introduction to using the API, see [Introduction to the VDC API](https://cloudstore.interoute.com/knowledge-centre/library/vdc-api-introduction-api).

See the other repo [Interoute/API-fun-and-education](https://github.com/Interoute/API-fun-and-education) for API programming and application examples.


## List of programs

[vdc_api_call.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/vdc_api_call.py): Base Python class VDCApiCall for working with the Interoute Virtual Data Centre API

[disk_offering_get_all.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/disk_offering_get_all.py): Get a list of the available disk offerings

[iso_get_by_zone.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/iso_get_by_zone.py): List available ISOs to create a virtual machine, in a specified zone

[networks_get_by_zone.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/networks_get_by_zone.py): List available networks in a specified zone

[service_offering_get_all.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/service_offering_get_all.py): List all the available service offerings (CPU and RAM) for a virtual machine

[template_get_by_zone.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/template_get_by_zone.py): List available templates to create a virtual machine, in a specified zone

[vm_changeserviceoffering.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/vm_changeserviceoffering.py): Change the service offering (CPU and RAM) of a stopped virtual machine

[vm_deploy.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/vm_deploy.py): Deploy a virtual machine

[vm_destroy.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/vm_destroy.py): Destroy a virtual machine

[vm_get_one.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/vm_get_one.py): Get status and properties information about one virtual machine

[vm_reboot.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/vm_reboot.py): Reboot (stop and start) a virtual machine

[vm_resetpassword.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/vm_resetpassword.py): Reset the administrator/root user password for a virtual machine

[vm_scale.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/vm_scale.py): Scale the service offering (CPU and RAM) of a virtual machine

[vm_start.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/vm_start.py): Start a virtual machine from a stopped state

[vm_stop.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/vm_stop.py): Stop a virtual machine from a running state

[zone_get_all.py](https://github.com/Interoute/VDC-API-examples-Python/blob/master/zone_get_all.py): List the available zones

