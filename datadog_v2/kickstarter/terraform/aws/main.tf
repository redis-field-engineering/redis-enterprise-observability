terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "aws_vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet" "aws_subnet" {
  filter {
    name   = "tag:Name"
    values = [var.subnet_name]
  }
}

data "aws_security_group" "aws_security_group" {
  filter {
    name   = "tag:Name"
    values = [var.aws_security_group_name]
  }
}

resource "aws_instance" "datadog_agent_vm" {
  ami                    = var.aws_ami_id
  instance_type          = "t3.medium"
  key_name               = var.aws_key_name
  subnet_id              = data.aws_subnet.aws_subnet.id
  vpc_security_group_ids = [data.aws_security_group.aws_security_group.id]

  tags = {
    Name = "datadog-agent-vm"
  }
}

resource "null_resource" "install_datadog_agent" {
  connection {
    type        = "ssh"
    host        = aws_instance.datadog_agent_vm.public_ip
    user        = "ubuntu"
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "DD_API_KEY=${var.datadog_api_key} DD_SITE=\"${var.datadog_site}\" bash -c \"$(curl -L https://install.datadoghq.com/scripts/install_script_agent7.sh)\"",
      "sudo apt update",
      "sudo datadog-agent integration install -r -t datadog-redis_enterprise_prometheus==1.0.0",
    ]
  }

  provisioner "file" {
    source      = "config.yaml.example"
    destination = "conf.yaml.template"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get install -y gettext-base",
      "export REDIS_FQDN=${var.redis_fqdn}",
      "envsubst < conf.yaml.template > conf.yaml",
      "sudo cp conf.yaml /etc/datadog-agent/conf.d/redis_enterprise_prometheus.d/conf.yaml",
      "sudo systemctl restart datadog-agent"
    ]
  }

  depends_on = [aws_instance.datadog_agent_vm]
}

output "instance_ip" {
  description = "Public IP address of the Datadog agent instance"
  value       = aws_instance.datadog_agent_vm.public_ip
}
