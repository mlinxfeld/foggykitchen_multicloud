resource "oci_core_instance" "foggykitchen_bastion_vm" {
  provider            = oci.region1
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = oci_identity_compartment.foggykitchen_compartment.id
  display_name        = "foggykitchen_bastion_vm"
  shape               = var.bastion_vm_shape

  dynamic "shape_config" {
    for_each = local.is_bastion_vm_flexible_shape ? [1] : []
    content {
      memory_in_gbs = var.bastion_vm_flex_shape_memory
      ocpus         = var.bastion_vm_flex_shape_ocpus
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.foggykitchen_public_sub.id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.latest_oci_linux_image_for_bastion_vm.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
}

resource "oci_core_instance" "foggykitchen_backend_vm" {
  provider = oci.region1
  count = var.node_count

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[count.index % length(data.oci_identity_availability_domains.ads.availability_domains)].name
  compartment_id      = oci_identity_compartment.foggykitchen_compartment.id
  display_name        = "foggykitchen_backend_vm${count.index + 1}"
  fault_domain        = "FAULT-DOMAIN-${(count.index % 3)+ 1}"
  shape               = var.backend_vm_shape

  dynamic "shape_config" {
    for_each = local.is_backend_vm_flexible_shape ? [1] : []
    content {
      memory_in_gbs = var.backend_vm_flex_shape_memory
      ocpus         = var.backend_vm_flex_shape_ocpus
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.foggykitchen_private_sub.id
    assign_public_ip = false
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.latest_oci_linux_image_for_backend_vm.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
}

resource "oci_core_instance" "foggykitchen_bastion_vm2" {
  provider            = oci.region2
  availability_domain = data.oci_identity_availability_domains.ads2.availability_domains[0].name
  compartment_id      = oci_identity_compartment.foggykitchen_compartment.id
  display_name        = "foggykitchen_bastion_vm2"
  shape               = var.bastion_vm_shape

  dynamic "shape_config" {
    for_each = local.is_bastion_vm_flexible_shape ? [1] : []
    content {
      memory_in_gbs = var.bastion_vm_flex_shape_memory
      ocpus         = var.bastion_vm_flex_shape_ocpus
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.foggykitchen_public_sub2.id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.latest_oci_linux_image_for_bastion_vm2.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
}

resource "oci_core_instance" "foggykitchen_analytical_vm" {
  provider = oci.region2

  availability_domain = data.oci_identity_availability_domains.ads2.availability_domains[0].name
  compartment_id      = oci_identity_compartment.foggykitchen_compartment.id
  display_name        = "foggykitchen_analytical_vm"
  fault_domain        = "FAULT-DOMAIN-1"
  shape               = var.analytical_vm_shape

  dynamic "shape_config" {
    for_each = local.is_analytical_vm_flexible_shape ? [1] : []
    content {
      memory_in_gbs = var.analytical_vm_flex_shape_memory
      ocpus         = var.analytical_vm_flex_shape_ocpus
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.foggykitchen_private_sub2.id
    assign_public_ip = false
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.latest_oci_linux_image_for_analytical_vm.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
}
