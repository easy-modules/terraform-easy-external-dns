variable "cluster_name" {
  description = "Cluster Name"
  type        = string
}

variable "namespace" {
  type        = string
  description = "Namespace for the External DNS deployment"
  default     = "external-dns-system"
}

variable "external_dns_name" {
  type        = string
  description = "External DNS Name"
  default     = "external-dns"
}

variable "service_account_name" {
  description = "Service Account Name"
  type        = string
  default     = "external-dns-sa"
}

variable "role_tags" {
  description = "Role Tags"
  type        = map(any)
  default     = {}
}

variable "cloudflare_enabled" {
  type        = bool
  default     = false
  description = "Enable Cloudflare DNS"
}

variable "dns_zone" {
  description = "DNS Zone"
  type        = list(string)
}

variable "cloudflare_api_key" {
  description = "Cloudflare API Key"
  type        = string
  default     = null
}

variable "cloudflare_api_email" {
  description = "Cloudflare API Email"
  type        = string
  default     = null
}

variable "node_selector" {
  type        = string
  default     = null
  description = "Node labels for K8S Pod assignment of the Deployments/StatefulSets/DaemonSets"
}
