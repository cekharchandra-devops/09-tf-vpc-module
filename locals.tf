locals {
  resource_name = "${var.project_name}-${var.environmet}"
  availability_zone = slice(data.aws_availability_zones.available.names,0,2)
}