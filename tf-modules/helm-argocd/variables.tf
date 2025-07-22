variable "create" {
  description = "Whether to create the infrastructure resources"
  type        = bool
  default     = true
}

variable "cluster_id" {
  type        = string
  description = "The id of the Kubernetes cluster to deploy the ingress-nginx controller to."
}