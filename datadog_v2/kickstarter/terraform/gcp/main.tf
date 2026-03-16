provider "google" {
  project = var.project
  region  = var.region
}

data "google_compute_network" "primary_network" {
  name = var.network
}

data "google_compute_subnetwork" "primary_subnet" {
  name   = var.subnet
  region = var.region
}

resource "google_compute_instance" "datadog-agent-vm" {
  name         = "datadog-agent-vm"
  machine_type = "e2-medium"
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20240731"
    }
  }

  network_interface {
    network    = data.google_compute_network.primary_network.name
    subnetwork = data.google_compute_subnetwork.primary_subnet.name
    access_config {}
  }
}

resource "null_resource" "install_datadog_agent" {
  connection {
    type        = "ssh"
    host        = google_compute_instance.datadog-agent-vm.network_interface[0].access_config[0].nat_ip
    user        = var.gcp_user_name
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
}
