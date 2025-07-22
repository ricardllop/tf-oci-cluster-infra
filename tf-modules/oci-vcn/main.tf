provider "oci" {
  region = var.region
}

# https://registry.terraform.io/modules/oracle-terraform-modules/vcn/oci/latest
module "vcn" {
  count   = var.create ? 1 : 0
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.6.0"

  compartment_id = var.compartment_id
  region         = var.region

  internet_gateway_route_rules = null
  local_peering_gateways       = null
  nat_gateway_route_rules      = null

  vcn_name      = "${var.vcn_name}-vcn"
  vcn_dns_label = replace("${var.vcn_name}vcn", "/[^a-zA-Z0-9]/", "")
  vcn_cidrs     = ["10.0.0.0/16"]

  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true
}

resource "oci_core_security_list" "private_subnet_sl" {
  count          = var.create ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = module.vcn[0].vcn_id

  display_name = "${var.vcn_name}-private-subnet-sl"

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/24"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 10256
      max = 10256
    }
  }
}

resource "oci_core_security_list" "public_subnet_sl" {
  count          = var.create ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = module.vcn[0].vcn_id

  display_name = "${var.vcn_name}-public-subnet-sl"

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

 ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 80
      min = 80
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 443
      min = 443
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 6443
      max = 6443
    }
  }
  
}

resource "oci_core_subnet" "vcn_private_subnet" {
  count          = var.create ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = module.vcn[0].vcn_id
  cidr_block     = "10.0.1.0/24"

  route_table_id             = module.vcn[0].nat_route_id
  security_list_ids          = [oci_core_security_list.private_subnet_sl[0].id]
  display_name               = "${var.vcn_name}-private-subnet"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "vcn_public_subnet" {
  count          = var.create ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = module.vcn[0].vcn_id
  cidr_block     = "10.0.0.0/24"

  route_table_id    = module.vcn[0].ig_route_id
  security_list_ids = [oci_core_security_list.public_subnet_sl[0].id]
  display_name      = "${var.vcn_name}-public-subnet"
}