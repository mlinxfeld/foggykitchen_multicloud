resource "oci_core_vcn" "foggykitchen_vcn1" {
  provider       = oci.region1
  cidr_block     = "10.0.0.0/16"
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  display_name   = "foggykitchen_vcn1"
  dns_label      = "fkvcn1"
}

resource "oci_core_vcn" "foggykitchen_vcn2" {
  provider       = oci.region1
  cidr_block     = "192.168.0.0/16"
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  display_name   = "foggykitchen_vcn2"
  dns_label      = "fkvcn2"
}

resource "oci_core_internet_gateway" "foggykitchen_igw1" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn1.id
  display_name   = "foggykitchen_igw1"
  enabled        = true
}

resource "oci_core_nat_gateway" "foggykitchen_natgw1" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn1.id
  display_name   = "foggykitchen_natgw1"
}

resource "oci_core_nat_gateway" "foggykitchen_natgw2" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn2.id
  display_name   = "foggykitchen_natgw2"
}

resource "oci_core_service_gateway" "foggykitchen_sgw1" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  display_name   = "foggykitchen_sgw1"
  vcn_id         = oci_core_vcn.foggykitchen_vcn1.id
  services {
    service_id = lookup(data.oci_core_services.foggykitchen_region1_oci_services.services[0], "id")
  }
}

resource "oci_core_service_gateway" "foggykitchen_sgw2" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  display_name   = "foggykitchen_sgw2"
  vcn_id         = oci_core_vcn.foggykitchen_vcn2.id
  services {
    service_id = lookup(data.oci_core_services.foggykitchen_region1_oci_services.services[0], "id")
  }
}

resource "oci_core_route_table" "foggykitchen_public_rt1" {
  provider       = oci.region1
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
  provider                   = oci.region1
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
  provider                   = oci.region1
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
  provider                   = oci.region1
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
  provider                   = oci.region1
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
  provider                   = oci.region1
  cidr_block                 = "192.168.1.0/24"
  compartment_id             = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id                     = oci_core_vcn.foggykitchen_vcn2.id
  display_name               = "foggykitchen_db_sub"
  route_table_id             = oci_core_route_table.foggykitchen_private_rt2.id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "db"
}

resource "oci_core_local_peering_gateway" "foggykitchen_region1_lpg1" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn1.id
  display_name   = "foggykitchen_region1_lpg1"
  peer_id        = oci_core_local_peering_gateway.foggykitchen_region1_lpg2.id
}

resource "oci_core_route_table" "foggykitchen_private_rt1" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn1.id
  display_name   = "foggykitchen_private_rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.foggykitchen_natgw1.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.foggykitchen_region1_oci_services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.foggykitchen_sgw1.id
  }

  route_rules {
    destination       = "192.168.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.foggykitchen_region1_lpg1.id
  }

  route_rules {
    destination       = "10.1.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.foggykitchen_drg1.id
  }

  route_rules {
    destination       = "10.2.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.foggykitchen_drg1.id
  }

}

resource "oci_core_local_peering_gateway" "foggykitchen_region1_lpg2" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn2.id
  display_name   = "foggykitchen_region1_lpg2"
}

resource "oci_core_route_table" "foggykitchen_private_rt2" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn2.id
  display_name   = "foggykitchen_private_rt2"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.foggykitchen_natgw2.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.foggykitchen_region1_oci_services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.foggykitchen_sgw2.id
  }

  route_rules {
    destination       = "10.0.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.foggykitchen_region1_lpg2.id
  }

  route_rules {
    destination       = "10.2.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.foggykitchen_drg1.id
  }
}

resource "oci_core_drg" "foggykitchen_drg1" {
  provider       = oci.region1
  display_name   = "foggykitchen_drg1"
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
}

resource "oci_core_drg_attachment" "foggykitchen_drg1_vcn1_attachment" {
  provider       = oci.region1
  display_name   = "foggykitchen_drg1_vcn1_attachment"
  drg_id         = oci_core_drg.foggykitchen_drg1.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn1.id
}

resource "oci_core_drg_attachment" "foggykitchen_drg1_vcn2_attachment" {
  provider       = oci.region1
  display_name   = "foggykitchen_drg1_vcn2_attachment"
  drg_id         = oci_core_drg.foggykitchen_drg1.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn2.id
}

resource "oci_core_remote_peering_connection" "foggykitchen_rpc1_to_rpc2" {
  provider         = oci.region1
  compartment_id   = oci_identity_compartment.foggykitchen_compartment.id
  drg_id           = oci_core_drg.foggykitchen_drg1.id
  display_name     = "foggykitchen_rpc1_to_rpc2"
  peer_id          = oci_core_remote_peering_connection.foggykitchen_rpc2_to_rpc1.id
  peer_region_name = var.region2
}

resource "oci_core_remote_peering_connection" "foggykitchen_rpc1_to_rpc3" {
  provider         = oci.region1
  compartment_id   = oci_identity_compartment.foggykitchen_compartment.id
  drg_id           = oci_core_drg.foggykitchen_drg1.id
  display_name     = "foggykitchen_rpc1_to_rpc3"
  peer_id          = oci_core_remote_peering_connection.foggykitchen_rpc3_to_rpc1.id
  peer_region_name = var.region2
}

resource "oci_core_drg_route_table" "foggykitchen_drg1_rpc_rt" {
  provider     = oci.region1
  drg_id       = oci_core_drg.foggykitchen_drg1.id
  display_name = "foggykitchen_drg1_rpc_rt"
}

# <DRG1> -> <VCN1>
resource "oci_core_drg_route_table_route_rule" "foggykitchen_drg1_route_to_vcn1" {
  provider                   = oci.region1
	drg_route_table_id         = oci_core_drg_route_table.foggykitchen_drg1_rpc_rt.id
	destination                = "10.0.0.0/16"
	destination_type           = "CIDR_BLOCK"
	next_hop_drg_attachment_id = oci_core_drg_attachment.foggykitchen_drg1_vcn1_attachment.id
}

# <DRG1> -> <VCN2>
resource "oci_core_drg_route_table_route_rule" "foggykitchen_drg1_route_to_vcn2" {
  provider                   = oci.region1
  drg_route_table_id         = oci_core_drg_route_table.foggykitchen_drg1_rpc_rt.id
  destination                = "192.168.0.0/16"
  destination_type           = "CIDR_BLOCK"
  next_hop_drg_attachment_id = oci_core_drg_attachment.foggykitchen_drg1_vcn2_attachment.id
} 

resource "oci_core_drg_attachment_management" "foggykitchen_drg1_rpc1_to_rpc2_attachment_management" {
  provider           = oci.region1
  compartment_id     = oci_identity_compartment.foggykitchen_compartment.id
  attachment_type    = "REMOTE_PEERING_CONNECTION"
  display_name       = "foggykitchen_drg1_rpc1_to_rpc2_attachment_management"
  network_id         = oci_core_remote_peering_connection.foggykitchen_rpc1_to_rpc2.id
  drg_id             = oci_core_drg.foggykitchen_drg1.id
  drg_route_table_id = oci_core_drg_route_table.foggykitchen_drg1_rpc_rt.id
}

# <DRG1> -> <RPC1> -> <RPC2> -> <VCN3>
resource "oci_core_drg_route_table_route_rule" "foggykitchen_drg1_route_to_vcn3" {
    provider                   = oci.region1
    drg_route_table_id         = oci_core_drg_route_table.foggykitchen_drg1_rpc_rt.id
    destination                = "10.1.0.0/16"
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = oci_core_drg_attachment_management.foggykitchen_drg1_rpc1_to_rpc2_attachment_management.id
}

resource "oci_core_drg_attachment_management" "foggykitchen_drg1_rpc1_to_rpc3_attachment_management" {
  provider           = oci.region1
  compartment_id     = oci_identity_compartment.foggykitchen_compartment.id
  attachment_type    = "REMOTE_PEERING_CONNECTION"
  display_name       = "foggykitchen_drg1_rpc1_to_rpc3_attachment_management"
  network_id         = oci_core_remote_peering_connection.foggykitchen_rpc1_to_rpc3.id
  drg_id             = oci_core_drg.foggykitchen_drg1.id
  drg_route_table_id = oci_core_drg_route_table.foggykitchen_drg1_rpc_rt.id
}

# <DRG1> -> <RPC1> -> <RPC3> -> <VCN3>
resource "oci_core_drg_route_table_route_rule" "foggykitchen_drg1_route_to_vcn4" {
    provider                   = oci.region1
    drg_route_table_id         = oci_core_drg_route_table.foggykitchen_drg1_rpc_rt.id
    destination                = "10.2.0.0/16"
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = oci_core_drg_attachment_management.foggykitchen_drg1_rpc1_to_rpc3_attachment_management.id
}