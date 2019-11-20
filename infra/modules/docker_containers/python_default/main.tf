locals {
  container_count = 4
  python_container = {
    image_repo = "devopsexchange"
    image_name = "python-default"
    image_tag  = "latest"
    port_map = {
      5000 = "5000"
    }
    env = [
      "METRICS_HOSTNAME=${var.metrics_hostname}",
      "ENV_NAME=${var.env_name}",
    ]
    command = ["./app.py"]
  }
  siege_container = {
    image_repo     = "devopsexchange"
    image_name     = "siege"
    image_tag      = "latest"
    command_prefix = ["-d", "1", "-c", "2"]
  }
}

resource "random_shuffle" "sex" {
  input = ["MALE", "FEMALE", "OTHER"]
  result_count = local.container_count
}

module "python_default_containers" {
  source                = "../../docker_container"
  container_count       = random_shuffle.sex.result_count
  container_name_prefix = local.python_container.image_name
  image_name            = local.python_container.image_name
  image_repository      = local.python_container.image_repo
  image_tag             = local.python_container.image_tag
  port_map              = local.python_container.port_map
  container_envs        = [for i in range(random_shuffle.sex.result_count) :
    concat(
      ["SEX=${random_shuffle.sex.result[i]}"],
      local.python_container.env
    )
  ]
  container_command     = local.python_container.command
  network_name          = var.network_name
}

module "siege_python_default_containers" {
  source                = "../../docker_container"
  container_count       = length(module.python_default_containers.container_names)
  container_name_prefix = local.siege_container.image_name
  image_name            = local.siege_container.image_name
  image_repository      = local.siege_container.image_repo
  image_tag             = local.siege_container.image_tag
  container_commands = [for pyname in module.python_default_containers.container_names :
    concat(local.siege_container.command_prefix,
      [
        format("http://%s:%s/config",
          pyname,
          "5000"
        )
    ])
  ]
  network_name = var.network_name
}

output "container_names" {
  value = concat(module.python_default_containers.container_names,
  module.siege_python_default_containers.container_names)
}

