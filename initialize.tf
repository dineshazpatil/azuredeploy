terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

provider "azurerm" {
  features {}

}

resource "azurerm_resource_group" "azurefunction" {
  name     = "${var.project}-${var.environment}-rg"
  location = var.regionname
}




