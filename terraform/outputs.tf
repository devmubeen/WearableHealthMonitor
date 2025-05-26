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

output "dps_id_scope" {
  value = module.iot_hub.dps_id_scope
}

output "function_app_url" {
  value = module.function_app.function_app_url
}

output "synapse_workspace_url" {
  value = module.synapse.synapse_workspace_url
}

output "key_vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}