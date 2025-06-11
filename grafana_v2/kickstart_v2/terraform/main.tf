terraform {
  required_providers {
    rediscloud = {
      source = "RedisLabs/rediscloud"
      version = "2.0.0"
    }
  }
}

provider "rediscloud" {
    secret_key = var.redis_cloud_api_key
    api_key = var.redis_cloud_account_key
}

provider "google" {
    project = var.gcp_project
    region  = var.gcloud_region
}


resource "google_compute_network" "redispeer_test_vpc" {
    name="redispeer-test-vpc"
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "redispeer_test_subnet" {
    name          = "redispeer-test-subnet"
    region        = var.gcloud_region
    ip_cidr_range = "10.32.0.0/24"
    network       = google_compute_network.redispeer_test_vpc.id
    private_ip_google_access = true

}


resource "google_compute_firewall" "redispeer_allow_ssh" {
    name    = "redispeer-allow-ssh"
    network = google_compute_network.redispeer_test_vpc.id

    allow {
        protocol = "tcp"
        ports    = ["22","80","443","3000"]
    }

    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "redispeer_allow_icmp" {
    name    = "redispeer-allow-icmp"
    network = google_compute_network.redispeer_test_vpc.id

    allow {
        protocol = "icmp"
    }

    source_ranges = ["0.0.0.0/0"]
}


resource "google_compute_firewall" "redispeer_allow_dns" {
    name    = "redispeer-allow-dns"
    network = google_compute_network.redispeer_test_vpc.id

    allow {
        protocol = "udp"
        ports    = ["53","5353"]
    }

    source_ranges = ["0.0.0.0/0"]

}

resource "google_compute_firewall" "redispeer_allow_egress" {
    name    = "redispeer-allow-egress"
    network = google_compute_network.redispeer_test_vpc.id

    allow {
        protocol = "all"
    }

    direction     = "EGRESS"
    destination_ranges = ["0.0.0.0/0"]
}


resource "rediscloud_subscription_peering" "redispeer-sub-vpc-peering" {
    subscription_id = var.subscription_id
    provider_name="GCP"
    gcp_project_id = var.gcp_project
    gcp_network_name = google_compute_network.redispeer_test_vpc.name
}

resource "google_compute_network_peering" "redispeer-gcp-vpc-peering" {
    name = "redispeer-gcp-vpc-peering"
    network = google_compute_network.redispeer_test_vpc.id
    peer_network = "https://www.googleapis.com/compute/v1/projects/${rediscloud_subscription_peering.redispeer-sub-vpc-peering.gcp_redis_project_id}/global/networks/${rediscloud_subscription_peering.redispeer-sub-vpc-peering.gcp_redis_network_name}"
}

resource "google_compute_instance" "redispeerr-vm"{
    name = "kickstart-redispeer-vm"
    machine_type = "n1-standard-1"
    zone = var.gcloud_zone
    boot_disk {
        initialize_params {
            image = "ubuntu-2004-focal-v20240731"
            size = 50
        }
    }

    network_interface {
        network = google_compute_network.redispeer_test_vpc.id
        subnetwork = google_compute_subnetwork.redispeer_test_subnet.id
        access_config {
        }
    }

    metadata = {
        enable-oslogin = "FALSE"
    }
}


resource "null_resource" "install_docker_python" {
    connection {
            type = "ssh"
            user = var.gcloud_username
            private_key = file(var.ssh_key_file)
            host = google_compute_instance.redispeerr-vm.network_interface[0].access_config[0].nat_ip
    }

    provisioner "remote-exec" {
        inline = [
            "git clone https://github.com/redis-field-engineering/redis-enterprise-observability",
            # install python 3.12
            "sudo apt update",
            "sudo apt install apt-transport-https ca-certificates curl software-properties-common -y",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
            "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable\"",
            "apt-cache policy docker-ce",
            "sudo apt install docker-ce -y",
            "sudo usermod -aG docker $${USER}",
            "sudo add-apt-repository ppa:deadsnakes/ppa -y",
            "sudo apt update",
            "sudo apt install -y python3.12 python3.12-venv python3.12-dev",
            "python3.12 -m venv venv",
            ". venv/bin/activate",
            "pip install build",
            "pip install redis",
        ]
    }


}

resource "null_resource" "run-kickstart" {

    depends_on = [ null_resource.install_docker_python ]

    connection {
            type = "ssh"
            user = var.gcloud_username
            private_key = file(var.ssh_key_file)
            host = google_compute_instance.redispeerr-vm.network_interface[0].access_config[0].nat_ip
    }

    provisioner "remote-exec" {
            inline = [
                "cd redis-enterprise-observability/grafana_v2/kickstart_v2",
                "git checkout main",
                "./setup.sh ${var.redis_db_primary_fqdn}",
            ]
        }
}

resource "google_dns_record_set" "redispeerr_dns" {
    managed_zone = var.dns-zone-name
    name = "${var.top_level_domain}.${var.subdomain}."
    type = "A"
    ttl = 300
    rrdatas = [google_compute_instance.redispeerr-vm.network_interface[0].access_config[0].nat_ip]
}

resource "null_resource" "setup_nginx_ssl" {
    depends_on = [
        google_dns_record_set.redispeerr_dns,
        null_resource.run-kickstart
    ]

    connection {
        type = "ssh"
        user = var.gcloud_username
        private_key = file(var.ssh_key_file)
        host = google_compute_instance.redispeerr-vm.network_interface[0].access_config[0].nat_ip
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt update",
            "sudo apt install -y nginx snap",
            "sudo snap install --classic certbot",
            "sudo ln -s /snap/bin/certbot /usr/bin/certbot",
            # Create basic HTTP-only nginx config first
            "sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF",
            "server {",
            "    listen 80;",
            "    server_name ${var.top_level_domain}.${var.subdomain};",
            "    location / {",
            "        proxy_pass http://127.0.0.1:3000;",
            "        proxy_set_header Host \\$host;",
            "        proxy_set_header X-Real-IP \\$remote_addr;",
            "        proxy_set_header X-Forwarded-For \\$proxy_add_x_forwarded_for;",
            "        proxy_set_header X-Forwarded-Proto \\$scheme;",
            "        proxy_buffering off;",
            "    }",
            "}",
            "EOF",
            # Test and start nginx with HTTP-only config
            "sudo nginx -t",
            "sudo systemctl start nginx",
            "sudo systemctl enable nginx",
            # Wait a bit for DNS propagation and nginx to be ready
            "sleep 30",
            # Get SSL certificate using HTTP validation (simpler and more reliable)
            "sudo certbot --nginx -d ${var.top_level_domain}.${var.subdomain} --agree-tos --non-interactive --email admin@${var.subdomain}",
            # Set up certificate renewal
            "sudo crontab -l 2>/dev/null | { cat; echo '0 12 * * * /snap/bin/certbot renew --quiet --deploy-hook \"systemctl reload nginx\"'; } | sudo crontab -"
        ]
    }
}


