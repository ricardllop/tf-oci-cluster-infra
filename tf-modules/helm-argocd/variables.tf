variable "create" {
  description = "Whether to create the infrastructure resources"
  type        = bool
  default     = true
}

variable "cluster_id" {
  type        = string
  description = "The id of the Kubernetes cluster to deploy the ingress-nginx controller to."
}

variable "tailscale_oauth_clientid" {
  type        = string
  sensitive   = true
  description = "Tailscale OAuth client ID for the operator"
  default     = null
}

variable "tailscale_oauth_secret" {
  type        = string
  sensitive   = true
  description = "Tailscale OAuth client secret for the operator"
  default     = null
}