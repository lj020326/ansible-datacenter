#!/usr/bin/env python
# coding=utf-8
#
# Copyright © 2015 VMware, Inc. All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
# to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

__author__ = 'yasensim'

import requests
import ssl
import time
from pyVim.connect import SmartConnect
from pyVmomi import vim, vmodl

try: # Try block handles behaviour change in 3.7 on ssl cert error
    ssl_cert_error = ssl.SSLCertVerificationError
except:
    ssl_cert_error = ssl.SSLError

def find_virtual_machine(content, searched_vm_name):
    virtual_machines = get_all_objs(content, [vim.VirtualMachine])
    for vm in virtual_machines:
        if vm.name == searched_vm_name:
            return vm
    return None

def get_all_objs(content, vimtype):
    obj = {}
    container = content.viewManager.CreateContainerView(content.rootFolder, vimtype, True)
    for managed_object_ref in container.view:
        obj.update({managed_object_ref: managed_object_ref.name})
    return obj

def connect_to_api(vchost, vc_user, vc_pwd):
    global service_instance
    try:
        service_instance = SmartConnect(host=vchost, user=vc_user, pwd=vc_pwd)
    except (requests.ConnectionError, ssl.SSLError, ssl_cert_error):    
        context = ssl.SSLContext(ssl.PROTOCOL_SSLv23)
        context.verify_mode = ssl.CERT_NONE
        service_instance = SmartConnect(host=vchost, user=vc_user, pwd=vc_pwd, sslContext=context)
    return service_instance.RetrieveContent()

def add_scsi_controller(esxi_version):
    # sharedBus = vim.vm.device.VirtualSCSIController.Sharing.noSharing
    if esxi_version >= 7.0:
        device = vim.vm.device.ParaVirtualSCSIController(sharedBus=vim.vm.device.VirtualSCSIController.Sharing.noSharing)
    else:
        device = vim.vm.device.VirtualLsiLogicSASController(sharedBus=vim.vm.device.VirtualSCSIController.Sharing.noSharing)
    virtual_scsi_spec = vim.vm.device.VirtualDeviceSpec()
    virtual_scsi_spec.device = device
    virtual_scsi_spec.operation = "add"
    return virtual_scsi_spec

def create_virtual_disk(capacity, controller_key, unit_number, in_bytes=False):
    virtual_disk = vim.vm.device.VirtualDisk()
    if in_bytes:
        virtual_disk.capacityInBytes = capacity
    else:
        virtual_disk.capacityInKB = capacity
    virtual_disk.unitNumber = unit_number
    virtual_disk.controllerKey = controller_key
    virtual_disk_backing_info = vim.vm.device.VirtualDisk.FlatVer2BackingInfo()
    virtual_disk_backing_info.diskMode = "persistent"
    virtual_disk_backing_info.thinProvisioned = True
    virtual_disk.backing = virtual_disk_backing_info
    virtual_disk_spec = vim.vm.device.VirtualDeviceSpec()
    virtual_disk_spec.device = virtual_disk
    virtual_disk_spec.fileOperation = "create"
    virtual_disk_spec.operation = "add"
    return virtual_disk_spec

def create_nic(content, portGroup):
    nic_spec = vim.vm.device.VirtualDeviceSpec()
    nic_spec.operation = vim.vm.device.VirtualDeviceSpec.Operation.add
    nic_spec.device = vim.vm.device.VirtualE1000e()
    nic_spec.device.wakeOnLanEnabled = True
    nic_spec.device.deviceInfo = vim.Description()
    try:
        network = get_obj(content, [vim.dvs.DistributedVirtualPortgroup], portGroup)
        dvs_port_connection = vim.dvs.PortConnection()
        dvs_port_connection.portgroupKey = network.key
        dvs_port_connection.switchUuid = network.config.distributedVirtualSwitch.uuid
        nic_spec.device.backing = vim.vm.device.VirtualEthernetCard.DistributedVirtualPortBackingInfo()
        nic_spec.device.backing.port = dvs_port_connection
    except:
        nic_spec.device.backing = vim.vm.device.VirtualEthernetCard.NetworkBackingInfo()
        nic_spec.device.backing.network = get_obj(content, [vim.Network], portGroup)
        nic_spec.device.backing.deviceName = portGroup
    nic_spec.device.connectable = vim.vm.device.VirtualDevice.ConnectInfo()
    nic_spec.device.connectable.startConnected = True
    nic_spec.device.connectable.allowGuestControl = True
    nic_spec.device.connectable.connected = True
    return nic_spec

def invoke_and_track(func, *args, **kw):
    try :
        task = func(*args, **kw)
    except:
        raise

def get_obj(content, vimtype, name):
    obj = None
    container = content.viewManager.CreateContainerView( content.rootFolder, vimtype, True)
    for c in container.view:
        if name:
            if c.name == name:
                obj = c
                break
        else:
            obj = c
            break
    return obj

def create_cd_rom(content, datastore, dataStorePath):
    cdspec = vim.vm.device.VirtualDeviceSpec()
    cdspec.operation = vim.vm.device.VirtualDeviceSpec.Operation.add
    cdspec.device = vim.vm.device.VirtualCdrom()
    cdspec.device.key = 3000
    cdspec.device.controllerKey = 200
    cdspec.device.unitNumber = 0
    cdspec.device.deviceInfo = vim.Description()
    cdspec.device.deviceInfo.label = 'CD/DVD drive 1'
    cdspec.device.deviceInfo.summary = 'ISO'
    cdspec.device.backing = vim.vm.device.VirtualCdrom.IsoBackingInfo()
    cdspec.device.backing.fileName = "[" + datastore + "] "+ dataStorePath
    datastore = get_obj(content=content, vimtype=[vim.Datastore], name=datastore)
    cdspec.device.backing.datastore = datastore
    cdspec.device.connectable = vim.vm.device.VirtualDevice.ConnectInfo()
    cdspec.device.connectable.startConnected = True
    cdspec.device.connectable.allowGuestControl = True
    cdspec.device.connectable.connected = False
    return cdspec

def wait_for_tasks(tasks):
    property_collector = service_instance.content.propertyCollector
    task_list = [str(task) for task in tasks]
    obj_specs = [vmodl.query.PropertyCollector.ObjectSpec(obj=task)
                 for task in tasks]
    property_spec = vmodl.query.PropertyCollector.PropertySpec(type=vim.Task,
                                                               pathSet=[],
                                                               all=True)
    filter_spec = vmodl.query.PropertyCollector.FilterSpec()
    filter_spec.objectSet = obj_specs
    filter_spec.propSet = [property_spec]
    pcfilter = property_collector.CreateFilter(filter_spec, True)
    try:
        version, state = None, None
        while len(task_list):
            update = property_collector.WaitForUpdates(version)
            for filter_set in update.filterSet:
                for obj_set in filter_set.objectSet:
                    task = obj_set.obj
                    for change in obj_set.changeSet:
                        if change.name == 'info':
                            state = change.val.state
                        elif change.name == 'info.state':
                            state = change.val
                        else:
                            continue

                        if not str(task) in task_list:
                            continue

                        if state == vim.TaskInfo.State.success:
                            task_list.remove(str(task))
                        elif state == vim.TaskInfo.State.error:
                            raise task.info.error
            version = update.version
    finally:
        if pcfilter:
            pcfilter.Destroy()

def create_vm(module, vmName, content, clusterName, datastore, vmnic_physical_portgroup_assignment, CPUs, memory, \
                                dataStorePath, disks, esxi_version):
    datacenter = content.rootFolder.childEntity[0]
    vmfolder = datacenter.vmFolder
    hosts = datacenter.hostFolder.childEntity
    cluster = get_obj(content, [vim.ClusterComputeResource], clusterName)
    resource_pool = cluster.resourcePool
    datastore_path = "[" + datastore + "]" + vmName
    vmx_file = vim.vm.FileInfo(logDirectory=None, snapshotDirectory=None, suspendDirectory=None, vmPathName=datastore_path)
    dev_changes = []

    scsi_spec = add_scsi_controller(esxi_version)
    dev_changes.append(scsi_spec)

    for idx, disk in enumerate(disks):
        if not isinstance(disk['size_gb'], int):
            module.fail_json(msg='Error adding disks to %s. Disk position %s size is not a valid integetr' % (vmName, str(idx)))
        new_disk_kb = 1024 * 1024 * disk['size_gb']
        disk_spec = create_virtual_disk(new_disk_kb, 0, idx, False)
        dev_changes.append(disk_spec)
        
    for vmnic in vmnic_physical_portgroup_assignment:
        #TODO check that the networks exist
        nic_spec = create_nic(content, vmnic)
        dev_changes.append(nic_spec)

    cdrom = create_cd_rom(content, datastore, dataStorePath)
    dev_changes.append(cdrom)

    memory_mb = memory * 1024
    config = vim.vm.ConfigSpec(
                              name=vmName,
                              memoryMB=memory_mb,
                              numCPUs=CPUs,
                              numCoresPerSocket=CPUs,
                              nestedHVEnabled=True,
                              files=vmx_file,
                              guestId='vmkernel6Guest',
                              version='vmx-11'
                            ) 
    config.deviceChange = dev_changes
    for idx in range(len(disks)):
        ssdOption = vim.option.OptionValue(key='scsi0:%s.virtualSSD' % idx,value='1')
        config.extraConfig  = [ssdOption]

    task = vmfolder.CreateVM_Task(config=config, pool=resource_pool)
    wait_for_tasks([task])
    vm = get_obj(content, [vim.VirtualMachine], vmName)
    invoke_and_track(vm.PowerOn, None)
    time.sleep(600)
    tools_status = vm.guest.toolsStatus
    if (tools_status == 'toolsNotInstalled' or tools_status == 'toolsNotRunning'):
        time.sleep(120)
    return 0


def main():

    module = AnsibleModule(
        argument_spec=dict(
            vmname=dict(required=True, type='str'),
            vcenter=dict(required=True, type='str'),
            vcenter_user=dict(required=True, type='str'),
            vcenter_passwd=dict(required=True, type='str', no_log=True),
            cluster=dict(required=True, type='str'),
            datastore=dict(required=True, type='str'),
            vmnic_physical_portgroup_assignment=dict(required=True, type='list'),
            cpucount=dict(required=True, type='int'),
            memory=dict(required=True, type='int'),
            isopath=dict(required=True, type='str'),
            disks=dict(required=True, type='list'),
            esxi_version=dict(required=False, type='str', default="6.7")
        ),
        supports_check_mode=True,
    )
    # Ensure that esxi_version can be converted to a float to support being passed in as an env var
    try:
        esxi_version = float(module.params['esxi_version'])
    except ValueError:
        module.fail_json(msg='Error evaluating ESXi version %s. Must be passed in as a float. E.g 6.7.' %  module.params['esxi_version'])
    try:
        content = connect_to_api(module.params['vcenter'], module.params['vcenter_user'],
                                 module.params['vcenter_passwd'])
    except vim.fault.InvalidLogin:
        module.fail_json(msg='exception while connecting to vCenter, login failure, check username and password')
    except (requests.exceptions.ConnectionError, OSError):
        module.fail_json(msg='exception while connecting to vCenter, check hostname, FQDN or IP')
    vm = find_virtual_machine(content, module.params['vmname'])
    if vm:
        module.exit_json(changed=False, msg='A VM with the name {} was already present'.format(module.params['vmname']), stat = '1')
        return 0
    if module.check_mode:
        module.exit_json(changed=True, debug_out="Test Debug out, Yasen !!!")
    result = create_vm(module, module.params['vmname'], content, module.params['cluster'], module.params['datastore'],
                                             module.params['vmnic_physical_portgroup_assignment'], module.params['cpucount'], module.params['memory'], 
                                             module.params['isopath'], module.params['disks'],  
                                             esxi_version) 
    if result != 0:
        module.fail_json(msg='Failed to deploy nested ESXi vm with name {}'.format(module.params['vmname']))
    module.exit_json(changed=True, result=module.params['vmname'] + " created")

from ansible.module_utils.basic import *

if __name__ == '__main__':
    main()
