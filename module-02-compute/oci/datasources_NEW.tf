data "oci_core_images" "latest_oci_linux_image_for_bastion_vm" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  operating_system = "Oracle Linux"
  operating_system_version = "8"
  shape = var.bastion_vm_shape
  sort_by = "TIMECREATED"

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

data "oci_core_images" "latest_oci_linux_image_for_backend_vm" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  operating_system = "Oracle Linux"
  operating_system_version = "8"
  shape = var.backend_vm_shape
  
  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
}
