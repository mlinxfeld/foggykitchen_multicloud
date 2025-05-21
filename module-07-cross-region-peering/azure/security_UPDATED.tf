resource "azurerm_network_security_group" "foggykitchen_frontend_nsg" {
  name                = "foggykitchen_frontend_nsg"
  location            = azurerm_resource_group.foggykitchen_rg1.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg1.name
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
    resource_group_name         = azurerm_resource_group.foggykitchen_rg1.name
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
  resource_group_name         = azurerm_resource_group.foggykitchen_rg1.name
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
  resource_group_name         = azurerm_resource_group.foggykitchen_rg1.name
  network_security_group_name = azurerm_network_security_group.foggykitchen_frontend_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "public_nsg_assoc" {
  subnet_id                 = azurerm_subnet.foggykitchen_public_subnet.id
  network_security_group_id = azurerm_network_security_group.foggykitchen_frontend_nsg.id
}

resource "azurerm_network_security_group" "foggykitchen_backend_nsg" {
  name                = "foggykitchen_backend_nsg"
  location            = var.location1
  resource_group_name = azurerm_resource_group.foggykitchen_rg1.name
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
  resource_group_name         = azurerm_resource_group.foggykitchen_rg1.name
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
  resource_group_name         = azurerm_resource_group.foggykitchen_rg1.name
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
  resource_group_name         = azurerm_resource_group.foggykitchen_rg1.name
  network_security_group_name = azurerm_network_security_group.foggykitchen_backend_nsg.name
}

resource "azurerm_network_security_rule" "foggykitchen_backend_nsg_rule_allow_nfs_inbound" {
  name                        = "AllowNFSInbound"
  priority                    = 1004
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "2049"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.foggykitchen_rg1.name
  network_security_group_name = azurerm_network_security_group.foggykitchen_backend_nsg.name
}

resource "azurerm_network_security_rule" "foggykitchen_backend_nsg_rule_allow_nfs_outbound" {
  name                        = "AllowNFSOutbound"
  priority                    = 1005
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "2049"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.foggykitchen_rg1.name
  network_security_group_name = azurerm_network_security_group.foggykitchen_backend_nsg.name
}


resource "azurerm_network_security_group" "foggykitchen_db_nsg" {
  name                = "foggykitchen-db-nsg"
  location            = azurerm_resource_group.foggykitchen_rg1.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg1.name
}

resource "azurerm_network_security_rule" "foggykitchen_db_nsg_rule_allow_backend_pgsql" {
  name                        = "AllowPostgreSQLFromBackend"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5432"
  source_address_prefix       = "10.0.2.0/24"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.foggykitchen_db_nsg.name
  resource_group_name         = azurerm_resource_group.foggykitchen_rg1.name
}

resource "azurerm_subnet_network_security_group_association" "db_nsg_assoc" {
  subnet_id                 = azurerm_subnet.foggykitchen_db_subnet.id
  network_security_group_id = azurerm_network_security_group.foggykitchen_db_nsg.id
}

resource "azurerm_network_security_group" "foggykitchen_frontend_nsg2" {
  name                = "foggykitchen_frontend_nsg2"
  location            = azurerm_resource_group.foggykitchen_rg2.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg2.name
}

resource "azurerm_network_security_rule" "foggykitchen_frontend_nsg2_rule_allow_ssh_from_internet" {
  name                        = "foggykitchen_frontend_nsg2_rule_allow_ssh_from_internet"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.foggykitchen_rg2.name
  network_security_group_name = azurerm_network_security_group.foggykitchen_frontend_nsg2.name
}

resource "azurerm_network_security_rule" "foggykitchen_frontend_nsg2_rule_allow_internet_outbound" {
  name                        = "foggykitchen_frontend_nsg2_rule_allow_internet_outbound"
  priority                    = 1003
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = azurerm_resource_group.foggykitchen_rg2.name
  network_security_group_name = azurerm_network_security_group.foggykitchen_frontend_nsg2.name
}


resource "azurerm_subnet_network_security_group_association" "public_nsg2_assoc" {
  subnet_id                 = azurerm_subnet.foggykitchen_public_subnet2.id
  network_security_group_id = azurerm_network_security_group.foggykitchen_frontend_nsg2.id
}

