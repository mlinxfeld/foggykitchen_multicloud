
resource "null_resource" "provision_backend" {
  count = var.node_count

  depends_on = [oci_core_instance.foggykitchen_backend_vm]

  connection {
    type                = "ssh"
    user                = "opc"
    private_key         = tls_private_key.public_private_key_pair.private_key_pem
    host                = oci_core_instance.foggykitchen_backend_vm[count.index].private_ip
    bastion_host        = oci_core_instance.foggykitchen_bastion_vm.public_ip
    bastion_user        = "opc"
    bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
  }

  provisioner "remote-exec" {
    inline = ["echo '== 1. Installing HTTPD package with dnf'",
      "sudo -u root dnf -y -q install httpd",

      "echo '== 2. Creating /var/www/html/index.html'",
      "sudo -u root touch /var/www/html/index.html",
      "sudo /bin/su -c \"echo 'Welcome to FoggyKitchen.com! This is WEBSERVER${count.index + 1}...' > /var/www/html/index.html\"",

      "echo '== 3. Disabling firewall and starting HTTPD service'",
      "sudo -u root service firewalld stop",
      "sudo -u root service httpd start"]
  }

}
