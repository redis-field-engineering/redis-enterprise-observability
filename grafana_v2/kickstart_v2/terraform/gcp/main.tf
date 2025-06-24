# Redis Enterprise Observability - Grafana v2 Kickstarter
#
# This Terraform configuration supports two deployment modes:
# 1. CREATE NEW INFRASTRUCTURE (default): Creates new VPC, subnet, and firewall rules
# 2. USE EXISTING INFRASTRUCTURE: Uses existing VPC and subnet by providing their IDs
#
# To use existing infrastructure, set these variables in your .tfvars file:
# - existing_vpc_id: Full VPC resource ID (e.g., "projects/my-project/global/networks/my-vpc")
# - existing_subnet_id: Full subnet resource ID (e.g., "projects/my-project/regions/us-central1/subnetworks/my-subnet")
# - existing_vpc_name: VPC name for peering (e.g., "my-vpc")
#
# If any of these are null/unset, new infrastructure will be created.

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

# Data source to fetch Redis Cloud database information
data "rediscloud_database" "redis_db" {
    subscription_id = var.subscription_id
    name           = var.db_name
}

# Local values to determine which VPC and subnet to use
# NOTE: Ensure that if you provide existing_vpc_id, you also provide existing_subnet_id and existing_vpc_name
locals {
  vpc_id     = var.existing_vpc_id != null ? var.existing_vpc_id : google_compute_network.redispeer_test_vpc[0].id
  vpc_name   = var.existing_vpc_name != null ? var.existing_vpc_name : google_compute_network.redispeer_test_vpc[0].name
  subnet_id  = var.existing_subnet_id != null ? var.existing_subnet_id : google_compute_subnetwork.redispeer_test_subnet[0].id

  # Extract FQDN from Redis Cloud database public_endpoint
  # Format: redis-18738.c41372.us-central1-mz.gcp.cloud.rlrcp.com:18738
  # Extract: c41372.us-central1-mz.gcp.cloud.rlrcp.com
  redis_db_primary_fqdn = regex("^[^.]+\\.(.+):\\d+$", data.rediscloud_database.redis_db.public_endpoint)[0]
}

# Conditionally create VPC only if not using existing one
resource "google_compute_network" "redispeer_test_vpc" {
    count = var.existing_vpc_id == null ? 1 : 0
    name="redispeer-test-vpc"
    auto_create_subnetworks = false
}

# Conditionally create subnet only if not using existing one
resource "google_compute_subnetwork" "redispeer_test_subnet" {
    count = var.existing_subnet_id == null ? 1 : 0
    name          = "redispeer-test-subnet"
    region        = var.gcloud_region
    ip_cidr_range = "10.32.0.0/24"
    network       = google_compute_network.redispeer_test_vpc[0].id
    private_ip_google_access = true
}


# Conditionally create firewall rules only if creating new VPC
resource "google_compute_firewall" "redispeer_allow_ssh" {
    count   = var.existing_vpc_id == null ? 1 : 0
    name    = "redispeer-allow-ssh"
    network = local.vpc_id

    allow {
        protocol = "tcp"
        ports    = ["22","80","443","3000"]
    }

    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "redispeer_allow_icmp" {
    count   = var.existing_vpc_id == null ? 1 : 0
    name    = "redispeer-allow-icmp"
    network = local.vpc_id

    allow {
        protocol = "icmp"
    }

    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "redispeer_allow_dns" {
    count   = var.existing_vpc_id == null ? 1 : 0
    name    = "redispeer-allow-dns"
    network = local.vpc_id

    allow {
        protocol = "udp"
        ports    = ["53","5353"]
    }

    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "redispeer_allow_egress" {
    count   = var.existing_vpc_id == null ? 1 : 0
    name    = "redispeer-allow-egress"
    network = local.vpc_id

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
    gcp_network_name = local.vpc_name
}

resource "google_compute_network_peering" "redispeer-gcp-vpc-peering" {
    name = "redispeer-gcp-vpc-peering"
    network = local.vpc_id
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
        network = local.vpc_id
        subnetwork = local.subnet_id
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
                "./setup.sh ${local.redis_db_primary_fqdn} ../dashboards/grafana_v9-11/cloud/basic",
            ]
        }
}

resource "google_dns_record_set" "redispeerr_dns" {
    managed_zone = var.dns-zone-name
    name = "${var.subdomain}.${var.zone_dns_name}."
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
            "    server_name ${var.subdomain}.${var.zone_dns_name};",
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
            "sudo certbot --nginx -d ${var.subdomain}.${var.zone_dns_name} --agree-tos --non-interactive --email admin@${var.zone_dns_name}",
            # Set up certificate renewal
            "sudo crontab -l 2>/dev/null | { cat; echo '0 12 * * * /snap/bin/certbot renew --quiet --deploy-hook \"systemctl reload nginx\"'; } | sudo crontab -"
        ]
    }
}


