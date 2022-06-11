module "k8s" {
  source = "git@github.com:maban92/terrform-module-libvirt.git"

  network_cidr    = "10.12.12.0/24"
  project_name    = "k8s"
  template        = "rhel-8.5-x86_64-kvm-50g.qcow2"
  domain          = "lab.local"

  vms = {
    master = {
      cpu    = 4,
      memory = 2048,
      hostID = 10 
    }
    node01 = { 
      cpu    = 4,
      memory = 4096,
      hostID = 11
    }
    node02 = {
      cpu    = 4,
      memory = 4096,
      hostID = 12
    }
  }
}
