locals {
  tld         = "home.kidibox.net"
  cidr_prefix = "10.0.0.0"
  cidr_bits   = 9
  cidr        = "${local.cidr_prefix}/${local.cidr_bits}"
  vlans = {
    adm = {
      id   = 99
      cidr = cidrsubnet(local.cidr, 7, 99)
    }
    srv = {
      id = 10
    }
    media = {
      id = 30
    }
    lan = {
      id = 100
    }
    iot = {
      id = 101
    }
    ioc = {
      id = 102
    }
  }
  wan_port = "ether8"
  ports = {
    sfp-sfpplus1 = {
      comment = "pve"
      pvid    = local.vlans.srv.id
      tagged = [
        # local.vlans.srv.id,
        local.vlans.media.id,
        # local.vlans.svc.id,
        local.vlans.iot.id,
        local.vlans.ioc.id,
        local.vlans.lan.id,
      ]
      # frame_types = "admit-only-vlan-tagged"
      frame_types = "admit-all"
    }
    ether1 = {
      comment = "hypernix"
      tagged = [
        local.vlans.srv.id,
        local.vlans.media.id,
        # local.vlans.svc.id,
        local.vlans.iot.id,
        local.vlans.ioc.id,
        local.vlans.lan.id,
      ]
      frame_types = "admit-only-vlan-tagged"
      # frame_types = "admit-all"
    }
    ether2 = {
      comment = "pve-ipmi"
      pvid    = local.vlans.adm.id
    }
    ether3 = {
      comment = "cap-xr-0"
      tagged = [
        local.vlans.adm.id,
        local.vlans.lan.id,
        local.vlans.iot.id,
        local.vlans.ioc.id,
      ]
      frame_types = "admit-only-vlan-tagged"
    }
    ether4 = {
      comment = "cap-xr-1"
      tagged = [
        local.vlans.adm.id,
        local.vlans.lan.id,
        local.vlans.iot.id,
        local.vlans.ioc.id,
      ]
      frame_types = "admit-only-vlan-tagged"
    }
    ether5 = {
      comment = "kid-pc"
      pvid    = local.vlans.lan.id
    }
    ether6 = {
      pvid = local.vlans.srv.id
      tagged = [
        # local.vlans.srv.id,
        local.vlans.media.id,
        # local.vlans.svc.id,
        local.vlans.iot.id,
        local.vlans.ioc.id,
        local.vlans.lan.id,
      ]
      frame_types = "admit-all"
    }
    ether7 = {
      comment = "doorbell"
      pvid    = local.vlans.iot.id
    }
  }
  hosts = {
    pve = {
      mac = "d0:50:99:fe:51:b5"
      ip  = cidrhost(local.vlan_cidrs.srv, 10)
    }
    pve-ipmi = {
      mac = "d0:50:99:f7:ee:15"
      ip  = cidrhost(local.vlan_cidrs.adm, (local.vlans.srv.id * 256) + 10)
    }
    hypernix = {
      # mac = "74:56:3c:69:1e:30",
      mac = "be:4f:11:f4:ba:61",
      ip  = cidrhost(local.vlan_cidrs.srv, 20)
    }
    plex = {
      mac = "ba:e7:db:ac:3b:04"
      ip  = cidrhost(local.vlan_cidrs.media, 100)
    }
    prowlarr = {
      mac = "92:e2:50:9d:92:8a"
      ip  = cidrhost(local.vlan_cidrs.media, 110)
    }
    radarr = {
      mac = "ae:f3:c0:18:2e:aa"
      ip  = cidrhost(local.vlan_cidrs.media, 120)
    }
    sonarr = {
      mac = "d6:64:99:36:6f:c3"
      ip  = cidrhost(local.vlan_cidrs.media, 130)
    }
    animarr = {
      mac = "42:ba:e6:ac:f1:c9"
      ip  = cidrhost(local.vlan_cidrs.media, 140)
    }
    sabnzbd = {
      mac = "92:45:e0:4e:9f:2c"
      ip  = cidrhost(local.vlan_cidrs.media, 150)
    }
  }
  vlan_cidrs = { for k, v in local.vlans : k => lookup(v, "cidr", cidrsubnet(local.cidr, 15, v.id)) }
}

resource "routeros_ip_dhcp_client" "wan" {
  interface         = local.wan_port
  add_default_route = "yes"
  use_peer_dns      = false
  use_peer_ntp      = false
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

resource "routeros_interface_bridge_port" "ports" {
  for_each    = local.ports
  comment     = lookup(each.value, "comment", null)
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
  interface = local.wan_port
}

resource "routeros_interface_list" "lan_trusted" {
  name = "LAN-TRUSTED"
}

resource "routeros_interface_list_member" "lan_trusted_vlans" {
  for_each  = { for k, v in local.vlans : k => v if lookup(v, "trusted", true) }
  list      = routeros_interface_list.lan_trusted.name
  interface = each.key
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

resource "routeros_ip_dns" "upstream" {
  servers               = "1.1.1.1"
  use_doh_server        = "https://cloudflare-dns.com/dns-query"
  verify_doh_cert       = true
  allow_remote_requests = true
}

resource "routeros_dns_record" "rb5009" {
  type    = "A"
  address = split("/", routeros_ip_address.vlan["adm"].address)[0]
  name    = "rb5009.${local.tld}"
}

resource "routeros_dns_record" "static_hosts" {
  for_each = { for k, v in local.hosts : k => v }
  type     = "A"
  address  = routeros_dhcp_server_lease.static_hosts[each.key].address
  name     = "${each.key}.${local.tld}"
}
