output "iot_hub_name" {
  value = azurerm_iothub.main.name
}

output "iot_hub_connection_string" {
  value     = azurerm_iothub.main.primary_connection_string
  sensitive = true
}

output "event_hub_connection_string" {
  value     = azurerm_iothub.main.event_hub_events_endpoint
  sensitive = true
}

output "dps_id_scope" {
  value = azurerm_iothub_dps.main.id_scope
}

output "dps_connection_string" {
  value     = "HostName=${azurerm_iothub_dps.main.service_operations_host_name};SharedAccessKeyName=provisioningserviceowner;SharedAccessKey=${azurerm_iothub_dps.main.primary_key}"
  sensitive = true
}