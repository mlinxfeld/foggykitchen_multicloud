resource "null_resource" "provision_backend" {
  depends_on = [azurerm_linux_virtual_machine.foggykitchen_backend_vm]

  connection {
    type                = "ssh"
    user                = "azureuser"
    host                = azurerm_public_ip.foggykitchen_bastion_public_ip.ip_address
    private_key         = tls_private_key.public_private_key_pair.private_key_pem
    bastion_host        = azurerm_public_ip.foggykitchen_bastion_public_ip.ip_address
    bastion_user        = "azureuser"
    bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }
}