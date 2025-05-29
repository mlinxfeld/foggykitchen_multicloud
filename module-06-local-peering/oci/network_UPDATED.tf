resource "oci_core_vcn" "foggykitchen_vcn1" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  display_name   = "foggykitchen_vcn1"
  dns_label      = "fkvcn"
}

resource "oci_core_vcn" "foggykitchen_vcn2" {
  cidr_block     = "192.168.0.0/16"
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  display_name   = "foggykitchen_vcn2"
  dns_label      = "fkvcn2"
}

resource "oci_core_internet_gateway" "foggykitchen_igw1" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn1.id
  display_name   = "foggykitchen_igw1"
  enabled        = true
}

resource "oci_core_nat_gateway" "foggykitchen_natgw1" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn1.id
  display_name   = "foggykitchen_natgw1"
}

resource "oci_core_nat_gateway" "foggykitchen_natgw2" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn2.id
  display_name   = "foggykitchen_natgw2"
}

resource "oci_core_service_gateway" "foggykitchen_sgw1" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  display_name   = "foggykitchen_sgw1"
  vcn_id         = oci_core_vcn.foggykitchen_vcn1.id
  services {
    service_id = lookup(data.oci_core_services.foggykitchen_all_oci_services.services[0], "id")
  }
}

resource "oci_core_service_gateway" "foggykitchen_sgw2" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  display_name   = "foggykitchen_sgw2"
  vcn_id         = oci_core_vcn.foggykitchen_vcn2.id
  services {
    service_id = lookup(data.oci_core_services.foggykitchen_all_oci_services.services[0], "id")
  }
}

resource "oci_core_route_table" "foggykitchen_public_rt1" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn1.id
  display_name   = "foggykitchen_public_rt1"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.foggykitchen_igw1.id
  }
}


resource "oci_core_subnet" "foggykitchen_public_sub" {
  cidr_block                 = "10.0.1.0/24"
  compartment_id             = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id                     = oci_core_vcn.foggykitchen_vcn1.id
  display_name               = "foggykitchen_public_sub"
  route_table_id             = oci_core_route_table.foggykitchen_public_rt1.id
  prohibit_public_ip_on_vnic = false
  dns_label                  = "pub"
  security_list_ids          = [
    oci_core_security_list.foggykitchen_ssh_seclist.id
  ]
}

resource "oci_core_subnet" "foggykitchen_private_sub" {
  cidr_block                 = "10.0.2.0/24"
  compartment_id             = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id                     = oci_core_vcn.foggykitchen_vcn1.id
  display_name               = "foggykitchen_priv_sub"
  route_table_id             = oci_core_route_table.foggykitchen_private_rt1.id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "priv"
  security_list_ids          = [
    oci_core_security_list.foggykitchen_ssh_seclist.id, 
    oci_core_security_list.foggykitchen_backend_seclist.id
  ]
}

resource "oci_core_subnet" "foggykitchen_lb_sub" {
  cidr_block                 = "10.0.3.0/24"
  compartment_id             = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id                     = oci_core_vcn.foggykitchen_vcn1.id
  display_name               = "foggykitchen_lb_sub"
  route_table_id             = oci_core_route_table.foggykitchen_public_rt1.id
  prohibit_public_ip_on_vnic = false
  dns_label                  = "lb"
  security_list_ids          = [
    oci_core_security_list.foggykitchen_lb_seclist.id
  ]
}

resource "oci_core_subnet" "foggykitchen_fss_sub" {
  cidr_block                 = "10.0.4.0/24"
  compartment_id             = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id                     = oci_core_vcn.foggykitchen_vcn1.id
  display_name               = "foggykitchen_fss_sub"
  route_table_id             = oci_core_route_table.foggykitchen_private_rt1.id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "fss"
  security_list_ids          = [
    oci_core_security_list.foggykitchen_ssh_seclist.id, 
    oci_core_security_list.foggykitchen_backend_seclist.id
  ]
}

resource "oci_core_subnet" "foggykitchen_db_sub" {
  cidr_block                 = "192.168.1.0/24"
  compartment_id             = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id                     = oci_core_vcn.foggykitchen_vcn2.id
  display_name               = "foggykitchen_db_sub"
  route_table_id             = oci_core_route_table.foggykitchen_private_rt2.id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "db"
}

resource "oci_core_local_peering_gateway" "foggykitchen_lpg1" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn1.id
  display_name   = "foggykitchen_lpg1"
  peer_id        = oci_core_local_peering_gateway.foggykitchen_lpg2.id
}

resource "oci_core_local_peering_gateway" "foggykitchen_lpg2" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn2.id
  display_name   = "foggykitchen_lpg2"
}

resource "oci_core_route_table" "foggykitchen_private_rt1" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn1.id
  display_name   = "foggykitchen_private_rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.foggykitchen_natgw1.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.foggykitchen_all_oci_services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.foggykitchen_sgw1.id
  }

   # VCN1 -> LPG1 -> VCN2
  route_rules {
    destination       = "192.168.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.foggykitchen_lpg1.id
  }
}

resource "oci_core_route_table" "foggykitchen_private_rt2" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn2.id
  display_name   = "foggykitchen_private_rt2"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.foggykitchen_natgw2.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.foggykitchen_all_oci_services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.foggykitchen_sgw2.id
  }

  # VCN2 -> LPG2 -> VCN1
  route_rules {
    destination       = "10.0.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.foggykitchen_lpg2.id
  }
}
