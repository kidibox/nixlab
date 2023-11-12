terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.37.1"
    }
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.23.0"
    }
    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password

  ssh {
    node {
      name    = "pve"
      address = "10.0.10.10"
    }
  }
}

provider "routeros" {
  hosturl  = var.routeros_url
  username = var.routeros_username
  password = var.routeros_password
  insecure = var.routeros_insecure
}
