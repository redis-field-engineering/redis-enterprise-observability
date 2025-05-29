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

variable "dns_zone_id" {
  description = "Route53 hosted zone ID (optional)"
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "Domain for Prometheus instance (optional)"
  type        = string
  default     = ""
}

variable "redis_fqdn" {
  description = "Redis Cloud or Enterprise FQDN"
  type        = string
}

variable "newrelic_bearer_token" {
  description = "New Relic Ingest API Token"
  type        = string
  sensitive   = true
}

variable "newrelic_service_name" {
  description = "Service name identifier in New Relic"
  type        = string
}

variable "ssh_private_key" {
  description = "Path to SSH private key file"
  type        = string
}