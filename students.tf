locals {
  student_zone_files = fileset(path.module, "students/*.json")
  student_zones = length(local.student_zone_files) == 0 ? {} : merge([
    for file in local.student_zone_files : jsondecode(file("${path.module}/${file}"))
  ]...)
}

module "student_zone" {
  source = "./modules/student_zone"

  for_each = local.student_zones

  parent_zone    = azurerm_dns_zone.cubix_root
  subdomain_name = each.value.subdomain_name
  name_servers   = each.value.name_servers
  tags           = local.tags
  ttl            = lookup(each.value, "ttl", null)

  depends_on = [
    azurerm_dns_zone.cubix_root
  ]
}
