# Redis Enterprise Dynatrace Observability - Kickstarter

This kickstarter contains Terraform configurations to quickly deploy Dynatrace ActiveGate instances for Redis Enterprise monitoring in AWS and GCP environments.

## About the Kickstarter

The kickstarter automates the deployment and configuration of:
- Dynatrace ActiveGate VM instance
- ActiveGate installation and bootstrap
- Optional custom CA installation on the ActiveGate host
- Required networking and security configurations

## Prerequisites

Before using either AWS or GCP deployments, ensure you have:

1. **Terraform** installed (version 1.0 or later)
2. **Dynatrace tenant** with appropriate permissions
3. **Redis Cloud or Enterprise Software cluster** accessible from the cloud environment
4. **Optional CA certificate** if you want the kickstarter to preload trust material onto ActiveGate

### Required Dynatrace Permissions

Your Dynatrace API token must be able to download the ActiveGate installer:
- `PaaS integration - Installer download`

If you later activate or test extension builds manually, use whatever additional Dynatrace permissions that workflow requires. This kickstarter no longer uploads extensions or creates monitoring configurations.

## AWS Deployment

### Prerequisites for AWS

- AWS CLI configured with appropriate credentials
- EC2 Key Pair created in your target region
- VPC, subnet, and security group configured
- Route53 hosted zone (if using DNS)

### Setup Steps

1. Navigate to the AWS terraform directory:
   ```bash
   cd dynatrace_v2/kickstarter/terraform/aws
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
   
   # Dynatrace Configuration
   tenant_id = "abc12345"
   dynatrace_api_token = "dt0c01.ST2EY72KQINMH613..."
   
   # Security Files
   ssh_private_key = "path/to/your/private-key.pem"
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
| `tenant_id` | Dynatrace tenant ID | Yes |
| `dynatrace_api_token` | Dynatrace API token | Yes |
| `ssh_private_key` | Path to SSH private key | Yes |
| `custom_ca_pem` | Path to CA certificate | No |

## GCP Deployment

### Prerequisites for GCP

- GCP CLI (`gcloud`) configured with appropriate credentials
- GCP project with Compute Engine API enabled
- VPC network and subnet configured
- SSH key pair configured

### Setup Steps

1. Navigate to the GCP terraform directory:
   ```bash
   cd dynatrace_v2/kickstarter/terraform/gcp
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
   
   # Dynatrace Configuration
   tenant_id = "abc12345"
   dynatrace_api_token = "dt0c01.ST2EY72KQINMH613..."
   
   # Security and Access
   gcp_user_name = "your-gcp-username"
   ssh_private_key = "path/to/your/private-key"
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
| `tenant_id` | Dynatrace tenant ID | Yes |
| `dynatrace_api_token` | Dynatrace API token | Yes |
| `gcp_user_name` | GCP SSH username | Yes |
| `ssh_private_key` | Path to SSH private key | Yes |
| `custom_ca_pem` | Path to CA certificate | No |

## What Gets Deployed

Both deployments create:

1. **Compute Instance**: VM running Ubuntu 20.04 LTS with Dynatrace ActiveGate
2. **ActiveGate Bootstrap**: Dynatrace ActiveGate installed and ready for extension activation
3. **Certificate Installation**: Optional custom CA certificates installed for secure communication with Redis endpoints

## Post-Deployment

After successful deployment:

1. Access your Dynatrace environment at `https://{tenant_id}.live.dynatrace.com`
2. Verify the ActiveGate host is connected and healthy
3. Activate the published `Redis Enterprise - Prometheus` extension from Dynatrace Hub
4. Create or update the monitoring configuration in Dynatrace for your Redis Enterprise endpoint

For development work, this kickstarter is still useful when you want a ready ActiveGate host with your CA material already installed before manually testing extension builds.

## Cleanup

To remove all deployed resources:

```bash
terraform destroy
```

This will:
- Delete the ActiveGate VM instance
- Remove any created DNS records (AWS only)

## Troubleshooting

### Common Issues

1. **SSH connection fails**: Verify your SSH key permissions and path
2. **ActiveGate installation fails**: Check that the Dynatrace tenant URL and token are correct
3. **CA installation fails**: Ensure `custom_ca_pem` points to a readable PEM file, or leave it unset

### Logs and Debugging

- ActiveGate logs: `/var/log/dynatrace/gateway/`
- Extension logs: Check Dynatrace UI under **Hub > Extensions** after you activate the extension manually
- Terraform state: `terraform show` to inspect current state
