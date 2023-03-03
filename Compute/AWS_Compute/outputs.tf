
#================================>  AWS_Compute outputs.tf   <=============================================

output "alb_dns" {
  value = "http://${aws_lb.hubble_alb.dns_name}"
}