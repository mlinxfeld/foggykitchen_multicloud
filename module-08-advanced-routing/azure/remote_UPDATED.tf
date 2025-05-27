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
  depends_on = [ 
    azurerm_private_endpoint.foggykitchen_storage_pe 
  ]
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
      "sudo mkdir -p /mount/sharedfs",
      "sudo /bin/su -c \"echo 'foggykitchenstorage.file.core.windows.net:/foggykitchenstorage/sharedfs /mount/sharedfs nfs vers=4,minorversion=1,_netdev,nofail,sec=sys 0 0' >> /etc/fstab\"",
      "sudo mount /mount/sharedfs -v"
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
    inline = [
      "echo '== 1. Installing Apache2 package with apt'",
      "sudo apt-get update -qq",
      "sudo apt-get install -y apache2",

      "echo '== 2. Creating /mount/sharedfs/index.html'",
      "echo 'Welcome to FoggyKitchen.com! These are both WEBSERVERS under LB umbrella with shared index.html ...' | sudo tee /mount/sharedfs/index.html",

      "echo '== 3. Adding Alias to Apache config'",
      "sudo bash -c 'echo \"Alias /shared/ /mount/sharedfs/\" > /etc/apache2/conf-available/sharedfs.conf'",
      "sudo bash -c 'echo \"<Directory /mount/sharedfs>\" >> /etc/apache2/conf-available/sharedfs.conf'",
      "sudo bash -c 'echo \"  AllowOverride All\" >> /etc/apache2/conf-available/sharedfs.conf'",
      "sudo bash -c 'echo \"  Require all granted\" >> /etc/apache2/conf-available/sharedfs.conf'",
      "sudo bash -c 'echo \"</Directory>\" >> /etc/apache2/conf-available/sharedfs.conf'",

      "echo '== 4. Enabling sharedfs config and restarting Apache'",
      "sudo a2enconf sharedfs",
      "sudo systemctl restart apache2",

      "echo '== 5. Ensuring Apache is enabled on boot'",
      "sudo systemctl enable apache2"
    ]
  }
}

resource "null_resource" "foggykitchen_access_db_from_backend" {
  count = var.node_count

  depends_on = [
    null_resource.foggykitchen_provision_backend,
    null_resource.foggykitchen_attach_and_mount_data_disk,
    null_resource.foggykitchen_mount_nfs_shared_storage,
    azurerm_postgresql_flexible_server.foggykitchen_pg,
    azurerm_postgresql_flexible_server_database.foggykitchen_db,
    azurerm_private_dns_zone_virtual_network_link.foggykitchen_pg_dns_link1,
    azurerm_private_dns_zone_virtual_network_link.foggykitchen_pg_dns_link2
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
      "echo '== Installing PostgreSQL client tools'",
      "sudo apt-get update -y",
      "sudo apt-get install -y postgresql-client",

      "echo '== Testing PostgreSQL database private address'",
      "nslookup foggykitchen-pg.postgres.database.azure.com",
      
      "echo '== Testing PostgreSQL connection from backend VM'",
      "PGPASSWORD=\"${var.pg_admin_password}\" PAGER=cat psql \"host=foggykitchen-pg.postgres.database.azure.com dbname=foggydb user=${var.pg_admin_username} sslmode=require\" -c \"\\l\" "
    ]
  }
}

resource "null_resource" "foggykitchen_access_db_from_analytical" {

  depends_on = [
    null_resource.foggykitchen_provision_backend,
    null_resource.foggykitchen_attach_and_mount_data_disk,
    null_resource.foggykitchen_mount_nfs_shared_storage,
    azurerm_postgresql_flexible_server.foggykitchen_pg,
    azurerm_postgresql_flexible_server_database.foggykitchen_db,
    azurerm_private_dns_zone_virtual_network_link.foggykitchen_pg_dns_link1,
    azurerm_private_dns_zone_virtual_network_link.foggykitchen_pg_dns_link2,
    azurerm_private_dns_zone_virtual_network_link.foggykitchen_pg_dns_link3
  ]

  connection {
    type                = "ssh"
    host                = azurerm_linux_virtual_machine.foggykitchen_analytical_vm.private_ip_address
    user                = "azureuser"
    private_key         = tls_private_key.public_private_key_pair.private_key_pem
    bastion_host        = azurerm_public_ip.foggykitchen_bastion2_public_ip.ip_address
    bastion_user        = "azureuser"
    bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "echo '== Installing PostgreSQL client tools'",
      "sudo apt-get update -y",
      "sudo apt-get install -y postgresql-client",

      "echo '== Testing PostgreSQL database private address'",
      "nslookup foggykitchen-pg.postgres.database.azure.com",
      
      "echo '== Testing PostgreSQL connection from backend VM'",
      "PGPASSWORD=\"${var.pg_admin_password}\" PAGER=cat psql \"host=foggykitchen-pg.postgres.database.azure.com dbname=foggydb user=${var.pg_admin_username} sslmode=require\" -c \"\\l\" "
    ]
  }
}