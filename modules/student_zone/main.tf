resource "azurerm_dns_ns_record" "student_zone" {
  name                = var.subdomain_name
  zone_name           = var.parent_zone.name
  resource_group_name = var.parent_zone.resource_group_name
  ttl                 = var.ttl
  records             = var.name_servers
}
