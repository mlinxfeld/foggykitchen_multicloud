resource "oci_file_storage_mount_target" "foggykitchen_mount_target" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = oci_identity_compartment.foggykitchen_compartment.id
  subnet_id           = oci_core_subnet.foggykitchen_fss_sub.id
  ip_address          = var.mount_target_ip_address
  display_name        = "foggykitchen_mount_target"
  nsg_ids             = [oci_core_network_security_group.foggykitchen_fss_nsg.id]
}

resource "oci_file_storage_export_set" "foggykitchen_exportset" {
  mount_target_id = oci_file_storage_mount_target.foggykitchen_mount_target.id
  display_name    = "foggykitchen_exportset"
}

resource "oci_file_storage_file_system" "foggykitchen_filesystem" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = oci_identity_compartment.foggykitchen_compartment.id
  display_name        = "foggykitchen_filesystem"
}

resource "oci_file_storage_export" "foggykitchen_export" {
  export_set_id  = oci_file_storage_mount_target.foggykitchen_mount_target.export_set_id
  file_system_id = oci_file_storage_file_system.foggykitchen_filesystem.id
  path           = "/sharedfs"

  export_options {
    source                         = "10.0.2.0/24" # Private subnet only
    access                         = "READ_WRITE"
    identity_squash                = "NONE"
  }

}


