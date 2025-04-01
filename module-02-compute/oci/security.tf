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
