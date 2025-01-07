create VPC (enable_dns_host_names)

create common_tags, vpc_tags, 

outputs -> vpc_id

internet gateway

HA --> atleast 2 AZ

public subnet --> 1a, 1b --> 10.0.1.0/24, 10.0.2.0/24

create subnet in two availablity zone --> variable validation

query aws_availability_zones 

auto-assign public ip4 address (map_public_ip_on_launch)

create db subnet group

create elastic ip
create nat gateway



VPC Peering
=============

establish connection between two VPC (two VPC CIDR must be different )

same account, same region with  different VPC can connect/Peering
same account, different region with  different VPC can connect/Peering

different account
same region with two VPC can connect/Peering
different region with two VPC can connect/Peering

resource aw vpc peering connection

count variable

vpc id 

vpc peering id (data source)