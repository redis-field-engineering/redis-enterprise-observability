variable "gcp_project" {
  type      = string
  description = "The GCP project ID"
}

variable "dns-zone-name" {
  type      = string
  sensitive = true
  description = "The DNS Zone to deploy the app to"
}

variable "zone_dns_name" {
  type      = string
  sensitive = true
  description = "The DNS zone name to deploy the app to"

}

variable "redis_cloud_account_key" {
  type      = string
  sensitive = true
  description = "The Redis Cloud account key"
}

variable "redis_cloud_api_key" {
  type      = string
  sensitive = true
  description = "The Redis Cloud API key"
}

variable "sub_name" {
    type      = string
    description = "The name of the subscription"
}

variable "db_name" {
    type      = string
    description = "The name of the database"
}

variable "gcloud_username" {
    type      = string
    description = "The GCP username"
}

variable "gcloud_region" {
    type      = string
    description = "The GCP region"
}

variable "gcloud_zone" {
    type      = string
    description = "The GCP zone"
}

variable "ssh_key_file" {
    type      = string
    description = "The path to the SSH key file"
}

variable "subscription_id" {
    type      = string
    description = "The Redis Cloud subscription ID"
}



variable "subdomain" {
    type      = string
    description = "The subdomain"
}

# Optional existing VPC ID - if provided, will use existing VPC instead of creating new one
# NOTE: If using existing infrastructure, you must provide existing_vpc_id, existing_subnet_id, and existing_vpc_name together
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

# Optional existing VPC name - required when using existing VPC for peering
variable "existing_vpc_name" {
  type        = string
  default     = null
  description = "Name of existing VPC to use for peering. Required when existing_vpc_id is provided."
}