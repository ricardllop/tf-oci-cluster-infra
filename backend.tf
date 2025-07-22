/* ----- COMMENT OR REMOVE THIS WHOLE FILE TO USE LOCAL BACKEND -----

With this config terraform is using the remote OCI backend in Oracle Cloud Infrastructure (OCI) Object Storage. Free until 20GB of storage.
https://developer.hashicorp.com/terraform/language/backend/oci#oci

-----  The bucket has to be manually created in the OCI console first ----- */

terraform {
  backend "oci" {
    bucket            = "terraform-states"
    namespace         = "axncq10mwcu5"
  }
}