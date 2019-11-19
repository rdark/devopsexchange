locals {
  env_name = basename(abspath(path.module))
}

output "env_name" {
  value = local.env_name
}

module "python_default" {
  source           = "../../modules/docker_containers/python_default"
  network_name     = data.terraform_remote_state.main.outputs.docker_network_name
  metrics_hostname = data.terraform_remote_state.main.outputs.metrics_container_name
  env_name         = local.env_name
}

output "python_default_container_names" {
  value = module.python_default.container_names
}
