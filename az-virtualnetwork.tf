terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.95"
    }
  }

  required_version = "~> 1.1.5"
}

data "azurerm_log_analytics_workspace" "logs" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_resource_group_name
}

resource "azurerm_virtual_network" "network" {
  name                = var.virtual_network_name
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  address_space       = var.virtual_network_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "sql" {
  name                 = "sql"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.0.0.0/24"]
  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet_network_security_group_association" "sql" {
  subnet_id                 = azurerm_subnet.sql.id
  network_security_group_id = azurerm_network_security_group.network.id
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
