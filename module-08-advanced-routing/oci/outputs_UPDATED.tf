output "foggykitchen_bastion_vm_public_ip" {
  description = "The public IP address of the Bastion VM (region1)"
  value       = oci_core_instance.foggykitchen_bastion_vm.public_ip
}

output "foggykitchen_bastion_vm2_public_ip" {
  description = "The public IP address of the Bastion VM2 (region2)"
  value       = oci_core_instance.foggykitchen_bastion_vm2.public_ip
}

output "foggykitchen_backend_vms_private_ips" {
  value = {
    for i, ip in data.oci_core_vnic.foggykitchen_backend_vm_vnic1[*].private_ip_address :
    oci_core_instance.foggykitchen_backend_vm[i].display_name => ip
  }
}

output "foggykitchen_analytics_vm_private_ip" {
  value = data.oci_core_vnic.foggykitchen_analytical_vm_vnic1.private_ip_address
}

output "ssh_private_key_pem" {
  description = "Private SSH key for connecting to the instances"
  value       = tls_private_key.public_private_key_pair.private_key_pem
  sensitive   = true
}

output "ssh_public_key_openssh" {
  description = "Public SSH key used for instance metadata"
  value       = tls_private_key.public_private_key_pair.public_key_openssh
}

output "foggykitchen_loadbalancer_public_ip" {
  value = oci_load_balancer.foggykitchen_loadbalancer.ip_address_details[0].ip_address
}

output "foggykitchen_adbs_database_id" {
  value = module.oci-foggykitchen-adb.adb_database.adb_database_id 
}