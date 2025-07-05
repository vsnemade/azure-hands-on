terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
  required_version = ">= 1.3"
}

provider "azurerm" {
  features {}

  subscription_id = "a509f092-aae7-411e-901f-539db8d734d1" 
  #tenant_id       = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"  # Replace with your actual Tenant ID
}

