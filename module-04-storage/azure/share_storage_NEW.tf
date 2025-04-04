resource "azurerm_storage_account" "foggykitchen_sa" {
  name                     = "foggykitchenstorage${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.foggykitchen_rg.name
  location                 = azurerm_resource_group.foggykitchen_rg.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"
  access_tier              = "Hot"
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_share" "foggykitchen_share" {
  name                 = "sharedfs"
  storage_account_name = azurerm_storage_account.foggykitchen_sa.name
  quota                = var.storage_quota_gb
  enabled_protocol     = "NFS"
}

resource "azurerm_storage_account_network_rules" "foggykitchen_nfs_nsg" {
  storage_account_id = azurerm_storage_account.foggykitchen_sa.id

  default_action             = "Deny"
  virtual_network_subnet_ids = [
    azurerm_subnet.foggykitchen_private_subnet.id
  ]
  bypass = ["AzureServices"]
}

