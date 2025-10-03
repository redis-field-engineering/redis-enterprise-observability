variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "network" {
  description = "VPC network name"
  type        = string
}

variable "subnet" {
  description = "Subnet name"
  type        = string
}

variable "dns_zone_name" {
  description = "Cloud DNS managed zone name (optional)"
  type        = string
  default     = ""
}

variable "dns_subdomain" {
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

variable "gcp_user_name" {
  description = "GCP SSH username"
  type        = string
}

variable "ssh_private_key" {
  description = "Path to SSH private key file"
  type        = string
}