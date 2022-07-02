resource "aws_instance" "master" {
  count = 2
  ami           = data.aws_ami.latest_ubuntu_linux.id
  instance_type = "t2.medium"
  key_name      = "wordpress-key"
  subnet_id = aws_subnet.test_subnet_private_1.id
  vpc_security_group_ids = [aws_security_group.es_sg.id]
  user_data       = data.template_file.user_data_master.rendered
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }
  tags = {
    Name = "master${count.index}"
  }
}


resource "aws_instance" "node" {
  count = 4
  ami           = data.aws_ami.latest_ubuntu_linux.id
  instance_type = "t2.medium"
  key_name      = "wordpress-key"
  subnet_id = "${element([aws_subnet.test_subnet_private_1.id, aws_subnet.test_subnet_private_2.id, aws_subnet.test_subnet_private_1.id, aws_subnet.test_subnet_private_2.id], count.index)}"
  vpc_security_group_ids = [aws_security_group.es_sg.id]
  user_data       = data.template_file.user_data_nodes.rendered
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }
  tags = {
    Name = "node${count.index}"
  }
}
