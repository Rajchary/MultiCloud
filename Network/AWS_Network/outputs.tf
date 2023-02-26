

output "vpc_id" {
  value = aws_vpc.hubble_aws_vpc.id
}

output "route_table_id" {
  value = aws_route_table.hubble_rt.id
}

output "aws_subnet_id" {
  value = aws_subnet.hubble_subnet.id
}