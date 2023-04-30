terraform {
  required_providers {
    routeros = {
      source  = "GNewbury1/routeros"
      version = "~> 1.0.0"
    }
  }
}

provider "routeros" {
  hosturl  = var.routeros_url
  username = var.routeros_username
  password = var.routeros_password
  insecure = var.routeros_insecure
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

locals {
  # cidr = "10.0.0.0/8"
  cidr_prefix = "10.128.0.0"
  cidr_bits   = 9
  cidr        = "${local.cidr_prefix}/${local.cidr_bits}"
  vlans = {
    mgmt = {
      id      = 99
      newbits = 7
      cidr    = cidrsubnet(local.cidr, 7, 99)
      # network = "10.199.0.0"
      # address = "10.199.0.1/16"
    }
    srv = {
      id      = 10
      newbits = 15
      cidr    = cidrsubnet(local.cidr, 15, 10)
      # network = "10.100.10.0"
      # address = "10.100.10.1/24"
    }
    lan = {
      id      = 100
      newbits = 15
      cidr    = cidrsubnet(local.cidr, 15, 100)
      # network = "10.100.100.0"
      # address = "10.100.100.1/24"
      # tagged   = []
      # untagged = ["ether5"]
    }
  }
  ports = {
    ether2 = {
      pvid        = local.vlans.lan.id
      frame_types = "admit-only-untagged-and-priority-tagged"
    }
    # ether5 = {
    #   pvid        = local.vlans.lan.id
    #   frame_types = "admit-only-untagged-and-priority-tagged"
    # }
    # ether6 = {
    #
    # }
  }
}

resource "routeros_interface_bridge" "bridge" {
  name           = "bridge"
  vlan_filtering = true
}

resource "routeros_interface_vlan" "vlan" {
  for_each  = local.vlans
  name      = each.key
  interface = routeros_interface_bridge.bridge.name
  vlan_id   = each.value.id
}

resource "routeros_ip_address" "vlan" {
  for_each  = local.vlans
  interface = routeros_interface_vlan.vlan[each.key].name
  network   = split("/", each.value.cidr)[0]
  address   = "${cidrhost(each.value.cidr, 0)}/${split("/", each.value.cidr)[1]}"
  # network   = cidrhost(cidrsubnet(local.cidr, each.value.newbits, each.value.id), 0)
  # address   = "${cidrhost(cidrsubnet(local.cidr, each.value.newbits, each.value.id), 1)}/${local.cidr_bits + each.value.newbits}"
  # network   = each.value.network
  # address   = each.value.address
}

resource "routeros_ip_pool" "vlans" {
  for_each = local.vlans
  name     = each.key
  ranges   = ["${cidrhost(each.value.cidr, 100)}-${cidrhost(each.value.cidr, 200)}"]
}

resource "routeros_ip_dhcp_server" "vlans" {
  for_each     = local.vlans
  name         = each.key
  interface    = each.key
  address_pool = routeros_ip_pool.vlans[each.key].name
}

resource "routeros_dhcp_server_network" "vlans" {
  for_each   = local.vlans
  address    = each.value.cidr
  gateway    = cidrhost(each.value.cidr, 1)
  dns_server = cidrhost(each.value.cidr, 1)
}

resource "routeros_interface_bridge_port" "ports" {
  for_each    = local.ports
  bridge      = routeros_interface_bridge.bridge.name
  interface   = each.key
  pvid        = coalesce(each.value.pvid, 1)
  frame_types = each.value.frame_types
  hw          = true
}

resource "routeros_interface_bridge_vlan" "vlans" {
  for_each = local.vlans
  bridge   = routeros_interface_bridge.bridge.name
  vlan_ids = tostring(each.value.id)
  tagged   = [routeros_interface_bridge.bridge.name]
  untagged = []
  # untagged = [for k, v in local.ports : k if v.pvid == each.value.id]
}
