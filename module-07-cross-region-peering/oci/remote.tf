resource "null_resource" "foggykitchen_iscsi_attach_on_backend_vm" {
  count = var.node_count
  triggers = {
    instance_id = oci_core_instance.foggykitchen_backend_vm[count.index].id
  }  
  depends_on = [
    oci_core_instance.foggykitchen_backend_vm, 
    oci_core_instance.foggykitchen_bastion_vm,
    oci_core_volume_attachment.foggykitchen_backend_vm_block_volume_attach
  ]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      host                = oci_core_instance.foggykitchen_backend_vm[count.index].private_ip
      bastion_host        = oci_core_instance.foggykitchen_bastion_vm.public_ip
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = ["sudo /bin/su -c \"rm -Rf /home/opc/iscsiattach.sh\""]
  }

  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "opc"
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      host                = oci_core_instance.foggykitchen_backend_vm[count.index].private_ip
      bastion_host        = oci_core_instance.foggykitchen_bastion_vm.public_ip
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    source      = "iscsiattach.sh"
    destination = "/home/opc/iscsiattach.sh"
  }

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      host                = oci_core_instance.foggykitchen_backend_vm[count.index].private_ip
      bastion_host        = oci_core_instance.foggykitchen_bastion_vm.public_ip
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = ["sudo /bin/su -c \"chown root /home/opc/iscsiattach.sh\"",
              "sudo /bin/su -c \"chmod u+x /home/opc/iscsiattach.sh\"",
              "sudo /bin/su -c \"/home/opc/iscsiattach.sh\""]
  }

}

resource "null_resource" "foggykitchen_mount_u01_fstab_on_backend_vm" {
  count = var.node_count
  triggers = {
    instance_id = oci_core_instance.foggykitchen_backend_vm[count.index].id
  } 
  depends_on = [
    null_resource.foggykitchen_iscsi_attach_on_backend_vm
  ]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      host                = oci_core_instance.foggykitchen_backend_vm[count.index].private_ip
      bastion_host        = oci_core_instance.foggykitchen_bastion_vm.public_ip
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = ["echo '== Start of null_resource.foggykitchen_mount_u01_fstab_on_backend_vm'",
      "sudo -u root parted /dev/sdb --script -- mklabel gpt",
      "sudo -u root parted /dev/sdb --script -- mkpart primary ext4 0% 100%",
      "sudo -u root mkfs.ext4 -F /dev/sdb1",
      "sudo -u root mkdir /u01",
      "sudo -u root mount /dev/sdb1 /u01",
      "sudo /bin/su -c \"echo '/dev/sdb1              /u01  ext4    defaults,noatime,_netdev    0   0' >> /etc/fstab\"",
      "sudo -u root mount | grep sdb1",
      "echo '== End of null_resource.foggykitchen_mount_u01_fstab_on_backend_vm'",
    ]
  }
}

resource "null_resource" "foggykitchen_shared_filesystem_mount_on_backend_vm" {
  count = var.node_count
  triggers = {
    instance_id = oci_core_instance.foggykitchen_backend_vm[count.index].id
  }  
  depends_on = [
    oci_core_instance.foggykitchen_backend_vm, 
    oci_core_instance.foggykitchen_bastion_vm, 
    oci_file_storage_export.foggykitchen_export
  ]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      host                = oci_core_instance.foggykitchen_backend_vm[count.index].private_ip
      bastion_host        = oci_core_instance.foggykitchen_bastion_vm.public_ip
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = [
      "sudo /bin/su -c \"dnf install -y -q nfs-utils\"",
      "sudo /bin/su -c \"mkdir -p /sharedfs\"",
      "sudo /bin/su -c \"echo '${var.mount_target_ip_address}:/sharedfs /sharedfs nfs rsize=8192,wsize=8192,timeo=14,intr 0 0' >> /etc/fstab\"",
      "sudo /bin/su -c \"mount /sharedfs -v\"",
    ]
  }

}

resource "null_resource" "foggykitchen_provision_backend" {
  count = var.node_count

  depends_on = [null_resource.foggykitchen_shared_filesystem_mount_on_backend_vm]

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
    inline = [
      "echo '== 1. Installing HTTPD package with dnf'",
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
      "sudo -u root service httpd start"
    ]
  }

}

 resource "null_resource" "foggykitchen_access_db_from_backend" {
  count = var.node_count

  depends_on = [null_resource.foggykitchen_provision_backend,
                module.oci-foggykitchen-adb]

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
    inline = [
      "echo '== Installing Oracle Instant Client (SQLPlus)'",
      "sudo yum install -y oracle-release-el8 || true",
      "sudo yum install -y oracle-instantclient-release-el8 || true",
      "sudo yum install -y oracle-instantclient-basic oracle-instantclient-sqlplus oracle-instantclient-tools || true",

      "echo '== Unpacking ADB Wallet & SQL*Net setup'",
      "echo '${module.oci-foggykitchen-adb.adb_database.adb_wallet_content}' | base64 -d | sudo tee /usr/lib/oracle/21/client64/lib/network/admin/wallet_ADB.zip > /dev/null",
      "sudo unzip -o /usr/lib/oracle/21/client64/lib/network/admin/wallet_ADB.zip -d /usr/lib/oracle/21/client64/lib/network/admin/",
      "sudo sed -i 's/fkadbpe\\.adb\\.${var.region1}\\.oraclecloud\\.com/${module.oci-foggykitchen-adb.adb_database.private_endpoint_ip}/g' /usr/lib/oracle/21/client64/lib/network/admin/tnsnames.ora",
      "sudo chmod 644 /usr/lib/oracle/21/client64/lib/network/admin/*",
      "sudo rm /usr/lib/oracle/21/client64/lib/network/admin/sqlnet.ora",
      "echo 'WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY=/usr/lib/oracle/21/client64/lib/network/admin/)))' | sudo tee /usr/lib/oracle/21/client64/lib/network/admin/sqlnet.ora > /dev/null",
      "echo 'SSL_SERVER_DN_MATCH=no' | sudo tee -a /usr/lib/oracle/21/client64/lib/network/admin/sqlnet.ora > /dev/null",

      "echo '== Setting up connection and checking database open-mode'",
      "export TNS_ADMIN=/usr/lib/oracle/21/client64/lib/network/admin",
      "export LD_LIBRARY_PATH=/usr/lib/oracle/21/client64/lib",
      "echo \"SELECT NAME, OPEN_MODE FROM V\\$DATABASE;\" > adb-check.sql",
      "echo \"EXIT;\" >> adb-check.sql",
      "export LD_LIBRARY_PATH=/usr/lib/oracle/21/client64/lib && export TNS_ADMIN=/usr/lib/oracle/21/client64/lib/network/admin && /usr/lib/oracle/21/client64/bin/sqlplus -s admin/${var.adb_password}@foggykitchenadbs_high @adb-check.sql"
    ]
  } 
}   