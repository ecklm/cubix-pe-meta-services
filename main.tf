locals {
  location = "westeurope"
  tags = {
    work = "Cubix Platform Engineer course"
  }
}

resource "azurerm_resource_group" "meta_services" {
  name     = "cubix-meta-services"
  location = local.location
  tags     = local.tags
}

resource "azurerm_dns_zone" "cubix_root" {
  name                = "cubix.ecklm.com"
  resource_group_name = azurerm_resource_group.meta_services.name
  tags                = local.tags

  depends_on = [
    azurerm_resource_group.meta_services
  ]
}

output "cubix_root_name_servers" {
  description = "Name servers for the cubix.ecklm.com public DNS zone."
  value       = azurerm_dns_zone.cubix_root.name_servers
}

output "student_zones" {
  description = "Delegated student subzone FQDNs."
  value       = [for zone in module.student_zone : zone.fqdn]
}
