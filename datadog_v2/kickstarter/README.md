# Redis Enterprise Datadog Observability - Kickstarter

This kickstarter contains Terraform configurations to quickly deploy Datadog Agent instances with Datadog's official `redis-enterprise-prometheus` integration configured for Redis Enterprise monitoring.

## About the Kickstarter

The kickstarter automates the deployment and configuration of:
- Datadog Agent VM instance with the Redis Enterprise integration
- Installation of Datadog's published `redis-enterprise-prometheus` integration package
- Required networking and security configurations
- Automatic service setup and monitoring configuration

## Prerequisites

Before using the GCP deployment, ensure you have:

1. **Terraform** installed (version 1.0 or later)
2. **Datadog account** with API access
3. **Redis Cloud or Enterprise Software cluster** accessible from the cloud environment
4. **GCP credentials** configured (gcloud CLI)

### Datadog Requirements

- Active Datadog account
- Datadog API Key (found in Organization Settings > API Keys)
- Datadog Site identifier (e.g., `datadoghq.com`, `datadoghq.eu`, `us3.datadoghq.com`)

### Redis Enterprise Requirements

- Redis Enterprise Software cluster with metrics endpoint accessible on port 8070
- Or Redis Cloud Pro subscription with private endpoint for metrics collection
- Network connectivity between the Datadog Agent VM and Redis cluster

## GCP Deployment

### Prerequisites for GCP

- GCP CLI (`gcloud`) configured with appropriate credentials
- GCP project with Compute Engine API enabled
- VPC network and subnet configured
- SSH key pair configured

### Setup Steps

1. Navigate to the GCP terraform directory:
   ```bash
   cd datadog_v2/kickstarter/terraform/gcp
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
   
   # Redis Configuration
   redis_fqdn = "redis-cluster.example.com"
   
   # Datadog Configuration
   datadog_api_key = "your-datadog-api-key"
   datadog_site = "datadoghq.com"  # or your specific site
   datadog_integration_name = "redis_enterprise_prometheus"
   
   # Security and Access
   gcp_user_name = "your-gcp-username"
   ssh_private_key = "path/to/your/private-key"
   ```

3. Initialize and apply Terraform:
   ```bash
   terraform init
   terraform plan --var-file=terraform.tfvars
   terraform apply --var-file=terraform.tfvars
   ```

### GCP Configuration Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `project` | GCP project ID | Yes | |
| `region` | GCP region | Yes | |
| `zone` | GCP zone | Yes | |
| `network` | VPC network name | Yes | |
| `subnet` | Subnet name | Yes | |
| `redis_fqdn` | Redis cluster FQDN | Yes | |
| `datadog_api_key` | Datadog API key | Yes | |
| `datadog_site` | Datadog site identifier | Yes | |
| `datadog_integration_name` | Datadog Agent check name | No | `redis_enterprise_prometheus` |
| `gcp_user_name` | GCP SSH username | Yes | |
| `ssh_private_key` | Path to SSH private key | Yes | |

## What Gets Deployed

The deployment creates:

1. **Compute Instance**: VM running Ubuntu 20.04 LTS with Datadog Agent
2. **Integration Install**: Automatic installation of the official Redis Enterprise Prometheus integration package
3. **Agent Configuration**: Configured to collect metrics from Redis Enterprise on port 8070
4. **Service Management**: Systemd service management for automatic startup

## Integration Details

The kickstarter automatically:

1. **Installs Datadog Agent 7** using the official installation script
2. **Installs the published integration package**: `sudo datadog-agent integration install -t -r datadog-redis_enterprise_prometheus==1.0.0`
3. **Configures monitoring**: Sets up the integration configuration file with your Redis FQDN

## Agent Configuration

The deployed Datadog Agent is configured to:
- Connect to Redis Enterprise on `https://{redis_fqdn}:8070/v2`
- Skip TLS verification for self-signed certificates
- Use appropriate type overrides for specific metrics
- Automatically start monitoring upon deployment

## Post-Deployment

After successful deployment:

1. **Verify Agent Status**: SSH into the VM and check agent status:
   ```bash
   sudo datadog-agent status
   ```

2. **Check Integration**: Verify the Redis Enterprise integration is loaded:
   ```bash
   sudo datadog-agent check redis_enterprise_prometheus
   ```

3. **Monitor Datadog UI**: 
   - Navigate to your Datadog dashboard
   - Go to **Infrastructure > Host Map** to see your new host
   - Search for metrics with prefix `rdse2.*`

4. **Import Dashboards**: Use any available Redis Enterprise dashboards for Datadog

## Network Requirements for Redis Cloud

When monitoring Redis Cloud deployments, ensure your VPC is properly configured:

### VPC Peering (Recommended)
- Set up VPC peering between your GCP project and Redis Cloud VPC
- Ensure routing tables allow traffic between networks
- Configure security groups to allow HTTPS traffic on port 8070

### Private Connectivity
- Use Redis Cloud's private endpoint for metrics collection
- Ensure the Datadog Agent VM subnet has access to the Redis private network
- Configure DNS to resolve Redis private endpoints if needed

## Monitoring Verification

To verify metrics are flowing correctly:

1. **Agent Logs**: Check the agent logs for any errors:
   ```bash
   sudo tail -f /var/log/datadog/agent.log
   ```

2. **Integration Check**: Run the integration check manually:
   ```bash
   sudo datadog-agent check redis_enterprise_prometheus
   ```

3. **Datadog Metrics Explorer**: In Datadog UI, search for:
   - `rdse2.cluster.total_live_nodes_count`
   - `rdse2.node.node_available_memory_bytes`
   - `rdse2.database.endpoint_client_connections`

## Cleanup

To remove all deployed resources:

```bash
terraform destroy --var-file=terraform.tfvars
```

### Network Requirements

Ensure the following network access from the Datadog Agent VM:
- **Outbound HTTPS (443)** to Datadog endpoints (based on your site)
- **Outbound HTTPS (8070)** to Redis Enterprise cluster
- **Inbound SSH (22)** for management access

### Integration Updates

The kickstarter installs the Datadog-published package. To update:

1. SSH into the VM
2. Reinstall the desired published package version: `sudo datadog-agent integration install -t -r datadog-redis_enterprise_prometheus==1.0.0`
3. Restart the agent: `sudo systemctl restart datadog-agent`
