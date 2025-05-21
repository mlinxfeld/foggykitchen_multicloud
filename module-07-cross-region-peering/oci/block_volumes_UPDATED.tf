resource "oci_core_volume" "foggykitchen_backend_vm_block_volume" {
  provider            = oci.region1
  count               = var.node_count
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[count.index % length(data.oci_identity_availability_domains.ads.availability_domains)].name  
  compartment_id      = oci_identity_compartment.foggykitchen_compartment.id
  display_name        = "foggykitchen_backend_vm${count.index + 1}_block_volume"
  size_in_gbs         = var.volume_size_in_gbs
  vpus_per_gb         = var.vpus_per_gb
}

resource "oci_core_volume_attachment" "foggykitchen_backend_vm_block_volume_attach" {
  provider        = oci.region1
  count           = var.node_count
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.foggykitchen_backend_vm[count.index].id
  volume_id       = oci_core_volume.foggykitchen_backend_vm_block_volume[count.index].id
}

