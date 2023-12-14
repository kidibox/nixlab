terraform {
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.27.0"
    }
  }
}

variable "ip_address" {
  type = string
}

variable "mac_address" {
  type = string
}

variable "dns_name" {
  type    = string
  default = null
}

variable "dhcp_server" {
  type    = string
  default = "lan"
}

resource "routeros_ip_dhcp_server_lease" "static_hosts" {
  mac_address = upper(var.mac_address)
  address     = var.ip_address
  server      = var.dhcp_server
}

resource "routeros_ip_dns_record" "name" {
  count   = var.dns_name != null && var.dns_name != "" ? 1 : 0
  type    = "A"
  name    = var.dns_name
  address = var.ip_address
}
