provider "port" {
  base_url = "https://api.port.io"
}

resource "port_blueprint" "student_zone" {
  identifier = "studentZone"
  title      = "Student Zone"
  icon       = "Azure"
  properties = {
    string_props = {
      subdomain_name = {
        title = "Subdomain Name"
      }
    }
    array_props = {
      name_servers = {
        title     = "Name Servers"
        min_items = 1
      }
    }
  }
}

resource "port_entity" "student_zone" {
  for_each   = var.student_zones
  blueprint  = port_blueprint.student_zone.identifier
  identifier = each.key
  title      = "${each.key}.cubix.ecklm.com"
  depends_on = [module.student_zone]
  lifecycle {
    ignore_changes = [properties]
  }
  properties = {
    string_props = {
      subdomain_name = each.value.subdomain_name
    }
    array_props = {
      name_servers = each.value.name_servers
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
    blueprint_identifier = port_blueprint.student_zone.identifier
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

  integration_method = {
    installation_id         = "meta-services"
    integration_action_type = "dispatch_workflow"
    integration_action_execution_properties = {
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
}

resource "port_action" "delete_student_zone" {
  title       = "Delete student DNS zone"
  identifier  = "delete-student-zone"
  icon        = "GithubActions"
  description = "Open a GitHub pull request that deletes a student subzone delegation under cubix.ecklm.com."

  self_service_trigger = {
    operation            = "DAY-2"
    blueprint_identifier = port_blueprint.student_zone.identifier
  }

  integration_method = {
    installation_id         = "meta-services"
    integration_action_type = "dispatch_workflow"
    integration_action_execution_properties = {
      org                    = "ecklm"
      repo                   = "cubix-pe-meta-services"
      workflow               = "delete-student-zone.yml"
      report_workflow_status = true
      workflow_inputs = jsonencode({
        subdomain_name = "{{ .entity.identifier }}"
      })
    }
  }
}
