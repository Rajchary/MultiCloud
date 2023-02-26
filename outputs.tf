
output "aws_vm_ip" {
  value = module.aws_compute.hubble_aws_instance_ip
}

output "azure_vm_ip" {
  value = module.azure_compute.azure_vm_ip
}