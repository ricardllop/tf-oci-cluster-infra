locals {
  oci_region           = "eu-madrid-1"  # Replace with your desired region
  oci_compartment_id   = "ocid1.tenancy.oc1..aaaaaaaayz5ixcqhspsl642j7e3ojdkfpo3mkzwkhta2iykkc35utk4bkz2a"  # Replace with your actual compartment OCID, This is specific to your OCI account
}
# Creation of vcn, subnets, and security lists for the OKE cluster
module "vcn" {
  create          = true
  source          = "./tf-modules/oci-vcn"
  vcn_name        = "free-k8s"

  region         = local.oci_region
  compartment_id = local.oci_compartment_id
}

# Creation the OKE cluster and node pool. Depends on VCN creation
module "oke" {
  create            = true
  source            = "./tf-modules/oci-oke"
  cluster_name      = "free-k8s"
  # Maximum resources of the Oracle Always FREE tier are 4 OCPUs and 24 GB of memory total. Mine is (2x1=) 2 OCPUs and (2x6=) 12 GB of memory. Half of the maximum resources.
  node_pool_config = {
    size          = 2
    memory_in_gbs = 12
    ocpus         = 2
  }
  vcn_id            = module.vcn.vcn_id 
  public_subnet_id  = module.vcn.public_subnet_id
  private_subnet_id = module.vcn.private_subnet_id

  region         = local.oci_region
  compartment_id = local.oci_compartment_id
}

# Deployment of argocd + argocd-apps helm chart
# Set create = false and apply to first provision the OKE cluster and VCN.
# After that, set create = true to deploy the argo-cd helm chart.
module "helm-argocd" {
  create            = true
  source            = "./tf-modules/helm-argocd"
  cluster_id        = module.oke.cluster_id
}