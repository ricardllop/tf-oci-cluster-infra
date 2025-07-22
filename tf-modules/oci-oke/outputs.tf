output "cluster_id" {
  value = var.create ? oci_containerengine_cluster.k8s_cluster[0].id : null
}

output "node_pool_id" {
  value = var.create ? oci_containerengine_node_pool.k8s_node_pool[0].id : null
}