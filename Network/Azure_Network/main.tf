
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

resource "azurerm_network_security_group" "hubble_sts_nsg" {
  name                = var.azure_sg_data.name
  location            = data.azurerm_resource_group.resource_rg.location
  resource_group_name = var.resource_rg_name

  dynamic "security_rule" {
    for_each = var.azure_sg_data.security_rule
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}
