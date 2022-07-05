data "aws_ami" "latest_ubuntu_linux" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "template_file" "user_data_wordpress" {
  template = "${file("user_data_wordpress.sh")}"
  vars = {
    db_endpoint = "${aws_db_instance.wordpress_db.address}"
    efs_endpoint = "${aws_efs_file_system.wordpress_efs.dns_name}"
    db_username = "${local.db_cred.db_username}"
    db_password = "${local.db_cred.db_password}"
    ip_logstash0 = "${aws_instance.logstash[0].private_ip}"
    ip_logstash1 = "${aws_instance.logstash[1].private_ip}"
  }
}

data "aws_secretsmanager_secret_version" "db_cred" {
  secret_id = "db_cred"
}

locals {
  db_cred = jsondecode(data.aws_secretsmanager_secret_version.db_cred.secret_string)
}

data "aws_acm_certificate" "issued" {
  domain   = "wordpressdenisdugar.click"
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "myZone" {
  name         = "wordpressdenisdugar.click"
}

data "template_file" "user_data_master" {
  template = "${file("user_data_master.sh")}"
}

data "template_file" "user_data_bastion" {
  template = "${file("user_data_bastion.sh")}"
}

data "template_file" "user_data_nodes" {
  template = "${file("user_data_nodes.sh")}"
}

data "template_file" "user_data_logstash" {
  template = "${file("user_data_logstash.sh")}"
}

data "template_file" "user_data_kibana" {
  template = "${file("user_data_kibana.sh")}"
}

data "aws_sns_topic" "http_checker_error" {
  name = "http_checker_error"
}
