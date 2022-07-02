resource "aws_instance" "bastion" {
  ami           = data.aws_ami.latest_ubuntu_linux.id
  instance_type = "t2.micro"
  key_name      = "bastion"
  subnet_id = aws_subnet.test_subnet_public_1.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  user_data       = data.template_file.user_data_bastion.rendered
  tags = {
    Name = "bastion"
  }
  provisioner "local-exec"{
    command = <<-EOT
    echo "$(aws ec2 describe-instances --region us-east-1 --instance-ids $(aws autoscaling describe-auto-scaling-instances --region us-east-1 --output text \
--query "AutoScalingInstances[?AutoScalingGroupName=='${aws_autoscaling_group.wordpress_autoscaling.name}'].InstanceId") --query "Reservations[].Instances[].PrivateIpAddress" --output text)" > ./ansible/hosts.txt
    sed -i.bak 's/\t/\n/g' ./ansible/hosts.txt
    sed -i 's/-q ubuntu@.* -o I/-q ubuntu@${aws_instance.bastion.public_ip} -o I/' ./ansible/group_vars/all
    sed -i "s|http://.*:9200/_cluster/|http://${aws_instance.master[0].private_ip}:9200/_cluster/|" http_checker.py
    rm code.zip
    zip -g code.zip http_checker.py
    echo "${aws_instance.master[0].private_ip}
    ${aws_instance.master[1].private_ip}
    ${aws_instance.node[0].private_ip}
    ${aws_instance.node[1].private_ip}
    ${aws_instance.node[2].private_ip}
    ${aws_instance.node[3].private_ip}
    ${aws_instance.logstash[0].private_ip}
    ${aws_instance.logstash[1].private_ip}
    ${aws_instance.kibana.public_ip}" >> ./ansible/hosts.txt
    echo "127.0.0.1 localhost
    ${aws_instance.master[0].private_ip}  ${aws_instance.master[0].tags.Name}
    ${aws_instance.master[1].private_ip}  ${aws_instance.master[1].tags.Name}
    ${aws_instance.node[0].private_ip}  ${aws_instance.node[0].tags.Name}
    ${aws_instance.node[1].private_ip}  ${aws_instance.node[1].tags.Name}
    ${aws_instance.node[2].private_ip}  ${aws_instance.node[2].tags.Name}
    ${aws_instance.node[3].private_ip}  ${aws_instance.node[3].tags.Name}
    ::1     ip6-localhost ip6-loopback 
    fe00::0 ip6-localnet 
    ff00::0 ip6-mcastprefix 
    ff02::1 ip6-allnodes 
    ff02::2 ip6-allrouters" > ./ansible/conf/hosts
    EOT
  }
}
