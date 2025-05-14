resource "azurerm_network_security_group" "foggykitchen_frontend_nsg" {
  name                = "foggykitchen_frontend_nsg"
  location            = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name
}

resource "azurerm_network_security_rule" "foggykitchen_frontend_nsg_rule_allow_ssh_from_internet" {
    name                       = "foggykitchen_frontend_nsg_rule_allow_ssh_from_internet"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    resource_group_name         = azurerm_resource_group.foggykitchen_rg.name
    network_security_group_name = azurerm_network_security_group.foggykitchen_frontend_nsg.name
  }

resource "azurerm_network_security_rule" "foggykitchen_frontend_nsg_rule_allow_http_from_internet" {
  name                        = "foggykitchen_frontend_nsg_rule_allow_http_from_internet"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.foggykitchen_rg.name
  network_security_group_name = azurerm_network_security_group.foggykitchen_frontend_nsg.name
}

resource "azurerm_network_security_rule" "foggykitchen_frontend_nsg_rule_allow_internet_outbound" {
  name                        = "foggykitchen_frontend_nsg_rule_allow_internet_outbound"
  priority                    = 1003
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = azurerm_resource_group.foggykitchen_rg.name
  network_security_group_name = azurerm_network_security_group.foggykitchen_frontend_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "public_nsg_assoc" {
  subnet_id                 = azurerm_subnet.foggykitchen_public_subnet.id
  network_security_group_id = azurerm_network_security_group.foggykitchen_frontend_nsg.id
}

resource "azurerm_network_security_group" "foggykitchen_backend_nsg" {
  name                = "foggykitchen_backend_nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name
}

resource "azurerm_subnet_network_security_group_association" "backend_nsg_assoc" {
  subnet_id                 = azurerm_subnet.foggykitchen_private_subnet.id
  network_security_group_id = azurerm_network_security_group.foggykitchen_backend_nsg.id
}

resource "azurerm_network_security_rule" "foggykitchen_backend_nsg_rule_allow_lb_http_inbound" {
  name                        = "foggykitchen_backend_allow_lb_http_inbound"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.foggykitchen_rg.name
  network_security_group_name = azurerm_network_security_group.foggykitchen_backend_nsg.name
}

resource "azurerm_network_security_rule" "foggykitchen_backend_nsg_rule_allow_health_probe" {
  name                        = "foggykitchen_backend_nsg_rule_allow_health_probe"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "168.63.129.16"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.foggykitchen_rg.name
  network_security_group_name = azurerm_network_security_group.foggykitchen_backend_nsg.name
}


resource "azurerm_network_security_rule" "foggykitchen_backend_nsg_rule_allow_http_from_internet" {
  name                        = "foggykitchen_backend_nsg_rule_allow_http_from_internet"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.foggykitchen_rg.name
  network_security_group_name = azurerm_network_security_group.foggykitchen_backend_nsg.name
}