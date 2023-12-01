resource "azurerm_virtual_wan" "this" {
  name = var.name
  # Configuration 
  office365_local_breakout_category = "OptimizeAndAllow"

  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_virtual_hub" "this" {
  name           = var.hub_name
  virtual_wan_id = azurerm_virtual_wan.this.id
  address_prefix = var.address_prefix

  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_virtual_hub_connection" "this" {
  for_each                  = var.vnet_ids
  name                      = each.key
  virtual_hub_id            = azurerm_virtual_hub.this.id
  remote_virtual_network_id = each.value
}
