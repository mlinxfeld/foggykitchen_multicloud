
resource "null_resource" "provision_backend" {
  depends_on = [oci_core_instance.foggykitchen_backend_vm]

  connection {
    type                = "ssh"
    user                = "opc"
    private_key         = tls_private_key.public_private_key_pair.private_key_pem
    host                = oci_core_instance.foggykitchen_backend_vm.private_ip
    bastion_host        = oci_core_instance.foggykitchen_bastion_vm.public_ip
    bastion_user        = "opc"
    bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }
}
