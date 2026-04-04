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