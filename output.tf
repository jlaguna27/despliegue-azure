output "resource_group_name" {
    value = azurerm_resource_group.var.name
}

output "resource_virtual_network" {
    value = azurerm_virtual_network.var.name
}

output "resource_subnet" {
    value = azurerm_subnet.var.name
}

output "resource_ip_public" {
    value = azurerm_public_ip.var_master.id
}