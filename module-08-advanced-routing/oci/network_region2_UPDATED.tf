resource "oci_core_vcn" "foggykitchen_vcn3" {
  provider       = oci.region2
  cidr_block     = "10.1.0.0/16"
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  display_name   = "foggykitchen_vcn3"
  dns_label      = "fkvcn3"
}

resource "oci_core_subnet" "foggykitchen_public_sub2" {
  provider                   = oci.region2
  cidr_block                 = "10.1.1.0/24"
  compartment_id             = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id                     = oci_core_vcn.foggykitchen_vcn3.id
  display_name               = "foggykitchen_public_sub2"
  route_table_id             = oci_core_route_table.foggykitchen_public_rt2.id
  prohibit_public_ip_on_vnic = false
  dns_label                  = "pub2"
}

resource "oci_core_internet_gateway" "foggykitchen_igw2" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn3.id
  display_name   = "foggykitchen_igw2"
  enabled        = true
}

resource "oci_core_route_table" "foggykitchen_public_rt2" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn3.id
  display_name   = "foggykitchen_public_rt2"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.foggykitchen_igw2.id
  }

  route_rules {
    destination       = "10.0.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.foggykitchen_drg2.id
  }

  route_rules {
    destination       = "10.2.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.foggykitchen_region2_lpg1.id
  }
}

resource "oci_core_local_peering_gateway" "foggykitchen_region2_lpg1" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn3.id
  display_name   = "foggykitchen_region2_lpg1"
  peer_id        = oci_core_local_peering_gateway.foggykitchen_region2_lpg2.id
}

resource "oci_core_drg" "foggykitchen_drg2" {
  provider       = oci.region2
  display_name   = "foggykitchen_drg2"
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
}

resource "oci_core_drg_attachment" "foggykitchen_drg2_attachment" {
  provider       = oci.region2
  display_name   = "foggykitchen_drg2_attachment"
  drg_id         = oci_core_drg.foggykitchen_drg2.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn3.id
}

resource "oci_core_remote_peering_connection" "foggykitchen_rpc2_to_rpc1" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  drg_id         = oci_core_drg.foggykitchen_drg2.id
  display_name   = "foggykitchen_rpc2_to_rpc1"
}

resource "oci_core_drg_route_table" "foggykitchen_drg2_rpc_rt" {
  provider     = oci.region2
  drg_id       = oci_core_drg.foggykitchen_drg2.id
  display_name = "foggykitchen_drg2_rpc_rt"
}

# <DRG2> -> <VCN3>
resource "oci_core_drg_route_table_route_rule" "foggykitchen_drg2_route_to_vcn3" {
    provider                   = oci.region2
	drg_route_table_id         = oci_core_drg_route_table.foggykitchen_drg2_rpc_rt.id
	destination                = "10.1.0.0/16"
	destination_type           = "CIDR_BLOCK"
	next_hop_drg_attachment_id = oci_core_drg_attachment.foggykitchen_drg2_attachment.id
}

resource "oci_core_drg_attachment_management" "foggykitchen_drg2_rpc2_to_rpc1_attachment_management" {
  provider           = oci.region2
  compartment_id     = oci_identity_compartment.foggykitchen_compartment.id
  attachment_type    = "REMOTE_PEERING_CONNECTION"
  display_name       = "foggykitchen_drg2_rpc2_to_rpc1_attachment_management"
  network_id         = oci_core_remote_peering_connection.foggykitchen_rpc2_to_rpc1.id
  drg_id             = oci_core_drg.foggykitchen_drg2.id
  drg_route_table_id = oci_core_drg_route_table.foggykitchen_drg2_rpc_rt.id
}

# <DRG2> -> <RPC2> -> <RPC1> -> <VCN1>
resource "oci_core_drg_route_table_route_rule" "foggykitchen_drg2_route_to_vcn1" {
    provider                   = oci.region2
    drg_route_table_id         = oci_core_drg_route_table.foggykitchen_drg2_rpc_rt.id
    destination                = "10.0.0.0/16"
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = oci_core_drg_attachment_management.foggykitchen_drg2_rpc2_to_rpc1_attachment_management.id
}

resource "oci_core_vcn" "foggykitchen_vcn4" {
  provider       = oci.region2
  cidr_block     = "10.2.0.0/16"
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  display_name   = "foggykitchen_vcn4"
  dns_label      = "fkvcn4"
}

resource "oci_core_subnet" "foggykitchen_private_sub2" {
  provider                   = oci.region2
  cidr_block                 = "10.2.1.0/24"
  compartment_id             = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id                     = oci_core_vcn.foggykitchen_vcn4.id
  display_name               = "foggykitchen_private_sub2"
  route_table_id             = oci_core_route_table.foggykitchen_private_rt3.id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "priv2"
}

resource "oci_core_nat_gateway" "foggykitchen_natgw3" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn4.id
  display_name   = "foggykitchen_natgw2"
}

resource "oci_core_service_gateway" "foggykitchen_sgw3" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  display_name   = "foggykitchen_sgw3"
  vcn_id         = oci_core_vcn.foggykitchen_vcn4.id
  services {
    service_id = lookup(data.oci_core_services.foggykitchen_region2_oci_services.services[0], "id")
  }
}

resource "oci_core_route_table" "foggykitchen_private_rt3" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn4.id
  display_name   = "foggykitchen_private_rt3"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.foggykitchen_natgw3.id
  }

  route_rules {
    destination       = "192.168.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.foggykitchen_drg3.id
  }

  route_rules {
    destination       = "10.1.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.foggykitchen_region2_lpg2.id
  }

  route_rules {
    destination       = "10.0.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.foggykitchen_drg3.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.foggykitchen_region2_oci_services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.foggykitchen_sgw3.id
  }

}

resource "oci_core_local_peering_gateway" "foggykitchen_region2_lpg2" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn4.id
  display_name   = "foggykitchen_region2_lpg2"
}

resource "oci_core_drg" "foggykitchen_drg3" {
  provider       = oci.region2
  display_name   = "foggykitchen_drg3"
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
}

resource "oci_core_drg_attachment" "foggykitchen_drg3_attachment" {
  provider       = oci.region2
  display_name   = "foggykitchen_drg3_attachment"
  drg_id         = oci_core_drg.foggykitchen_drg3.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn4.id
}

resource "oci_core_remote_peering_connection" "foggykitchen_rpc3_to_rpc1" {
  provider         = oci.region2
  compartment_id   = oci_identity_compartment.foggykitchen_compartment.id
  drg_id           = oci_core_drg.foggykitchen_drg3.id
  display_name     = "foggykitchen_rpc3_to_rpc1"
}

resource "oci_core_drg_route_table" "foggykitchen_drg3_rpc_rt" {
  provider     = oci.region2
  drg_id       = oci_core_drg.foggykitchen_drg3.id
  display_name = "foggykitchen_drg3_rpc_rt"
}

# <DRG3> -> <VCN4>
resource "oci_core_drg_route_table_route_rule" "foggykitchen_drg3_route_to_vcn4" {
    provider                   = oci.region2
	drg_route_table_id         = oci_core_drg_route_table.foggykitchen_drg3_rpc_rt.id
	destination                = "10.2.0.0/16"
	destination_type           = "CIDR_BLOCK"
	next_hop_drg_attachment_id = oci_core_drg_attachment.foggykitchen_drg3_attachment.id
}

resource "oci_core_drg_attachment_management" "foggykitchen_drg3_rpc3_to_rpc1_attachment_management" {
  provider           = oci.region2
  compartment_id     = oci_identity_compartment.foggykitchen_compartment.id
  attachment_type    = "REMOTE_PEERING_CONNECTION"
  display_name       = "foggykitchen_drg3_rpc3_to_rpc1_attachment_management"
  network_id         = oci_core_remote_peering_connection.foggykitchen_rpc3_to_rpc1.id
  drg_id             = oci_core_drg.foggykitchen_drg3.id
  drg_route_table_id = oci_core_drg_route_table.foggykitchen_drg3_rpc_rt.id
}

# <DRG3> -> <RPC3> -> <RPC1> -> <VCN1>
resource "oci_core_drg_route_table_route_rule" "foggykitchen_drg3_route_to_vcn1" {
    provider                   = oci.region2
    drg_route_table_id         = oci_core_drg_route_table.foggykitchen_drg3_rpc_rt.id
    destination                = "10.0.0.0/16"
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = oci_core_drg_attachment_management.foggykitchen_drg3_rpc3_to_rpc1_attachment_management.id
}

# <DRG3> -> <RPC3> -> <RPC1> -> <VCN2>
resource "oci_core_drg_route_table_route_rule" "foggykitchen_drg3_route_to_vcn2" {
    provider                   = oci.region2
    drg_route_table_id         = oci_core_drg_route_table.foggykitchen_drg3_rpc_rt.id
    destination                = "192.168.0.0/16"
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = oci_core_drg_attachment_management.foggykitchen_drg3_rpc3_to_rpc1_attachment_management.id
}

# <DRG3> -> <RPC3> -> <RPC1> -> <VCN3>
resource "oci_core_drg_route_table_route_rule" "foggykitchen_drg3_route_to_vcn3" {
    provider                   = oci.region2
    drg_route_table_id         = oci_core_drg_route_table.foggykitchen_drg3_rpc_rt.id
    destination                = "10.1.0.0/16"
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = oci_core_drg_attachment_management.foggykitchen_drg3_rpc3_to_rpc1_attachment_management.id
}