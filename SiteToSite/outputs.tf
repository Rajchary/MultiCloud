


output "aws_sg_id" {
  value = aws_security_group.hubble_aws_sts_sg.id
}

output "azure_nsg_id" {
  value = azurerm_network_security_group.hubble_sts_nsg.id
}