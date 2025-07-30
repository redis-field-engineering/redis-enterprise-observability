variable "aws_region" {
  type        = string
  description = "The AWS region"
  default     = "us-east-1"
}

variable "aws_account_id" {
  type        = string
  description = "The AWS account ID"
}

variable "zone_dns_name" {
  type        = string
  sensitive   = true
  description = "The DNS zone name to deploy the app to"
}

variable "redis_cloud_account_key" {
  type        = string
  sensitive   = true
  description = "The Redis Cloud account key"
}

variable "redis_cloud_api_key" {
  type        = string
  sensitive   = true
  description = "The Redis Cloud API key"
}

variable "db_name" {
  type        = string
  description = "The name of the database"
}

variable "aws_username" {
  type        = string
  description = "The AWS EC2 username"
  default     = "ubuntu"
}

variable "ssh_key_file" {
  type        = string
  description = "The path to the SSH key file"
}

variable "aws_key_pair_name" {
  type        = string
  description = "The name of the AWS key pair"
}

variable "subscription_id" {
  type        = string
  description = "The Redis Cloud subscription ID"
}

variable "subdomain" {
  type        = string
  description = "The subdomain"
}

# Optional existing VPC ID - if provided, will use existing VPC instead of creating new one
# NOTE: If using existing infrastructure, you must provide existing_vpc_id, existing_subnet_id, and related variables together
variable "existing_vpc_id" {
  type        = string
  default     = null
  description = "ID of existing VPC to use. If not provided, a new VPC will be created."
}

# Optional existing subnet ID - if provided, will use existing subnet instead of creating new one
variable "existing_subnet_id" {
  type        = string
  default     = null
  description = "ID of existing subnet to use. If not provided, a new subnet will be created."
}

# Required when using existing VPC - CIDR block of existing VPC for peering
variable "existing_vpc_cidr" {
  type        = string
  default     = null
  description = "CIDR block of existing VPC. Required when existing_vpc_id is provided."
}

# Required when using existing VPC - Security group ID to use
variable "existing_security_group_id" {
  type        = string
  default     = null
  description = "ID of existing security group to use. Required when existing_vpc_id is provided."
}