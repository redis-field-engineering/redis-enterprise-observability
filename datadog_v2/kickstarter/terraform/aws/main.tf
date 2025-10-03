terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
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
  ami           = var.aws_ami_id
  instance_type = "t3.medium"
  key_name      = var.aws_key_name
  subnet_id     = data.aws_subnet.aws_subnet.id
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
      "git clone https://github.com/redis-field-engineering/datadog-integrations-extras",
      "sudo apt update",
      "sudo apt install -y software-properties-common",
      "sudo add-apt-repository ppa:deadsnakes/ppa -y",
      "sudo apt update",
      "sudo apt install -y python3.12 python3.12-venv python3.12-dev",
      "python3.12 -m venv venv",
      ". venv/bin/activate",
      "pip install build",
      "cd datadog-integrations-extras",
      "git checkout v2-metrics-extended",
      "cd ${var.datadog_integration_name}",
      "python3.12 -m build --wheel",
      "sudo datadog-agent integration install -r -w  ./dist/datadog_redis_enterprise_prometheus-2.0.1-py3-none-any.whl",
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