resource "aws_instance" "kibana" {
  ami           = data.aws_ami.latest_ubuntu_linux.id
  instance_type = "t2.micro"
  key_name      = "wordpress-key"
  subnet_id = aws_subnet.test_subnet_public_1.id
  vpc_security_group_ids = [aws_security_group.kibana_sg.id]
  user_data       = data.template_file.user_data_kibana.rendered
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }
  tags = {
    Name = "kibana"
  }
}

output "kibana_ip"{
  value = aws_instance.kibana.public_ip
}