variable "student_zones" {
  description = "Student DNS zones to delegate from cubix.ecklm.com."
  type = map(object({
    subdomain_name = string
    name_servers   = list(string)
    ttl            = optional(number, 300)
  }))
  default = {}
}

module "student_zone" {
  source = "./modules/student_zone"

  for_each = var.student_zones

  parent_zone    = azurerm_dns_zone.cubix_root
  subdomain_name = each.value.subdomain_name
  name_servers   = each.value.name_servers
  ttl            = each.value.ttl

  depends_on = [
    azurerm_dns_zone.cubix_root
  ]
}
