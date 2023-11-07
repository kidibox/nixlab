include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/terraform/proxmox"
}

dependencies {
  paths = []
}

inputs = {
  proxmox_endpoint         = "https://pve.servers.home.kidibox.net:8006"
  repo_root = get_repo_root()
}
