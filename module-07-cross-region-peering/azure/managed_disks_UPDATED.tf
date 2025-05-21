resource "azurerm_managed_disk" "foggykitchen_backend_vm_data_disk" {
  count                = var.node_count
  name                 = "foggykitchen-backend-vm${count.index + 1}-data-disk"
  location             = azurerm_resource_group.foggykitchen_rg1.location
  resource_group_name  = azurerm_resource_group.foggykitchen_rg1.name
  storage_account_type = var.disk_sku          
  create_option        = "Empty"
  disk_size_gb         = var.disk_size_gb
  zone                 = var.use_zones ? element(["1", "2", "3"], count.index % 3) : null
}

resource "azurerm_virtual_machine_data_disk_attachment" "foggykitchen_backend_vm_attach_disk" {
  count              = var.node_count
  managed_disk_id    = azurerm_managed_disk.foggykitchen_backend_vm_data_disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.foggykitchen_backend_vm[count.index].id
  lun                = 10 + count.index
  caching            = "ReadWrite"
}
