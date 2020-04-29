provider "aws" {
    region = "eu-west-1"
}

# Create a VPC
resource "aws_vpc" "app_vpc" {
   cidr_block = "10.0.0.0/16"
   tags = {
       Name = "${var.name}-vpc"
   }
}

# Creates an internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "${var.name}-ig"
  }
}

module "app" {
  source = "./modules/app_tier"
  vpc_id = aws_vpc.app_vpc.id
  name = var.name
  ami_id = var.app_ami_id
  gateway_id_var = aws_internet_gateway.igw.id
  db_ip = module.db.instance_ip_address
}

module "db" {
  source = "./modules/db_tier"
  vpc_id = aws_vpc.app_vpc.id
  name = var.name
  ami_id = var.db_ami_id
  gateway_id_var = aws_internet_gateway.igw.id
}
