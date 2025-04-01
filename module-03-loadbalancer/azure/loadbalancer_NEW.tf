resource "azurerm_public_ip" "foggykitchen_lb_public_ip" {
  name                = "foggykitchen-lb-public-ip"
  location            = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "foggykitchen_lb" {
  name                = "foggykitchen-lb"
  location            = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicLBIP"
    public_ip_address_id = azurerm_public_ip.foggykitchen_lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "foggykitchen_lb_backend" {
  name                = "fk-backend-pool"
  loadbalancer_id     = azurerm_lb.foggykitchen_lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "foggykitchen_backend_pool_assoc" {
  count = var.node_count
  
  network_interface_id    = azurerm_network_interface.foggykitchen_backend_nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.foggykitchen_lb_backend.id
}

resource "azurerm_lb_probe" "http_health_probe" {
  name                = "http-probe"
  loadbalancer_id     = azurerm_lb.foggykitchen_lb.id
  #protocol            = "Http"
  protocol            = "Tcp"    
  port                = 80
#  request_path        = "/"
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "http_rule" {
  name                           = "http"
  loadbalancer_id                = azurerm_lb.foggykitchen_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicLBIP"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.foggykitchen_lb_backend.id]
  probe_id                       = azurerm_lb_probe.http_health_probe.id
}
