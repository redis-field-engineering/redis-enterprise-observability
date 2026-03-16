# Redis Enterprise Dynatrace Observability - Kickstarter

This kickstarter contains Terraform configurations to quickly deploy Dynatrace ActiveGate instances and configure Redis Enterprise monitoring for both AWS and GCP environments.

## About the Kickstarter

The kickstarter automates the deployment and configuration of:
- Dynatrace ActiveGate VM instance
- Redis Enterprise extension upload and signing
- Monitoring configuration for Redis Enterprise clusters
- Required networking and security configurations

## Prerequisites

Before using either AWS or GCP deployments, ensure you have:

1. **Terraform** installed (version 1.0 or later)
2. **Python 3** with `dt-cli` package installed
3. **Dynatrace tenant** with appropriate permissions
4. **Developer certificate** for extension signing
5. **Redis Cloud or Enterprise Software cluster** accessible from the cloud environment

### Required Dynatrace Permissions

Your Dynatrace API token must have the following scopes:
- `PaaS integration - Installer download`
- `Write extension environment configurations`
- `Read extension environment configurations`
- `Write extension monitoring configurations`
- `Read extension monitoring configurations`
- `Write extensions`
- `Read extensions`

## AWS Deployment

### Prerequisites for AWS

- AWS CLI configured with appropriate credentials
- EC2 Key Pair created in your target region
- VPC, subnet, and security group configured
- Route53 hosted zone (if using DNS)

### Setup Steps

1. Navigate to the AWS terraform directory:
   ```bash
   cd kickstart/terraform/aws
   ```

2. Create a `terraform.tfvars` file with your configuration:
   ```hcl
   # AWS Configuration
   aws_region = "us-west-2"
   aws_account_id = "123456789012"
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
   
   # Dynatrace Configuration
   tenant_id = "abc12345"
   dynatrace_api_token = "dt0c01.ST2EY72KQINMH613..."
   extension_version = "1.0.0"
   
   # Security Files
   ssh_private_key = "path/to/your/private-key.pem"
   developer_pem = "secrets/developer.pem"
   custom_ca_pem = "secrets/ca.pem"
   ```

3. Initialize and apply Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. The deployment will output the ActiveGate instance IP and DNS record when complete.

### AWS Configuration Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `aws_region` | AWS region for deployment | Yes |
| `aws_account_id` | Your AWS account ID | Yes |
| `aws_ami_id` | Ubuntu 20.04 LTS AMI ID | Yes |
| `aws_key_name` | EC2 key pair name | Yes |
| `vpc_name` | VPC name (tag-based lookup) | Yes |
| `subnet_name` | Subnet name (tag-based lookup) | Yes |
| `aws_security_group_name` | Security group name | Yes |
| `dns_zone_id` | Route53 hosted zone ID | No |
| `subdomain` | Domain for ActiveGate | No |
| `redis_fqdn` | Redis cluster FQDN | Yes |
| `tenant_id` | Dynatrace tenant ID | Yes |
| `dynatrace_api_token` | Dynatrace API token | Yes |
| `extension_version` | Extension version | Yes |
| `ssh_private_key` | Path to SSH private key | Yes |
| `developer_pem` | Path to developer certificate | Yes |
| `custom_ca_pem` | Path to CA certificate | Yes |

## GCP Deployment

### Prerequisites for GCP

- GCP CLI (`gcloud`) configured with appropriate credentials
- GCP project with Compute Engine API enabled
- VPC network and subnet configured
- SSH key pair configured

### Setup Steps

1. Navigate to the GCP terraform directory:
   ```bash
   cd kickstart/terraform/gcp
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
   
   # Dynatrace Configuration
   tenant_id = "abc12345"
   dynatrace_api_token = "dt0c01.ST2EY72KQINMH613..."
   extension_version = "1.0.0"
   
   # Security and Access
   gcp_user_name = "your-gcp-username"
   ssh_private_key = "path/to/your/private-key"
   developer_pem = "secrets/developer.pem"
   custom_ca_pem = "secrets/ca.pem"
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
| `redis_fqdn` | Redis cluster FQDN | Yes |
| `tenant_id` | Dynatrace tenant ID | Yes |
| `dynatrace_api_token` | Dynatrace API token | Yes |
| `extension_version` | Extension version | Yes |
| `gcp_user_name` | GCP SSH username | Yes |
| `ssh_private_key` | Path to SSH private key | Yes |
| `developer_pem` | Path to developer certificate | Yes |
| `custom_ca_pem` | Path to CA certificate | No |

## What Gets Deployed

Both deployments create:

1. **Compute Instance**: VM running Ubuntu 20.04 LTS with Dynatrace ActiveGate
2. **Extension Management**: Automated upload and signing of the Redis Enterprise extension
3. **Monitoring Configuration**: ActiveGate configured to monitor your Redis endpoints
4. **Certificate Installation**: Custom CA certificates installed for secure communication

## Post-Deployment

After successful deployment:

1. Access your Dynatrace environment at `https://{tenant_id}.live.dynatrace.com`
2. Navigate to **Hub > Extensions** to verify the Redis Enterprise extension is installed
3. Check **Infrastructure > Technologies** to see your Redis cluster
4. Import the provided dashboards from the `src/dashboards/` directory

## Monitoring Scripts

Both deployments include monitoring management scripts:

- `start-monitoring.sh` - Configure monitoring for Redis endpoints
- `stop-monitoring.sh` - Remove monitoring configuration

These scripts are automatically executed during Terraform apply/destroy operations.

## Cleanup

To remove all deployed resources:

```bash
terraform destroy
```

This will:
- Delete the ActiveGate VM instance
- Remove the extension from Dynatrace
- Clean up monitoring configurations
- Remove any created DNS records (AWS only)

## Troubleshooting

### Common Issues

1. **Extension upload fails**: Ensure your API token has `extensions.*` scope
2. **SSH connection fails**: Verify your SSH key permissions and path
3. **ActiveGate installation fails**: Check that the Dynatrace tenant URL and token are correct
4. **Redis connection fails**: Ensure your Redis FQDN is accessible from the cloud environment

### Logs and Debugging

- ActiveGate logs: `/var/log/dynatrace/gateway/`
- Extension logs: Check Dynatrace UI under **Hub > Extensions**
- Terraform state: `terraform show` to inspect current state