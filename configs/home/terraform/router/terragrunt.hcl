include {
  path = find_in_parent_folders()
}

terraform {
  // source = "github.com/kidibox/nixlab//terraform/network"
  source = "../../../../terraform/network"
}

inputs = {
  routeros_url = "https://10.99.0.1"
}
