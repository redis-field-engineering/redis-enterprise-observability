# variables.tf

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

variable "dynatrace_api_token" {
  description = "API token with extensions.* and metrics.ingest scopes"
  type        = string
  sensitive   = true
}

variable "custom_ca_pem" {
  description = "Path to a custom CA PEM file, if any"
  type        = string
  default     = ""
}

variable "gcp_user_name" {
  description = "GCP user name"
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID for the Dynatrace environment"
  type        = string
}
