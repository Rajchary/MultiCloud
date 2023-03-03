
#=======================================>  Root outputs.tf  <========================================

output "alb_dns" {
  value = module.aws_compute.alb_dns
}

output "azure_vm_ip" {
  value = module.azure_compute.azure_vm_ip
}