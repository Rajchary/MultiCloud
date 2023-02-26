
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

resource "azurerm_public_ip" "hubble_sts_pip" {
  name                = var.hubble_sts_pip_name
  location            = data.azurerm_resource_group.resource_rg.location
  resource_group_name = var.resource_rg_name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "hubble_sts_azure_vnet_gw" {
  name                = var.hubble_sts_vnetGW_name
  location            = data.azurerm_resource_group.resource_rg.location
  resource_group_name = var.resource_rg_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = false
  sku                 = "VpnGw1"
  generation          = "Generation1"
  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.hubble_sts_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hubble_subnet[1].id
  }
}

