# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true  # Enable Data Lake Gen2

  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

# Data Lake Gen2 Filesystem
resource "azurerm_storage_data_lake_gen2_filesystem" "main" {
  name               = "health-data-lake"
  storage_account_id = azurerm_storage_account.main.id
}

# Container for Function App
resource "azurerm_storage_container" "function" {
  name                  = "azure-webjobs-hosts"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Container for health data
resource "azurerm_storage_container" "health_data" {
  name                  = "health-data"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Container for processed data
resource "azurerm_storage_container" "processed_data" {
  name                  = "processed-data"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# App Service Plan for Function App
resource "azurerm_service_plan" "main" {
  name                = "${var.storage_account_name}-asp"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "Y1"  # Consumption plan

  tags = var.tags
}