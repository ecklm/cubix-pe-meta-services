variable "parent_zone" {
  description = "Parent azurerm_dns_zone resource to delegate the student subzone from."
  type = object({
    name                = string
    resource_group_name = string
  })
}

variable "name_servers" {
  description = "Name servers for the delegated student DNS zone."
  type        = list(string)
}

variable "subdomain_name" {
  description = "Subdomain name to delegate under the Cubix root DNS zone."
  type        = string
}

variable "ttl" {
  description = "TTL for the delegated NS record."
  type        = number
  default     = 300
}
