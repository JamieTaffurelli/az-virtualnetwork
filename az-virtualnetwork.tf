data "azurerm_log_analytics_workspace" "logs" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_resource_group_name
}

data "azurerm_network_security_group" "nsg" {
  for_each            = var.subnets
  name                = each.value.nsg_name
  resource_group_name = each.value.nsg_resource_group_name
}

resource "azurerm_virtual_network" "network" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.virtual_network_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each                                       = var.subnets
  name                                           = each.value.name
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.network.name
  address_prefixes                               = each.value.address_prefixes
  service_endpoints                              = each.value.service_endpoints
  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = true
}

resource "azurerm_subnet_network_security_group_association" "nsg_join" {
  for_each                  = var.subnets
  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = data.azurerm_network_security_group.nsg[each.key].id
}

resource "azurerm_monitor_diagnostic_setting" "virtual_network_diagnostics" {
  name                       = "security-logging"
  target_resource_id         = azurerm_virtual_network.network.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs.id

  log {
    category = "VMProtectionAlerts"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }
}
