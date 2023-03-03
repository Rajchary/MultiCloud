
#=====================================>  Azure_Compute outputs.tf  <=======================================

output "azure_vm_ip" {
  value = ["Private_IP : ${azurerm_linux_virtual_machine.hubble_azure_vm.private_ip_address}",
  "Public_IP : ${azurerm_linux_virtual_machine.hubble_azure_vm.public_ip_address}"]
}