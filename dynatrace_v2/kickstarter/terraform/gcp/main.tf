# main.tf

provider "google" {
  project = var.project
  region  = var.region
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
      image = "ubuntu-2204-jammy-v20251212"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet
    access_config {}
  }

  labels = var.instance_labels

  tags = ["dynatrace"]
}

locals {
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
      "sudo ./ActiveGate.sh --set-group=gcp",
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

resource "null_resource" "install_ca_pem" {
  count = var.custom_ca_pem == "" ? 0 : 1

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
