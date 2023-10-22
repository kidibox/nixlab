include {
  path = find_in_parent_folders()
}

terraform {
  // source = "github.com/kidibox/nixlab//terraform/network"
  source = "../../../../terraform/capxr"
}

dependencies {
  paths = ["../router"]
}

inputs = {
  routeros_url = "https://10.99.0.191"
}
