locals {
  container = {
    image_repo = "samuelebistoletti"
    image_name = "docker-statsd-influxdb-grafana"
    image_tag  = "latest"
    port_map = {
      3003 = "3003"
      3004 = "8888"
      8086 = "8086"
      8125 = "8125/udp"
    }
    ulimits = [{
      hard = 66000
      name = "nofile"
      soft = 66000
    }]
  }
}

module "metrics_container" {
  source                = "../../docker_container"
  container_name_prefix = "metrics"
  image_name            = local.container.image_name
  image_repository      = local.container.image_repo
  image_tag             = local.container.image_tag
  port_map              = local.container.port_map
  ulimits               = local.container.ulimits
  network_name          = var.network_name
}

output "container_name" {
  value = module.metrics_container.container_names[0]
}
