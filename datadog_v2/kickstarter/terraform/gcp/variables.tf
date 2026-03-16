variable "project" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "zone" {
  description = "GCP Zone"
  type        = string
}

variable "network" {
  description = "VPC network name"
  type        = string
}

variable "subnet" {
  description = "Subnetwork name"
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

variable "gcp_user_name" {
  description = "GCP user name"
  type        = string
  
}

variable "redis_fqdn" {
  description = "The fully qualified domain name (FQDN) of the Redis cluster"
  type        = string
}
