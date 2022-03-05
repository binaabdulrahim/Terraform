provider "aws" {
    region = "us-east-1"  
}

resource "aws_instance" "web_server_ec2" {
    ami = "ami-0c293f3f676ec4f90"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html 
                nohup busybox httpd -f -p 8080 &
            EOF
    tags = {
        Name = "web_server_ec2"
    }
  
}


#create security group so AWS can allow incoming and outgoing traffic on EC2 instance
resource "aws_security_group" "ec2_sg" {
    name = "web-server-ec2-sg"

#ingress allows incoming tcp traffic on port 8080
    ingress = [ {
      description      = "Allow HTTP from anywhere"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]  
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false      
    } ]
}

 
