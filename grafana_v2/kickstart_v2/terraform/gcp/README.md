# Redis Cloud Grafana Kickstarter for GCP

The Redis Cloud Grafana Kickstarter automates the deployment of a complete observability stack for your Redis Cloud Pro databases on Google Cloud Platform. This Terraform configuration creates the necessary infrastructure and sets up a monitoring solution with custom domain and SSL encryption, perfect for getting started with Redis monitoring, demos, and development environments.

## What This Kickstarter Does

- **Network Infrastructure**: Creates a new VPC and subnet in GCP (or uses existing ones if provided)
- **VPC Peering**: Establishes secure peering between your GCP VPC and Redis Cloud Pro subscription (If you bring your own VCP it's assumed it's already peered)
- **Monitoring Stack**: Deploys a VM with Prometheus and Grafana pre-configured for Redis monitoring
- **Dashboard Integration**: Automatically installs Redis Cloud dashboards from this repository
- **SSL & Domain Setup**: Configures nginx reverse proxy with Let's Encrypt SSL certificates
- **DNS Management**: Creates DNS records for secure HTTPS access to your Grafana instance

## Prerequisites

Before running this kickstarter, ensure you have:

### Redis Cloud Requirements
- Redis Cloud Pro subscription with at least one database
- Redis Cloud API credentials (API Key and Secret Key)
- Subscription ID and database name

### GCP Requirements
- GCP project with billing enabled
- Terraform installed locally
- GCP credentials configured (via `gcloud auth application-default login`)
- A managed DNS zone in Cloud DNS
- SSH key pair for VM access

### Required GCP APIs
Enable the following APIs in your GCP project:
- Compute Engine API
- Cloud DNS API
- Cloud Resource Manager API

## Configuration

### 1. Create Variables File

Create a `terraform.tfvars` file in this directory with your configuration:

```hcl
# Redis Cloud Configuration
redis_cloud_api_key     = "your-redis-cloud-api-key"
redis_cloud_account_key = "your-redis-cloud-account-key"
subscription_id         = "12345"
db_name                = "your-database-name"

# GCP Configuration
gcp_project    = "your-gcp-project-id"
gcloud_region  = "us-central1"
gcloud_zone    = "us-central1-a"
gcloud_username = "your-username"

# SSH Configuration
ssh_key_file = "path/to/your/private-key"

# DNS Configuration
dns-zone-name   = "your-dns-zone-name"
zone_dns_name   = "yourdomain.com"
subdomain      = "grafana"

# Optional: Use Existing Infrastructure
# existing_vpc_id    = "projects/your-project/global/networks/existing-vpc"
# existing_subnet_id = "projects/your-project/regions/us-central1/subnetworks/existing-subnet"
# existing_vpc_name  = "existing-vpc"
```

### 2. Infrastructure Options

The kickstarter supports two deployment modes:

#### Option A: Create New Infrastructure (Default)
Leave the `existing_*` variables commented out. The kickstarter will create:
- New VPC (`redispeer-test-vpc`)
- New subnet (`redispeer-test-subnet`)
- Firewall rules for SSH, HTTP, HTTPS, and Grafana access

#### Option B: Use Existing Infrastructure
Uncomment and configure the `existing_*` variables to use your existing VPC and subnet.

## Deployment Steps

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Review the Plan
```bash
terraform plan
```

### 3. Deploy the Infrastructure
```bash
terraform apply
```

The deployment process will:
1. Create or configure network infrastructure
2. Set up VPC peering with Redis Cloud
3. Launch and configure the monitoring VM
4. Install Docker, Python, and monitoring tools
5. Deploy Prometheus and Grafana with Redis dashboards
6. Configure nginx with SSL certificates
7. Set up DNS records

**Note**: The complete deployment takes approximately 10-15 minutes.

### 4. Access Your Grafana Instance

Once deployment completes, access your Grafana instance at:
```
https://your-subdomain.yourdomain.com
```

Default Grafana credentials:
- **Username**: `admin`
- **Password**: `admin` (you'll be prompted to change this on first login)

## What You Get

After successful deployment, you'll have:

- **Secure Access**: HTTPS-enabled Grafana instance with Let's Encrypt SSL certificates
- **Pre-configured Dashboards**: Redis Cloud monitoring dashboards automatically imported
- **Prometheus Integration**: Metrics collection from your Redis Cloud databases
- **Custom Domain**: Professional URL for your monitoring solution
- **Auto-renewal**: SSL certificates automatically renewed via cron job

## Available Dashboards

The kickstarter installs the following Redis Cloud dashboards:
- **Active-Active Dashboard**: Multi-region database monitoring
- **Database Dashboard**: Core database metrics and performance
- **Proxy Dashboard**: Redis Cloud proxy performance metrics
- **Cluster Dashboard**: Overall cluster health and status

## Production Considerations

This kickstarter is designed to get you up and running quickly with Redis monitoring. For production workloads requiring high availability, data persistence, and enterprise-grade reliability, consider these alternatives:

- **Grafana Cloud**: Fully managed Grafana service with built-in high availability
- **Managed Prometheus**: Cloud provider managed Prometheus services (GCP Managed Service for Prometheus, AWS Managed Prometheus)
- **Kubernetes Deployment**: Deploy Prometheus and Grafana using Helm charts with persistent storage, clustering, and backup strategies
- **Enterprise Solutions**: Redis Insight, Datadog, New Relic, or other enterprise monitoring platforms

The kickstarter provides an excellent foundation for understanding your Redis metrics and can serve as a reference for building more robust monitoring infrastructure.

## Troubleshooting

### Common Issues

**DNS Propagation**: If SSL certificate generation fails, wait 5-10 minutes for DNS propagation and re-run `terraform apply`.

**SSH Connection Issues**: Ensure your SSH key has appropriate permissions (`chmod 600 path/to/private-key`).

**API Rate Limits**: If you encounter Redis Cloud API rate limits, wait a few minutes and retry.

### Accessing Logs

SSH into the VM to check service status:
```bash
# Connect to VM
ssh -i path/to/private-key username@vm-external-ip

# Check Grafana status
sudo docker ps

# View Grafana logs
sudo docker logs grafana

# Check nginx status
sudo systemctl status nginx
```

## Cleanup

To remove all created resources:
```bash
terraform destroy
```

**Warning**: This will permanently delete all infrastructure created by this kickstarter.

## Support

For issues and questions:
- Review the [main repository documentation](../../../../README.adoc)
- Check [Redis Cloud documentation](https://docs.redis.com/latest/rc/)
- Open an issue in the repository

---

*This kickstarter is part of the Redis Enterprise Observability toolkit. For more monitoring solutions and dashboards, explore the complete repository.*