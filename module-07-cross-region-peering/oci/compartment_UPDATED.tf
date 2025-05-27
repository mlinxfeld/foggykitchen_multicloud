resource "oci_identity_compartment" "foggykitchen_compartment" {
  name          = "foggykitchen_compartment"
  description   = "foggykitchen_compartment"
  enable_delete = true
  compartment_id = var.tenancy_ocid
  provisioner "local-exec" {
    command = "sleep 60"
  }
}
