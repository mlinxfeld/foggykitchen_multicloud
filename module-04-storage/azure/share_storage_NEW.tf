resource "azurerm_storage_account" "foggykitchen_sa" {
  name                       = "foggykitchenstorage" 
  resource_group_name        = azurerm_resource_group.foggykitchen_rg.name
  location                   = azurerm_resource_group.foggykitchen_rg.location
  account_tier               = "Premium"
  account_replication_type   = "LRS"
  account_kind               = "FileStorage"
  access_tier                = "Hot"
  https_traffic_only_enabled = false 
}

resource "azurerm_storage_share" "foggykitchen_share" {
  name                 = "sharedfs"
  storage_account_name = azurerm_storage_account.foggykitchen_sa.name
  quota                = var.storage_quota_gb
  enabled_protocol     = "NFS"
}

resource "azurerm_storage_account_network_rules" "foggykitchen_nfs_nsg" {
  depends_on = [
    azurerm_subnet.foggykitchen_private_subnet,
    azurerm_storage_account.foggykitchen_sa
  ]
  storage_account_id = azurerm_storage_account.foggykitchen_sa.id

  default_action             = "Deny"
  virtual_network_subnet_ids = [ azurerm_subnet.foggykitchen_private_subnet.id ]
  ip_rules                   = ["89.64.90.117"]

  bypass = ["AzureServices"]
}

resource "azurerm_private_endpoint" "foggykitchen_storage_pe" {
  name                = "foggykitchen-storage-pe"
  location            = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name
  subnet_id           = azurerm_subnet.foggykitchen_private_subnet.id

  private_service_connection {
    name                           = "foggykitchen-storage-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.foggykitchen_sa.id
    subresource_names              = ["file"] 
  }

  depends_on = [
    azurerm_storage_account_network_rules.foggykitchen_nfs_nsg
  ]
}

