variable "create" {
  description = "Whether to create the infrastructure resources"
  type        = bool
  default     = true
}

variable "create_node_pool" {
  description = "Whether to create the node pool. If false, the cluster will be created without a node pool. This is useful for the nodepool spam create script. (FOR ALWAYS FREE ACCOUNTS THAT MIGHT HAVE PROBLEMS CREATING NODE POOLS)"
  type    = bool
  default = true
}

variable "vcn_id" {
  type        = string
  description = "The OCID of the Virtual Cloud Network (VCN) where the Kubernetes cluster will be created."
}

variable "public_subnet_id" {
  type        = string
  description = "The OCID of the public subnet to be used for the Kubernetes API endpoint and service load balancers."
}

variable "private_subnet_id" {
  type        = string
  description = "The OCID of the private subnet to be used for the worker nodes in the Kubernetes node pool."
}

variable "cluster_name" {
  type        = string
  description = "The name for the Kubernetes cluster and node pool resources"
  default     = "free-k8s"
}

variable "node_pool_config" {
  description = "Node pool configuration including size, memory, and OCPUs"
  type = object({
    size           = number
    memory_in_gbs  = number
    ocpus          = number
  })
  # Maximum resources of the Oracle Always FREE tier are 4 OCPUs and 24 GB of memory total. (default set to half of that)
  default = {
    size          = 2
    memory_in_gbs = 6
    ocpus         = 1
  }
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the OKE cluster and node pool. Must match the version in node_image_id."
  default     = "v1.33.1"
}

variable "node_image_id" {
  type        = string
  description = "OCID of the node image. Must be aarch64/ARM and match the kubernetes_version. See https://docs.oracle.com/en-us/iaas/images/oke-worker-node-oracle-linux-8x/index.htm"
}

variable "region" {
  type        = string
  description = "The region to provision the oke cluster in"
}

variable "compartment_id" {
  type        = string
  description = "The compartment to create the oke cluster in"
}