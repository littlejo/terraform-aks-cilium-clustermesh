resource "azurerm_virtual_network_peering" "mesh1tomesh2" {
  name                      = "mesh1tomesh2"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.vnet_1.name
  remote_virtual_network_id = var.vnet_2.id
}

resource "azurerm_virtual_network_peering" "mesh2tomesh1" {
  name                      = "mesh2tomesh1"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.vnet_2.name
  remote_virtual_network_id = var.vnet_1.id
}
