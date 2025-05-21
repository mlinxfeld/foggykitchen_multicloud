output "bastion_vm_public_ip" {
  description = "The public IP address of the Bastion VM"
  value       = azurerm_public_ip.foggykitchen_bastion_public_ip.ip_address
}

output "backend_vms_private_ips" {
  description = "The private IP addresses of backend VMs"
  value = {
    for i in range(var.node_count) :
    azurerm_linux_virtual_machine.foggykitchen_backend_vm[i].name => azurerm_network_interface.foggykitchen_backend_nic[i].private_ip_address
  }
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
  description = "Public IP of the Azure Load Balancer"
  value       = azurerm_public_ip.foggykitchen_lb_public_ip.ip_address
}

output "foggykitchen_postgresql_fqdn" {
  description = "The fully qualified domain name of the PostgreSQL flexible server"
  value       = azurerm_postgresql_flexible_server.foggykitchen_pg.fqdn
}