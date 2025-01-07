
# Terraform VPC Module

This Terraform module creates a Virtual Private Cloud (VPC) in AWS along with subnets, route tables, NAT Gateway, and associated resources. The module is designed to set up a highly available network infrastructure across two Availability Zones.

![alt text](vpc.drawio.svg)


![alt text](peering.drawio.svg)

The above diagram illustrates how the route table helps to determine communication pathways

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
- **Database Subnets**: For database instances with internet access through NAT Gateway.

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



# VPC Peering Configuration

for better understanding, considered first VPC name as `expense-vpc`.

This document explains the configuration of a VPC peering connection between the `expense-dev` VPC and the `default` VPC, along with the routes created to enable communication.

## Architecture Overview

### VPCs Involved
1. **expense-dev VPC**
   - CIDR: 10.1.0.0/16
   - Subnets: Public, Private, and Database
2. **default VPC**
   - CIDR: 172.31.0.0/16
   - Default subnets

### VPC Peering
- Peering connection established from:
  - **expense-dev VPC** → **default VPC**
  - **default VPC** → **expense-dev VPC**

### Routes
1. **From expense-dev VPC to default VPC**:
   - Added routes in public, private, and database route tables with `vpc_peering_connection_id`.
2. **From default VPC to expense-dev VPC**:
   - Added a route in the default route table with the `vpc_peering_connection_id`.

## Resources Created

### VPC Peering Connection
- A VPC peering connection was established between the `expense-dev` VPC and the `default` VPC.

### Route Tables and Routes
1. **expense-dev VPC**:
   - Public Route Table:
     - Destination CIDR: 172.31.0.0/16
     - Target: VPC Peering Connection
   - Private Route Table:
     - Destination CIDR: 172.31.0.0/16
     - Target: VPC Peering Connection
   - Database Route Table:
     - Destination CIDR: 172.31.0.0/16
     - Target: VPC Peering Connection

2. **default VPC**:
   - Default Route Table:
     - Destination CIDR: 10.1.0.0/16
     - Target: VPC Peering Connection

## Terraform Configuration

```hcl
resource "aws_vpc_peering_connection" "example" {
  peer_vpc_id = aws_vpc.default.id
  vpc_id      = aws_vpc.expense_dev.id

  tags = {
    Name = "expense-dev-to-default"
  }
}

resource "aws_route" "public_to_default" {
  route_table_id        = aws_route_table.public.id
  destination_cidr_block = aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.example.id
}

resource "aws_route" "default_to_expense" {
  route_table_id        = aws_vpc.default.main_route_table_id
  destination_cidr_block = aws_vpc.expense_dev.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.example.id
}
```

## Diagram

Below is a high-level representation of the setup:

```
expense-dev VPC (10.1.0.0/16)
    ├── Public Subnet
    ├── Private Subnet
    └── Database Subnet
        │
        │ (VPC Peering Connection)
        ▼
default VPC (172.31.0.0/16)
    ├── Default Subnet
```

## How It Works

1. **VPC Peering Connection**: Establishes a direct connection between the two VPCs.
2. **Routes**: Enables traffic flow between the VPCs by creating routes in the respective route tables.
3. **Communication**: Instances in the subnets can communicate with each other over private IPs as long as the security groups and network ACLs allow the traffic.

## Prerequisites

- AWS CLI configured with appropriate permissions.
- Terraform installed locally.





