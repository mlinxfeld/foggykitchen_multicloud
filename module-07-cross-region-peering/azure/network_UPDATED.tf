resource "azurerm_virtual_network" "foggykitchen_vnet1" {
  name                = "foggykitchen-vnet1"
  address_space       = ["10.0.0.0/16"]
  location            = var.location1
  resource_group_name = azurerm_resource_group.foggykitchen_rg1.name
}

resource "azurerm_virtual_network" "foggykitchen_vnet2" {
  name                = "foggykitchen-vnet2"
  address_space       = ["192.168.0.0/16"]
  location            = var.location1
  resource_group_name = azurerm_resource_group.foggykitchen_rg1.name
}

resource "azurerm_virtual_network" "foggykitchen_vnet3" {
  name                = "foggykitchen-vnet3"
  address_space       = ["10.1.0.0/16"]
  location            = var.location2
  resource_group_name = azurerm_resource_group.foggykitchen_rg2.name
}

resource "azurerm_virtual_network_peering" "foggykitchen_vnet1_to_vnet2_peering" {
  name                      = "foggykitchen_vnet1_to_vnet2_peering"
  resource_group_name       = azurerm_resource_group.foggykitchen_rg1.name
  virtual_network_name      = azurerm_virtual_network.foggykitchen_vnet1.name
  remote_virtual_network_id = azurerm_virtual_network.foggykitchen_vnet2.id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "foggykitchen_vnet2_to_vnet1_peering" {
  name                      = "foggykitchen_vnet2_to_vnet1_peering"
  resource_group_name       = azurerm_resource_group.foggykitchen_rg1.name
  virtual_network_name      = azurerm_virtual_network.foggykitchen_vnet2.name
  remote_virtual_network_id = azurerm_virtual_network.foggykitchen_vnet1.id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "foggykitchen_vnet1_to_vnet3_peering" {
  name                      = "foggykitchen_vnet1_to_vnet3_peering"
  resource_group_name       = azurerm_resource_group.foggykitchen_rg1.name
  virtual_network_name      = azurerm_virtual_network.foggykitchen_vnet1.name
  remote_virtual_network_id = azurerm_virtual_network.foggykitchen_vnet3.id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "foggykitchen_vnet3_to_vnet1_peering" {
  name                      = "foggykitchen_vnet3_to_vnet1_peering"
  resource_group_name       = azurerm_resource_group.foggykitchen_rg2.name
  virtual_network_name      = azurerm_virtual_network.foggykitchen_vnet3.name
  remote_virtual_network_id = azurerm_virtual_network.foggykitchen_vnet1.id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}


resource "azurerm_subnet" "foggykitchen_public_subnet" {
  name                 = "foggykitchen_public_subnet"
  resource_group_name  = azurerm_resource_group.foggykitchen_rg1.name
  virtual_network_name = azurerm_virtual_network.foggykitchen_vnet1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "foggykitchen_public_subnet2" {
  name                 = "foggykitchen_public_subnet2"
  resource_group_name  = azurerm_resource_group.foggykitchen_rg2.name
  virtual_network_name = azurerm_virtual_network.foggykitchen_vnet3.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "foggykitchen_private_subnet" {
  name                 = "foggykitchen_private_subnet"
  resource_group_name  = azurerm_resource_group.foggykitchen_rg1.name
  virtual_network_name = azurerm_virtual_network.foggykitchen_vnet1.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "foggykitchen_db_subnet" {
  name                 = "foggykitchen_db_subnet"
  resource_group_name  = azurerm_resource_group.foggykitchen_rg1.name
  virtual_network_name = azurerm_virtual_network.foggykitchen_vnet2.name
  address_prefixes     = ["192.168.1.0/24"]
  
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_nat_gateway" "foggykitchen_nat_gw" {
  name                = "foggykitchen_nat_gw"
  location            = azurerm_resource_group.foggykitchen_rg1.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg1.name
  sku_name            = "Standard"
}

resource "azurerm_public_ip" "foggykitchen_natgw_public_ip" {
  name                = "foggykitchen-natgw-ip"
  location            = azurerm_resource_group.foggykitchen_rg1.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg1.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "foggykitchen_natgw_ip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.foggykitchen_nat_gw.id
  public_ip_address_id = azurerm_public_ip.foggykitchen_natgw_public_ip.id
}

resource "azurerm_subnet_nat_gateway_association" "private_nat_assoc" {
  subnet_id      = azurerm_subnet.foggykitchen_private_subnet.id
  nat_gateway_id = azurerm_nat_gateway.foggykitchen_nat_gw.id
}


resource "azurerm_network_interface" "foggykitchen_bastion_nic" {
  name                = "fkbastion-nic"
  location            = azurerm_resource_group.foggykitchen_rg1.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.foggykitchen_public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.foggykitchen_bastion_public_ip.id
  }
}

resource "azurerm_network_interface" "foggykitchen_backend_nic" {
  count               = var.node_count

  name                = "fkbackend-nic${count.index + 1}"
  location            = azurerm_resource_group.foggykitchen_rg1.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.foggykitchen_private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "foggykitchen_bastion_public_ip" {
  name                = "fkbastion-public-ip"
  location            = azurerm_resource_group.foggykitchen_rg1.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg1.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "foggykitchen_bastion2_nic" {
  name                = "fkbastion-nic"
  location            = azurerm_resource_group.foggykitchen_rg2.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.foggykitchen_public_subnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.foggykitchen_bastion2_public_ip.id
  }
}

resource "azurerm_public_ip" "foggykitchen_bastion2_public_ip" {
  name                = "fkbastion2-public-ip"
  location            = azurerm_resource_group.foggykitchen_rg2.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg2.name
  allocation_method   = "Static"
  sku                 = "Basic"
}