provider "google" {
  project = var.project
  region  = var.region
}

data "google_compute_network" "primary_network" {
    name = var.network   
}

resource "google_compute_instance" "prometheus" {
  name         = "redis-prometheus-newrelic"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 50
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet
    access_config {}
  }

  tags = ["prometheus", "newrelic"]
}

resource "google_dns_record_set" "prometheus-dns" {
    count        = var.dns_zone_name != "" ? 1 : 0
    managed_zone = var.dns_zone_name
    name         = "prometheus.${var.dns_subdomain}."
    type         = "A"
    ttl          = 300
    rrdatas      = [google_compute_instance.prometheus.network_interface[0].access_config[0].nat_ip]
}

resource "null_resource" "setup_prometheus" {
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

  connection {
    type        = "ssh"
    host        = google_compute_instance.prometheus.network_interface[0].access_config[0].nat_ip
    user        = var.gcp_user_name
    private_key = file(var.ssh_private_key)
  }

  depends_on = [google_compute_instance.prometheus]
}

output "instance_ip" {
  description = "Public IP address of the Prometheus instance"
  value       = google_compute_instance.prometheus.network_interface[0].access_config[0].nat_ip
}

output "dns_record" {
  description = "Full DNS record for the Prometheus instance"
  value       = var.dns_zone_name != "" ? google_dns_record_set.prometheus-dns[0].name : "DNS not configured"
}

output "prometheus_endpoint" {
  description = "Prometheus service endpoint"
  value       = var.dns_zone_name != "" ? "http://prometheus.${var.dns_subdomain}:9090" : "http://${google_compute_instance.prometheus.network_interface[0].access_config[0].nat_ip}:9090"
}