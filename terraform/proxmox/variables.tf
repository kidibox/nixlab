variable "repo_root" {
  type = string
}

variable "routeros_url" {
  type      = string
  sensitive = true
}

variable "routeros_username" {
  type      = string
  sensitive = true
}

variable "routeros_password" {
  type      = string
  sensitive = true
}

variable "routeros_insecure" {
  type    = bool
  default = false
}
variable "proxmox_endpoint" {
  type = string
}

variable "proxmox_username" {
  type      = string
  sensitive = true
}

variable "proxmox_password" {
  type      = string
  sensitive = true
}

variable "control_plane_nodes" {
  type    = number
  default = 2
}
