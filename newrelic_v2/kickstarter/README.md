# Redis Enterprise New Relic Observability - Kickstarter

This kickstarter contains Terraform configurations to quickly deploy Prometheus instances with New Relic remote write integration for monitoring Redis Enterprise clusters on AWS and GCP.

## About the Kickstarter

The kickstarter automates the deployment and configuration of:
- Prometheus VM instance configured to scrape Redis Enterprise metrics
- New Relic remote write integration for metric forwarding
- Required networking and security configurations
- Automatic service setup and management

## Prerequisites

Before using either AWS or GCP deployments, ensure you have:

1. **Terraform** installed (version 1.0 or later)
2. **New Relic account** with Ingest API access
3. **Redis Cloud or Enterprise Software cluster** accessible from the cloud environment
4. **Cloud provider credentials** configured (AWS CLI or gcloud)

### New Relic Requirements

- Active New Relic account
- Ingest API Token (found in New Relic One > API Keys)
- Ability to create dashboards and alerts in New Relic

## AWS Deployment

### Prerequisites for AWS

- AWS CLI configured with appropriate credentials
- EC2 Key Pair created in your target region
- VPC, subnet, and security group configured
- Route53 hosted zone (optional, for DNS)

### Setup Steps

1. Navigate to the AWS terraform directory:
   ```bash
   cd newrelic_v2/kickstarter/terraform/aws
   ```

2. Create a `terraform.tfvars` file with your configuration:
   ```hcl
   # AWS Configuration
   aws_region = "us-west-2"
   aws_ami_id = "ami-0abcdef1234567890"  # Ubuntu 20.04 LTS
   aws_key_name = "your-ec2-keypair"
   
   # Networking
   vpc_name = "your-vpc-name"
   subnet_name = "your-subnet-name"
   aws_security_group_name = "your-security-group"
   
   # DNS (optional)
   dns_zone_id = "Z1234567890ABC"
   subdomain = "example.com"
   
   # Redis Configuration
   redis_fqdn = "internal-redis-cluster.example.com"
   
   # New Relic Configuration
   newrelic_bearer_token = "NRAK-ABC123..."
   newrelic_service_name = "redis-enterprise-production"
   
   # Security Files
   ssh_private_key = "path/to/your/private-key.pem"
   ```

3. Initialize and apply Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. The deployment will output the Prometheus instance IP and endpoint when complete.

### AWS Configuration Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `aws_region` | AWS region for deployment | Yes |
| `aws_ami_id` | Ubuntu 20.04 LTS AMI ID | Yes |
| `aws_key_name` | EC2 key pair name | Yes |
| `vpc_name` | VPC name (tag-based lookup) | Yes |
| `subnet_name` | Subnet name (tag-based lookup) | Yes |
| `aws_security_group_name` | Security group name | Yes |
| `dns_zone_id` | Route53 hosted zone ID | No |
| `subdomain` | Domain for Prometheus | No |
| `redis_fqdn` | Redis cluster FQDN | Yes |
| `newrelic_bearer_token` | New Relic Ingest API Token | Yes |
| `newrelic_service_name` | Service identifier in New Relic | Yes |
| `ssh_private_key` | Path to SSH private key | Yes |

## GCP Deployment

### Prerequisites for GCP

- GCP CLI (`gcloud`) configured with appropriate credentials
- GCP project with Compute Engine API enabled
- VPC network and subnet configured
- SSH key pair configured

### Setup Steps

1. Navigate to the GCP terraform directory:
   ```bash
   cd newrelic_v2/kickstarter/terraform/gcp
   ```

2. Create a `terraform.tfvars` file with your configuration:
   ```hcl
   # GCP Configuration
   project = "your-gcp-project-id"
   region = "us-central1"
   zone = "us-central1-a"
   
   # Networking
   network = "your-vpc-network"
   subnet = "your-subnet"
   
   # DNS (optional)
   dns_zone_name = "your-dns-zone"
   dns_subdomain = "example.com"
   
   # Redis Configuration
   redis_fqdn = "redis-cluster.example.com"
   
   # New Relic Configuration
   newrelic_bearer_token = "NRAK-ABC123..."
   newrelic_service_name = "redis-enterprise-production"
   
   # Security and Access
   gcp_user_name = "your-gcp-username"
   ssh_private_key = "path/to/your/private-key"
   ```

3. Initialize and apply Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### GCP Configuration Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `project` | GCP project ID | Yes |
| `region` | GCP region | Yes |
| `zone` | GCP zone | Yes |
| `network` | VPC network name | Yes |
| `subnet` | Subnet name | Yes |
| `dns_zone_name` | Cloud DNS managed zone name | No |
| `dns_subdomain` | Domain for Prometheus | No |
| `redis_fqdn` | Redis cluster FQDN | Yes |
| `newrelic_bearer_token` | New Relic Ingest API Token | Yes |
| `newrelic_service_name` | Service identifier in New Relic | Yes |
| `gcp_user_name` | GCP SSH username | Yes |
| `ssh_private_key` | Path to SSH private key | Yes |

## What Gets Deployed

Both deployments create:

1. **Compute Instance**: VM running Ubuntu 20.04 LTS with Prometheus
2. **Prometheus Configuration**: Configured to scrape Redis Enterprise metrics on port 8070
3. **New Relic Integration**: Remote write configuration for metric forwarding
4. **Service Management**: Systemd service for automatic startup and management
5. **Optional DNS**: DNS record for easy access (if configured)

## Prometheus Configuration

The deployed Prometheus instance is configured to:
- Scrape metrics from Redis Enterprise on `https://{redis_fqdn}:8070/v2`
- Use 30-second scrape intervals
- Skip TLS verification for self-signed certificates
- Forward all metrics to New Relic via remote write

## Post-Deployment

After successful deployment:

1. **Verify Prometheus**: Access Prometheus UI at the provided endpoint
2. **Check New Relic**: 
   - Navigate to New Relic One
   - Go to **Data Explorer** or **Query Builder**
   - Search for metrics with your service name
3. **Import Dashboards**: Use the dashboards from `newrelic_v2/dashboards/` directory
4. **Configure Alerts**: Set up alerts based on Redis Enterprise metrics

## Security Considerations

- Prometheus scrapes Redis Enterprise over HTTPS with TLS verification disabled
- New Relic communication uses HTTPS with bearer token authentication
- EC2/GCE instance uses SSH key authentication
- Consider using VPN or private networking for production deployments

## Monitoring Verification

To verify metrics are flowing:

1. **Prometheus Targets**: Check `http://prometheus-endpoint:9090/targets`
2. **New Relic Query**: 
   ```
   FROM Metric SELECT * WHERE prometheus_server = 'your-service-name'
   ```
3. **Sample Metrics**:
   - `redis_up`
   - `redis_node_cpu_usage`
   - `redis_db_total_requests`

## Cleanup

To remove all deployed resources:

```bash
terraform destroy
```

This will:
- Delete the Prometheus VM instance
- Remove any created DNS records
- Stop metric collection and forwarding

## Troubleshooting

### Common Issues

1. **Metrics not appearing in New Relic**:
   - Verify the Ingest API token is correct
   - Check Prometheus logs: `sudo journalctl -u prometheus`
   - Ensure network connectivity to New Relic

2. **Prometheus cannot scrape Redis**:
   - Verify Redis FQDN is accessible from the VM
   - Check Redis Enterprise cluster allows metric access
   - Confirm port 8070 is accessible

3. **SSH connection fails**:
   - Verify SSH key permissions and path
   - Check security group/firewall rules allow SSH (port 22)

4. **Service not starting**:
   - Check systemd logs: `sudo journalctl -u prometheus`
   - Verify configuration file syntax: `promtool check config /etc/prometheus/prometheus.yml`

### Logs and Debugging

- **Prometheus logs**: `sudo journalctl -u prometheus -f`
- **System logs**: `sudo journalctl -f`
- **Configuration validation**: `promtool check config /etc/prometheus/prometheus.yml`
- **New Relic connectivity**: Check prometheus targets page for remote write status

### Network Requirements

Ensure the following network access:
- **Outbound HTTPS (443)** to New Relic (metric-api.newrelic.com)
- **Outbound HTTPS (8070)** to Redis Enterprise cluster
- **Inbound SSH (22)** for management access
- **Inbound HTTP (9090)** for Prometheus UI access (optional)