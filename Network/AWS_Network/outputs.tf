

output "vpc_id" {
  value = aws_vpc.hubble_aws_vpc.id
}

output "route_table_id" {
  value = aws_route_table.hubble_rt.id
}

output "aws_subnet_id" {
  value = aws_subnet.hubble_subnet.*.id
}

output "aws_sg_ids" {
  value = { sts_sg = aws_security_group.hubble_aws_sts_sg.id,
    frontier_sg = aws_security_group.hubble_aws_frontier_sg.id,
  midtier_sg = aws_security_group.hubble_aws_midtier_sg.id }
}