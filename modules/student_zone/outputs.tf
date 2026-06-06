output "name" {
  description = "Name of the delegated student subdomain NS record."
  value       = azurerm_dns_ns_record.student_zone.name
}

output "fqdn" {
  description = "Fully qualified domain name for the delegated student subdomain."
  value       = azurerm_dns_ns_record.student_zone.fqdn
}

output "name_servers" {
  description = "Name servers configured for the delegated student subdomain."
  value       = azurerm_dns_ns_record.student_zone.records
}
