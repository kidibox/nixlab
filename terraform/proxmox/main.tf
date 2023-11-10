module "installer_iso" {
  source    = "github.com/nix-community/nixos-anywhere//terraform/nix-build"
  attribute = ".#nixosConfigurations.installer.config.formats.install-iso"
}

resource "proxmox_virtual_environment_file" "nixos" {
  node_name    = "pve"
  content_type = "iso"
  datastore_id = "local"

  source_file {
    path = module.installer_iso.result.out
  }
}

resource "proxmox_virtual_environment_vm" "control_plane" {
  depends_on = [routeros_dhcp_server_lease.static_hosts]
  count      = var.control_plane_nodes
  name       = "control-plane-${count.index}"
  node_name  = "pve"
  machine    = "q35"

  cpu {
    cores = 4
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  operating_system {
    type = "l26"
  }

  tags = [
    "nixlab",
    "nixos",
    "terraform",
  ]

  agent {
    enabled = true
    trim    = true
  }

  bios       = "ovmf"
  boot_order = ["virtio0", "ide0"]

  efi_disk {
    datastore_id = "local-zfs"
    file_format  = "raw"
  }

  disk {
    datastore_id = "local-zfs"
    interface    = "virtio0"
    file_format  = "raw"
    size         = 32
  }

  cdrom {
    enabled   = true
    file_id   = proxmox_virtual_environment_file.nixos.id
    interface = "ide0"
  }

  network_device {
    bridge      = "vmbr0"
    vlan_id     = 100
    mac_address = macaddress.control_plane[count.index].address
  }
}

module "deploy" {
  count  = var.control_plane_nodes
  source = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"

  nixos_system_attr      = ".#nixosConfigurations.${proxmox_virtual_environment_vm.control_plane[count.index].name}.config.system.build.toplevel"
  nixos_partitioner_attr = ".#nixosConfigurations.${proxmox_virtual_environment_vm.control_plane[count.index].name}.config.system.build.diskoScript"

  target_host = flatten(proxmox_virtual_environment_vm.control_plane[count.index].ipv4_addresses)[1]
  instance_id = flatten(proxmox_virtual_environment_vm.control_plane[count.index].ipv4_addresses)[1] # trigger reinstall
}

output "control_plane_ips" {
  value = [
    for host in range(0, var.control_plane_nodes) : [
      for ip in flatten(proxmox_virtual_environment_vm.control_plane[host].ipv4_addresses) : ip if ip != "127.0.0.1"
    ]
  ]
}

resource "macaddress" "control_plane" {
  count = var.control_plane_nodes
}

resource "routeros_dhcp_server_lease" "static_hosts" {
  count = var.control_plane_nodes
  # comment     = proxmox_virtual_environment_vm.control_plane[count.index].name
  comment     = "control-plane-${count.index}"
  mac_address = macaddress.control_plane[count.index].address
  address     = "10.0.100.${(count.index + 1) * 10}"
}
