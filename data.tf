data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default_vpc_id" {
  default = true
}

data "aws_route_table" "default_route_table" {
  vpc_id = data.aws_vpc.default_vpc_id.id
  filter {
    name = "association.main"
    values = [ "true" ]
  }
}