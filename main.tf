# Define a variable for server name
variable "server_name" {
  default = "adithya-instance"
}

# Define a Security Group
resource "aws_security_group" "my_sg" {
  name        = "my_security_group"
  description = "Allow HTTP and SSH inbound traffic"

  # Inbound Rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP access from anywhere
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.25/32"] # Replace YOUR_IP with your actual public IP
  }

  # Outbound Rules (Allow all traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an AWS EC2 instance
resource "aws_instance" "myserver" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"
  key_name      = "Controller_key"

  # Attach Security Group
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  # User Data to install Apache and create a web page
  user_data = <<EOF
#!/bin/bash
sudo yum install httpd -y
sudo systemctl enable httpd
echo "Hello, Welcome to bharghav page" > /var/www/html/index.html
sudo systemctl restart httpd
EOF

  # Assign a tag to the instance
  tags = {
    Name = var.server_name
  }
}

# Output Public IP Address
output "mypublicip" {
  value = aws_instance.myserver.public_ip
}
