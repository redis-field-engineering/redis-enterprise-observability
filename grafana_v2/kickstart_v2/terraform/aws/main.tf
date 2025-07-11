# Redis Enterprise Observability - Grafana v2 Kickstarter for AWS
#
# This Terraform configuration supports two deployment modes:
# 1. CREATE NEW INFRASTRUCTURE (default): Creates new VPC, subnet, and security groups
# 2. USE EXISTING INFRASTRUCTURE: Uses existing VPC and subnet by providing their IDs
#
# To use existing infrastructure, set these variables in your .tfvars file:
# - existing_vpc_id: VPC ID (e.g., "vpc-12345678")
# - existing_subnet_id: Subnet ID (e.g., "subnet-12345678")
# - existing_vpc_name: VPC name for peering (e.g., "my-vpc")
#
# If any of these are null/unset, new infrastructure will be created.

terraform {
  required_providers {
    rediscloud = {
      source = "RedisLabs/rediscloud"
      version = "2.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "rediscloud" {
    secret_key = var.redis_cloud_api_key
    api_key = var.redis_cloud_account_key
}

provider "aws" {
    region = var.aws_region
}

# Data source to fetch Redis Cloud database information
data "rediscloud_database" "redis_db" {
    subscription_id = var.subscription_id
    name           = var.db_name
}

# Data source to get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source to get Route53 hosted zone
data "aws_route53_zone" "main" {
  name = var.zone_dns_name
}

# Local values to determine which VPC and subnet to use
locals {
  vpc_id     = var.existing_vpc_id != null ? var.existing_vpc_id : aws_vpc.redispeer_test_vpc[0].id
  subnet_id  = var.existing_subnet_id != null ? var.existing_subnet_id : aws_subnet.redispeer_test_subnet[0].id

  # Extract FQDN from Redis Cloud database private_endpoint
  # Format: redis-18738.internal.c41372.us-east-1.aws.cloud.rlrcp.com:18738
  # Extract: internal.c41372.us-east-1.aws.cloud.rlrcp.com
  redis_db_primary_fqdn = regex("^[^.]+\\.(.+):\\d+$", data.rediscloud_database.redis_db.private_endpoint)[0]
}

# Conditionally create VPC only if not using existing one
resource "aws_vpc" "redispeer_test_vpc" {
    count = var.existing_vpc_id == null ? 1 : 0
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    
    tags = {
        Name = "redispeer-test-vpc"
    }
}

# Conditionally create internet gateway only if creating new VPC
resource "aws_internet_gateway" "redispeer_test_igw" {
    count  = var.existing_vpc_id == null ? 1 : 0
    vpc_id = aws_vpc.redispeer_test_vpc[0].id
    
    tags = {
        Name = "redispeer-test-igw"
    }
}

# Conditionally create subnet only if not using existing one
resource "aws_subnet" "redispeer_test_subnet" {
    count                   = var.existing_subnet_id == null ? 1 : 0
    vpc_id                  = aws_vpc.redispeer_test_vpc[0].id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = true
    
    tags = {
        Name = "redispeer-test-subnet"
    }
}

# Conditionally create route table only if creating new VPC
resource "aws_route_table" "redispeer_test_rt" {
    count  = var.existing_vpc_id == null ? 1 : 0
    vpc_id = aws_vpc.redispeer_test_vpc[0].id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.redispeer_test_igw[0].id
    }
    
    tags = {
        Name = "redispeer-test-rt"
    }
}

# Conditionally create route table association only if creating new VPC
resource "aws_route_table_association" "redispeer_test_rta" {
    count          = var.existing_vpc_id == null ? 1 : 0
    subnet_id      = aws_subnet.redispeer_test_subnet[0].id
    route_table_id = aws_route_table.redispeer_test_rt[0].id
}

# Conditionally create security group only if creating new VPC
resource "aws_security_group" "redispeer_test_sg" {
    count       = var.existing_vpc_id == null ? 1 : 0
    name        = "redispeer-test-sg"
    description = "Security group for Redis peering test"
    vpc_id      = local.vpc_id
    
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port   = 3000
        to_port     = 3000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
        Name = "redispeer-test-sg"
    }
}

# VPC Peering with Redis Cloud
resource "rediscloud_subscription_peering" "redispeer-sub-vpc-peering" {
    count               = var.existing_vpc_id == null ? 1 : 0
    subscription_id     = var.subscription_id
    provider_name       = "AWS"
    aws_account_id      = var.aws_account_id
    vpc_id              = local.vpc_id
    vpc_cidr            = var.existing_vpc_id == null ? aws_vpc.redispeer_test_vpc[0].cidr_block : var.existing_vpc_cidr
}

# Accept VPC peering connection
resource "aws_vpc_peering_connection_accepter" "redispeer-aws-vpc-peering" {
    count                     = var.existing_vpc_id == null ? 1 : 0
    vpc_peering_connection_id = rediscloud_subscription_peering.redispeer-sub-vpc-peering[0].aws_peering_id
    auto_accept               = true
    
    tags = {
        Name = "redispeer-aws-vpc-peering"
    }
}

# Get the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
    most_recent = true
    owners      = ["099720109477"] # Canonical
    
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

# EC2 Instance
resource "aws_instance" "redispeer_vm" {
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = "t3.medium"
    subnet_id              = local.subnet_id
    vpc_security_group_ids = [var.existing_vpc_id == null ? aws_security_group.redispeer_test_sg[0].id : var.existing_security_group_id]
    key_name               = var.aws_key_pair_name
    
    root_block_device {
        volume_size = 50
        volume_type = "gp3"
    }
    
    tags = {
        Name = "kickstart-redispeer-vm"
    }
}

# Install Docker and Python
resource "null_resource" "install_docker_python" {
    connection {
        type        = "ssh"
        user        = var.aws_username
        private_key = file(var.ssh_key_file)
        host        = aws_instance.redispeer_vm.public_ip
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

# Run kickstart setup
resource "null_resource" "run-kickstart" {
    depends_on = [null_resource.install_docker_python]
    
    connection {
        type        = "ssh"
        user        = var.aws_username
        private_key = file(var.ssh_key_file)
        host        = aws_instance.redispeer_vm.public_ip
    }
    
    provisioner "remote-exec" {
        inline = [
            "cd redis-enterprise-observability/grafana_v2/kickstart_v2",
            "git checkout main",
            "./setup.sh ${local.redis_db_primary_fqdn} ../dashboards/grafana_v9-11/cloud/basic",
        ]
    }
}

# Route53 DNS record
resource "aws_route53_record" "redispeer_dns" {
    zone_id = data.aws_route53_zone.main.zone_id
    name    = "${var.subdomain}.${var.zone_dns_name}"
    type    = "A"
    ttl     = 300
    records = [aws_instance.redispeer_vm.public_ip]
}

# Setup Nginx and SSL
resource "null_resource" "setup_nginx_ssl" {
    depends_on = [
        aws_route53_record.redispeer_dns,
        null_resource.run-kickstart
    ]
    
    connection {
        type        = "ssh"
        user        = var.aws_username
        private_key = file(var.ssh_key_file)
        host        = aws_instance.redispeer_vm.public_ip
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
            # Get SSL certificate using HTTP validation
            "sudo certbot --nginx -d ${var.subdomain}.${var.zone_dns_name} --agree-tos --non-interactive --email admin@${var.zone_dns_name}",
            # Set up certificate renewal
            "sudo crontab -l 2>/dev/null | { cat; echo '0 12 * * * /snap/bin/certbot renew --quiet --deploy-hook \"systemctl reload nginx\"'; } | sudo crontab -"
        ]
    }
}