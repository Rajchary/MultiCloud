
#===========================>  Azure Network main.tf  <================================

data "azurerm_resource_group" "resource_rg" {
  name = var.resource_rg_name
}

resource "azurerm_virtual_network" "hubble_vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_rg_name
  location            = data.azurerm_resource_group.resource_rg.location
  address_space       = var.vnet_cidr_block
}

resource "azurerm_subnet" "hubble_subnet" {
  depends_on = [
    azurerm_virtual_network.hubble_vnet
  ]
  count                = var.azure_snet_count
  name                 = var.azure_subnet_names[count.index]
  resource_group_name  = var.resource_rg_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.azure_subnet_cirdrs[count.index]]
}


