# IoT Hub
resource "azurerm_iothub" "main" {
  name                = var.iot_hub_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  endpoint {
    type                       = "AzureIotHub.StorageContainer"
    connection_string          = azurerm_storage_account.iot.primary_blob_connection_string
    name                       = "storage-endpoint"
    batch_frequency_in_seconds = 60
    max_chunk_size_in_bytes    = 10485760
    container_name             = azurerm_storage_container.iot.name
    encoding                   = "JSON"
    file_name_format           = "{iothub}/{partition}/{YYYY}/{MM}/{DD}/{HH}/{mm}"
  }

  route {
    name           = "storage-route"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["storage-endpoint"]
    enabled        = true
  }

  route {
    name           = "default-route"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["events"]
    enabled        = true
  }

  tags = var.tags
}

# Storage Account for IoT Hub
resource "azurerm_storage_account" "iot" {
  name                     = "${var.iot_hub_name}storage"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = var.tags
}

# Storage Container for IoT Hub
resource "azurerm_storage_container" "iot" {
  name                  = "iot-data"
  storage_account_name  = azurerm_storage_account.iot.name
  container_access_type = "private"
}

# Device Provisioning Service
resource "azurerm_iothub_dps" "main" {
  name                = var.dps_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  linked_hub {
    connection_string = azurerm_iothub.main.primary_connection_string
    location          = var.location
  }

  tags = var.tags
}

# Consumer Group for Function App
resource "azurerm_iothub_consumer_group" "function" {
  name                   = "function-consumer-group"
  iothub_name            = azurerm_iothub.main.name
  eventhub_endpoint_name = "events"
  resource_group_name    = var.resource_group_name
}