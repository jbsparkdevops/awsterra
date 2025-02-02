

# Variables

variable "server_name" {
        default = "adithya-instance"
}


resource "aws_instance" "myserver" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"
  key_name = "Controller_key"
  user_data = <<EOF
#!/bin/bash
sudo yum install httpd -y
sudo systemctl enable httpd
echo "Hello, Welcome to Terraform" > /var/www/html/index.html
sudo systemctl restart httpd
EOF
  tags = {
    Name = "${var.server_name}"
  }
}


output "mypublicip" {
        value = "${aws_instance.myserver.public_ip}"

}
