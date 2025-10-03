variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

variable "aws_ami_id" {
  description = "Ubuntu 20.04 LTS AMI ID for the region"
  type        = string
}

variable "aws_key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
}

variable "vpc_name" {
  description = "VPC name (looked up by tag:Name)"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name (looked up by tag:Name)"
  type        = string
}

variable "aws_security_group_name" {
  description = "Security group name (looked up by tag:Name)"
  type        = string
}

variable "ssh_private_key" {
  description = "Path to SSH private key file"
  type        = string
}

variable "datadog_site" {
  description = "Datadog site"
  type        = string
  sensitive   = true
}

variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
  sensitive   = true  
}

variable "datadog_integration_name" {
  description = "Name of the Datadog integration to install"
  type        = string
  default     = "redis_enterprise_prometheus"  
}

variable "redis_fqdn" {
  description = "The fully qualified domain name (FQDN) of the Redis cluster"
  type        = string
}