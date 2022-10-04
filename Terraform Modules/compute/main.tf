# - - - compute/main.tf - - - 
# use the data source to get the ID of AMI. No need to hardcode one.
data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "random_id" "tf_node_id" {
  byte_length = 2
  count       = var.instance_count
  #force random_id to change whenever we modify something like keypair. Forces replacements especially if you need different ids
  keepers = {
    key_name = var.key_name
  }
}

resource "aws_key_pair" "tfckey" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "tf_node" {
  count         = var.instance_count
  instance_type = var.instance_type
  ami           = data.aws_ami.server_ami.id
  tags = {
    Name = "tf_node-${random_id.tf_node_id[count.index].dec}" #dec means decimal of random id we are using 
  }

  # create the key name via cli: ssh-keygen -t rsa (use whatever is compatible) then run ls ~/.ssh/ 
  key_name               = aws_key_pair.tfckey.id
  vpc_security_group_ids = [var.public_sg]
  subnet_id              = var.public_subnets[count.index]

  #use templatefile function reads the file at the given path and renders its content
  user_data = templatefile(var.user_data_path,
    {
      nodename    = "tf-${random_id.tf_node_id[count.index].dec}"
      db_endpoint = var.db_endpoint
      dbuser      = var.dbuser
      dbpass      = var.dbpassword
      dbname      = var.dbname

    }
  )
  root_block_device {
    volume_size = var.vol_size # 10
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file(var.private_key_path)
    }
    script = "${path.cwd}/delay.sh"

  }
  provisioner "local-exec" {
    command = templatefile("${path.cwd}/scp_script.tpl",
      {
        nodeip   = self.public_ip
        k3s_path = "${path.cwd}/../"
        nodename = self.tags.Name
        private_key_path = var.private_key_path
      }
    )
  }
  provisioner "local-exec" {
    when = destroy
    command = "rm -f ${path.cwd}/../k3s-${self.tags.Name}.yaml"
  
  }
}

resource "aws_lb_target_group_attachment" "tf_tg_attach" {
  count            = var.instance_count
  target_group_arn = var.lb_target_group_arn
  target_id        = aws_instance.tf_node[count.index].id
  port             = var.tg_port
}