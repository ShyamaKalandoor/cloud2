# Define the provider
provider "aws" {
  region = "us-east-1"

  
}

# Create a security group to allow HTTP and SSH traffic
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and SSH traffic"

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
}

# Create a key pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Define the EC2 instance
resource "aws_instance" "web" {
  ami           = "ami-0bb84b8ffd87024d8" # Amazon Linux 2 AMI (replace with your desired AMI)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<html><body><h1>Hello, World</h1></body></html>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "WebServer"
  }
}

# Output the public IP address of the instance
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}