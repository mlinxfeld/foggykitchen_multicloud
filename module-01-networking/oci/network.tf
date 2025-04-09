resource "oci_core_vcn" "foggykitchen_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  display_name   = "foggykitchen_vcn"
  dns_label      = "fkvcn"
}

resource "oci_core_internet_gateway" "foggykitchen_igw" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn.id
  display_name   = "foggykitchen_igw"
  enabled        = true
}

resource "oci_core_nat_gateway" "foggykitchen_natgw" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn.id
  display_name   = "foggykitchen_natgw"
}

resource "oci_core_route_table" "foggykitchen_public_rt" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn.id
  display_name   = "foggykitchen_public_rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.foggykitchen_igw.id
  }
}

resource "oci_core_route_table" "foggykitchen_private_rt" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn.id
  display_name   = "foggykitchen_private_rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.foggykitchen_natgw.id
  }
}

resource "oci_core_subnet" "foggykitchen_public_sub" {
  cidr_block                 = "10.0.1.0/24"
  compartment_id             = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id                     = oci_core_vcn.foggykitchen_vcn.id
  display_name               = "foggykitchen_public_sub"
  route_table_id             = oci_core_route_table.foggykitchen_public_rt.id
  prohibit_public_ip_on_vnic = false
  dns_label                  = "pub"
  security_list_ids          = [oci_core_security_list.foggykitchen_ssh_seclist.id]
}

resource "oci_core_subnet" "foggykitchen_private_sub" {
  cidr_block                 = "10.0.2.0/24"
  compartment_id             = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id                     = oci_core_vcn.foggykitchen_vcn.id
  display_name               = "foggykitchen_private_sub"
  route_table_id             = oci_core_route_table.foggykitchen_private_rt.id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "priv"
}

