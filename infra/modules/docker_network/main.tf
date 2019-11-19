locals {
  network_name = "devopsexchange"
}

resource "docker_network" "this" {
  name       = local.network_name
  attachable = true
  internal   = false
  ipam_config {
    subnet  = "192.168.101.128/25"
    gateway = "192.168.101.129"
  }
}

output "network_name" {
  value = docker_network.this.name
}

output "network_id" {
  value = docker_network.this.id
}
