data "oci_core_images" "latest_oci_linux_image_for_bastion_vm" {
  provider = oci.region1
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

data "oci_core_images" "latest_oci_linux_image_for_bastion_vm2" {
  provider = oci.region2
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

data "oci_core_images" "latest_oci_linux_image_for_analytical_vm" {
  provider = oci.region2
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
  provider = oci.region1
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
  provider = oci.region1
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
}

data "oci_identity_availability_domains" "ads2" {
  provider = oci.region2
  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
}

data "oci_core_vnic_attachments" "foggykitchen_backend_vm_vnic1_attach" {
  provider            = oci.region1
  count               = var.node_count

  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[count.index % length(data.oci_identity_availability_domains.ads.availability_domains)], "name") 
  compartment_id      = oci_identity_compartment.foggykitchen_compartment.id
  instance_id         = oci_core_instance.foggykitchen_backend_vm[count.index].id
}

data "oci_core_vnic" "foggykitchen_backend_vm_vnic1" {
  provider = oci.region1
  count   = var.node_count

  vnic_id = data.oci_core_vnic_attachments.foggykitchen_backend_vm_vnic1_attach[count.index].vnic_attachments.0.vnic_id
}

data "oci_core_vnic_attachments" "foggykitchen_analytical_vm_vnic1_attach" {
  provider            = oci.region2
  availability_domain = data.oci_identity_availability_domains.ads2.availability_domains[0].name
  compartment_id      = oci_identity_compartment.foggykitchen_compartment.id
  instance_id         = oci_core_instance.foggykitchen_analytical_vm.id
}

data "oci_core_vnic" "foggykitchen_analytical_vm_vnic1" {
  provider = oci.region2
  vnic_id  = data.oci_core_vnic_attachments.foggykitchen_analytical_vm_vnic1_attach.vnic_attachments.0.vnic_id
}

data "oci_core_services" "foggykitchen_region1_oci_services" {
  provider = oci.region1
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

data "oci_core_services" "foggykitchen_region2_oci_services" {
  provider = oci.region2
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}