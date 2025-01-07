
# Terraform VPC Module

This Terraform module creates a Virtual Private Cloud (VPC) in AWS along with subnets, route tables, NAT Gateway, and associated resources. The module is designed to set up a highly available network infrastructure across two Availability Zones.

![alt text](vpc.drawio.svg)

## Features

- Creates a VPC with the specified CIDR block.
- Provisions Internet Gateway (IGW) for public internet access.
- Creates public, private, and database subnets across two Availability Zones.
- Configures Elastic IP (EIP) and NAT Gateway for private subnets.
- Creates Route Tables and routes for public, private, and database subnets.
- Associates Route Tables with the respective subnets.

## Architecture Overview

### Resources Created
- VPC
- Internet Gateway (IGW)
- Public, Private, and Database subnets (in two Availability Zones)
- Elastic IP for NAT Gateway
- NAT Gateway
- Route Tables and Route Table Associations

### Subnet Distribution
- **Public Subnets**: For resources requiring direct internet access.
- **Private Subnets**: For application servers with internet access through NAT Gateway.
- **Database Subnets**: For database instances, isolated from internet access.

## Usage

```hcl
module "vpc" {
  source = "path/to/your/module"

  vpc_cidr          = "10.0.0.0/16"

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnets = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]

  database_subnets = [
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]


}
```

## Inputs

| Name                 | Type          | Description                                                  | Default         |
|----------------------|---------------|--------------------------------------------------------------|-----------------|
| `vpc_cidr`           | `string`      | CIDR block for the VPC                                       | "10.0.0.0/16"            |
| `public_subnets`     | `list(string)`| CIDR blocks for public subnets                               | n/a             |
| `private_subnets`    | `list(string)`| CIDR blocks for private subnets                              | n/a             |
| `database_subnets`   | `list(string)`| CIDR blocks for database subnets                             | n/a             |
| `project_name` | `string`        |       project_name is required                        | `no default`         |
| `environment` | `string`        | environment is requied                              | `no default`         |

## Outputs

| Name                | Description                                  |
|---------------------|----------------------------------------------|
| `vpc_id`            | ID of the created VPC                       |
| `public_subnets`    | IDs of the created public subnets            |
| `private_subnets`   | IDs of the created private subnets           |
| `database_subnets`  | IDs of the created database subnets          |
| `nat_gateway_id`    | ID of the created NAT Gateway (if enabled)   |
| `route_table_ids`   | IDs of the created route tables              |

## How It Works

1. **VPC Creation**: The module creates a VPC with the specified CIDR block.
2. **Subnet Creation**: Public, private, and database subnets are created in the first two Availability Zones in the specified region.
3. **Internet Gateway**: An IGW is provisioned and attached to the VPC for internet access.
4. **Route Tables**: Separate Route Tables are created for public, private, and database subnets.
5. **NAT Gateway**: a NAT Gateway is created in the public subnet to provide internet access for the private subnets.
6. **Routing**: Routes are added to the Route Tables:
   - Public subnets: Route to IGW.
   - Private and Database subnets: Route to NAT Gateway.
7. **Associations**: Subnets are associated with their respective Route Tables.

## Prerequisites

- AWS CLI configured with proper credentials.
- Terraform installed on your local machine.



