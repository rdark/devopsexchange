resource "docker_container" "this" {
  count    = var.container_count
  name     = "${var.container_name_prefix}-${count.index + 1}"
  image    = "${var.image_repository}/${var.image_name}:${var.image_tag}"
  env      = length(var.container_envs) >= 1 ? var.container_envs[count.index] : var.container_env
  command  = length(var.container_commands) >= 1 ? var.container_commands[count.index] : var.container_command
  hostname = "${var.container_name_prefix}-${count.index + 1}"

  dynamic "ulimit" {
    for_each = var.ulimits
    content {
      hard = ulimit.value["hard"]
      soft = ulimit.value["soft"]
      name = ulimit.value["name"]
    }
  }
  dynamic "ports" {
    for_each = var.port_map
    content {
      internal = ports.key
      external = format("%d", split("/", ports.value)[0]) + count.index
      protocol = length(split("/", ports.value)) > 1 ? split("/", ports.value)[1] : "tcp"
    }
  }
  networks_advanced {
    name = var.network_name
  }
}

output "container_names" {
  value = docker_container.this.*.name
}
