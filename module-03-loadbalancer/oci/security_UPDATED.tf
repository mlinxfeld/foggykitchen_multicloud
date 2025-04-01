resource "oci_core_security_list" "foggykitchen_ssh_seclist" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  vcn_id         = oci_core_vcn.foggykitchen_vcn.id
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
  vcn_id         = oci_core_vcn.foggykitchen_vcn.id
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
  vcn_id         = oci_core_vcn.foggykitchen_vcn.id
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

