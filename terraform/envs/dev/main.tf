resource "azurerm_resource_group" "this" {
name = "rg-aks-dev"
location = "westeurope"
}


module "network" {
source = "../../modules/network"
vnet_name = "dev-vnet"
location = "westeurope"
resource_group_name = azurerm_resource_group.this.name
vnet_cidr = "10.10.0.0/16"
aks_subnet_cidr = "10.10.1.0/24"
}


module "acr" {
source = "../../modules/acr"
acr_name = "devaksacr2025"
location = "westeurope"
resource_group_name = azurerm_resource_group.this.name
}


module "aks" {
source = "../../modules/aks"
cluster_name = "dev-aks"
location = "westeurope"
resource_group_name = azurerm_resource_group.this.name
subnet_id = module.network.aks_subnet_id
}