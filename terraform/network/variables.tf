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

variable "zt_central_token" {
  type      = string
  sensitive = true
}
