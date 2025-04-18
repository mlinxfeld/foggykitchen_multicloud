resource "azurerm_virtual_network" "foggykitchen_vnet" {
  name                = "foggykitchen-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name
}

resource "azurerm_subnet" "foggykitchen_public_subnet" {
  name                 = "foggykitchen_public_subnet"
  resource_group_name  = azurerm_resource_group.foggykitchen_rg.name
  virtual_network_name = azurerm_virtual_network.foggykitchen_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "foggykitchen_private_subnet" {
  name                 = "foggykitchen_private_subnet"
  resource_group_name  = azurerm_resource_group.foggykitchen_rg.name
  virtual_network_name = azurerm_virtual_network.foggykitchen_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_nat_gateway" "foggykitchen_nat_gw" {
  name                = "foggykitchen_nat_gw"
  location            = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name
  sku_name            = "Standard"
}

resource "azurerm_subnet_nat_gateway_association" "private_nat_assoc" {
  subnet_id      = azurerm_subnet.foggykitchen_private_subnet.id
  nat_gateway_id = azurerm_nat_gateway.foggykitchen_nat_gw.id
}

