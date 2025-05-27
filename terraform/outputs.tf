output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "iot_hub_name" {
  value = module.iot_hub.iot_hub_name
}

output "iot_hub_connection_string" {
  value     = module.iot_hub.iot_hub_connection_string
  sensitive = true
}

output "iot_hub_event_hub_endpoint" {
  value     = module.iot_hub.event_hub_connection_string
  sensitive = true
}

output "dps_id_scope" {
  value = module.iot_hub.dps_id_scope
}

output "dps_connection_string" {
  value     = module.iot_hub.dps_connection_string
  sensitive = true
}

output "function_app_url" {
  value = module.function_app.function_app_url
}

output "function_app_name" {
  value = module.function_app.function_app_name
}

output "synapse_workspace_url" {
  value = module.synapse.synapse_workspace_url
}

output "synapse_workspace_name" {
  value = module.synapse.synapse_workspace_name
}

output "sql_pool_name" {
  value = module.synapse.sql_pool_name
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "key_vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}

output "key_vault_name" {
  value = azurerm_key_vault.main.name
}