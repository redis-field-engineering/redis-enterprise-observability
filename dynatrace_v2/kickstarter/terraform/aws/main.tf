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

resource "aws_instance" "activegate" {
  ami           = var.aws_ami_id
  instance_type = "t3.small"
  key_name      = var.aws_key_name
  subnet_id     = data.aws_subnet.aws-subnet.id
  vpc_security_group_ids = [data.aws_security_group.aws_security_group.id]
  tags = {
    Name = "fe-activegate-vm"
  }
}


resource "aws_route53_record" "fe-activegate-dns" {
    zone_id = var.dns_zone_id
    name    = "activegate.${var.subdomain}"
    type    = "A"
    ttl     = 300
    records = [aws_instance.activegate.public_ip]
  
}

locals {
  dynatrace_tenant_url = "https://${var.tenant_id}.live.dynatrace.com"
  activegate_installer_url = "https://${var.tenant_id}.live.dynatrace.com/api/v1/deployment/installer/gateway/unix/latest?arch=x86"
}

resource "null_resource" "install_activegate" {
    connection {
      type = "ssh"
      host = aws_instance.activegate.public_ip
      user = "ubuntu"
      private_key = file(var.ssh_private_key)
    }

    provisioner "remote-exec" {
      inline = [
        "sudo apt-get update",
        "sudo apt-get install -y wget",
        "wget -O ActiveGate.sh \"${local.activegate_installer_url}\" --header=\"Authorization: Api-Token ${var.dynatrace_api_token}\"",
        "chmod +x ActiveGate.sh",
        "sudo ./ActiveGate.sh"
      ]      
    }

    triggers = {
        extension_hash = filesha256("../../../src/extension.yaml")
        dynatrace_api_token = var.dynatrace_api_token
        dynatrace_tenant_url = local.dynatrace_tenant_url
    }

    depends_on = [aws_instance.activegate]
}

resource "null_resource" "upload_extension" {
      provisioner "local-exec" {
        command = <<EOT
            python3 -m venv .dt_venv
            source .dt_venv/bin/activate
            pip install dt-cli
            base_dir=$(pwd)
            cd ../../..
            dt extension assemble
            dt extension sign --key $base_dir/${var.developer_pem}
            dt extension upload --tenant-url ${local.dynatrace_tenant_url} --api-token ${var.dynatrace_api_token} bundle.zip
        EOT
    }

    provisioner "local-exec" {
        when = destroy
        command = <<EOT
            python3 -m venv .dt_venv
            source .dt_venv/bin/activate
            DTCLI_API_TOKEN=${self.triggers.dynatrace_api_token} dt extension delete --tenant-url ${self.triggers.dynatrace_tenant_url} custom:com.redis.enterprise.extension
        EOT
    }

    triggers = {
        extension_hash = filesha256("../../../src/extension.yaml")
        dynatrace_api_token = var.dynatrace_api_token
        dynatrace_tenant_url = local.dynatrace_tenant_url
    }

    depends_on = [null_resource.install_activegate]
}

resource "null_resource" "install_ca_pem" {
  provisioner "file" {
    source      = var.custom_ca_pem
    destination = "ca.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv ~/ca.pem /var/lib/dynatrace/remotepluginmodule/agent/conf/certificates/ca.pem",
      "sudo systemctl restart dynatracegateway"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.activegate.public_ip
    user        = "ubuntu"
    private_key = file(var.ssh_private_key)
  }

  depends_on = [null_resource.install_activegate]
  
}

locals {
  primary_endpoint = "https://${var.redis_fqdn}:8070/v2"
}

resource "null_resource" "create_monitoring_configuration" {
    depends_on = [ aws_instance.activegate, null_resource.upload_extension, null_resource.install_activegate, null_resource.install_ca_pem ]
      provisioner "local-exec" {
        command = "../scripts/start-monitoring.sh ${local.primary_endpoint} ${var.extension_version} ${var.dynatrace_api_token} ${var.tenant_id}"
    } 

    provisioner "local-exec" {
        when = destroy    
        command = "../scripts/stop-monitoring.sh ${self.triggers.token} ${self.triggers.tenant_id}"
    }

    triggers = {
        token = var.dynatrace_api_token
        tenant_id = var.tenant_id
    }
}

output "instance_ip" {
  description = "Public IP address of the ActiveGate instance"
  value       = aws_instance.activegate.public_ip
}

output "dns_record" {
  description = "Full DNS record for the ActiveGate instance"
  value       = aws_route53_record.fe-activegate-dns.fqdn
}