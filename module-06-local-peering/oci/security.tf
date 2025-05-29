resource "oci_core_security_list" "foggykitchen_ssh_seclist" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn1.id
  display_name   = "foggykitchen_ssh_seclist"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_security_list" "foggykitchen_lb_seclist" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn1.id
  display_name   = "foggykitchen_lb_seclist"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }
}

resource "oci_core_security_list" "foggykitchen_backend_seclist" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn1.id
  display_name   = "foggykitchen_backend_seclist"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "10.0.3.0/24" # Allow traffic only from the Load Balancer Subnet

    tcp_options {
      min = 80
      max = 80
    }
  }
}


resource "oci_core_network_security_group" "foggykitchen_fss_nsg" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  display_name   = "foggykitchen_fss_nsg"
  vcn_id         = oci_core_vcn.foggykitchen_vcn1.id
}

resource "oci_core_network_security_group_security_rule" "foggykitchen_fss_nsg_ingress_tcp_group_rules" {
  for_each = toset(var.fss_ingress_tcp_ports)

  network_security_group_id = oci_core_network_security_group.foggykitchen_fss_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "10.0.2.0/24"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

resource "oci_core_network_security_group_security_rule" "foggykitchen_fss_nsg_ingress_udp_group_rules" {
  for_each = toset(var.fss_ingress_udp_ports)

  network_security_group_id = oci_core_network_security_group.foggykitchen_fss_nsg.id
  direction                 = "INGRESS"
  protocol                  = "17"
  source                    = "10.0.2.0/24"
  source_type               = "CIDR_BLOCK"
  udp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

resource "oci_core_network_security_group_security_rule" "foggykitchen_fss_nsg_egress_tcp_group_rules" {
  for_each = toset(var.fss_egress_tcp_ports)

  network_security_group_id = oci_core_network_security_group.foggykitchen_fss_nsg.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "10.0.2.0/24"
  destination_type          = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

resource "oci_core_network_security_group_security_rule" "foggykitchen_fss_nsg_egress_udp_group_rules" {
  for_each = toset(var.fss_egress_udp_ports)

  network_security_group_id = oci_core_network_security_group.foggykitchen_fss_nsg.id
  direction                 = "EGRESS"
  protocol                  = "17"
  destination               = "10.0.2.0/24"
  destination_type          = "CIDR_BLOCK"
  udp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

resource "oci_core_network_security_group" "foggykitchen_adb_nsg" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  display_name   = "foggykitchen_adb_nsg"
  vcn_id         = oci_core_vcn.foggykitchen_vcn2.id
}

resource "oci_core_network_security_group_security_rule" "foggykitchen_adb_nsg_egress_group_sec_rule" {
  network_security_group_id = oci_core_network_security_group.foggykitchen_adb_nsg.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "10.0.2.0/24"
  destination_type          = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "fk_adb_nsg_ingress_group_sec_rule" {
  network_security_group_id = oci_core_network_security_group.foggykitchen_adb_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "10.0.2.0/24"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 1522
      min = 1522
    }
  }
}


