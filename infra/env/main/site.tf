locals {
  env_name = basename(abspath(path.module))
}

output "env_name" {
  value = local.env_name
}

module "docker_network" {
  source = "../../modules/docker_network"
}

module "metrics" {
  source       = "../../modules/docker_containers/metrics"
  network_name = module.docker_network.network_name
}

output "metrics_container_name" {
  value = module.metrics.container_name
}

output "docker_network_name" {
  value = module.docker_network.network_name
}


