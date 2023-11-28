resource "azurerm_virtual_network" "this" {
  address_space       = var.address_space
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_subnet" "node" {
  address_prefixes     = var.subnet_cidr
  name                 = var.subnet_name
  virtual_network_name = azurerm_virtual_network.this.name
  resource_group_name  = var.resource_group_name
}
