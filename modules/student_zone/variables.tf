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

  validation {
    condition     = length(var.name_servers) > 0
    error_message = "At least one delegated name server is required."
  }

  validation {
    condition = alltrue([
      for name_server in var.name_servers :
      length(name_server) <= 253 && can(regex("^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\\.)+$", name_server))
    ])
    error_message = "Each name server must be a lowercase fully qualified DNS name with a trailing dot."
  }
}

variable "subdomain_name" {
  description = "Subdomain name to delegate under the Cubix root DNS zone."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the delegated student NS record."
  type        = map(string)
}

variable "ttl" {
  description = "TTL for the delegated NS record."
  type        = number
  default     = 300
  nullable    = false
}
