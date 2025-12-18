provider "azurerm" {
  features {}
  use_oidc = true
  # Subscription ID will be provided by Azure login in GitHub Actions
}
