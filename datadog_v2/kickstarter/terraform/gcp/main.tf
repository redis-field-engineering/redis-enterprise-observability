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

resource "google_compute_instance" "datadog-agent-vm"{
    name = "datadog-agent-vm"
    machine_type = "e2-medium"
    zone = var.zone
    boot_disk {
        initialize_params {
            image = "ubuntu-os-cloud/ubuntu-2004-lts"
        }
    }

    network_interface {
        network = data.google_compute_network.primary_network.name
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
                "git clone https://github.com/redis-field-engineering/datadog-integrations-extras",
                # install python 3.12
                "sudo apt update",
                "sudo apt install -y software-properties-common",
                "sudo add-apt-repository ppa:deadsnakes/ppa -y",
                "sudo apt update",
                "sudo apt install -y python3.12 python3.12-venv python3.12-dev",
                "python3.12 -m venv venv",
                ". venv/bin/activate",
                "pip install build",
                "cd datadog-integrations-extras",
                # "git checkout redis_enterprise_prometheus",
                "git checkout v2-metrics-extended",
                "cd ${var.datadog_integration_name}",
                "python3.12 -m build --wheel",
                "sudo datadog-agent integration install -r -w  ./dist/datadog_redis_enterprise_prometheus-2.0.1-py3-none-any.whl",
            ]
        }
  
        provisioner "file" {
            source = "config.yaml.example"
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