resource "azurerm_kubernetes_cluster" "this" {
name = var.cluster_name
location = var.location
resource_group_name = var.resource_group_name
dns_prefix = var.cluster_name


default_node_pool {
name = "system"
node_count = 1
vm_size = "Standard_B2s_v2"
vnet_subnet_id = var.subnet_id
}


identity {
type = "SystemAssigned"
}


network_profile {
network_plugin = "azure"
}
}