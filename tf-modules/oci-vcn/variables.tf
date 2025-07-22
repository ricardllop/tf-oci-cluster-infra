variable "create" {
  description = "Whether to create the infrastructure resources"
  type        = bool
  default     = true
}

variable "vcn_name" {
  type        = string
  description = "The names for the vcn and subnets resources"
  default     = "free-k8s"
}

variable "region" {
  type        = string
  description = "The region to provision the oke cluster in"
}

variable "compartment_id" {
  type        = string
  description = "The compartment to create the oke cluster in"
}