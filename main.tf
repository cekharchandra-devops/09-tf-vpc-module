resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
        Name = local.resource_name
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
        Name = local.resource_name
    }
  )
}


#  public subnet in first two available zones

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_blocks[count.index]
  availability_zone = local.availability_zone[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    var.common_tags,
    var.public_subnet_tags,
    {
        Name = "${local.resource_name}-public-${local.availability_zone[count.index]}"
    }
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr_blocks)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_blocks[count.index]
  availability_zone = local.availability_zone[count.index]
  tags = merge(
    var.common_tags,
    var.private_subnet_tags,
    {
        Name = "${local.resource_name}-private-${local.availability_zone[count.index]}"
    }
  )
}

resource "aws_subnet" "db" {
  count = length(var.db_subnet_cidr_blocks)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.db_subnet_cidr_blocks[count.index]
  availability_zone = local.availability_zone[count.index]
  tags = merge(
    var.common_tags,
    var.db_subnet_tags,
    {
        Name = "${local.resource_name}-db-${local.availability_zone[count.index]}"
    }
  )
}

resource "aws_db_subnet_group" "default" {
  name       = "${local.resource_name}"
  subnet_ids = aws_subnet.db[*].id

  tags = merge(
    var.common_tags,
    var.db_subnet_group_tags,
    {
        Name = "${local.resource_name}"
    }
  )
}

resource "aws_eip" "eip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.public_route_table_tags,
    {
        Name = "${local.resource_name}-public"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.private_route_table_tags,
    {
        Name = "${local.resource_name}-private"
    }
  )
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.database_route_table_tags,
    {
        Name = "${local.resource_name}-database"
    }
  )
}

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}


resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr_blocks)  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat_gw.id
}


resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr_blocks)  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.db.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat_gw.id
}


resource "aws_route_table_association" "database" {
  count = length(var.db_subnet_cidr_blocks)  
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}