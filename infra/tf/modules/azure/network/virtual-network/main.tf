resource "azurerm_virtual_network" "main" {
  name                = "${var.name}-net"
  address_space       = "${var.address_space}"
  location            = "${var.resource_group.location}"
  resource_group_name = "${var.resource_group.name}"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${var.resource_group.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = "${var.subnet}"
}
