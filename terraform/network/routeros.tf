locals {
  # cidr = "10.0.0.0/8"
  cidr_prefix = "10.128.0.0"
  cidr_bits   = 9
  cidr        = "${local.cidr_prefix}/${local.cidr_bits}"
  vlans = {
    mgmt = {
      id   = 99
      cidr = cidrsubnet(local.cidr, 7, 99)
    }
    srv = {
      id   = 10
      cidr = cidrsubnet(local.cidr, 15, 10)
    }
    lan = {
      id     = 100
      cidr   = cidrsubnet(local.cidr, 15, 100)
      tagged = ["ether2", "ether6", "ether7", "ether8"]
    }
    legacy = {
      id   = 88
      cidr = "192.168.88.0/24"
    }
  }
  ports = {
    sfp-sfpplus1 = {
      # pvid = local.vlans.srv.id
      tagged = [
        local.vlans.srv.id,
        local.vlans.lan.id,
      ]
      frame_types = "admit-only-vlan-tagged"
    }
    ether2 = {
      pvid = local.vlans.lan.id
    }
    ether3 = {
      pvid = local.vlans.legacy.id
    }
    ether4 = {
      pvid = local.vlans.legacy.id
    }
    ether5 = {
      pvid = local.vlans.srv.id
    }
    ether6 = {
      pvid = local.vlans.lan.id
    }
    ether7 = {
      pvid = local.vlans.lan.id
    }
    ether8 = {
      pvid = local.vlans.lan.id
    }
  }
}

resource "routeros_interface_bridge" "bridge" {
  name           = "bridge1"
  vlan_filtering = true
  frame_types    = "admit-only-vlan-tagged"
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
  address   = "${cidrhost(each.value.cidr, 1)}/${split("/", each.value.cidr)[1]}"
}

resource "routeros_ip_pool" "vlans" {
  for_each = local.vlans
  name     = each.key
  ranges   = ["${cidrhost(each.value.cidr, 100)}-${cidrhost(each.value.cidr, 200)}"]
}

resource "routeros_ip_dhcp_server" "vlans" {
  depends_on   = [routeros_interface_vlan.vlan]
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
  pvid        = lookup(each.value, "pvid", 1)
  frame_types = lookup(each.value, "frame_types", "admit-only-untagged-and-priority-tagged")
  hw          = true
}

resource "routeros_interface_bridge_vlan" "vlans" {
  for_each = local.vlans
  bridge   = routeros_interface_bridge.bridge.name
  vlan_ids = tostring(each.value.id)
  tagged = concat(
    [routeros_interface_bridge.bridge.name],
    [for k, v in local.ports : k if contains(lookup(v, "tagged", []), each.value.id)]
  )
  untagged = [for k, v in local.ports : k if lookup(v, "pvid", 0) == each.value.id]
}

resource "routeros_interface_list" "wan" {
  name = "WAN"
}

resource "routeros_interface_list_member" "wan" {
  list      = routeros_interface_list.wan.name
  interface = "ether1"
}

resource "routeros_interface_list" "lan_trusted" {
  name = "LAN-TRUSTED"
}

resource "routeros_interface_list_member" "lan_trusted_vlans" {
  for_each  = { for k, v in local.vlans : k => v if lookup(v, "trusted", true) }
  list      = routeros_interface_list.lan_trusted.name
  interface = each.key
}
