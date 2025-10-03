# Variables for AWS deployment
variable "aws_region" {
  type        = string
  description = "The AWS region to deploy resources"
}

variable "aws_account_id" {
  type        = string
  description = "The AWS account ID"
}

variable "aws_ami_id" {
  type        = string
  description = "The AMI ID to use for EC2 instances (Ubuntu 20.04 recommended)"
}

variable "aws_key_name" {
  type        = string
  description = "The EC2 key pair name to use for SSH access"
}

variable "dns_zone_id" {
  type        = string
  description = "The AWS Route53 hosted zone ID"
}

variable "subdomain" {
  type        = string
  description = "The subdomain to deploy the app to"
}

variable "redis_fqdn" {
  type        = string
  description = "The fully qualified domain name (FQDN) of the Redis cluster, in the case of Redis cloud this would be the private endpoint (starting with internal.)"  
}

variable "vpc_name" {
    type        = string
    description = "The name of the VPC to deploy resources in"
}

variable "subnet_name" {
    type        = string
    description = "The name of the subnet to deploy resources in"
}

variable "aws_security_group_name" {
    type        = string
    description = "The ID of the security group to associate with the EC2 instance" 
}

variable "tenant_id" {
  type        = string
  description = "Dynatrace tenant ID"
}

variable "dynatrace_api_token" {
  type        = string
  description = "API token with extensions.* and metrics.ingest scopes"
  sensitive   = true
}

variable "ssh_private_key" {
  type        = string
  description = "Path to SSH private key file"  
}

variable "developer_pem" {
  type        = string
  description = "Path to the developer PEM file for signing the extension"
}

variable "custom_ca_pem" {
  type        = string
  description = "Path to a custom CA PEM file, if any"
}

variable "extension_version" {
  type        = string
  description = "Version of the extension to deploy"  
}