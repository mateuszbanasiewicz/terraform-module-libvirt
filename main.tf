provider "libvirt" {
  uri = "qemu:///system"
}

locals {
  network_name        = format("tf--%s_%s", var.project_id, replace(replace(var.network_cidr, ".", "-"), "/","--"))
  network_bridge      = format("tf--%s", var.project_id)
  network_domain      = format("%s.%s", var.project_id, var.domain)
  pool_name           = format("tf--%s", var.project_id)
  pool_path           = format("/var/lib/libvirt/images/%s", var.project_id)
  volume_source_path  = format("/var/lib/libvirt/templates/%s", var.base_image)
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
      hostname = format("xeon.%s.%s", var.project_id, var.domain)
      ip = "192.168.1.58"
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
    hostname = format("%s.%s.%s", each.key, var.project_id, var.domain)
    fqdn = format("%s.%s.%s", each.key, var.project_id, var.domain)
    ip   = each.value.IPaddresses[0]
    mask = var.network_mask
    gw   = var.network_gateway
  }
}

resource "libvirt_pool" "pool" {
  name = local.pool_name
  type = "dir"
  path = local.pool_path
}

resource "libvirt_cloudinit_disk" "cloudinit_disk" {
  for_each       = var.vms
  name           = format("tf--%s_%s-seed.iso", var.project_id, each.key)
  user_data      = data.template_file.cloudinit_cfg_file[each.key].rendered
  pool           = libvirt_pool.pool.name
}

resource "libvirt_volume" "volume" {
  for_each   = var.vms
  name       = format("tf--%s_%s-boot.gcow2", var.project_id, each.key)
  pool       = libvirt_pool.pool.name
  source     = local.volume_source_path
  format     = "qcow2"
}

resource "libvirt_domain" "domain_master" {
  for_each  = var.vms
  name      = format("tf--%s_%s_ip_%s", var.project_id, each.key, replace(each.value.IPaddresses[0], ".", "-"))
  memory    = each.value.memory
  vcpu      = each.value.cpu

  cloudinit = libvirt_cloudinit_disk.cloudinit_disk[each.key].id

  network_interface {
    network_id     = libvirt_network.network.id
    addresses      = each.value.IPaddresses
    hostname       = format("%s.%s.%s", each.key, var.project_id, var.domain)
    mac            = format("52:54:%s:%s:%s:%s",format("%02x", tonumber(split(".", each.value.IPaddresses[0])[0])), format("%02x", tonumber(split(".", each.value.IPaddresses[0])[1])),format("%02x", tonumber(split(".", each.value.IPaddresses[0])[2])),format("%02x", tonumber(split(".", each.value.IPaddresses[0])[3])))
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

resource "null_resource" "redhat" {

  provisioner "local-exec" {
    command = "sleep 60; ansible -T 120 -i inv all -m redhat_subscription -a \"state=present  username=$RHU password=$RHP auto_attach=true\""
    on_failure = continue

  }

}


terraform {
  required_version = ">= 0.12"
}
