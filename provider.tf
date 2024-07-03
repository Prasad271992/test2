terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.98.0"
    }
  }
}

provider "azurerm" {
  
  subscription_id = "00dd52ea-be3f-4deb-aced-2e7091561086"
  skip_provider_registration = true

  features {}

}

provider "azurerm" {
    alias           = "subscription2"
    subscription_id = "9bfd5c53-14f7-45f3-93b4-5218307a1216"
    skip_provider_registration = true

    features {}
}

