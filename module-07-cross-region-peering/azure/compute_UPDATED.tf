resource "azurerm_linux_virtual_machine" "foggykitchen_bastion_vm" {
  name                = "foggykitchen_bastion_vm"
  computer_name       = "fkbastionvm"
  location            = azurerm_resource_group.foggykitchen_rg1.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg1.name
  size                = var.vm_size
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.foggykitchen_bastion_nic.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.public_private_key_pair.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "foggykitchen_backend_vm" {
  count = var.node_count

  name                = "foggykitchen_backend_vm${count.index + 1}"
  computer_name       = "fkbackendvm${count.index + 1}"
  location            = azurerm_resource_group.foggykitchen_rg1.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg1.name
  size                = var.vm_size
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.foggykitchen_backend_nic[count.index].id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.public_private_key_pair.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "foggykitchen_bastion_vm2" {
  name                = "foggykitchen_bastion_vm2"
  computer_name       = "fkbastionvm2"
  location            = azurerm_resource_group.foggykitchen_rg2.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg2.name
  size                = var.vm_size
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.foggykitchen_bastion2_nic.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.public_private_key_pair.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
