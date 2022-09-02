terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["/Users/binafshaabdul/.aws/credentials"]
}

# Create a VPC
resource "aws_vpc" "twotier_architecture_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "My 2 Tier Architecture VPC"
  }
}

#create a security group for public subnet
resource "aws_security_group" "twotier_sg" {
  name   = "twotier-sg"
  vpc_id = aws_vpc.twotier_architecture_vpc.id

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

  tags = {
    Name = "twotier-sg"
  }
}


# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

#Create 2 public subnets in different AZ 
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.twotier_architecture_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.twotier_architecture_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 2"
  }
}

#create internet gateway
resource "aws_internet_gateway" "twotier_gw" {
  vpc_id = aws_vpc.twotier_architecture_vpc.id
  tags = {
    Name = "2tier igw"
  }
}

#route table for public subnets  
resource "aws_route_table" "twotier_route_table" {
  vpc_id = aws_vpc.twotier_architecture_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.twotier_gw.id
  }

  tags = {
    Name = "2tier route table"
  }
}

resource "aws_route_table_association" "public_sub1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.twotier_route_table.id
}

resource "aws_route_table_association" "public_sub2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.twotier_route_table.id
}

#Create 1 EC2 in each of the public subnet
resource "aws_instance" "ec2_subnet1" {
  ami                         = "ami-05fa00d4c63e32376"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet1.id
  security_groups             = [aws_security_group.twotier_sg.id]
  associate_public_ip_address = true
  user_data                   = <<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start httpd
        systemctl enable httpd
        echo "<html><body><h1>Bina's Two Tier Architect Project with Terraform</h1></body></html>" > /var/www/html/index.html
        EOF
  tags = {
    Name = "EC2 for public subnet 1"
  }
}

resource "aws_instance" "ec2_subnet2" {
  ami                         = "ami-05fa00d4c63e32376"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet2.id
  security_groups             = [aws_security_group.twotier_sg.id]
  associate_public_ip_address = true
  user_data                   = <<-EOFF
  #!/bin/bash
  read -r -d '' META <<- EOF
  Bina Abdul Rahim
  LinkedIn: https://www.linkedin.com/in/binaabdulrahim
  EOF
echo "$META"
EOFF

  tags = {
    Name = "EC2 for public subnet 2"
  }
}

# Create a nat gateway
resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = {
    Name = "NAT gw"
  }
}

#Create 2 private subnets in different AZ + RDS MySQL for one of the subnets 
resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.twotier_architecture_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.twotier_architecture_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet 2"
  }
}

#Create a private SG
resource "aws_security_group" "twotier_private_sg" {
  name        = "twotier_private-sg"
  description = "Allow web tier and ssh traffic"
  vpc_id      = aws_vpc.twotier_architecture_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]
    security_groups = [aws_security_group.twotier_sg.id]
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
#route table for private subnet
resource "aws_route_table" "twotier_private_route_table" {
  vpc_id = aws_vpc.twotier_architecture_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.twotier_gw.id
  }

  tags = {
    Name = "priavte tier route table"
  }
}

resource "aws_route_table_association" "private_sub1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.twotier_private_route_table.id
}

resource "aws_route_table_association" "private_sub2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.twotier_private_route_table.id
}



# Database subnet group
resource "aws_db_subnet_group" "twotier_db_subnet" {
  name       = "main"
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
}

#MySQL RDS 

resource "aws_db_instance" "rds_mysql" {
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "8.0.28"
  instance_class         = "db.t3.micro"
  username               = "bina"
  password               = "binabina"
  db_subnet_group_name   = aws_db_subnet_group.twotier_db_subnet.id
  vpc_security_group_ids = [aws_security_group.twotier_private_sg.id]
  publicly_accessible    = true
  skip_final_snapshot    = true
}

#Create application load balancer creation for public subnet

resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.twotier_sg.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

}

#Target group
resource "aws_lb_target_group" "my_target" {
  name     = "my-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.twotier_architecture_vpc.id

  depends_on = [
    aws_vpc.twotier_architecture_vpc
  ]
}


resource "aws_lb_target_group_attachment" "attachment-1" {
  target_group_arn = aws_lb_target_group.my_target.arn
  target_id        = aws_instance.ec2_subnet1.id
  port             = 80

  depends_on = [
    aws_instance.ec2_subnet1
  ]
}

resource "aws_lb_target_group_attachment" "attachment-2" {
  target_group_arn = aws_lb_target_group.my_target.arn
  target_id        = aws_instance.ec2_subnet2.id
  port             = 80

  depends_on = [
    aws_instance.ec2_subnet2
  ]
}

#Create listener
resource "aws_lb_listener" "listener_balance" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target.arn
  }
}


