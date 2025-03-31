resource "azurerm_network_security_group" "foggykitchen_nsg" {
  name                = "foggykitchen_nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "public_nsg_assoc" {
  subnet_id                 = azurerm_subnet.foggykitchen_public_subnet.id
  network_security_group_id = azurerm_network_security_group.foggykitchen_nsg.id
}

