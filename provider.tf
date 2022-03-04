// Terraform Backend Configuration specifying organization and workspace
terraform {

}

// Provider AzureRM Configuration
provider "azurerm" {
  version = "~> 2.97.0"
  features {}
}