terraform {
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.20.0"
    }
  }
}

provider "routeros" {
  hosturl  = var.routeros_url
  username = var.routeros_username
  password = var.routeros_password
  insecure = var.routeros_insecure
}
