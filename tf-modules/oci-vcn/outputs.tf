output "vcn_id" {
  value = var.create ? module.vcn[0].vcn_id : null
}

output "public_subnet_id" {
  value = var.create ? oci_core_subnet.vcn_public_subnet[0].id : null
}

output "private_subnet_id" {
  value = var.create ? oci_core_subnet.vcn_private_subnet[0].id : null
}