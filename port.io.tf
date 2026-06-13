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

  relations = {
    many_relations = {
      githubTeams = []
    }
  }
}

resource "port_action" "register_student_zone" {
  title       = "Register student DNS zone"
  identifier  = "register-student-zone"
  icon        = "GithubActions"
  description = "Open a GitHub pull request that delegates a student subzone under cubix.ecklm.com."

  self_service_trigger = {
    operation            = "CREATE"
    blueprint_identifier = "githubRepository"
    user_properties = {
      string_props = {
        subdomain_name = {
          title       = "Subdomain name"
          description = "Single DNS label to delegate under cubix.ecklm.com."
          required    = true
          pattern     = "^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$"
        }
        name_server_1 = {
          title       = "Name server 1"
          description = "First authoritative name server for the delegated zone."
          required    = true
        }
        name_server_2 = {
          title       = "Name server 2"
          description = "Second authoritative name server for the delegated zone."
        }
        name_server_3 = {
          title       = "Name server 3"
          description = "Third authoritative name server for the delegated zone."
        }
        name_server_4 = {
          title       = "Name server 4"
          description = "Fourth authoritative name server for the delegated zone."
        }
      }
    }
  }

  github_method = {
    org                    = "ecklm"
    repo                   = "cubix-pe-meta-services"
    workflow               = "register-student-zone.yml"
    report_workflow_status = true
    workflow_inputs = jsonencode({
      subdomain_name = "{{ .inputs.subdomain_name }}"
      name_server_1  = "{{ .inputs.name_server_1 }}"
      name_server_2  = "{{ .inputs.name_server_2 }}"
      name_server_3  = "{{ .inputs.name_server_3 }}"
      name_server_4  = "{{ .inputs.name_server_4 }}"
    })
  }
}
