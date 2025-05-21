module "oci-foggykitchen-adb" {
  source                                = "github.com/mlinxfeld/terraform-oci-fk-adb"
  adb_database_db_name                  = "foggykitchenadbs"
  adb_database_display_name             = "foggykitchenadbs"
  adb_password                          = var.adb_password
  adb_database_db_workload              = "OLTP" 
  adb_free_tier                         = false
  adb_database_cpu_core_count           = 1
  adb_database_data_storage_size_in_tbs = 1
  compartment_ocid                      = oci_identity_compartment.foggykitchen_compartment.id
  use_existing_vcn                      = true
  adb_private_endpoint                  = true
  adb_subnet_id                         = oci_core_subnet.foggykitchen_db_sub.id
  adb_nsg_id                            = oci_core_network_security_group.foggykitchen_adb_nsg.id
}
