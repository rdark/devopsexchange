variable "image_repository" {}
variable "image_name" {}
variable "image_tag" {}
variable "port_map" {
  type    = map(string)
  default = {}
}
variable "container_name_prefix" {}
variable "container_count" {
  default = 1
}

variable "container_env" {
  type    = set(string)
  default = []
}

variable "container_envs" {
  type        = list(set(string))
  description = "If present, used instead of container_env, mapped by index against container_count; must be equal in length to"
  default     = []
}

variable container_command {
  type    = list(string)
  default = []
}

variable container_commands {
  type        = list(list(string))
  description = "If present, used instead of container_command, mapped by index against container_count; must be equal in length to"
  default     = []
}

variable "ulimits" {
  type    = list(object({ hard = number, soft = number, name = string }))
  default = []
}

variable "network_name" {
}
