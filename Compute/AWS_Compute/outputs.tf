


output "hubble_aws_instance_ip" {
  value = ["Private_IP : ${aws_instance.hubble_aws_vm.private_ip}",
  "Public_IP : ${aws_instance.hubble_aws_vm.public_ip}"]
}