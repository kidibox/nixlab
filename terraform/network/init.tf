terraform {
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.10.4"
    }
    zerotier = {
      source  = "zerotier/zerotier"
      version = "1.4.0"
    }
  }
}

provider "routeros" {
  hosturl  = var.routeros_url
  username = var.routeros_username
  password = var.routeros_password
  insecure = var.routeros_insecure
}

provider "zerotier" {
  zerotier_central_token = var.zt_central_token
}
