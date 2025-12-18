terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateprod1766084184"
    container_name       = "tfstate"
    key                  = "aks-dev.tfstate"
    use_oidc            = true
  }
}
