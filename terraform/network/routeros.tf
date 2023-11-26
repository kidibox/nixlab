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
    # ioc = {
    #   id = 102
    # }
  }
  wan_port = "ether8"
  ports = {
    # sfp-sfpplus1 = {
    #   pvid = local.vlans.srv.id
    # }
    ether1 = {
      comment = "hypernix"
      tagged = [
        local.vlans.srv.id,
        # local.vlans.media.id,
        # local.vlans.svc.id,
        # local.vlans.iot.id,
        # local.vlans.ioc.id,
        local.vlans.lan.id,
      ]
      frame_types = "admit-only-vlan-tagged"
      # frame_types = "admit-all"
    }
    ether2 = {
      comment = "pve"
      pvid    = local.vlans.srv.id
      tagged = [
        local.vlans.adm.id,
        # local.vlans.srv.id,
        local.vlans.media.id,
        # local.vlans.svc.id,
        # local.vlans.iot.id,
        # local.vlans.ioc.id,
        local.vlans.lan.id,
        local.vlans.adm.id,
      ]
      # frame_types = "admit-only-vlan-tagged"
      frame_types = "admit-all"
    }
    # ether2 = {
    #   comment = "pve-ipmi"
    #   pvid    = local.vlans.adm.id
    # }
    ether3 = {
      comment = "capxr0"
      tagged = [
        local.vlans.adm.id,
        local.vlans.lan.id,
        # local.vlans.iot.id,
        # local.vlans.ioc.id,
      ]
      frame_types = "admit-only-vlan-tagged"
    }
    ether4 = {
      comment = "capxr1"
      tagged = [
        local.vlans.adm.id,
        local.vlans.lan.id,
        # local.vlans.iot.id,
        # local.vlans.ioc.id,
      ]
      frame_types = "admit-only-vlan-tagged"
    }
    ether5 = {
      comment = "kid-pc"
      pvid    = local.vlans.adm.id
    }
    # ether6 = {
    #   comment = "cc-pc"
    #   pvid    = local.vlans.lan.id
    # }
    ether6 = {
      comment = "sw-office"
      # pvid    = local.vlans.adm.id
      tagged = [
        local.vlans.adm.id,
        # local.vlans.srv.id,
        # local.vlans.media.id,
        local.vlans.lan.id,
        local.vlans.iot.id,
        # local.vlans.ioc.id,
      ]
      frame_types = "admit-only-vlan-tagged"
      # frame_types = "admit-all"
    }
    # ether7 = {
    #   comment = "doorbell"
    #   pvid    = local.vlans.iot.id
    # }
  }
  hosts = {
    capxr0 = {
      mac         = "48:a9:8a:cc:6d:62"
      ip          = cidrhost(local.vlan_cidrs.adm, 10)
      dhcp_server = "adm"
    }
    capxr1 = {
      mac         = "48:a9:8a:ba:2a:6e"
      ip          = cidrhost(local.vlan_cidrs.adm, 11)
      dhcp_server = "adm"
    }
    unifi = {
      mac         = "2e:e6:a6:ae:b1:41"
      ip          = cidrhost(local.vlan_cidrs.adm, 20)
      dhcp_server = "adm"
    }
    sw-office = {
      mac         = "f0:9f:c2:c5:f9:44"
      ip          = cidrhost(local.vlan_cidrs.adm, 21)
      dhcp_server = "adm"
    }
    pve = {
      mac         = "d0:50:99:fe:51:b5"
      ip          = cidrhost(local.vlan_cidrs.srv, 10)
      dhcp_server = "srv"
    }
    pve-ipmi = {
      mac         = "d0:50:99:f7:ee:15"
      ip          = cidrhost(local.vlan_cidrs.adm, (local.vlans.srv.id * 256) + 10)
      dhcp_server = "adm"
    }
    hypernix = {
      # mac = "74:56:3c:69:1e:30",
      mac         = "be:4f:11:f4:ba:61",
      ip          = cidrhost(local.vlan_cidrs.srv, 20)
      dhcp_server = "srv"
    }
    # plex = {
    #   mac = "ba:e7:db:ac:3b:04"
    #   ip  = cidrhost(local.vlan_cidrs.media, 100)
    # }
    # prowlarr = {
    #   mac = "92:e2:50:9d:92:8a"
    #   ip  = cidrhost(local.vlan_cidrs.media, 110)
    # }
    # radarr = {
    #   mac = "ae:f3:c0:18:2e:aa"
    #   ip  = cidrhost(local.vlan_cidrs.media, 120)
    # }
    # sonarr = {
    #   mac = "d6:64:99:36:6f:c3"
    #   ip  = cidrhost(local.vlan_cidrs.media, 130)
    # }
    # animarr = {
    #   mac = "42:ba:e6:ac:f1:c9"
    #   ip  = cidrhost(local.vlan_cidrs.media, 140)
    # }
    # sabnzbd = {
    #   mac = "92:45:e0:4e:9f:2c"
    #   ip  = cidrhost(local.vlan_cidrs.media, 150)
    # }
  }
  vlan_cidrs = { for k, v in local.vlans : k => lookup(v, "cidr", cidrsubnet(local.cidr, 15, v.id)) }
}


resource "routeros_interface_list" "wan" {
  name = "WAN"
}
#
resource "routeros_interface_list_member" "wan" {
  list      = routeros_interface_list.wan.name
  interface = local.wan_port
}
#
# resource "routeros_interface_list" "lan_trusted" {
#   name = "LAN-TRUSTED"
# }
#
# resource "routeros_interface_list_member" "lan_trusted_vlans" {
#   for_each  = { for k, v in local.vlans : k => v if lookup(v, "trusted", true) }
#   list      = routeros_interface_list.lan_trusted.name
#   interface = each.key
# }

resource "routeros_ip_dns" "upstream" {
  servers = "1.1.1.1"
  # use_doh_server        = "https://cloudflare-dns.com/dns-query"
  # verify_doh_cert       = true
  allow_remote_requests = true
}
#
# resource "routeros_dns_record" "rb5009" {
#   type    = "A"
#   address = split("/", routeros_ip_address.vlan["adm"].address)[0]
#   name    = "rb5009.${local.tld}"
# }
#
# resource "routeros_dns_record" "static_hosts" {
#   for_each = { for k, v in local.hosts : k => v }
#   type     = "A"
#   address  = routeros_dhcp_server_lease.static_hosts[each.key].address
#   name     = "${each.key}.${local.tld}"
# }
#
# resource "routeros_routing_bgp_connection" "hypernix_k3s" {
#   name = "toHypernix"
#   as   = 64512
#
#   local {
#     role = "ebgp"
#   }
#
#   remote {
#     address = local.hosts.hypernix.ip
#   }
# }
