resource "null_resource" "provision_backend" {
  count = var.node_count

  depends_on = [azurerm_linux_virtual_machine.foggykitchen_backend_vm]

  connection {
    type                = "ssh"
    user                = "azureuser"
    host                = azurerm_network_interface.foggykitchen_backend_nic[count.index].private_ip_address
    private_key         = tls_private_key.public_private_key_pair.private_key_pem
    bastion_host        = azurerm_public_ip.foggykitchen_bastion_public_ip.ip_address
    bastion_user        = "azureuser"
    bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
  }

provisioner "remote-exec" {
  inline = [
    "echo '== 1. Installing NGINX package with apt'",
    "sudo apt-get update -qq",
    "sudo apt-get install -y nginx",

    "echo '== 2. Creating /var/www/html/index.html'",
    "echo 'Welcome to FoggyKitchen.com! This is WEBSERVER${count.index + 1}...' | sudo tee /var/www/html/index.html",

    "echo '== 3. Disabling UFW and starting NGINX service'",
    "sudo ufw disable || true",
    "sudo systemctl enable nginx",
    "sudo systemctl restart nginx"
  ]
}
}