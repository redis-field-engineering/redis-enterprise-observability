# main.tf

provider "google" {
  project = var.project
  region  = var.region
}

terraform {
    required_providers {
        dynatrace = {
            version = "~> 1.0"
            source = "dynatrace-oss/dynatrace"
        }
    }
} 

data "google_compute_network" "primary_network" {
    name = var.network   
}

resource "google_compute_instance" "activegate" {
  name         = "dynatrace-activegate"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20240731"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet
    access_config {}
  }

  tags = ["dynatrace"]
}

locals {
  dynatrace_tenant_url = "https://${var.tenant_id}.live.dynatrace.com"
  activegate_installer_url = "https://${var.tenant_id}.live.dynatrace.com/api/v1/deployment/installer/gateway/unix/latest?arch=x86"
}

resource "null_resource" "install_activegate" {
  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "sudo apt-get update",
      "sudo apt-get install -y wget",
      "wget -O ActiveGate.sh \"${local.activegate_installer_url}\" --header=\"Authorization: Api-Token ${var.dynatrace_api_token}\"",
      "chmod +x ActiveGate.sh",
      "sudo ./ActiveGate.sh",
      "sudo add-apt-repository ppa:deadsnakes/ppa -y",
      "sudo apt update",
      "sudo apt install -y python3.12 python3.12-venv python3.12-dev",
      "python3.12 -m venv venv",
      ". venv/bin/activate",
      "pip install redis"
    ]
  }
  connection {
    type        = "ssh"
    host        = google_compute_instance.activegate.network_interface[0].access_config[0].nat_ip
    user        = var.gcp_user_name
    private_key = file(var.ssh_private_key)
  }
  depends_on = [google_compute_instance.activegate]
}



resource "null_resource" "upload_extension" {
  provisioner "local-exec" {
    command = <<EOT
      python3 -m venv .dt_venv
      source .dt_venv/bin/activate
      pip install dt-cli
      base_dir=$(pwd)
      cd ../../..
      rm -f bundle.zip
      rm -f extension.zip
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
    host        = google_compute_instance.activegate.network_interface[0].access_config[0].nat_ip
    user        = var.gcp_user_name
    private_key = file(var.ssh_private_key)
  }
  depends_on = [null_resource.install_activegate]
}


locals {
  primary_endpoint = "https://${var.redis_fqdn}:8070/v2"
}

resource "null_resource" "create_monitoring_configuration" {
  depends_on = [ google_compute_instance.activegate, null_resource.upload_extension, null_resource.install_ca_pem, null_resource.install_activegate ]
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
