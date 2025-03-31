resource "azurerm_virtual_network" "foggykitchen_vnet" {
  name                = "foggykitchen-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "foggykitchen_public_subnet" {
  name                 = "foggykitchen_public_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.foggykitchen_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "foggykitchen_private_subnet" {
  name                 = "foggykitchen_private_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.foggykitchen_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_nat_gateway" "foggykitchen_nat_gw" {
  name                = "foggykitchen_nat_gw"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
}

resource "azurerm_subnet_nat_gateway_association" "private_nat_assoc" {
  subnet_id      = azurerm_subnet.foggykitchen_private_subnet.id
  nat_gateway_id = azurerm_nat_gateway.foggykitchen_nat_gw.id
}

resource "azurerm_network_interface" "foggykitchen_bastion_nic" {
  name                = "fkbastion-nic"
  location            = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.foggykitchen_public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.foggykitchen_bastion_public_ip.id
  }
}

resource "azurerm_network_interface" "foggykitchen_backend_nic" {
  name                = "fkbackend-nic"
  location            = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.foggykitchen_private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "foggykitchen_bastion_public_ip" {
  name                = "fkbastion-public-ip"
  location            = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name
  allocation_method   = "Static"
  sku                 = "Basic"
}
