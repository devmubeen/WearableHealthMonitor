output "storage_account_id" {
  value = azurerm_storage_account.main.id
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "storage_account_primary_key" {
  value     = azurerm_storage_account.main.primary_access_key
  sensitive = true
}

output "storage_account_connection_string" {
  value     = azurerm_storage_account.main.primary_connection_string
  sensitive = true
}

output "data_lake_gen2_id" {
  value = azurerm_storage_data_lake_gen2_filesystem.main.id
}

output "app_service_plan_id" {
  value = azurerm_service_plan.main.id
}