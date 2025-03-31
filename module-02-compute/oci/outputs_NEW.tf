
output "bastion_public_ip" {
  description = "The public IP address of the Bastion VM"
  value       = oci_core_instance.foggykitchen_bastion_vm.public_ip
}

output "backend_private_ip" {
  description = "The private IP address of the Backend VM"
  value       = oci_core_instance.foggykitchen_backend_vm.private_ip
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