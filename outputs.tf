output "virtual_network_id" {
  value       = azurerm_virtual_network.network.id
  description = "Resource ID of the Virtual Network"
}

output "virtual_network_address_space" {
  value       = azurerm_virtual_network.network.address_space
  description = "Address space of the Virtual Network"
}

output "subnets" {
  value       = azurerm_subnet.subnets
  description = "The subnets deployed to the Virtual Network"
}
