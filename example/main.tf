module "k8s" {
  source = "../"

  network_cidr    = "10.12.12.0/24"
  project_name    = "k8s"
  base_image      = "rhel-8.5-x86_64-kvm-50g.qcow2"
  domain          = "edu.local"

  ansible_variables = {
    "bbb" = "siema"
  }

  vms = {
    master = {
      cpu    = 4,
      memory = 10240,
      IPaddresses = ["10.12.12.100"]
      ansible_variables = {
        "aaa" = false
      }
      ansible_groups = ["kube_control_plane", "etcd"]
    }
    node01 = { 
      cpu    = 4,
      memory = 10240,
      IPaddresses = ["10.12.12.101"]
      ansible_variables = {}
      ansible_groups = ["kube_node"]
    }
    node02 = {
      cpu    = 4,
      memory = 10240,
      IPaddresses = ["10.12.12.102"]
      ansible_variables = {}
      ansible_groups = ["kube_node"]
    }
  }
}
