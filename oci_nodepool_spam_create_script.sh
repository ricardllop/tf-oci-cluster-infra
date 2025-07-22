#!/bin/bash

# !!!!!!!!!!!!! Run first !!!!!!!!!!!!!!!!!!!!!
# terraform apply -var="create_node_pool=false"

# This will create only the vcn and the cluster, but not the node pool. (The nodepool is what is problematic with the free account)

# Then execute the script to run the terraform apply command in a loop until it succeeds
while true; do
	# Execute terraform apply with auto-approve
	terraform apply -target=module.oke.oci_containerengine_node_pool.k8s_node_pool

	# Check if the last command was successful
	if [ $? -eq 0 ]; then
		echo "Terraform apply to create the free nodepool succeeded."
		break
	else
		echo "Terraform apply to create the free nodepool failed. Retrying..."
	fi
	# Optional: You can add more delay before retrying if you want
	sleep 5
done
