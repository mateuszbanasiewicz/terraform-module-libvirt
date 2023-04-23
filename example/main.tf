module "k8s" {
  source = "../"

  network_cidr    = "10.12.12.0/24"
  project_name    = "k8s"
  template        = "rhel-8.5-x86_64-kvm-50g.qcow2"
  domain          = "lab.local"

  vms = {
    master = {
      cpu    = 4,
      memory = 10240,
      IPaddresses = ["10.12.12.100"]
    }
    node01 = { 
      cpu    = 4,
      memory = 10240,
      IPaddresses = ["10.12.12.101"]
    }
    node02 = {
      cpu    = 4,
      memory = 10240,
      IPaddresses = ["10.12.12.102"]
    }
  }
}
