resource "azurerm_resource_group" "foggykitchen_rg1" {
  name     = var.resource_group_name1
  location = var.location1
}

resource "azurerm_resource_group" "foggykitchen_rg2" {
  name     = var.resource_group_name2
  location = var.location2
}