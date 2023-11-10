locals {
  tfc_hostname = "app.terraform.io"
  tfc_organization = "kidibox"
  workspace = reverse(split("/", get_terragrunt_dir()))[0]
  secrets = yamldecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/secrets.sops.yaml"))
}

inputs = merge(
  local.secrets,
  {
    routeros_url = "https://10.99.0.1"
  }
)

generate "tfc" {
  path = "tfc.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  cloud {
    organization = "${local.tfc_organization}"

    workspaces {
      name = "${local.workspace}-home"
    }
  }
}
EOF
}


