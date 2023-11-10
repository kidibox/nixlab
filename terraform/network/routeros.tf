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
      pvid = local.vlans.srv.id
    }
    ether2 = {
      comment = "pve"
      pvid    = local.vlans.srv.id
      tagged = [
        # local.vlans.srv.id,
        local.vlans.media.id,
        # local.vlans.svc.id,
        local.vlans.iot.id,
        local.vlans.ioc.id,
        local.vlans.lan.id,
        local.vlans.adm.id,
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
    # ether2 = {
    #   comment = "pve-ipmi"
    #   pvid    = local.vlans.adm.id
    # }
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
      comment = "sw-office"
      # pvid    = local.vlans.adm.id
      tagged = [
        local.vlans.adm.id,
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

resource "routeros_ip_dns" "upstream" {
  servers = "1.1.1.1"
  # use_doh_server        = "https://cloudflare-dns.com/dns-query"
  # verify_doh_cert       = true
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

resource "routeros_routing_bgp_connection" "hypernix_k3s" {
  name = "toHypernix"
  as   = 64512

  local {
    role = "ebgp"
  }

  remote {
    address = local.hosts.hypernix.ip
  }
}
