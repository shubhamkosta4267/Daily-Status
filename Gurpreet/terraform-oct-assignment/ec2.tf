provider "aws"{
    region = "us-east-1"
}


resource "aws_instance" "webserver1" {
  ami           = "ami-0149b2da6ceec4bb0"
  instance_type = "t2.micro"
  key_name = "terraformoct"
  subnet_id = aws_subnet.publicsubnet.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.securitygroup.id]

  tags = {
    Name = "webserver1"
  }
  user_data = <<-EOF
  #!/bin/bash
  
  apt update
  apt install nginx -y
  EOF 
}

resource "aws_instance" "webserver2" {
  ami           = "ami-0149b2da6ceec4bb0"
  instance_type = "t2.micro"
  key_name = "terraformoct"
  subnet_id = aws_subnet.publicsubnet.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.securitygroup.id]

  tags = {
    Name = "webserver2"
  }

  user_data = <<-EOF
  #!/bin/bash
  
  apt update
  apt install apache2 -y
  EOF 
}
