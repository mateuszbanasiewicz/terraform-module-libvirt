provider "libvirt" {
  uri = "qemu:///system"
}

locals {
  network_name        = format("tf--%s_%s", var.project_name, replace(replace(var.network_cidr, ".", "-"), "/","--"))
  network_bridge      = format("tf--%s", var.project_name)
  network_domain      = format("%s.%s", var.project_name, var.domain)
  pool_name           = format("tf--%s", var.project_name)
  pool_path           = format("/var/lib/libvirt/images/%s", var.project_name)
  volume_source_path  = format("/var/lib/libvirt/template/%s", var.base_image)
}

resource "libvirt_network" "network" {
  name      = local.network_name
  autostart = true
  mode      = "route"
  bridge    = local.network_bridge
  domain    = local.network_domain
  addresses = [var.network_cidr]
  dns {
    enabled = true
    forwarders {
      address = "8.8.8.8"
    }
    hosts {
      hostname = format("xeon.%s.%s", var.project_name, var.domain)
      ip = "192.168.1.199"
    }
  }
  dhcp {
    enabled = true
  }
}

data "template_file" "cloudinit_cfg_file" {
  for_each  = var.vms
  template = file("${path.module}/cloud-init/config.cfg")
  vars = {
    hostname = format("%s.%s.%s", each.key, var.project_name, var.domain)
    fqdn = format("%s.%s.%s", each.key, var.project_name, var.domain)
  }
}

resource "libvirt_pool" "pool" {
  name = local.pool_name
  type = "dir"
  path = local.pool_path
}

resource "libvirt_cloudinit_disk" "cloudinit_disk" {
  for_each       = var.vms
  name           = format("tf--%s_%s-seed.iso", var.project_name, each.key)
  user_data      = data.template_file.cloudinit_cfg_file[each.key].rendered
  pool           = libvirt_pool.pool.name
}

resource "libvirt_volume" "volume" {
  for_each   = var.vms
  name       = format("tf--%s_%s-boot.gcow2", var.project_name, each.key)
  pool       = libvirt_pool.pool.name
  source     = local.volume_source_path
  format     = "qcow2"
}

resource "libvirt_domain" "domain_master" {
  for_each  = var.vms
  name      = format("tf--%s_%s_ip_%s", var.project_name, each.key, replace(each.value.IPaddresses[0], ".", "-"))
  memory    = each.value.memory
  vcpu      = each.value.cpu

  cloudinit = libvirt_cloudinit_disk.cloudinit_disk[each.key].id

  network_interface {
    network_id     = libvirt_network.network.id
    addresses      = each.value.IPaddresses
    hostname       = format("%s.%s.%s", each.key, var.project_name, var.domain)
  }

  disk {
    volume_id = libvirt_volume.volume[each.key].id
    scsi      = "true"
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
  graphics {
    type        = "vnc"
  }
}

terraform {
  required_version = ">= 0.12"
}
