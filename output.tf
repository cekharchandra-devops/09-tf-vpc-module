output "vpc_id" {
  value = aws_vpc.main.id
}

# output "availability_zones" {
#   value = data.aws_availability_zones.available
# }

# output "default_vpc_id" {
#   value = data.aws_vpc.default_vpc_id
# }

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "db_subnet_ids" {
  value = aws_subnet.db[*].id
}

output "nat_gw_id" {
  value = aws_nat_gateway.nat_gw.id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "db_route_table_id" {
  value = aws_route_table.db.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.default.name
}