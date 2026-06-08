terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name  = "cubix-meta-services"
    storage_account_name = "cubixmetastore"
    container_name       = "tfstate"
    key                  = "metaservices.tfstate"
    use_azuread_auth     = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    port = {
      source  = "port-labs/port-labs"
      version = "~> 1.2.3"
    }
  }
}

provider "azurerm" {
  subscription_id = "d4d35aad-20e7-4b76-bbb0-944c0f092cc4"
  tenant_id       = "8820d9af-b533-4848-9bf3-ebf24d29d140"

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
