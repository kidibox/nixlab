resource "routeros_ip_dhcp_client" "wan" {
  interface         = local.wan_port
  add_default_route = "yes"
  use_peer_dns      = false
  use_peer_ntp      = false
}

resource "routeros_ip_address" "vlan" {
  for_each  = local.vlan_cidrs
  interface = routeros_interface_vlan.vlan[each.key].name
  network   = split("/", local.vlan_cidrs[each.key])[0]
  address   = "${cidrhost(each.value, 1)}/${split("/", each.value)[1]}"
}

resource "routeros_ip_pool" "vlans" {
  for_each = local.vlan_cidrs
  name     = each.key
  ranges   = ["${cidrhost(each.value, 100)}-${cidrhost(each.value, 200)}"]
}

resource "routeros_ip_dhcp_server" "vlans" {
  depends_on   = [routeros_interface_vlan.vlan]
  for_each     = local.vlans
  name         = each.key
  interface    = each.key
  lease_time   = "1d"
  address_pool = routeros_ip_pool.vlans[each.key].name
}

resource "routeros_dhcp_server_network" "vlans" {
  for_each   = local.vlan_cidrs
  address    = each.value
  gateway    = cidrhost(each.value, 1)
  dns_server = cidrhost(each.value, 1)
  domain     = "${each.key}.${local.tld}"
}

resource "routeros_dhcp_server_lease" "static_hosts" {
  lifecycle {
    # avoids conflicts when making changes
    create_before_destroy = false
  }

  for_each    = { for k, v in local.hosts : k => v }
  comment     = each.key
  address     = each.value.ip
  mac_address = upper(each.value.mac)
}
