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

data "aws_vpc" "aws-vpc" {
    filter {
        name   = "tag:Name"
        values = [var.vpc_name]
    }  
}

data "aws_subnet" "aws-subnet" {
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

resource "aws_instance" "prometheus" {
  ami           = var.aws_ami_id
  instance_type = "t3.medium"
  key_name      = var.aws_key_name
  subnet_id     = data.aws_subnet.aws-subnet.id
  vpc_security_group_ids = [data.aws_security_group.aws_security_group.id]
  tags = {
    Name = "redis-prometheus-newrelic-vm"
  }
}

resource "aws_route53_record" "prometheus-dns" {
    count   = var.dns_zone_id != "" ? 1 : 0
    zone_id = var.dns_zone_id
    name    = "newrelic.prometheus.${var.subdomain}"
    type    = "A"
    ttl     = 300
    records = [aws_instance.prometheus.public_ip]
}

resource "null_resource" "setup_prometheus" {
    connection {
      type = "ssh"
      host = aws_instance.prometheus.public_ip
      user = "ubuntu"
      private_key = file(var.ssh_private_key)
    }

    provisioner "file" {
        content = templatefile("${path.module}/prometheus.template.yml", {
            redis_fqdn = var.redis_fqdn
            newrelic_bearer_token = var.newrelic_bearer_token
            newrelic_service_name = var.newrelic_service_name
        })
        destination = "prometheus.yml"
    }

    provisioner "remote-exec" {
      inline = [
        "sudo apt-get update",
        "sudo apt-get install -y wget tar",
        "sudo useradd --no-create-home --shell /bin/false prometheus",
        "sudo mkdir -p /etc/prometheus",
        "sudo mkdir -p /var/lib/prometheus",
        "sudo chown prometheus:prometheus /etc/prometheus",
        "sudo chown prometheus:prometheus /var/lib/prometheus",
        "wget https://github.com/prometheus/prometheus/releases/download/v2.42.0/prometheus-2.42.0.linux-amd64.tar.gz",
        "tar xvf prometheus-2.42.0.linux-amd64.tar.gz",
        "sudo mv prometheus-2.42.0.linux-amd64/prometheus /usr/local/bin/",
        "sudo mv prometheus-2.42.0.linux-amd64/promtool /usr/local/bin/",
        "sudo mv prometheus-2.42.0.linux-amd64/consoles /etc/prometheus",
        "sudo mv prometheus-2.42.0.linux-amd64/console_libraries /etc/prometheus",
        "sudo cp ./prometheus.yml /etc/prometheus/prometheus.yml",
        "sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml",

        "echo '[Unit]' | sudo tee -a /etc/systemd/system/prometheus.service",
        "echo 'Description=Prometheus Service' | sudo tee -a /etc/systemd/system/prometheus.service",
        "echo 'Wants=network-online.target' | sudo tee -a /etc/systemd/system/prometheus.service",
        "echo 'After=network-online.target' | sudo tee -a /etc/systemd/system/prometheus.service",
        "echo '[Service]' | sudo tee -a /etc/systemd/system/prometheus.service",
        "echo 'User=prometheus' | sudo tee -a /etc/systemd/system/prometheus.service",
        "echo 'Group=prometheus' | sudo tee -a /etc/systemd/system/prometheus.service",
        "echo 'Type=simple' | sudo tee -a /etc/systemd/system/prometheus.service",
        "echo 'ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/' | sudo tee -a /etc/systemd/system/prometheus.service",
        "echo '[Install]' | sudo tee -a /etc/systemd/system/prometheus.service",
        "echo 'WantedBy=multi-user.target' | sudo tee -a /etc/systemd/system/prometheus.service",
        "sudo systemctl daemon-reload",
        "sudo systemctl start prometheus",
        "sudo systemctl enable prometheus",
      ]      
    }

    depends_on = [aws_instance.prometheus]
}

output "instance_ip" {
  description = "Public IP address of the Prometheus instance"
  value       = aws_instance.prometheus.public_ip
}

output "dns_record" {
  description = "Full DNS record for the Prometheus instance"
  value       = var.dns_zone_id != "" ? aws_route53_record.prometheus-dns[0].fqdn : "DNS not configured"
}

output "prometheus_endpoint" {
  description = "Prometheus service endpoint"
  value       = var.dns_zone_id != "" ? "http://prometheus.${var.subdomain}:9090" : "http://${aws_instance.prometheus.public_ip}:9090"
}