module "k8s" {
  source = "../"

  network_cidr    = "10.12.12.0/24"
  network_mask    = "24"
  network_gateway = "10.12.12.1"
  project_id      = "c1d"
  base_image      = "rhel-8.8-x86_64-kvm.qcow2"
  domain          = "edu.local"

  ansible_variables = {
    kube_version = "v1.26.3"
}

  vms = {
    master = {
      cpu    = 4,
      memory = 10240,
      IPaddresses = ["10.12.12.100"]
      ansible_variables = {}
      ansible_groups = ["kube_control_plane", "etcd", "k8s_cluster"]
    }
    node01 = { 
      cpu    = 4,
      memory = 10240,
      IPaddresses = ["10.12.12.101"]
      ansible_variables = {}
      ansible_groups = ["kube_node", "k8s_cluster"]
    }
    node02 = {
      cpu    = 4,
      memory = 10240,
      IPaddresses = ["10.12.12.102"]
      ansible_variables = {}
      ansible_groups = ["kube_node","k8s_cluster"]
    }
  }
}
