output "network_id" {
  value = "${azurerm_virtual_network.main.id}"
}
output "subnet_id" {
  value = "${azurerm_subnet.internal.id}"
}