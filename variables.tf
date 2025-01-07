variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "common_tags" {
  default = {}
}

variable "vpc_tags" {
  default = {}
}

variable "project_name" {
  type = string
}

variable "environmet" {
  type = string
}

# igw tags
variable "igw_tags" {
  default = {}
}

#  public subnet tags

variable "public_subnet_tags" {
  default = {}
}

variable "public_subnet_cidr_blocks" {
  type = list(string)
  validation {
    condition = length(var.public_subnet_cidr_blocks) == 2
    error_message = "please provide two CIDR blocks for public subnet"
  }
}


variable "private_subnet_tags" {
  default = {}
}

variable "private_subnet_cidr_blocks" {
  type = list(string)
  validation {
    condition = length(var.private_subnet_cidr_blocks) == 2
    error_message = "please provide two CIDR blocks for private subnet"
  }
}

variable "db_subnet_tags" {
  default = {}
}

variable "db_subnet_cidr_blocks" {
  type = list(string)
  validation {
    condition = length(var.db_subnet_cidr_blocks) == 2
    error_message = "please provide two CIDR blocks for db subnet"
  }
}

variable "db_subnet_group_tags" {
  default = {}
}

variable "public_route_table_tags" {
  default = {}
}

variable "private_route_table_tags" {
  default = {}
}

variable "database_route_table_tags" {
  default = {}
}