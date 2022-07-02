#!/bin/bash
terraform apply --auto-approve
cd ansible/
ansible all -m ping
ansible-playbook playbook_send_conf.yml
