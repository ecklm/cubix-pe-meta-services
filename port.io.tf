provider "port" {
  base_url = "https://api.port.io"
}

resource "port_entity" "meta_services" {
  title      = "Meta services"
  identifier = "meta_services"
  blueprint  = "githubRepository"
  properties = {
    string_props = {
      defaultBranch = "main"
      description   = "Azure DNS meta services managed by Terraform"
    }
  }
}
