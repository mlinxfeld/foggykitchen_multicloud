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

data "oci_core_vnic_attachments" "foggykitchen_backend_vm_vnic1_attach" {
  count               = var.node_count

  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[count.index % length(data.oci_identity_availability_domains.ads.availability_domains)], "name") 
  compartment_id      = oci_identity_compartment.foggykitchen_compartment.id
  instance_id         = oci_core_instance.foggykitchen_backend_vm[count.index].id
}

data "oci_core_vnic" "foggykitchen_backend_vm_vnic1" {
  count   = var.node_count

  vnic_id = data.oci_core_vnic_attachments.foggykitchen_backend_vm_vnic1_attach[count.index].vnic_attachments.0.vnic_id
}
