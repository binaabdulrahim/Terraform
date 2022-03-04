provider "aws" {
    region = "us-east-1"

}

resource "aws_instance" "my_ec2" {
    ami = "ami-005d843eadb96ed7f "
    instance_type = "t2.micro"

    tags = {
        Name = "my_ec2"
    }
}