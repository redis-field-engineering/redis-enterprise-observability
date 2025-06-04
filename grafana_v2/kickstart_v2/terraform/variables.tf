variable "gcp_project" {
  type      = string
  description = "The GCP project ID"  
}

variable "dns-zone-name" {
  type      = string
  sensitive = true
  description = "The DNS Zone to deploy the app to"  
}

variable "subdomain" {
  type      = string
  sensitive = true
  description = "The subdomain to deploy the app to"
  
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

variable "redis_db_primary_fqdn" {
    type      = string
    description = "The Redis DB primary FQDN"
}

variable "top_level_domain" {
    type      = string
    description = "The top level domain"
}