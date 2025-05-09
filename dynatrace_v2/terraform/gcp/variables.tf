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

# variable "dynatrace_tenant_url" {
#   description = "Dynatrace tenant URL (e.g. https://<env>.live.dynatrace.com)"
#   type        = string
# }

variable "dynatrace_api_token" {
  description = "API token with extensions.* and metrics.ingest scopes"
  type        = string
  # sensitive   = true
}

variable "custom_ca_pem" {
  description = "Path to a custom CA PEM file, if any"
  type        = string
  default     = ""
}

# variable "activegate_installer_url" {
#   description = "URL to the ActiveGate installer script from Dynatrace"
#   type        = string
# }

# variable "platform_token" {
#   description = "Dynatrace platform token used for ActiveGate install"
#   type        = string
#   sensitive   = true
# }
variable "gcp_user_name" {
  description = "GCP user name"
  type        = string
  
}
variable "developer_pem" {
  description = "Path to the developer PEM file for signing the extension"
  type        = string  
}

# variable "downloader_token" {
#   description = "token for downloading activegate"
#   type        = string
# }

variable "primary_endpoint" {
  description = "Primary endpoint to monitor"
  type        = string  
}

variable "secondary_endpoint" {
  description = "Secondary endpoint to monitor"
  type        = string  
}

variable "extension_version" {
  description = "Version of the extension to be used"
  type        = string  
}

variable "tenant_id" {
  description = "Tenant ID for the Dynatrace environment"
  type        = string  
}