# Azure equivalent using Terraform and null_resource provisioners

resource "null_resource" "foggykitchen_attach_and_mount_data_disk" {
  count = var.node_count

  triggers = {
    vm_id = azurerm_linux_virtual_machine.foggykitchen_backend_vm[count.index].id
  }

  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.foggykitchen_backend_vm_attach_disk
  ]

  connection {
    type                = "ssh"
    host                = azurerm_linux_virtual_machine.foggykitchen_backend_vm[count.index].private_ip_address
    user                = "azureuser"
    private_key         = tls_private_key.public_private_key_pair.private_key_pem
    bastion_host        = azurerm_public_ip.foggykitchen_bastion_public_ip.ip_address
    bastion_user        = "azureuser"
    bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "echo '== Creating /u01 and mounting /dev/sdc1'",
      "sudo parted /dev/sdc --script -- mklabel gpt",
      "sudo parted /dev/sdc --script -- mkpart primary ext4 0% 100%",
      "sudo mkfs.ext4 -F /dev/sdc1",
      "sudo mkdir -p /u01",
      "sudo mount /dev/sdc1 /u01",
      "echo '/dev/sdc1 /u01 ext4 defaults,noatime,_netdev 0 0' | sudo tee -a /etc/fstab"
    ]
  }
}

resource "null_resource" "foggykitchen_mount_nfs_shared_storage" {
  count = var.node_count

  triggers = {
    vm_id = azurerm_linux_virtual_machine.foggykitchen_backend_vm[count.index].id
  }

  connection {
    type                = "ssh"
    host                = azurerm_linux_virtual_machine.foggykitchen_backend_vm[count.index].private_ip_address
    user                = "azureuser"
    private_key         = tls_private_key.public_private_key_pair.private_key_pem
    bastion_host        = azurerm_public_ip.foggykitchen_bastion_public_ip.ip_address
    bastion_user        = "azureuser"
    bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "echo '== Installing NFS utils and mounting share'",
      "sudo apt-get update -y",
      "sudo apt-get install -y nfs-common",
      "sudo mkdir -p /sharedfs",
      "echo '${azurerm_storage_account.foggykitchen_sa.primary_blob_host}:/sharedfs /sharedfs nfs defaults 0 0' | sudo tee -a /etc/fstab",
      "sudo mount /sharedfs"
    ]
  }
}

resource "null_resource" "foggykitchen_provision_backend" {
  count = var.node_count
  depends_on = [null_resource.foggykitchen_mount_nfs_shared_storage]

  connection {
    type                = "ssh"
    host                = azurerm_linux_virtual_machine.foggykitchen_backend_vm[count.index].private_ip_address
    user                = "azureuser"
    private_key         = tls_private_key.public_private_key_pair.private_key_pem
    bastion_host        = azurerm_public_ip.foggykitchen_bastion_public_ip.ip_address
    bastion_user        = "azureuser"
    bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
  }

  provisioner "remote-exec" {
    inline = ["echo '== 1. Installing HTTPD package with dnf'",
      "sudo -u root dnf -y -q install httpd",

      "echo '== 2. Creating /sharedfs/index.html'",
      "sudo -u root touch /sharedfs/index.html",
      "sudo /bin/su -c \"echo 'Welcome to FoggyKitchen.com! These are both WEBSERVERS under LB umbrella with shared index.html ...' > /sharedfs/index.html\"",

      "echo '== 3. Adding Alias and Directory sharedfs to /etc/httpd/conf/httpd.conf'",
      "sudo /bin/su -c \"echo 'Alias /shared/ /sharedfs/' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo '<Directory /sharedfs>' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo 'AllowOverride All' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo 'Require all granted' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo '</Directory>' >> /etc/httpd/conf/httpd.conf\"",

      "echo '== 4. Disabling SELinux'",
      "sudo -u root setenforce 0",

      "echo '== 5. Disabling firewall and starting HTTPD service'",
      "sudo -u root service firewalld stop",
    "sudo -u root service httpd start"]
  }
}
