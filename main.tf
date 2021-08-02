provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "shreya-vpc" {
  cidr_block           = "10.5.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"
  tags = {
    creator = "shreya"
  }
}
resource "aws_subnet" "sg-subnet-public" {
  vpc_id                  = aws_vpc.shreya-vpc.id
  cidr_block              = "10.5.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
}
resource "aws_subnet" "sg-subnet-private" {
  vpc_id                  = aws_vpc.shreya-vpc.id
  cidr_block              = "10.5.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"
}
resource "aws_internet_gateway" "shreya-igw" {
  vpc_id = aws_vpc.shreya-vpc.id
}
resource "aws_route_table" "shreya-route-table" {
  vpc_id = aws_vpc.shreya-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.shreya-igw.id
  }
}
resource "aws_route_table_association" "sg-route-table-public-subnet" {
  subnet_id      = aws_subnet.sg-subnet-public.id
  route_table_id = aws_route_table.shreya-route-table.id
}
resource "aws_security_group" "sg-security-group" {
  vpc_id = aws_vpc.shreya-vpc.id
  tags = {
    creator = "shreya"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
resource "aws_instance" "shreya-ec2-instance" {
  ami                    = "ami-id"
  instance_type          = "t2.micro"
  user_data              = file("script.sh")
  key_name               = "shreya-sa-key"
  vpc_security_group_ids = [aws_security_group.sg-security-group.id]
  subnet_id              = aws_subnet.sg-subnet-public.id
  tags = {
    Name = "shreya-terraform"
  }
}
