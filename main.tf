provider "aws" {
  region = "us-east-1"  # Change region as needed
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}

# Create a Subnet inside the VPC
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true  # Enables public IP for EC2 instances in this subnet

  tags = {
    Name = "my-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-internet-gateway"
  }
}

# Attach Internet Gateway to VPC
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my-route-table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "my_rta" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create a Security Group allowing all inbound and outbound traffic
resource "aws_security_group" "allow_all" {
  vpc_id = aws_vpc.my_vpc.id

  # Allow all inbound traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-all-traffic"
  }
}

# Create an EC2 Instance in the Subnet
resource "aws_instance" "my_ec2" {
  ami                    = "ami-06b21ccaeff8cd686"  # Amazon Linux 2 AMI ID (Change as needed)
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  associate_public_ip_address = true  # Ensure public IP for access

  key_name = "Controller_key"  # Replace with your key pair name

  user_data = <<EOF
#!/bin/bash
sudo yum install httpd -y
sudo systemctl enable httpd
echo "Hello, Welcome to bharghav page" > /var/www/html/index.html
sudo systemctl restart httpd
EOF

  tags = {
    Name = "my-ec2-instance"
  }
}

# Output the Public IP of EC2 Instance
output "ec2_public_ip" {
  value = aws_instance.my_ec2.public_ip
}
