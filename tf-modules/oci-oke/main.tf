provider "oci" {
  region = var.region
}

data "oci_identity_availability_domains" "ads" {
  count          = var.create ? 1 : 0
  compartment_id = var.compartment_id
}

locals {
  azs = var.create ? data.oci_identity_availability_domains.ads[0].availability_domains[*].name : []
}

resource "oci_containerengine_cluster" "k8s_cluster" {
  count = var.create ? 1 : 0

  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = "${var.cluster_name}-cluster"
  vcn_id             = var.vcn_id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = var.public_subnet_id
  }

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }
    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }
    service_lb_subnet_ids = [var.public_subnet_id]
  }
}

resource "oci_containerengine_node_pool" "k8s_node_pool" {
  count = (var.create && var.create_node_pool) ? 1 : 0

  cluster_id         = oci_containerengine_cluster.k8s_cluster[0].id
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = "${var.cluster_name}-node-pool"

  node_config_details {
    dynamic "placement_configs" {
      for_each = local.azs
      content {
        availability_domain = placement_configs.value
        subnet_id           = var.private_subnet_id
      }
    }

    size = var.node_pool_config.size
  }

  # Mandatory node shape for ALWAYS FREE tier, it is ARM64 architecture
  node_shape = "VM.Standard.A1.Flex"

  node_shape_config {
    memory_in_gbs = var.node_pool_config.memory_in_gbs
    ocpus         = var.node_pool_config.ocpus
  }

  node_source_details {
    image_id    = var.node_image_id
    source_type = "image"
  }

  initial_node_labels {
    key   = "name"
    value = "${var.cluster_name}-cluster-node"
  }
}