
#======================================> Azure_Network outputs.tf  <=======================================

output "azure_public_ip" {
  description = "Public IP used by Vnet GateWay"
  value       = azurerm_public_ip.hubble_sts_pip.ip_address
}

output "vnet_gw_id" {
  value = azurerm_virtual_network_gateway.hubble_sts_azure_vnet_gw.id
}

output "resource_rg_location" {
  value = data.azurerm_resource_group.resource_rg.location
}

output "azure_subnet_id" {
  value = azurerm_subnet.hubble_subnet[0].id
}