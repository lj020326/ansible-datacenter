#### GLOBAL CONFIG DC AND HOST
# Define datacenter
data "vsphere_datacenter" "dc" {
  name = var.vcenter.datacenter
}

data "vsphere_resource_pool" "pool" {
  # If you haven't resource pool, put "Resources" after cluster name
  name          = "${var.vcenter.cluster}/"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve datastore information on vsphere
data "vsphere_datastore" "datastore" {
  for_each      = var.vms
  name          = each.value.disk_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve network information on vsphere
data "vsphere_network" "network" {
  for_each      = var.vms
  name          = each.value.network.vdsport
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve template information on vsphere
data "vsphere_virtual_machine" "template" {
  for_each      = var.vms
  name          = each.value.template_image
  datacenter_id = data.vsphere_datacenter.dc.id
}
