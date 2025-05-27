output "synapse_workspace_id" {
  value = azurerm_synapse_workspace.main.id
}

output "synapse_workspace_name" {
  value = azurerm_synapse_workspace.main.name
}

output "synapse_workspace_url" {
  value = "https://${azurerm_synapse_workspace.main.name}.dev.azuresynapse.net"
}

output "synapse_connection_string" {
  value     = "Server=tcp:${azurerm_synapse_workspace.main.name}.sql.azuresynapse.net,1433;Database=${azurerm_synapse_sql_pool.health_data.name};User ID=${var.sql_admin_username};Password=${var.sql_admin_password};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive = true
}

output "sql_pool_name" {
  value = azurerm_synapse_sql_pool.health_data.name
}

output "spark_pool_name" {
  value = azurerm_synapse_spark_pool.analytics.name
}