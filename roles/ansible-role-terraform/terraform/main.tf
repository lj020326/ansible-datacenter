

#########
# Create a VM from a Template
#########

provider "vsphere" {
  user           = var.vcenter.user
  password       = var.vcenter.password
  vsphere_server = var.vcenter.address

  # If you have a self-signed cert
  allow_unverified_ssl = var.allow_unverified_ssl
}


resource "vsphere_virtual_machine" "vms" {
  for_each                   = var.vms
  name                       = each.value.hostname
  num_cpus                   = each.value.vcpu
  memory                     = each.value.ram
  datastore_id               = data.vsphere_datastore.datastore[each.key].id
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  guest_id                   = data.vsphere_virtual_machine.template[each.key].guest_id
  scsi_type                  = data.vsphere_virtual_machine.template[each.key].scsi_type
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0


  # Configure network interface
  network_interface {
    network_id = data.vsphere_network.network[each.key].id
  }

  # Configure Disk
  disk {
    name = "${each.value.hostname}.vmdk"
    size = each.value.disk_size
  }

  # Define template and customisation params
  clone {
    template_uuid = data.vsphere_virtual_machine.template[each.key].id

    customize {
      linux_options {
        host_name = each.value.hostname
        domain    = each.value.network.domain
      }

      network_interface {
        ipv4_address = each.value.network.ipv4_address
        ipv4_netmask = each.value.network.prefix_length

      }
      dns_server_list = var.dns_servers
      ipv4_gateway    = each.value.network.gateway
    }
  }
}
