resource "azurerm_postgresql_flexible_server" "foggykitchen_pg" {
  name                   = "foggykitchen-pg"
  resource_group_name    = azurerm_resource_group.foggykitchen_rg.name
  location               = azurerm_resource_group.foggykitchen_rg.location
  version                = "13"
  administrator_login    = var.pg_admin_username
  administrator_password = var.pg_admin_password
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  delegated_subnet_id    = azurerm_subnet.foggykitchen_db_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.foggykitchen_pg_dns.id
  public_network_access_enabled = false

  maintenance_window {
    day_of_week  = 0
    start_hour   = 22
    start_minute = 0
  }

  lifecycle {
    ignore_changes = [
      zone
    ]
  }
  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.foggykitchen_pg_dns_link
  ]
}

resource "azurerm_postgresql_flexible_server_database" "foggykitchen_db" {
  name      = "foggydb"
  server_id = azurerm_postgresql_flexible_server.foggykitchen_pg.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

resource "azurerm_private_dns_zone" "foggykitchen_pg_dns" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "foggykitchen_pg_dns_link" {
  name                  = "pg-dns-link"
  resource_group_name   = azurerm_resource_group.foggykitchen_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.foggykitchen_pg_dns.name
  virtual_network_id    = azurerm_virtual_network.foggykitchen_vnet.id
}
