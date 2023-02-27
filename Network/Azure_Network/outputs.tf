
#======================================> Azure_Network outputs.tf  <=======================================

output "resource_rg_location" {
  value = data.azurerm_resource_group.resource_rg.location
}

output "azure_subnet_id" {
  value = azurerm_subnet.hubble_subnet[0].id
}

output "azure_gw_subnet_id" {
  value = azurerm_subnet.hubble_subnet[1].id
}