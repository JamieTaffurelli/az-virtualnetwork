terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }

  required_version = "~> 1.1.5"
}

provider "azurerm" {
  features {}
}